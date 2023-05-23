# load packages
pacman::p_load(tidyverse, rethinking)


# The normal distribution -------------------------------------------------

hist(replicate(1000, sum(runif(16,-1,1))))
hist(replicate(1000, sum(rbern(1000, .5))))
hist(rbinom(1000, 1000, .5))
hist(replicate(1000, sum(rnorm(1000, 20,5))))
hist(replicate(1000, sum(rbeta(100, 2,2))))

# Gaussian model of Shaq's NBA points ----------------------------------------------------------

# Generative model

## Static model: Gaussian variation in points resulting from fluctuations over career history
N_games <- 1e3
sim_pts_static <- function(N_games, mu, sd){

  round(rnorm(N, mu, sd), 0)
  
}

pts_static <- tibble(pts = sim_pts_static(N_games, 20, 5))
ggplot(pts_static, aes(x = pts)) + 
  geom_histogram(fill = "#552583", alpha = .5, color = "#552583", bins = 30) + 
  labs(x = "PTS", 
       y = "Frequency") + 
  theme_minimal()


## Dynamic model: PTS as function of attempted field goals, free throws, and 3-pointer + hit rates; Gaussian variations resulting from summed fluctuations
sim_pts_dynamic <- function(N_games, N_shots, pFGA, pFTA, p3PA, hFG, hFT, h3P){ 
  
  # FTA
  FT <- rbinom(N_games, round(pFTA * N_shots, 0), prob = hFT)
  
  # 2PA  
  FG <- rbinom(N_games, round(pFGA * N_shots, 0), prob = hFG)*2
  
  # 3PA  
  TP <- rbinom(N_games, round(p3PA * N_shots, 0), prob = h3P)*3
  
  FT + FG + TP
  
}     

pts_dynamic <- tibble(pts = sim_pts_dynamic(N_games = 1e3, N_shots = 30, pFGA = .65, pFTA = .35, p3PA = 0, hFG = .7, hFT = .2, h3P = .2))
ggplot(pts_dynamic, aes(x = pts)) + 
  geom_histogram(fill = "#552583", alpha = .5, color = "#552583", bins = 20) + 
  labs(x = "PTS", 
       y = "Frequency") + 
  theme_minimal()

# Statistical model: y ~ Normal(mu, sigma) 

##  Priors on mu and sigma

### mu
range <- seq(-10, 60, length.out = 100) # range
d <- dnorm(range, mean = 20, sd = 8) # densities
mu <- data.frame(range, d)
ggplot(mu, aes(x = range, y = d)) +
  geom_line(size = 1, color = "#552583") +
  scale_x_continuous(limits = c(-10,60), breaks = seq(-10,60, 5)) + 
  labs(x = expression(mu), 
       y = "Density") +
  theme_minimal()
curve( dnorm( x , 20 , 5) , from=- 10, to=50 )

### sigma
range <- seq(-1, 11, length.out = 100) # sample space
d <- dunif(range, min = 0, max = 10) # densities
sigma <- data.frame(range, d)
ggplot(sigma, aes(x = range, y = d)) +
  geom_line(size = 1, color = "#552583") +
  scale_x_continuous(limits = c(-1,11), breaks = seq(-1,11, 1)) + 
  labs(x = expression(sigma), 
       y = "Density") +
  theme_minimal()
curve( dunif( x , 0 , 10 ) , from=-1 , to=11 )

### prior predictive check
mu_samples <- rnorm(1e4, 20, 8)
sigma_samples <- runif(1e4, 0, 10)

prior_pred <- tibble(pts = rnorm(1e4, mu_samples, sd_samples))
prior_pred %>% ggplot(aes(x = pts)) + 
  geom_histogram(fill = "#552583", alpha = .5, color = "#552583", bins = 20) + 
  labs(x = "PTS", 
       y = "Frequency") + 
  theme_minimal()

# Test model 

## Simulate data
N_games <- 1e3
pts_static <- tibble(pts = sim_pts_static(N_games, 30, 10))

PTS_sim <- PTS_dynamic(N_games = 1e4, N_shots = 30, p1 = .5, p2 = .6, p3 = .1)

# mu = (.65*shots*p2*2) + (.35*shots*p1)
# sd = ( (.65*shots*p2*2) * (1-p2) ) + ( (.35*shots*p1) * (1-p1) )


(.65*25*.6*2) + (.35*25*.5) # 28.65
( (.65*30*.6*2) * (1-.6) ) + ( (.35*30*.5) * (1-.5) ) # 11.985

