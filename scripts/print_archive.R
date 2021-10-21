#!/usr/bin/env Rscript
library(archive)
options(max.print=1000000)

# TODO: Fix reading from shalla-format tarballs

args <- commandArgs()
fname <- args[6]
archive <- archive_read(fname)
lines <- readLines(con=archive)

close(archive)
cat(lines, sep="\n")
