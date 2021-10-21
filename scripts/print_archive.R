#!/usr/bin/env Rscript
library(archive)

argv <- commandArgs()
argc <- length(argv)

if (argc > 5) {
  fname <- argv[6]

  printFile <- function(conn) {
    lines <- readLines(conn)

    close(conn)
    options(max.print=length(lines))
    cat(lines, sep="\n")
  }

  if (argc > 6) {
    files <- argv[7:length(argv)]

    for (fpath in archive(fname)$path) {
      for (file in files) {
        if (endsWith(fpath, file)) {
          printFile(archive_read(fname, fpath))
        }
      }
    }
  } else {
    printFile(archive_read(fname))
  }
} else {
  print("Usage: print_archive.R [archive] [files]")
}

warnings()
