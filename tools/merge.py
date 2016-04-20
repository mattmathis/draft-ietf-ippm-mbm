#!/usr/bin/python
"""Merge multiple source files using a fake cpp like syntax


"""

import sys


def readfile(name):
  with open(name, 'r') as f:
    for l in f:
      if l.startswith("#include"):
        n = l.split()[1].strip('"<> \'')
        readfile(n)
      else:
        print l,

def main():
  readfile(sys.argv[1])



if __name__ == '__main__':
  main()
