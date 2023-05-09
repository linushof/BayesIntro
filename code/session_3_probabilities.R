# install.packages("pacman")

pacman::p_load(tidyverse, MASS, ggExtra)

# Generate bivariate normal data
mu <- c(0, 0) # mean vector
Sigma <- matrix(c(1,.5, .5, 1), nrow = 2, ncol = 2) # covariance matrix
data <- data.frame(mvrnorm(n = 1000, mu = mu, Sigma = Sigma))

# Plot the joint probability distribution
p <- ggplot(data, aes(x=X1, y=X2)) +
  geom_point(alpha = .5) +
  theme_minimal()
p

# with marginal histogram
p1 <- ggMarginal(p, type="histogram")
p1

# marginal density
p2 <- ggMarginal(p, type="density")



# Probability of delay

## build generative model of delays

sim_rides <- function(N, p){
  sample(c("L", "O"), size=N, replace=TRUE, prob=c(p, 1-p)) 
}

## test the generative model via simulation
## change values of N and p and check (relative) number of delays
## check under extreme settings (e.g., p = 0, p = 1, N = 10000)

N <- 10
p <- .5
obs <- sim_rides(N, p = p)
sum(obs=="L") # absolute number of delays
sum(obs=="L")/N # relative number

## build a statistical model (estimator)

compute_post <- function(obs, poss){ 
  
  L <- sum(obs=="L") # data
  O <- sum(obs=="O")
  ways <- sapply( poss , function(q) (q*5)^L * ((1-q)*5)^O ) # number of ways the data could've been produced by poss
  post <- ways/sum(ways) # relative number
  data.frame(poss, ways, post=round(post,3)) # summary
  
}

## test the statistical model using the generative model
obs <- sim_rides(N = 10, poss=seq(0,1,.2))
compute_post(obs, poss)



## in probabilities

compute_post <- function(obs, poss){ 
  
  L <- sum(obs=="L")
  likelihood <- dbinom(L, N, prob = poss$theta) # likelihood = probability of the data given the model
  posterior <- likelihood*poss$prior
  posterior_norm <- posterior/sum(posterior)
  tibble(poss,lh=round(likelihood, 3), post=round(posterior_norm,3))
  
}

### Prior 
poss <- tibble(theta = seq(0,1,.1), 
               prior = rep(1/length(theta),length(theta)))

### Data
N <- 6
obs <- sim_rides(N, p = .5)

### Estimation 
estimation <- compute_post(obs, poss)


### Check results
estimation %>% 
  pivot_longer(cols = prior:post, names_to = "type", values_to = "probability") %>% 
  ggplot(aes(x=theta, y = probability, color = type)) + 
  geom_line(size = 1, alpha = .5) + 
  theme_minimal() + 
  labs(x = "Theta", 
       y = "Probability", 
       color = "Probability\nType")


### Bayesian updating: 

compute_post <- function(obs, poss){ 
  
  L <- sum(obs=="L")
  likelihood <- dbinom(L, 1, prob = poss$theta) # likelihood = probability of the data given the model
  posterior <- likelihood*poss$prior
  posterior_norm <- posterior/sum(posterior)
  tibble(poss,lh=round(likelihood, 3), post=round(posterior_norm,3))
  
}

N <- 9
p <- .5
samples <- vector("numeric", N)
results <- vector("list", N)
poss <- tibble(theta = seq(0,1,.05), 
               prior = rep(1/length(theta),length(theta)))
for (i in seq_along(1:N)){
  
  # sample new data
  samples[i] <- sample(c("L", "O"), size=1, replace=TRUE, prob=c(p, 1-p))
  
  estimation <- compute_post(samples[i], poss)
  results[[i]] <- expand_grid(N = i, estimation)
  
  poss$prior <- estimation$post
  
}


# plot

label <- tibble(N = 1:N,  samples)

plot <- results %>% 
  bind_rows() %>% 
  pivot_longer(cols = c(prior, post), names_to = "type", values_to = "probability") %>% 
  ggplot(aes(x=theta, y = probability)) + 
  facet_wrap(~N) +
  geom_line(aes(linetype = type, color = type), size = 1) + 
  theme_minimal() + 
  labs(x = "Theta", 
       y = "Probability", 
       color = "Probability",
       linetype = "Probability")

plot + geom_text(
  data    = label,
  mapping = aes(x = -Inf, y = -Inf, label = samples),
  hjust   = -1,
  vjust   = -11
)