#!/usr/bin/env Rscript
library(archive)
library(data.table)

argv = commandArgs()
argc = length(argv)

if (argc > 5) {
  fname = argv[6]

  printFile <- function(conn) {
    lines = readLines(conn)

    close(conn)
    options(max.print=length(lines))
    cat(lines, sep="\n")
  }

  if (argc > 6) {
    matches = grep(paste(argv[7:length(argv)], collapse="|"),
                   archive(fname)$path, value=TRUE)
    for (match in matches) {
      printFile(archive_read(fname, match))
    }
  } else {
    printFile(archive_read(fname))
  }
} else {
  print("Usage: print_archive.R [ARCHIVE] [FILES...]")
}

warnings()
