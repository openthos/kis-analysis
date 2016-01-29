dump.block <- function(mydata)
{
    mydata
}

dump.stream <- function()
{
    stdin = file("stdin")
    open(stdin)
    while (TRUE) {
        line <- readLines(stdin, n = 1)
        if (length(line) == 0)
            break
        print(line)
    }
    close(stdin)
}
