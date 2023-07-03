# load packages
pacman::p_load(tidyverse, 
               rstan, 
               rethinking)


# MCMC --------------------------------------------------------------------

# Metropolis Sampling Algorithm 

## King Markov
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
  prob_move <- proposal/current
  current <- ifelse( runif(1) < prob_move , proposal , current )
  }

positions[1:100]

# sequence 
data <- data.frame(position = positions, move = 1:1e5)
ggplot(data, aes(x=move, y = position)) +
  geom_line(size = 1, color = "#c80895") + 
  scale_x_continuous(limits = c(0,100)) + 
  theme_minimal()

# frequencies
ggplot(data, aes(x=position)) +
  geom_bar(color = "#c80895", fill = "#c80895", alpha = .5) + 
  scale_x_continuous(breaks = seq(1,10,1)) + 
  theme_minimal()


# Paper code
samples <- numeric(500)
samples[1] <- 110
for (i in 2:500){ 
  proposal <- samples[i-1] + rnorm(1, 0, 5)
  if( (dnorm(proposal, 100, 15) / dnorm(samples[i-1], 100, 15)) > runif(1)) samples[i] = proposal
  else(samples[i] = samples[i-1])
}

samples <-  as.data.frame(samples)
ggplot(samples, aes(x=samples)) +
  geom_histogram(color = "#c80895", fill = "#c80895", alpha = .5, bins = 10) + 
  theme_minimal()



# RStan -------------------------------------------------------------------

# set_cmdstan_path("C:/Users/ge84jux/cmdstan-2.30.1")

# load data
shaq <- read_csv("data/shaq.csv")

# step 1: prepare data 
dat <- list( # Stan requires a list of the data 
  N = nrow(shaq) , 
  pts = shaq$PTS ,
  min = shaq$Minutes ,
  fga = shaq$FGA , 
  fta = shaq$FTA , 
  min_bar = round(mean(shaq$Minutes), 2) , 
  fga_bar = round(mean(shaq$FGA), 2) ,
  fta_bar = round(mean(shaq$FTA), 2)
  )

# step 2 and 3: specify and fit the Stan model 
m1shaq <- stan("code/Stan/session_7_m1shaq.stan", 
               data=dat, 
               chains = 4, 
               cores = 4, 
               iter = 2000)


# step 4: inspect and evaluate the model
m1shaq
stan_dens(m1shaq)
pairs(m1shaq, pars = c("mu", "sigma"))
traceplot(m1shaq)

# Mediation / Pipe example

# step 3: Fit the model
m2shaq <- stan("code/Stan/session_7_m2shaq.stan", 
               data=dat, 
               chains = 4, 
               cores = 4, 
               iter = 4000)

# step 4: inspect and evaluate the model
m2shaq
plot(m2shaq)
pairs(m2shaq, pars = c("a", "b1", "b2", "b3", "sigma"))
traceplot(m2shaq)
stan_dens(m2shaq, separate_chains = TRUE)


# Rethinking --------------------------------------------------------------


# use to quap (quadratic approximation)
m2shaq_quap <- quap(
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
precis(m2shaq_quap)

# use ulam (interfacec to Stans HMC Sampler)
m5shaq <- ulam(
  alist(
    pts ~ dnorm(mu, sigma), 
    mu <- a + b_1 * (min - min_bar) + b_2 * (fga - fga_bar) * 2 + b_3 * (fta - fta_bar),
    a ~ dnorm(20, 8),
    b_1 ~ dnorm(0, 2), 
    b_2 ~ dunif(0, 2), 
    b_3 ~ dunif(0, 1), 
    sigma ~ dunif(0,10)
  ),
  data = dat, chains = 4, cores = 4, iter = 4000)
precis(m5shaq)

traceplot(m5shaq)
trankplot(m5shaq)
stancode(m5shaq)