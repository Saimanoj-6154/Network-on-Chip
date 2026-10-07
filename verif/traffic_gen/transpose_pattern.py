#!/usr/bin/env python3

import argparse
import csv


def main():

    ap = argparse.ArgumentParser()

    ap.add_argument(
        "--size",
        type=int,
        default=4
    )

    ap.add_argument(
        "--repeat",
        type=int,
        default=1
    )

    ap.add_argument(
        "--output",
        default="transpose.csv"
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

        seq = 0

        for _ in range(args.repeat):

            for y in range(args.size):

                for x in range(args.size):

                    src = y * args.size + x

                    dst = x * args.size + y

                    writer.writerow([
                        seq,
                        src,
                        dst,
                        x,
                        y,
                        y,
                        x,
                        seq & 0xFFF
                    ])

                    seq += 1


if __name__ == "__main__":
    main()
