# load packages
pacman::p_load(tidyverse, rethinking)

# generative simulation 



# load data 

d <- read_csv("data/Aging.csv")
d <- na.omit(d)

d$group <- as.factor(ifelse(d$Age <= 30, 1, 2))
View(d)

dat <- list( 
  age = standardize(d$Age) , 
  G = ifelse(d$Age <= 30, 1, 2) , 
  risk = standardize(d$RiskSeeking) , 
  quality = standardize(d$DecisionQuality) , 
  speed = standardize(d$Speed) , 
  affect = standardize(d$NegAffect) , 
  numeracy = standardize(d$Numeracy) 
)

# Risk seeking

mCP <- ulam( 
  alist(
    quality ~ dnorm(mu, sigma) , 
    mu <-  a[G] ,
    a[G] ~ dnorm(0,1), 
    sigma ~ dexp(1)), data = dat, chains = 4, cores = 4
)

precis(mCP, depth = 2)
traceplot(mCP)


# MLM

# 0 predictors
mPP0 <- ulam( 
  alist(
    risk ~ dnorm(mu, sigma) , 
    mu <-  a[G] ,
    a[G] ~ dnorm(a_bar , tau), 
    a_bar ~ dnorm(0, 1 ) , 
    tau ~ dexp(1) , 
    sigma ~ dexp(1)), data = dat, chains = 4, cores = 4
)

precis(mPP, depth = 2)
traceplot(mPP)


# 1 predictor
mPP1 <- ulam( 
  alist(
    risk ~ dnorm(mu, sigma) , 
    mu <-  a[G] + b[G] * speed ,
    a[G] ~ dnorm(a_bar , tau_1) , 
    b[G] ~ dnorm(b_bar, tau_2) , 
    a_bar ~ dnorm(0 , 1) , 
    b_bar ~ dnorm(0, 1) , 
    tau_1 ~ dexp(1) ,
    tau_2 ~ dexp(1) ,
    sigma ~ dexp(1)), data = dat, chains = 4, cores = 4
)

precis(mPP1, depth = 2)
traceplot(mPP)

dat

m1 <- quap(
  alist(
    risk ~ dnorm(mu, sigma) ,
    mu <- a + b*numeracy ,
    a ~ dnorm(0, 1) ,
    b ~ dnorm(0, 1) , 
      sigma ~ dexp(1)), data = dat)
precis(m1)



# quality

mCP <- ulam( 
  alist(
    quality ~ dnorm(mu, sigma) , 
    mu <-  a[G] ,
    a[G] ~ dnorm(0,1), 
    sigma ~ dexp(1)), data = dat, chains = 4, cores = 4
)

precis(mCP, depth = 2)
traceplot(mCP)


# MLM

# 0 predictors
mPP0 <- ulam( 
  alist(
    risk ~ dnorm(mu, sigma) , 
    mu <-  a[G] ,
    a[G] ~ dnorm(a_bar , tau), 
    a_bar ~ dnorm(0, 1 ) , 
    tau ~ dexp(1) , 
    sigma ~ dexp(1)), data = dat, chains = 4, cores = 4
)

precis(mPP, depth = 2)
traceplot(mPP)


# 1 predictor
mPP1 <- ulam( 
  alist(
    risk ~ dnorm(mu, sigma) , 
    mu <-  a[G] + b[G] * speed ,
    a[G] ~ dnorm(a_bar , tau_1) , 
    b[G] ~ dnorm(b_bar, tau_2) , 
    a_bar ~ dnorm(0 , 1) , 
    b_bar ~ dnorm(0, 1) , 
    tau_1 ~ dexp(1) ,
    tau_2 ~ dexp(1) ,
    sigma ~ dexp(1)), data = dat, chains = 4, cores = 4
)

precis(mPP1, depth = 2)
traceplot(mPP)

dat

m1 <- quap(
  alist(
    risk ~ dnorm(mu, sigma) ,
    mu <- a + b*numeracy ,
    a ~ dnorm(0, 1) ,
    b ~ dnorm(0, 1) , 
    sigma ~ dexp(1)), data = dat)
precis(m1)


