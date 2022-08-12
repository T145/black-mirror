#!/usr/bin/env python3

import sys

sys.dont_write_bytecode = True

if sys.version_info < (3, 0):
    print(" ################# ERROR ################")
    print(" ========================================")
    print(
        "   Invalid Python version detected: "
        + str(sys.version_info[0])
        + "."
        + str(sys.version_info[1])
    )
    print(" ========================================")
    print(" It seems your are still using Python 2 even though it's retired.")
    print(" For more info please read the following: https://pythonclock.org/")
    print(" ========================================")
    print(" Try again: python3 /path/to/" + sys.argv[0])
    print(" ################# ERROR ################")
    sys.exit(0)

from ast import literal_eval
from csv import DictReader
from os import remove
from typing import List

import twint


def file_output(path: str, name: str, extension: str) -> str:
    return "{}/{}.{}".format(path, name, extension)


def get_path(url: str) -> str:
    # return os.path.split(urlparse(url).path)[1]
    return url[1 : len(url)]


def main(argc: int, argv: List[str]) -> int:
    store = file_output(argv[1], argv[2], "csv")
    config = twint.Config()
    config.Username = get_path(argv[3])
    # config.Limit = sys.maxsize
    config.Store_csv = True
    config.User_full = False
    config.Output = store

    # Could be "shadow-banned" for being a bot, therefore Profile is needed.
    # Profile will also scrape an entire timeline.
    twint.run.Profile(config)

    with open(store, "r", newline="") as csv_file:
        for row in DictReader(csv_file):
            for url in literal_eval(row["urls"]):
                with open(file_output(argv[1], argv[2], "txt"), "a") as result:
                    result.write(f"{get_path(url)}\n")

    remove(store)
    return 0


# params: cache, key/filename, twitter url
if __name__ == "__main__":
    args = sys.argv
    sys.exit(main(len(args), args))
