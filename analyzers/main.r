#!/usr/bin/env Rscript

sourceDir <- function(path, trace = FALSE, ...) {
    for (nm in list.files(path, pattern = "\\.[RrSsQq]$")) {
        if(trace) cat(nm,":")
        source(file.path(path, nm), ...)
        if(trace) cat("\n")
    }
}

sourceDir(paste(Sys.getenv("LKP_SRC"), "analyzers", "lib", "r", sep="/"))

main <- function(args)
{
    options(width = 120, warn = -1)

    filename <- args[1]
    if (nchar(filename) > 0)
        mydata <- read.csv(file=filename, header=TRUE, sep=",")
    result <- eval(parse(text=args[2]))
    print(result)
}

main(commandArgs(trailingOnly = TRUE))
