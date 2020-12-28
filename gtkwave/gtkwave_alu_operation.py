#!/usr/bin/env python3

import sys
import tempfile
import subprocess

states = {
    0: "ADD",
    1: "SUB",
    2: "OR",
    3: "XOR",
    4: "AND",
    5: "<u",
    6: "<s",
    7: ">>",
    8: ">>>",
    9: "<<",
    10: "<<<",
    11: ">=u",
    12: ">=s"
}

def main(argv0, *args):
    fh_in = sys.stdin
    fh_out = sys.stdout

    while True:
        l = fh_in.readline()
        if not l:
            return 0

        if "x" in l:
            fh_out.write(l)
            fh_out.flush()
            continue

        state = int(l, 16)
        if state in states:
          fh_out.write("%s\n" % states[state])
        else:
          fh_out.write(l)

        fh_out.flush()



if __name__ == '__main__':
  sys.exit(main(*sys.argv))