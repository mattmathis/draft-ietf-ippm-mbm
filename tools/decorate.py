#! /usr/bin/python3

import fileinput
import sys
import re

wix=0
words=[]
white={0:""}
colors={}
art={}

# Terms of Art correct usage
artOnly=[
#    "sender interface rate bursts",

    # Phrases not defined that should be
    "TCP or other transport protocol",
    "TCP or other transport protocols",
    "delivery statistics",
    "subpath under test",
    "transport protocol",
    "temporal structure", "temporal structures",
    "ECN Congestion Experienced CE marks", "ECN CE marks"
    "packet transfer",
    "vantage independence"
    "test stream", "test streams", 
]
# These words and phrases are defined in the and used camonically.
ExplicitArt=[
    # general
    "Model Based Metrics",
    "Target Transport Performance",
    "Target Data Rate",
    "Target RTT",
    "Target MTU", "Maximum Transmission Unit",
    "Targeted IP Diagnostic Suite", "TIDS",
    "Fully Specified Targeted IP Diagnostic Suite",
    "Fully Specified Targeted IP Diagnostic Suites",
    "Bulk Transport Capacity",
    "IP diagnostic test", "IP diagnostic tests",
    
    # "traffic patterns"
    "packet transfer statistics",
    "packet loss", "packet loss ratio",
    "apportioned",
    "open loop",

    # paths
    "data sender", "data receiver",
    "complete path", "subpath", "complete Internet path",
    "measurement point", "measurement points",
    "test path",
    "dominant bottleneck",
    "front path", "back path", "return path", "cross traffic",

    # 
    "Application Data Rate",
    "IP rate", "IP capacity",
    "bottleneck IP capacity",
    "implied bottleneck IP capacity",
    "sender interface rate",
    "header_overhead",

    # Pramerters of models
    "window size", "pipe size", "target_window_size",
    "run length", "target_run_length",
    "reference target_run_length",

    # Anceillary parameters for some tests
    "derating",
    "subpath_IP_capacity",
    "test_path_RTT", "test_path_pipe", "test_window",

    # temporal patterns
    "packet headway", "burst headway",
    "paced single packets", # XXXX Look at 3432
    "paced burst", "slowstart burst", "repeated slowstart burst",
    "paced bursts", "slowstart bursts", "repeated slowstart bursts",

    # test types
    "capacity test", "monitoring test", "engineering test",
    "capacity tests", "monitoring tests", "engineering tests",

]

# Risky or forbidden terms and phrases.  These get diced to individual words.
# Strong yellow
stopw=[
    "delivery",
]

# common words used within art words, but may be ok in isolation
# soft yellow
safeWords=[
    "target", "specified", "packet", "packets", "window", "dominant", "diagnostic", "IP", "cross", "length",
    "measurement", "slowstart", "end-to-end",
]

# Words used in art that are too common to flag
# very pale yellow
commonWords=[
    "test", "tests", "path" "measurement", "back", "data", "under",
]

# Banned phrases
# Pink (transparent red)
unsafe=[
    "packet delivery statistics",

    "data rate", "ECN", "average rate", "traffic",
    "precomputed", "traffic", "patterns", "pattern",
    "parameter", "parameters",
    "flow", "flows",
    "packet delivery"
]

def scanfile():
    global wix, white, words, colors

    # parse the entire doc into words and delimiters 
    for line in fileinput.input():
        while line:
            ma=re.match("\W*", line)
            if ma:
                white[wix]=white[wix]+line[ma.start():ma.end()]
                line=line[ma.end():]
            ma=re.match("\w*", line)
            if ma:
                words.append(line[ma.start():ma.end()])
                line=line[ma.end():]
                colors[wix]=""
                wix  += 1
                white[wix]=""

def colorwords(sl, c):
    global wix, white, words, colors
    dic={}
    for wl in sl:
        for w in wl.lower().split():
            dic[w]=c
    for wo in range(wix):
        try:
            colors[wo]=dic[words[wo].lower()]
        except (KeyError):
            pass

def colorphrases(pl, c, fuzz=False):
    global wix, white, words, colors
    # Match case exactly, except allow optional 1st capital
    art={}
    if fuzz:
        for w in pl:
            art[w]=c.casefold()
    else:
        for w in pl:
            art[w]=c
            if w[0].islower():
                # only adjust the very first letter
                art[w[0].capitalize()+w[1:]]=c
    for wo in range(wix):
        for i in range(1, 7):
            t = " ".join(words[wo-i:wo])
            if fuzz:
                t = t.casefold()
            if wo>i and t in art:
                for ii in range(1, i+1):
                    colors[wo-ii] = art[t]

def showfile():
    global wix, white, words, colors

    # display it
    begincolor='<span style=\'background-color: {}\'>'
    endcolor='</span>'                       
    priorcolor=""
    skipping=True
    for wo in range(wix):
        if skipping:
            print (white[wo]+words[wo], end='') 
            if words[wo] == "body":
                skipping=False
        elif priorcolor == colors[wo]:
            print (white[wo]+words[wo], end='')
        else:
            ec=endcolor if priorcolor else ""
            bc=begincolor.format(colors[wo]) if colors[wo] else ""
            print (ec+white[wo]+bc+words[wo],
                   end='')
            priorcolor=colors[wo]




scanfile()
allwords=stopw+artOnly+unsafe+ExplicitArt
colorwords(allwords, "#FFFF00")
colorwords(safeWords, "#FFFF80")
colorwords(commonWords, "#FFFFC0")
colorphrases(artOnly, "PaleGreen")
colorphrases(unsafe, "Pink", True)
colorphrases(ExplicitArt, "PaleGreen")
showfile()
