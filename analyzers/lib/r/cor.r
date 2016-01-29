mosthighlycorrelated <- function(mydata, numtoreport)
{
    ## find the correlations
    cormatrix <- cor(mydata)

    ## set the correlations on the diagonal or lower triangle to zero,
    ## so they will not be reported as the highest ones:
    diag(cormatrix) <- 0
    cormatrix[lower.tri(cormatrix)] <- 0

    ## flatten the matrix into a dataframe for easy sorting
    fm <- as.data.frame(as.table(cormatrix))

    ## assign human-friendly names
    names(fm) <- c("First.Variable", "Second.Variable","Correlation")

    ## sort and rename the rows
    sorted <- head(fm[order(abs(fm$Correlation),decreasing=T),],n=numtoreport)
    row.names(sorted) <- seq(1:numtoreport)

    ## return the top n correlations to be printed
    sorted
}
