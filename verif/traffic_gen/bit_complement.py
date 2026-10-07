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
        default="bit_complement.csv"
    )

    args = ap.parse_args()

    nodes = args.size * args.size

    width = max(
        1,
        (nodes - 1).bit_length()
    )

    mask = (1 << width) - 1

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

            for src in range(nodes):

                dst = (~src) & mask

                if dst >= nodes:
                    dst %= nodes

                sx = src % args.size
                sy = src // args.size

                dx = dst % args.size
                dy = dst // args.size

                writer.writerow([
                    seq,
                    src,
                    dst,
                    sx,
                    sy,
                    dx,
                    dy,
                    seq & 0xFFF
                ])

                seq += 1


if __name__ == "__main__":
    main()
