from ast import literal_eval
from csv import DictReader
import twint
from urllib.parse import urlparse
from os.path import split
import sys
sys.dont_write_bytecode = True

# might be "shadow-banned" for being a bot,
# therefore Profile is needed
filename = 'exports/certego.csv'
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
            with open('exports/certego.txt', 'a') as output:
                output.write(f"{split(path)[1]}\n")
