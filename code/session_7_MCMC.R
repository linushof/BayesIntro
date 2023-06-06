# load packages
pacman::p_load(tidyverse, 
               rstan, 
               rethinking)


# MCMC --------------------------------------------------------------------

## Metropolis Sampling Algorithm 

num_weeks <- 1e5 
positions <- rep(0,num_weeks)
current <- 10
for ( i in 1:num_weeks ) {
  # record current position
  positions[i] <- current
  # flip coin to generate proposal
  proposal <- current + sample( c(-1,1) , size=1 )
  # now make sure he loops around the archipelago
  if ( proposal < 1 ) proposal <- 10
  if ( proposal > 10 ) proposal <- 1
  # move?
  prob_move <- proposal/current
  current <- ifelse( runif(1) < prob_move , proposal , current )
}


## Translation to Stan


# options(mc.cores = parallel::detectCores())
# set_cmdstan_path("C:/Users/ge84jux/cmdstan-2.30.1")

# load data
shaq <- read_csv("data/shaq.csv")


# step 1: prepare data 
dat <- list( # Stan requires a list of the data (tip: only use the data you want to model)
  N = nrow(shaq) , 
  pts = shaq$PTS ,
  min = shaq$Minutes ,
  fga = shaq$FGA , 
  fta = shaq$FTA , 
  min_bar = round(mean(shaq$Minutes), 2) , 
  fga_bar = round(mean(shaq$FGA), 2) ,
  fta_bar = round(mean(shaq$FTA), 2)
  )

## Gaussian Basis

# step 2: specify Stan model 

# step 3: Fit the model
m1shaq <- stan("code/Stan/session_7_mshaq1.stan", data=dat, chains = 4, cores = 4)

# step 4: inspect and evaluate the model
m1shaq
plot(m1shaq)
pairs(m1shaq, pars = c("mu", "sigma"))
traceplot(m1shaq)

stancode(m2shaq)

# compare to quap 
m1shaq_quap <- quap(
  alist(pts ~ dnorm( mu , sigma ),
        mu ~ dnorm( 20 , 8 ) ,
        sigma ~ dunif( 0 , 10 )) ,
  data = dat)
precis(m1shaq_quap)

# Mediation / Pipe example

# step 3: Fit the model
m2shaq <- stan("code/Stan/session_7_m2shaq.stan", data=dat, chains = 4, cores = 4)

# step 4: inspect and evaluate the model
m2shaq
plot(m2shaq)
pairs(m2shaq, pars = c("a", "b1", "b2", "b3", "sigma"))
traceplot(m2shaq)

# compare to quap
m4shaq <- quap(
  alist(
    pts ~ dnorm(mu, sigma), 
    mu <- a + b_1 * (min - min_bar) + b_2 * (fga - fga_bar) * 2 + b_3 * (fta - fta_bar),
    a ~ dnorm(20, 8),
    b_1 ~ dnorm(0, 2), 
    b_2 ~ dunif(0, 2), 
    b_3 ~ dunif(0, 1), 
    sigma ~ dunif(0,10)
  ),
  data = dat)
precis(m4shaq)


### rethinking 

data(rugged)
d <- rugged
d$log_gdp <- log(d$rgdppc_2000)
dd <- d[complete.cases(d$rgdppc_2000), ]
dd$log_gdp_std <- dd$log_gdp / mean(dd$log_gdp)
dd$rugged_std <- dd$rugged / max(dd$rugged)
dd$cid <- ifelse(dd$cont_africa==1, 1, 2)

m1 <- quap(
  alist(
    log_gdp_std ~ dnorm(mu, sigma), 
    mu <- a[cid] + b[cid]*(rugged_std - .215), 
    a[cid] ~ dnorm(1, .1), 
    b[cid] ~ dnorm(1, .3), 
    sigma ~ dexp(1)
  ), data = dd
)
precis(m1, depth = 2)


data_slim <- list(
  log_gdp_std = dd$log_gdp_std, 
  rugged_std = dd$rugged_std,
  cid = as.integer(dd$cid)
)
str(data_slim)

set_cmdstan_path("C:/Users/ge84jux/cmdstan-2.30.1")
m2 <- ulam(
  alist(
    log_gdp_std ~ dnorm(mu, sigma), 
    mu <- a[cid] + b[cid]*(rugged_std - .215), 
    a[cid] ~ dnorm(1, .1), 
    b[cid] ~ dnorm(1, .3), 
    sigma ~ dexp(1)
  ), data = data_slim, chains = 4, cores = 4, iter = 2000
)
precis(m2, depth = 2)

pairs(m2)
traceplot(m2, n_cols = 2)
trankplot(m2, n_cols = 2)



y <- c(-1,1)
set.seed(11)
m9.2 <- ulam(
  alist(
    y ~ dnorm( mu , sigma ) ,
    mu <- alpha ,
    alpha ~ dnorm( 1 , 10 ) ,
    sigma ~ dexp( 1 )
  ) ,
  data=list(y=y) , chains=2 )

precis( m9.2 )

pairs( m9.2@stanfit )
traceplot(m9.2)


x <- seq(-10, 10, length.out = 100)
dat <- data.frame(x, d = dnorm(x, 0,1))
dat <- dat %>% mutate(log_d_neg = -1*log(d))

ggplot(dat, aes(x, log_d_neg)) +
  geom_line() + 
  theme_minimal()
log(.1)


data("Wines2012")
d <- Wines2012

dat <- list(
  S = standardize(d$score) , 
  J = as.numeric(d$judge) , 
  W = as.numeric(d$wine) , 
  X = ifelse(d$wine.amer==1,1,2) , 
  Y = ifelse(d$judge.amer==1,1,2)
)

mQ <- ulam( 
  alist(
    S ~ dnorm(mu, sigma) , 
    mu <- Q[W] , 
    Q[W] ~ dnorm(0,1) , 
    sigma ~ dexp(1)
  ) , data = dat, chains = 4, cores = 4
  )

pairs(mQ)
traceplot(mQ)
trankplot(mQ)


plot(precis(mQ, depth = 2))

mQO <- ulam( 
  alist(
    S ~ dnorm(mu, sigma) , 
    mu <- Q[W] + O[X], 
    Q[W] ~ dnorm(0,1) ,
    O[X] ~ dnorm(0,1) ,
    sigma ~ dexp(1)
  ) , data = dat, chains = 4, cores = 4
)

traceplot(mQO)
trankplot(mQO)
precis(mQO, depth = 2)
plot(precis(mQO, depth = 2))


mQOJ <- ulam( 
  alist(
    S ~ dnorm(mu, sigma) , 
    mu <- (Q[W] + O[X] - H[J]) * D[J], 
    Q[W] ~ dnorm(0,1) ,
    O[X] ~ dnorm(0,1) ,
    H[J] ~ dnorm(0,1) , 
    D[J] ~ dexp(1) ,
    sigma ~ dexp(1)
  ) , data = dat, chains = 4, cores = 4
)

traceplot(mQOJ)
trankplot(mQOJ)

precis(mQOJ, depth = 2)
plot(precis(mQOJ, depth = 2))

rethinking::stancode(mQOJ)
