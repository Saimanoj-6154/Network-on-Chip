#!/usr/bin/env python3

import subprocess
import sys

from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]

commands = [
    ["make", "sim-router"],
    ["make", "sim-mesh"],
    ["make", "sim-deadlock"],
]


for cmd in commands:

    print(
        "$",
        " ".join(cmd)
    )

    result = subprocess.run(
        cmd,
        cwd=ROOT
    )

    if result.returncode != 0:
        sys.exit(result.returncode)


print("Regression PASS")
