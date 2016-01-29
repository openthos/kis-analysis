standardize <- function(mydata, output)
{
    nr.var.before <- dim(mydata)[2]
    vd <- scale(mydata[,apply(mydata, 2, var, na.rm=TRUE) != 0])
    nr.var.after <- dim(vd)[2]
    write.csv(vd, file=output, row.names=FALSE)
    paste("Saved to", output, ".", nr.var.before - nr.var.after, "columns removed.", sep=" ")
}
