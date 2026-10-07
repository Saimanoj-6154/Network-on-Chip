#!/usr/bin/env python3

from __future__ import annotations

import argparse
import random

from collections import deque
from dataclasses import dataclass


NORTH, SOUTH, EAST, WEST, LOCAL = range(5)


@dataclass(slots=True)
class Flit:

    src: int
    dst: int
    born: int
    payload: int


class MeshModel:

    def __init__(
        self,
        size=4,
        depth=4,
        seed=1
    ):

        self.size = size

        self.n = size * size

        self.depth = depth

        self.rng = random.Random(seed)

        # q[node][input_port]
        self.q = [
            [deque() for _ in range(5)]
            for _ in range(self.n)
        ]

        # Round-robin pointer per node/output.
        self.rr = [
            [0] * 5
            for _ in range(self.n)
        ]

        self.delivered = []

    def port(self, node, dst):

        x = node % self.size
        y = node // self.size

        dx = dst % self.size
        dy = dst // self.size

        if dx > x:
            return EAST

        if dx < x:
            return WEST

        if dy > y:
            return SOUTH

        if dy < y:
            return NORTH

        return LOCAL

    def inject(
        self,
        src,
        dst,
        cycle,
        payload=0
    ):

        if len(
            self.q[src][LOCAL]
        ) >= self.depth:

            return False

        self.q[src][LOCAL].append(
            Flit(
                src=src,
                dst=dst,
                born=cycle,
                payload=payload
            )
        )

        return True

    def step(self, cycle):

        transfers = []

        # Arbitration + transfer selection.
        for node in range(self.n):

            used_inputs = set()

            for out in range(5):

                candidates = []

                start = self.rr[node][out]

                for k in range(5):

                    inp = (
                        start + k
                    ) % 5

                    if inp in used_inputs:
                        continue

                    if not self.q[node][inp]:
                        continue

                    f = self.q[node][inp][0]

                    if self.port(node, f.dst) != out:
                        continue

                    if out == LOCAL:

                        candidates.append(inp)

                    else:

                        x = node % self.size
                        y = node // self.size

                        if out == EAST:
                            nb = node + 1

                        elif out == WEST:
                            nb = node - 1

                        elif out == SOUTH:
                            nb = node + self.size

                        else:
                            nb = node - self.size

                        reverse = {
                            EAST: WEST,
                            WEST: EAST,
                            SOUTH: NORTH,
                            NORTH: SOUTH
                        }[out]

                        if len(
                            self.q[nb][reverse]
                        ) < self.depth:

                            candidates.append(inp)

                if not candidates:
                    continue

                inp = candidates[0]

                flit = self.q[node][inp].popleft()

                used_inputs.add(inp)

                self.rr[node][out] = (
                    inp + 1
                ) % 5

                transfers.append(
                    (node, out, flit)
                )

        # Commit all transfers.
        for node, out, f in transfers:

            if out == LOCAL:

                self.delivered.append(
                    (f, cycle + 1)
                )

                continue

            if out == EAST:

                nb = node + 1
                inp = WEST

            elif out == WEST:

                nb = node - 1
                inp = EAST

            elif out == SOUTH:

                nb = node + self.size
                inp = NORTH

            else:

                nb = node - self.size
                inp = SOUTH

            self.q[nb][inp].append(f)


def run_sim(
    size=4,
    load=0.2,
    cycles=2000,
    depth=4,
    seed=1
):

    sim = MeshModel(
        size=size,
        depth=depth,
        seed=seed
    )

    rng = random.Random(seed)

    attempted = 0
    accepted = 0

    for cycle in range(cycles):

        # Generate traffic at every node.
        for src in range(sim.n):

            if rng.random() < load:

                attempted += 1

                dst = rng.randrange(
                    sim.n - 1
                )

                if dst >= src:
                    dst += 1

                if sim.inject(
                    src,
                    dst,
                    cycle,
                    attempted & 0xFFF
                ):

                    accepted += 1

        sim.step(cycle)

    latencies = [
        done - flit.born
        for flit, done
        in sim.delivered
    ]

    if latencies:
        avg_latency = (
            sum(latencies)
            / len(latencies)
        )
    else:
        avg_latency = float("inf")

    throughput = (
        len(sim.delivered)
        / (cycles * sim.n)
    )

    return {
        "attempted": attempted,
        "accepted": accepted,
        "delivered": len(sim.delivered),
        "avg_latency": avg_latency,
        "throughput_per_node_cycle": throughput
    }


def main():

    ap = argparse.ArgumentParser()

    ap.add_argument(
        "--size",
        type=int,
        default=4
    )

    ap.add_argument(
        "--load",
        type=float,
        default=0.2
    )

    ap.add_argument(
        "--cycles",
        type=int,
        default=2000
    )

    ap.add_argument(
        "--depth",
        type=int,
        default=4
    )

    ap.add_argument(
        "--seed",
        type=int,
        default=1
    )

    args = ap.parse_args()

    result = run_sim(
        size=args.size,
        load=args.load,
        cycles=args.cycles,
        depth=args.depth,
        seed=args.seed
    )

    print(result)


if __name__ == "__main__":
    main()
