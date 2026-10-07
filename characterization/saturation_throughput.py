#!/usr/bin/env python3

import argparse
import csv


def main():

    ap = argparse.ArgumentParser()

    ap.add_argument(
        "csv_file",
        nargs="?",
        default="sweep.csv"
    )

    args = ap.parse_args()

    with open(args.csv_file) as f:

        rows = list(
            csv.DictReader(f)
        )

    values = [

        (
            float(row["load"]),
            float(
                row[
                    "throughput_per_node_cycle"
                ]
            ),
            float(
                row["avg_latency"]
            )
        )

        for row in rows
    ]

    best = max(
        values,
        key=lambda t: t[1]
    )

    baseline = min(
        values,
        key=lambda t: t[0]
    )

    print(
        "Peak measured throughput: "
        f"{best[1]:.6f} "
        "flits/node/cycle "
        f"at load {best[0]:.3f}"
    )

    print(
        "Lowest-load latency: "
        f"{baseline[2]:.3f} cycles"
    )


if __name__ == "__main__":
    main()
