#!/usr/bin/env python3

import argparse
import csv
import sys

from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]

sys.path.insert(
    0,
    str(ROOT / "verif" / "ref_model")
)

from flit_level_sim import run_sim


def main():

    ap = argparse.ArgumentParser()

    ap.add_argument(
        "--loads",
        nargs="+",
        type=float,
        default=[
            0.05,
            0.10,
            0.15,
            0.20,
            0.30,
            0.40,
            0.50,
            0.60,
            0.70,
            0.80,
            0.90
        ]
    )

    ap.add_argument(
        "--size",
        type=int,
        default=4
    )

    ap.add_argument(
        "--cycles",
        type=int,
        default=3000
    )

    ap.add_argument(
        "--depth",
        type=int,
        default=4
    )

    ap.add_argument(
        "--output",
        default="sweep.csv"
    )

    args = ap.parse_args()

    with open(
        args.output,
        "w",
        newline=""
    ) as f:

        writer = csv.DictWriter(
            f,
            fieldnames=[
                "load",
                "attempted",
                "accepted",
                "delivered",
                "avg_latency",
                "throughput_per_node_cycle"
            ]
        )

        writer.writeheader()

        for load in args.loads:

            result = run_sim(
                args.size,
                load,
                args.cycles,
                args.depth,
                seed=123
            )

            writer.writerow({
                "load": load,
                **result
            })

            print(
                f"load={load:.2f} "
                f"latency={result['avg_latency']:.3f} "
                f"throughput="
                f"{result['throughput_per_node_cycle']:.5f}"
            )


if __name__ == "__main__":
    main()
