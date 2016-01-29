pca <- function(mydata, num.to.report, output)
{
    M <- as.matrix(mydata)
    r <- num.to.report
    pca <- prcomp(M)
    U <- t(t(pca$rotation[,1:r]))
    write.csv(U, file=output)

    summary(pca)$importance[,1:r]
}

pca.stream <- function(num.to.report, output)
{
    require("onlinePCA")

    n <- 0
    n0 <- 50  # number of sample paths for initialization

    stdin = file("stdin")
    open(stdin)

    ## Read the header
    line <- readLines(stdin, n=1)
    names <- unlist(strsplit(line, ","))
    r <- num.to.report

    ## Read data for initialization
    m.init <- matrix(nrow=0, ncol=length(names))
    while (n < n0) {
        line <- readLines(stdin, n=1)
        if (length(line) == 0)
            break
        line <- as.numeric(unlist(strsplit(line, ",")))
        m.init <- rbind(m.init, line)
        n <- n+1
    }
    pca <- prcomp(m.init)
    xbar <- pca$center
    pca <- list(values=pca$sdev[1:r]^2, vectors=pca$rotation[1:length(names),1:r])
    if (n >= n0) {
        while (TRUE) {
            line <- readLines(stdin, n=1)
            if (length(line) == 0)
                break
            line <- as.numeric(unlist(strsplit(line, ",")))
            xbar <- updateMean(xbar, line, n-1)
            pca <- incRpca(pca$values, pca$vectors, line, n-1, q=r, center=xbar)
            n <- n+1
        }
    }

    close(stdin)

    U <- t(t(pca$vectors[,1:r]))
    write.csv(U, file=output)
}
