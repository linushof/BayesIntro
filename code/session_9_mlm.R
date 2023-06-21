# load packages

pacman::p_load(tidyverse, 
               rethinking)


# mean group effects only --------------------------------------------------------------

# generative model

sim_quality_1 <- function(G) {
  N <- length(G)
  quality <- ifelse(G==1, .75, .6) + rnorm(N, 0, .2)
  data.frame(G, quality)
}

# simulate data 
G <- as.factor(sample(c(1, 2), 1e3, replace = T))
d1 <- sim_quality_1(G)

# test model

## complete pooling
mQCP1 <- ulam(
  alist(
    quality ~ dnorm(mu, sigma) , 
    mu ~ dnorm(.5, .2) , 
    sigma ~ dexp(.5)
  ) , data = d1, chains = 4, cores = 4
)
precis(mQCP1)


## no pooling
mQNP1 <- ulam(
  alist(
    quality ~ dnorm(mu, sigma) , 
    mu <- a[G] , 
    a[G] ~ dnorm(.5, .2) , 
    sigma ~ dexp(.5)
  ) , data = d1, chains = 4, cores = 4
)


precis(mQNP1, depth = 2)
traceplot(mQNP1)

## partial pooling
mQPP1 <- ulam(
  alist(
    quality ~ dnorm(mu, sigma) , 
    mu <- a[G] , 
    a[G] ~ dnorm(a_bar, tau) ,
    a_bar ~ dnorm(.5, .2) , 
    tau ~ dnorm(0, .1) , 
    sigma ~ dexp(.5)
  ) , 
  data = d1, 
  chains = 4, 
  cores = 4
)

precis(mQPP1, depth = 2)
traceplot(mQPP1)




# Underfitting --------------------------------------------------------------

# generative model

sim_quality_2 <- function(G, a, b) {
  N <- length(G)
  numeracy <- ifelse(G==1, .5, .3) + rnorm(N, 0, .1)
  quality <- a[G] + b[G]*numeracy + rnorm(N, 0, .1)
  data.frame(G, numeracy, quality)
}

# simulate data

G <- as.factor(sample(c(1, 2), 1e3, replace = T))
d2 <- sim_quality_2(G, a = c(.7, .6), b = c(.2, .1))

# test model

## complete pooling 

mQCP2 <- ulam(
  alist(
    quality ~ dnorm(mu, sigma) , 
    mu <- a + b * numeracy ,
    a ~ dnorm(.5, .2) , 
    b ~ dnorm(0, .15) ,
    sigma ~ dexp(1)
  ) , data = d2, chains = 4, cores = 4, iter = 2000
)
precis(mQCP2)
traceplot(mQCP2)

## no pooling

mQNP2 <- ulam(
  alist(
    quality ~ dnorm(mu, sigma) , 
    mu <- a[G] + b[G] * numeracy  , 
    a[G] ~ dnorm(.5, .2) , 
    b[G] ~ dnorm(0, .15) ,
    sigma ~ dexp(1)
  ) , data = d2, chains = 4, cores = 4, iter = 2000
)
precis(mQNP2, depth = 2)
traceplot(mQNP2)

## partial pooling 

mQPP2 <- ulam( 
  alist(
    quality ~ dnorm(mu, sigma) , 
    mu <-  a[G] + b[G] * numeracy ,
    a[G] ~ dnorm(a_bar, tau_a) ,
    b[G] ~ dnorm(b_bar, tau_b) , 
    a_bar ~ dnorm(.5, .2) , 
    b_bar ~ dnorm(0, .15) , 
    tau_a ~ dexp(.5) , 
    tau_b ~ dexp(.5) ,
    sigma ~ dexp(1)
  ) , data = d2, chains = 4, cores = 4, iter = 2000
)
precis(mQPP2, depth = 2)
traceplot(mQPP2)


# more groups ---------------------------------------------------------------

# generative model 

sim_quality_3 <- function(G, a, b, oa, ob) {
  N <- length(G)
  numeracy <- rnorm(N, .5, .2)
  quality <- a + oa[G] + b + ob[G]*numeracy + rnorm(N, 0, .1)
  data.frame(G, numeracy, quality)
}

# simulate data

G <- as.factor(sample(1:20, 1e4, replace = T))
oa <- round(sample(seq(-.3, .3, .05), 20, replace = T), 2)
ob <- round(sample(seq(-.2, .2, .05), 20, replace = T), 2)
d3 <- sim_quality_3(G, a = .5, b = 0, oa = oa, ob = ob)


head(tibble(oa, ob), 5)

# test model

## partial pooling 

mQPP3 <- ulam( 
  alist(
    quality ~ dnorm(mu, sigma) , 
    mu <-  a[G] + b[G] * numeracy ,
    a[G] ~ dnorm(a_bar, tau_a) ,
    b[G] ~ dnorm(b_bar, tau_b) , 
    a_bar ~ dnorm(.5, .2) , 
    b_bar ~ dnorm(0, .15) , 
    tau_a ~ dexp(.5) , 
    tau_b ~ dexp(.5) ,
    sigma ~ dexp(1)
  ) , 
  data = d3, 
  chains = 4, 
  cores = 4, 
  iter = 4000
)
precis(mQPP3, depth = 2)
plot(precis(mQPP3, depth = 2))
traceplot(mQPP3)
