# Exercise ----------------------------------------------------------------

# load packages 
pacman::p_load(tidyverse, 
               rethinking)

# load data 
d <- read_csv("data/Aging.csv")
d <- na.omit(d)

# analyzing

## Gaussian model

d1 <- list(
  G = ifelse(d$Age <= 30, 1, 2) , 
  risk = d$RiskSeeking , 
  quality = d$DecisionQuality
)

# no pooling / no pooling 

mQ1 <- ulam( 
  alist(
    quality ~ dnorm(mu, sigma) , 
    mu <-  a[G] ,
    a[G] ~ dnorm(.5, .2) , 
    sigma ~ dexp(2)
  ) , 
  data = d1, 
  chains = 4, 
  cores = 4,
)
precis(mQ1, depth = 2)

mQ2 <- ulam( 
  alist(
    quality ~ dnorm(mu, sigma) , 
    mu <-  a[G] ,
    a[G] ~ dnorm(a_bar, tau) , 
    a_bar ~ dnorm(.5, .2) ,
    tau ~ dexp(1) ,
    sigma ~ dexp(2)
  ) , 
  data = d1, 
  chains = 4, 
  cores = 4, 
)
precis(mQ2, depth = 2)
traceplot(mQ2)


## Linear predictor models

### preprocessing

d2 <- list(
  G = ifelse(d$Age <= 30, 1, 2) , 
  risk = standardize(d$RiskSeeking) , 
  quality = standardize(d$DecisionQuality) , 
  speed = standardize(d$Speed) , 
  affect = standardize(d$NegAffect) , 
  numeracy = standardize(d$Numeracy) 
)

d2
### analyzing

mQ3 <- ulam( 
  alist(
    quality ~ dnorm(mu, sigma) , 
    mu <-  a[G] + b[G] * numeracy ,
    a[G] ~ dnorm(0, .2) ,
    b[G] ~ dnorm(0, .15) , 
    sigma ~ dexp(2)
  ) , 
  data = d2, 
  chains = 4, 
  cores = 4, 
  iter = 2000
)
precis(mQ3, depth = 2)
traceplot(mQ3)

mQ4 <- ulam( 
  alist(
    quality ~ dnorm(mu, sigma) , 
    mu <-  a[G] + b[G] * numeracy ,
    a[G] ~ dnorm(a_bar, tau_a) , 
    b[G] ~ dnorm(b_bar, tau_b) ,
    a_bar ~ dnorm(0, .2) ,
    b_bar ~ dnorm(0, .2) ,
    tau_a ~ dexp(1) , 
    tau_b ~ dexp(1) ,
    sigma ~ dexp(2)
  ) , 
  data = d2, 
  chains = 4, 
  cores = 4, 
  iter = 4000
)
precis(mQ4, depth = 2)
traceplot(mQ4)



