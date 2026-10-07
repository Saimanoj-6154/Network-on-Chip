#!/usr/bin/env python3

import argparse
import csv

import matplotlib.pyplot as plt


def main():

    ap = argparse.ArgumentParser()

    ap.add_argument(
        "csv_file",
        nargs="?",
        default="sweep.csv"
    )

    ap.add_argument(
        "--output",
        default="latency_vs_load.png"
    )

    args = ap.parse_args()

    with open(args.csv_file) as f:

        rows = list(
            csv.DictReader(f)
        )

    x = [
        float(row["load"])
        for row in rows
    ]

    y = [
        float(row["avg_latency"])
        for row in rows
    ]

    plt.figure(
        figsize=(7, 4.5)
    )

    plt.plot(
        x,
        y,
        marker="o"
    )

    plt.xlabel(
        "Offered load (flits/node/cycle)"
    )

    plt.ylabel(
        "Average latency (cycles)"
    )

    plt.title(
        "NoC Latency vs Offered Load"
    )

    plt.grid(
        True,
        alpha=0.25
    )

    plt.tight_layout()

    plt.savefig(
        args.output,
        dpi=160
    )


if __name__ == "__main__":
    main()
