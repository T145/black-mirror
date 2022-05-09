#!/usr/bin/env python3
import sys

if (sys.version_info < (3, 0)):
    print(" ################# ERROR ################")
    print(" ========================================")
    print("   Invalid Python version detected: "+str(sys.version_info[0])+"."+str(sys.version_info[1]))
    print(" ========================================")
    print(" It seems your are still using Python 2 even though it's retired.")
    print(" For more info please read the following: https://pythonclock.org/")
    print(" ========================================")
    print(" Try again: python3 /path/to/"+sys.argv[0])
    print(" ################# ERROR ################")
    exit(0)

from ast import literal_eval
from csv import DictReader
import twint
from urllib.parse import urlparse
from os.path import split
from os import remove

sys.dont_write_bytecode = True

# might be "shadow-banned" for being a bot,
# therefore Profile is needed
filename = 'imports/out/certego.csv'
c = twint.Config()
c.Username = 'Certego_Intel'
c.Store_csv = True
c.Output = filename
twint.run.Profile(c)

with open(filename, 'r', newline='') as csv_file:
    reader = DictReader(csv_file)
    for row in reader:
        for url in literal_eval(row['urls']):
            path = urlparse(url).path
            with open('imports/out/certego.txt', 'a') as output:
                output.write(f"{split(path)[1]}\n")

remove(filename)
