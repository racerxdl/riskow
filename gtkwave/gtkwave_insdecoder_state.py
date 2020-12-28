#!/usr/bin/env python3

import sys
import tempfile
import subprocess

states = {
    0: "FETCH0",
    1: "FETCH1",
    2: "DECODE",
    3: "EXEC0",
    4: "EXEC1",
    5: "EXEC2",
    6: "EXEC3",
    7: "EXEC4",
    8: "EXEC5"
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