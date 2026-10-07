#!/usr/bin/env python3

import argparse
import csv
import random


def gen(nodes: int, count: int, seed: int):
    rng = random.Random(seed)

    nxy = int(nodes ** 0.5)

    if nxy * nxy != nodes:
        raise ValueError(
            "nodes must be a perfect square"
        )

    for seq in range(count):

        src = rng.randrange(nodes)

        # Select a destination different from source.
        dst = rng.randrange(nodes - 1)

        if dst >= src:
            dst += 1

        sx = src % nxy
        sy = src // nxy

        dx = dst % nxy
        dy = dst // nxy

        payload = rng.randrange(4096)

        yield (
            seq,
            src,
            dst,
            sx,
            sy,
            dx,
            dy,
            payload
        )


def main():

    ap = argparse.ArgumentParser()

    ap.add_argument(
        "--nodes",
        type=int,
        default=16
    )

    ap.add_argument(
        "--count",
        type=int,
        default=1000
    )

    ap.add_argument(
        "--seed",
        type=int,
        default=1
    )

    ap.add_argument(
        "--output",
        default="uniform_random.csv"
    )

    args = ap.parse_args()

    with open(
        args.output,
        "w",
        newline=""
    ) as f:

        writer = csv.writer(f)

        writer.writerow([
            "seq",
            "src",
            "dst",
            "sx",
            "sy",
            "dx",
            "dy",
            "payload"
        ])

        writer.writerows(
            gen(
                args.nodes,
                args.count,
                args.seed
            )
        )


if __name__ == "__main__":
    main()
