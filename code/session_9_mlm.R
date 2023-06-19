# load packages

pacman::p_load(tidyverse, 
               rethinking)


# generative simulation 


sim_quality <- function(G) {
  N <- length(G)
  quality <- ifelse(G=="Y", .75, .6) + rnorm(N, 0, .1)
  data.frame(G, quality)
}

G <- as.factor(sample(c("Y", "O"), 1e3, replace = T))
d <- sim_quality( G)


d %>% group_by(G) %>% summarize(m = mean(quality))
d

# testing the model

## complete pooling 
mQCP <- ulam(
  alist(
    quality ~ dnorm(mu, sigma) , 
    mu ~ dnorm(.5, .2) , 
    sigma ~ dexp(1)
  ) , data = d, chains = 4, cores = 4, iter = 2000
)
precis(mQCP)
traceplot(mQCP)

## no pooling 
mQNP <- ulam(
  alist(
    quality ~ dnorm(mu, sigma) , 
    mu <- a[G] , 
    a[G] ~ dnorm(.5, .2) , 
    sigma ~ dexp(1)
  ) , data = d, chains = 4, cores = 4, iter = 2000
)
precis(mQNP, depth = 2)
traceplot(mQCP)


## partial pooling 
mQPP <- ulam(
  alist(
    quality ~ dnorm(mu, sigma) , 
    mu <- a[G] , 
    a[G] ~ dnorm(a_bar, tau) ,
    a_bar ~ dnorm(.5, 2) , 
    tau ~ dnorm(0, .2) , 
    sigma ~ dexp(1)
  ) , data = d, chains = 4, cores = 4, iter = 2000
)
precis(mQPP, depth = 2)
traceplot(mQCP)




sim_quality <- function(G, a, b) {
  N <- length(G)
  numeracy <- ifelse(G==1, .5, .3) + rnorm(N, 0, .1)
  quality <- a[G] + b[G]*numeracy + rnorm(N, 0, .1)
  data.frame(G, numeracy, quality)
}

G <- as.factor(sample(c(1, 2), 1e3, replace = T))
d <- sim_quality(G, a = c(.7, .6), b = c(.2, .1))

d %>% group_by(G) %>% summarize(m = mean(quality))

# testing the model

## complete pooling 
mQCP <- ulam(
  alist(
    quality ~ dnorm(mu, sigma) , 
    mu ~ dnorm(.5, .2) , 
    sigma ~ dexp(1)
  ) , data = d, chains = 4, cores = 4, iter = 2000
)
precis(mQCP)
traceplot(mQCP)

## no pooling 
mQNP <- ulam(
  alist(
    quality ~ dnorm(mu, sigma) , 
    mu <- a[G] , 
    a[G] ~ dnorm(.5, .2) , 
    sigma ~ dexp(1)
  ) , data = d, chains = 4, cores = 4, iter = 2000
)
precis(mQNP, depth = 2)
traceplot(mQCP)

## partial pooling 
mQPP <- ulam(
  alist(
    quality ~ dnorm(mu, sigma) , 
    mu <- a[G] , 
    a[G] ~ dnorm(a_bar, tau) ,
    a_bar ~ dnorm(.5, 2) , 
    tau ~ dnorm(0, .2) , 
    sigma ~ dexp(1)
  ) , data = d, chains = 4, cores = 4, iter = 2000
)
precis(mQPP, depth = 2)
traceplot(mQPP)


mQPP1 <- ulam( 
  alist(
    quality ~ dnorm(mu, sigma) , 
    mu <-  a[G] + b[G] * numeracy ,
    a[G] ~ dnorm(a_bar, tau_a) ,
    b[G] ~ dnorm(b_bar, tau_b) , 
    a_bar ~ dnorm(0, .2) , 
    b_bar ~ dnorm(0, .5) , 
    tau_a ~ dexp(2) , 
    tau_b ~ dexp(2) ,
    sigma ~ dexp(2)
  ) , data = d, chains = 4, cores = 4, iter = 2000
)
traceplot(mQPP1)
precis(mQPP1, depth = 2)

names(d)






# load data 
d <- read_csv("data/Aging.csv")
d <- na.omit(d)
names(d)




# preprocessing
dat <- list( 
  age = standardize(d$Age) , 
  G = ifelse(d$Age <= 30, 1, 2) , 
  risk = standardize(d$RiskSeeking) , 
  quality = standardize(d$DecisionQuality) , 
  speed = standardize(d$Speed) , 
  affect = standardize(d$NegAffect) , 
  numeracy = standardize(d$Numeracy) 
)


# Decision Quality

# 0 predictors

# complete pooling
mQCP <- ulam(
  alist(
    quality ~ dnorm(mu, sigma) , 
    mu ~ dnorm(0,1) , 
    sigma ~ dexp(1)
    ) , data = dat, chains = 4, cores = 4, iter = 2000
)
precis(mQCP)
traceplot(mQCP)

# no pooling
mQNP <- ulam( 
  alist(
    quality ~ dnorm(mu, sigma) , 
    mu <-  a[G] ,
    a[G] ~ dnorm(0, 1) , 
    sigma ~ dexp(1)
    ) , data = dat, chains = 4, cores = 4, iter = 2000
)
precis(mNP, depth = 2)
traceplot(mNP)

# partial pooling

mPP <- ulam( 
  alist(
    quality ~ dnorm(mu, sigma) , 
    mu <-  a[G] ,
    a[G] ~ dnorm(a_bar , tau) ,
    a_bar ~ dnorm(0, 1 ) , 
    tau ~ dexp(1) , 
    sigma ~ dexp(1) 
    ) , data = dat, chains = 4, cores = 4, iter = 2000
)
precis(mPP, depth = 2)
traceplot(mNP)


# 1 predictor

mQPP1 <- ulam( 
  alist(
    quality ~ dnorm(mu, sigma) , 
    mu <-  a + b[G] * numeracy ,
    a ~ dnorm(0 , 1) ,
    b[G] ~ dnorm(b_bar, tau_b) , 
    b_bar ~ dnorm(0, 1) , 
    tau_b ~ dexp(2) ,
    sigma ~ dexp(1)
    ) , data = dat, chains = 4, cores = 4, iter = 2000
)
traceplot(mQPP1)
precis(mQPP1, depth = 2)






# Risk Seeking

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
traceplot(mPP1)
trankplot(mPP1)
plot(precis(mPP1))



m1 <- quap(
  alist(
    risk ~ dnorm(mu, sigma) ,
    mu <- a[G] + b[G]*affect ,
    a[G] ~ dnorm(0, 1) ,
    b[G] ~ dnorm(0, 1) , 
      sigma ~ dexp(1)), data = dat)
precis(m1, depth = 2)



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

data()
