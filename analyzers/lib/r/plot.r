chart.line <- function(mydata, prefix)
{
    x <- 1
    conf <- 2

    mydata[,conf][is.na(mydata[,conf])] <- "default"
    configs <- unique(mydata[,conf])

    for (c in configs) {
        part <- mydata[mydata[,conf] == c,]

        x.pseudo <- 1:length(part[,x])
        y.avg <- part[,3]
        y.min <- part[,4]
        y.max <- part[,5]

        metric <- gsub("\\.avg", "", names(mydata)[3])
        outfile = gsub("%", "", paste(prefix, c, "png", sep="."))
        png(filename=outfile, width=max(640, 60 * length(x.pseudo)), height=480)
        plot(range(x.pseudo), c(0, max(y.max)),
             main=paste(metric, c, sep="-"),
             xlab=names(mydata)[x], xaxt = "n",
             ylab=metric)
        axis(1, at=x.pseudo, labels=part[,x], cex.axis=0.85)
        lines(x.pseudo, y.avg, pch=15, col="black", type="b")
        arrows(x.pseudo, y.min, x.pseudo, y.max, length=0.05, angle=90, code=3)
    }

    NULL
}
