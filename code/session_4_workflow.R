pacman::p_load(tidyverse)

# prior distributions -----------------------------------------------------

## uniform distribution 

# create density distribution
x_min <- 0
x_max <- 1
range <- seq(x_min, x_max, length.out = 100) # sample space
d <- dunif(range, min = x_min, max = x_max) # densities
UNI <- data.frame(range, d)
UNI
# Plot
ggplot(UNI, aes(x = range, y = d)) +
  geom_line(size = 2) +
  labs(x = "x", 
       y = "Density") +
  theme_minimal()


## normal distribution 

# create density distributions
x_min <- -5
x_max <- 5
range <- seq(x_min, x_max, length.out = 100) # range
d <- dnorm(range, mean = 0, sd = 1) # densities
NORM <- data.frame(range, d)

# plot 
ggplot(NORM, aes(x = range, y = d)) +
  geom_line(size = 2) +
  labs(x = expression(mu_j),
       y = "Density") +
  theme_minimal()


x_min <- -5
x_max <- 5
range <- seq(x_min, x_max, length.out = 100) # range
d <- dnorm(range, mean = 0, sd = 5) # densities
NORM <- data.frame(range, d)

# plot 
ggplot(NORM, aes(x = range, y = d)) +
  geom_line(size = 2) +
  labs(x = expression(mu_j),
       y = "Density") +
  theme_minimal()



## beta distribution

# create density distributions
range <- seq(0, 1, length.out = 100)
d <- dbeta(range, shape1 = 4, shape2 = 2)
BETA <- data.frame(range, d)

# plot
ggplot(BETA, aes(x = range, y = d)) +
  geom_line(size = 2) +
  labs(x = "x", 
       y = "Density") +
  theme_minimal()

## exponential distribution

# create density distributions
x_min <- 0
x_max <- 10 
range <- seq(x_min, x_max, length.out = 100)
d <- dexp(range, rate = 100)
EXP <- data.frame(range, d)

# plot
ggplot(EXP, aes(x = range, y = d)) +
  geom_line(size = 2) +
  labs(x = "x", 
       y = "Density") +
  theme_minimal()


## gamma distribution 

# create density distributions
x_min <- 0
x_max <- 10
range <- seq(x_min, x_max, length.out = 100)
d <- dgamma(range, shape = 2, rate = 1)
GAMMA <- data.frame(range, d)

# plot
ggplot(GAMMA, aes(x = range, y = d)) +
  geom_line(size = 2) +
  labs(x = "x", 
       y = "Density") +
  theme_minimal()

# Prior predictive simulation --------------------------------------------------

# specify prior 
a <- 5
b <- 2

theta <- seq(0,1, length.out = 1e3)
d <- dbeta(theta, shape1 = a, shape2 = b)
summary <- data.frame(theta, d)

ggplot(summary, aes(x = theta, y = d)) +
  geom_line(size = 1, linetype = "dashed") +
  labs(x = expression(theta), 
       y = "Density") +
  theme_minimal()

no <- 1e3
prior_smp <- data.frame(smp = rbeta(no, a, b))
prior_smp

ggplot(summary) +
  geom_line(size = 1, linetype = "dashed", 
            aes(x = theta, y = d)) +
  geom_density(data = prior_smp, aes(x = smp), 
               color = "#F8766D", size = 1) + 
  labs(x = expression(theta), 
       y = "Density") +
  theme_minimal()

preds <- data.frame(L =vector("numeric", nrow(prior_smp)))
N <- 1e3

set.seed(832)
for (i in seq_along(prior_smp$smp)){ 
  
  preds[i, "L"] <- rbinom(n = 1, size = N, prob = prior_smp[i, "smp"])
  
}

preds %>% ggplot(aes(x=L)) + 
  geom_histogram(fill = "#F8766D", color = "#F8766D", 
                 alpha = .5, bins = 100) + 
  scale_x_continuous(limits = c(0,N), breaks = seq(0,N,100)) + 
  labs(x = "Number of Simulated L out of 1000",
       y = "Simulated Frequency") + 
  theme_minimal()


# Testing the model ----------------------------------------------

# scale prior to probability 
summary$prior <- (summary$d)/sum(summary$d)
upper <- seq((1/1e3), 1, length.out = 1e3)
lower <- seq(0, (999/1e3), length.out = 1e3)
summary$prior <- pbeta(upper, 5, 2) - pbeta(lower,5,2)

ggplot(summary, aes(x = theta, y = prior)) +
  geom_line(size = 1, linetype = "dashed") +
  labs(x = expression(theta), 
       y = "Prior") + 
  theme_minimal()

# simulate data
sim_rides <- function(N, p){
  sample(c("L", "O"), size=N, replace=TRUE, prob=c(p, 1-p)) 
}

N <- 1e2
set.seed(12385)
obs <- sim_rides(N, p = .1)

# grid approximation of posterior

compute_post <- function(obs, summary){ 
  L <- sum(obs=="L")
  likelihood <- dbinom(L, N, prob = summary$theta)
  posterior <- likelihood*summary$prior
  posterior_norm <- posterior/sum(posterior)
  tibble(summary,lh=round(likelihood, 3), post=round(posterior_norm,3))
}
estimation <- compute_post(obs, summary)

# Check results
estimation %>% 
  pivot_longer(cols = c(prior,post), 
               names_to = "type", 
               values_to = "probability") %>% 
  ggplot(aes(x=theta, y = probability, color = type, linetype = type)) + 
  geom_line(size = 1) + 
  theme_minimal() + 
  labs(x = "Theta", 
       y = "Probability", 
       color = "Probability",
       linetype = "Probability")

# posterior predictive check ----------------------------------------------

estimation %>% 
  ggplot(aes(x=theta, y = post)) + 
  geom_line(size = 1, linetype = "dashed") + 
  labs(x = expression(theta), 
       y = "Probability") + 
  theme_minimal()

set.seed(123461)
post_smp <- data.frame(smp = sample(estimation$theta, 1e3, prob = estimation$post, replace = TRUE))

ggplot(post_smp, aes(x=smp)) +
  geom_histogram(fill = "#F8766D", color = "#F8766D", alpha = .5, bins = 500) + 
  scale_x_continuous(limits = c(0,1), breaks = seq(0,1,.1)) + 
  labs(x = expression(theta), 
       y = "Probability") + 
  theme_minimal()

post_preds <- data.frame(L =vector("numeric", nrow(post_smp)))

N <- 1e3
for (i in seq_along(prior_smp$smp)){ 
  
  post_preds[i, "L"] <- rbinom(n = 1, size = N, prob = post_smp[i, "smp"])
  
}

post_preds %>% ggplot(aes(x=L)) + 
  geom_histogram(fill = "#F8766D", color = "#F8766D", alpha = .5, bins = 100) + 
  scale_x_continuous(limits = c(0,N), breaks = seq(0,N,100)) + 
  labs(x = "Number of Simulated L out of 1000",
       y = "Simulated Frequency") + 
  theme_minimal()