## Fit model on simulated data
m_sim <- quap(
  alist(pts ~ dnorm( mu , sigma ),
        mu ~ dnorm( 20 , 8 ) ,
        sigma ~ dunif( 0 , 10 )) ,
  data = pts_static)
precis(m_sim)

# Use model to analyze data

## load data
shaq <- read_csv("data/shaq.csv")

## fit model
m_shaq <- quap(
  alist(PTS ~ dnorm( mu , sigma ),
        mu ~ dnorm( 20 , 8 ) ,
        sigma ~ dunif( 0 , 10 )) ,
  data = shaq)
precis(m_shaq)

shaq %>% ggplot(aes(x=PTS)) + 
  geom_histogram(fill = "#552583", alpha = .5, color = "#552583", bins = 30) + 
  theme_minimal()


# Evaluate the model 

m_shaq_smp <- extract.samples(m_shaq, n = 1e3)

## Posterior intervals 
PI(m_shaq_smp$mu)
PI(m_shaq_smp$sigma)
HPDI(m_shaq_smp$mu)
HPDI(m_shaq_smp$sigma)

## Posterior predictive checks 

## densities
range <- seq(-10, 60, length.out = 100) # range
smp_dens <- m_shaq_smp %>% 
  mutate(smp = row_number()) %>% 
  expand_grid(range) %>% 
  mutate(d = dnorm(range, mu, sigma))

ggplot(smp_dens, aes(x = range, y = d, group = smp)) +
  geom_line(color = "#552583", size = .5, alpha = .1) +
  scale_x_continuous(limits = c(-10,60), breaks = seq(-10,60, 5)) + 
  labs(x = expression(mu), 
       y = "Density") +
  theme_minimal()

## posterior predictions
pts_sim_post <- tibble(pts = round(rnorm(nrow(m_shaq_smp), mean = m_shaq_smp$mu, sd = m_shaq_smp$sigma), 0))
ggplot(pts_sim_post, aes(x = pts)) + 
  geom_histogram(data = shaq, aes(x = PTS), alpha = .5, bins = 40) + 
  geom_histogram(fill = "#552583", alpha = .5, color = "#552583", bins = 40) +
  labs(x = "PTS", 
       y = "Frequency") +
  theme_minimal()



# Linear model ------------------------------------------------------------

# Generative model

## Static: Changes in FGA result in proportional changes in PTS
sim_pts_static <- function(FGA, b, sd){ 
  
  u <- rnorm(length(FGA), 0, sd)
  pts <- round(b*FGA + u, 0)
  
  }


FGA <- round(rnorm(1e3, 30, 10), 0)
pts_static <- tibble(pts = sim_pts_static(FGA, 1, 8))
ggplot(pts_static, aes(x = pts)) + 
  geom_histogram(fill = "#552583", alpha = .5, color = "#552583", bins = 30) + 
  labs(x = "PTS", 
       y = "Frequency") + 
  theme_minimal()


# Statistical model: y ~ Normal(mu, sigma), mu = a + b*FGA

##  Priors on a, b, and sigma


### a
range <- seq(-1, 16, length.out = 100) # sample space
d <- dunif(range, min = 0, max = 15) # densities
alpha <- data.frame(range, d)
ggplot(alpha, aes(x = range, y = d)) +
  geom_line(size = 1, color = "#552583") +
  scale_x_continuous(limits = c(-1,16), breaks = seq(-1,16, 1)) + 
  labs(x = expression(beta), 
       y = "Density") +
  theme_minimal()

### b
range <- seq(-1, 4, length.out = 100) # sample space
d <- dunif(range, min = 0, max = 3) # densities
beta <- data.frame(range, d)
ggplot(beta, aes(x = range, y = d)) +
  geom_line(size = 1, color = "#552583") +
  scale_x_continuous(limits = c(-1,4), breaks = seq(-1,4, 1)) + 
  labs(x = expression(beta), 
       y = "Density") +
  theme_minimal()

### sigma
range <- seq(-1, 11, length.out = 100) # sample space
d <- dunif(range, min = 0, max = 10) # densities
sigma <- data.frame(range, d)
ggplot(sigma, aes(x = range, y = d)) +
  geom_line(size = 1, color = "#552583") +
  scale_x_continuous(limits = c(-1,11), breaks = seq(-1,11, 1)) + 
  labs(x = expression(sigma), 
       y = "Density") +
  theme_minimal()

