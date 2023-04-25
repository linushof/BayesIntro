# R 2.1. Code Arithmetic Expressions

1+1 # addition
1-1 # subtraction
1*1 # multiplication
1/1 # division

## expressions where order of operations matter

1+1/2 #  division prior addition
(1+1)/2 # brackets prior the rest


# R 2.2. Scalars

scal_num <- 1
scal_chr <- "a"
scal_str <- "word"
scal_log <- TRUE # logical/Boolean

scal_num
scal_num + 1
scal_num + scal_num
scal_num + scal_num / 2
(scal_num + scal_num) / 2

scal_num
scal_num <- scal_num + 1  # overwriting
scal_num
scal_num2 <- scal_num + 1 # creating
scal_num2

scal_chr * 4

# R 2.3. Vectors

x <- c(1, 2, 3, 4) # create a vector object x
x
x*2
x <- c(1, 2, 3, 4) # vector x
y <- c(1, 2, 3, 4) # vector y
x*y

z <- c(1,2) # vector z
x*z

z <- rep(z, 2) # replicates and overwrite z
z
x*z

# R 2.4. Data Frames
x <- c(1, 2, 3)
y <- c(4, 5, 6)
z <- c(7, 8, 9)
dat <- data.frame(x, y, z)
dat

ID <- c("A", "B", "C")
dat <- data.frame(ID, dat)
dat

x <- c(1, 2, 3)
y <- c(4, 5, 6)
z <- c(7, 8, 9)
dat <- data.frame(x, y, z)
dat*2

dat$x # dollar notation with variable name
dat[, 1] # matrix notation with column number
dat[, "x"] # matrix notation with variable name

dat[, c(1,2)]
dat[, c("x","y")]

dat[1,1] # cell entry row 1 and column 1
dat[1, "x"]
dat[, 1] * 2

a <- c(1,2,3)
dat[, 1] * a 
dat$x * a

# adding
dat[, "v"] <- dat[, 1] * a 
dat


# overriding
dat[, 4] <- dat[, 4] / a
dat


# Functions
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

x <- c(-1, -2, -3)
sum_x <- sum(x)
sum_x
abs(sum_x)
abs(sum(x))


### Tidyverse
install.packages("tidyverse")
library("tidyverse")



### GitHub 
install.packages("usethis")
usethis::create_github_token()

install.packages("gitcreds")
gitcreds::gitcreds_set()










