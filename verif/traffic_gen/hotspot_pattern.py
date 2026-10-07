#!/usr/bin/env python3

import argparse
import csv
import random


def main():

    ap = argparse.ArgumentParser()

    ap.add_argument(
        "--nodes",
        type=int,
        default=16
    )

    ap.add_argument(
        "--hotspot",
        type=int,
        default=5
    )

    ap.add_argument(
        "--count",
        type=int,
        default=1000
    )

    ap.add_argument(
        "--hot-prob",
        type=float,
        default=0.40
    )

    ap.add_argument(
        "--seed",
        type=int,
        default=2
    )

    ap.add_argument(
        "--output",
        default="hotspot.csv"
    )

    args = ap.parse_args()

    nxy = int(args.nodes ** 0.5)

    rng = random.Random(args.seed)

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

        for seq in range(args.count):

            src = rng.randrange(args.nodes)

            if rng.random() < args.hot_prob:

                dst = args.hotspot

            else:

                dst = rng.randrange(args.nodes)

                while dst == src:
                    dst = rng.randrange(args.nodes)

            sx = src % nxy
            sy = src // nxy

            dx = dst % nxy
            dy = dst // nxy

            payload = rng.randrange(4096)

            writer.writerow([
                seq,
                src,
                dst,
                sx,
                sy,
                dx,
                dy,
                payload
            ])


if __name__ == "__main__":
    main()
