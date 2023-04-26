# R 2.1. Code Arithmetic Expressions

1+1 # addition
1-1 # subtraction
1*1 # multiplication
1/1 # division

## expressions where order of operations matter

1+1/2 #  division prior addition
(1+1)/2 # brackets prior the rest


# R 2.2. Scalars

## creating scalar objects

scal_num <- 1 # <- is the assignment operator
scal_chr <- "a"
scal_str <- "word"
scal_log <- TRUE # logical/Boolean

## operating on scalar objects

scal_num + 1
scal_num + scal_num
scal_num + scal_num / 2
(scal_num + scal_num) / 2

## creating new from existing objects

scal_num <- scal_num + 1  # overwriting
scal_num
scal_num2 <- scal_num + 1 # creating
scal_num2

## invalid operation

scal_chr * 4 # check and try to understand error message

# R 2.3. Vectors

x <- c(1, 2, 3, 4) # create a vector object x, c() combines inputs to vector

## Vectorized operations: the same operation is applied to each element in a vector

x*2 

### Operating with multiple operators

x <- c(1, 2, 3, 4) # vector x
y <- c(1, 2, 3, 4) # vector y
x*y # element-wise operation: R applies a given operation to elements that occupy the same position in their vectors

z <- c(1,2) 
x*z # R repeates the shorter vector until it matches the length of the longer vector and then operates element-wise

z <- rep(z, 2) # replicates and overwrite z
z
x*z

# R 2.4. Data Frames

x <- c(1, 2, 3)
y <- c(4, 5, 6)
z <- c(7, 8, 9)
dat <- data.frame(x, y, z) # data.frame() creates a data frame out of vector of the same length
dat

ID <- c("A", "B", "C")
dat <- data.frame(ID, dat) # add new variable to exisiting data frame
dat

x <- c(1, 2, 3)
y <- c(4, 5, 6)
z <- c(7, 8, 9)
dat <- data.frame(x, y, z)

dat*2 # operate on the entire data frame

### Retrieve information from a data frame and operate on them

dat$x # dollar notation with variable name
dat[, 1] # matrix notation with column number
dat[, "x"] # matrix notation with variable name

dat[, c(1,2)] # retrieve multiple columns
dat[, c("x","y")]

dat[1,1] # cell entry row 1 and column 1
dat[1, "x"]

dat[, 1] * 2

a <- c(1,2,3)
dat[, 1] * a 

# adding
dat[, "v"] <- dat[, 1] * a 
dat

dat[, 4] <- dat[, 4] / a # divides column 4 by vector a and overwrite the column with the results
dat


# 2.5 Functions

summing <- # function name
  function(x){ # inputs 
    
    # body 
    total <- 0
    for (i in 1:length(x)) {
      total <- total + x[i]
    }
    return(total)
    
  }
summing(x)
sum(x)

## combining operations of multiple functions

### step-by-step
x <- c(-1, -2, -3)
sum_x <- sum(x)
sum_x
abs(sum_x)

### at once 
abs(sum(x))


# 2.6 Tidyverse

install.packages("tidyverse")
library("tidyverse")

# Create a PAT in GitHub 

install.packages("usethis")
usethis::create_github_token()

install.packages("gitcreds")
gitcreds::gitcreds_set()