### prior predictive check
alpha_samples <- runif(1e3, 0, 10)
beta_samples <- runif(1e3, 0, 3)
sigma_samples <- runif(1e3, 0, 10)

prior_pred_1 <- tibble(alpha_samples, beta_samples)

ggplot(prior_pred_1, aes(x = seq(0,30,1))) + 
  scale_x_continuous(limits = c(0,40), breaks = seq(0,40,10)) + 
  scale_y_continuous(limits = c(0,80), breaks = seq(0,80,10)) + 
  labs(x = "FGA",
       y = "Points") + 
  geom_abline(aes(intercept = alpha_samples, slope = beta_samples), color = "#FDB927", size = .1, alpha = .1) + 
  theme_minimal()

FGA <-  round(rnorm(1e3, 20, 10), 0)
mu_samples <- alpha_samples + beta_samples*FGA
prior_pred_2 <- tibble(pts = rnorm(1e3, mu_samples, sigma_samples))
prior_pred_2 %>% ggplot(aes(x = pts)) + 
  geom_histogram(fill = "#552583", alpha = .5, color = "#552583", bins = 30) + 
  labs(x = "PTS", 
       y = "Frequency") + 
  theme_minimal()

# testing

# simulate data
set.seed(11562)
FGA <- round(rnorm(1e3, 30, 10), 0)
pts_static <- tibble(FGA = FGA, 
                     pts = sim_pts_static(FGA, 1.2, 3))

# fitting
m2_sim <- quap(
  alist(
    pts ~ dnorm(mu, sd), # likelihood
    mu <- a + b * FGA, # linear model
    a ~ dunif(0,10), # prior intercept
    b ~ dunif(0,3), # prior rate of change (slope)
    sd ~ dunif(0,10) # prior sd
  ),
  data = pts_static)
precis(m2_sim)

# analyze real data 

m2_shaq <- quap(
  alist(
    PTS ~ dnorm(mu, sd), # likelihood
    mu <- a + b * FGA, # linear model
    a ~ dunif(0,10), # prior intercept
    b ~ dunif(0,3), # prior rate of change (slope)
    sd ~ dunif(0,10) # prior sd
  ),
  data = shaq)
precis(m2_shaq)

# with mean centering
FGA_bar <-round(mean(shaq$FGA),0)
m3_shaq <- quap(
  alist(
    PTS ~ dnorm(mu, sd), # likelihood
    mu <- a + b * (FGA-FGA_bar), # linear model
    a ~ dnorm(20,5), # prior intercept
    b ~ dunif(0,3), # prior rate of change (slope)
    sd ~ dunif(0,10) # prior sd
  ),
  data = shaq)

# evaluate 

## Posterior intervals 
PI(m_shaq_smp$mu)
PI(m_shaq_smp$sigma)
HPDI(m_shaq_smp$mu)
HPDI(m_shaq_smp$sigma)

## Posterior predictive checks 

m3_shaq_smp <- extract.samples(m3_shaq, n = 1e3)

ggplot(m3_shaq_smp, aes(x = seq(0,30,1))) + 
  scale_x_continuous(limits = c(0,40), breaks = seq(0,40,10)) + 
  scale_y_continuous(limits = c(0,80), breaks = seq(0,80,10)) + 
  labs(x = "FGA",
       y = "Points") + 
  geom_abline(aes(intercept = a, slope = b), color = "#FDB927", size = .1, alpha = .1) + 
  theme_minimal()


ggplot(shaq, aes(x = FGA-FGA_bar, y = PTS)) +
  geom_jitter(color = "#552583", fill = "#552583", alpha = .2, size = 2) +
  labs(x = "FGA",
       y = "Points") + 
  geom_abline(data = m3_shaq_smp, aes(intercept = a, slope = b), color = "#FDB927", linewidth = .1, alpha = .1) +
  theme_minimal()


## posterior predictions
pts_sim_post <- tibble(pts = round(rnorm(nrow(m_shaq_smp), mean = m_shaq_smp$mu, sd = m_shaq_smp$sigma), 0))
ggplot(pts_sim_post, aes(x = pts)) + 
  geom_histogram(data = shaq, aes(x = PTS), alpha = .5, bins = 40) + 
  geom_histogram(fill = "#552583", alpha = .5, color = "#552583", bins = 40) +
  labs(x = "PTS", 
       y = "Frequency") +
  theme_minimal()

 


