# install and load packages 
pacman::p_load(tidyverse, 
               latex2exp)

# R 1.0. generative simulation: change theta and n to see how obs_sum change

theta <- .3 # can be anything between 0 and 1
n <- 10
obs <- sample(c("L", "P"), size = 10, replace = TRUE, prob = c(theta, (1-theta)))
obs_sums <- data.frame(NL = sum(obs=="L") ,
                       NP = sum(obs=="P")) 
obs_sums


# R 1.1. probability distributions associated with theta

## to obtain probability distributions
n <- 10 # number of trials
probs <- tibble(expand_grid(theta = seq(.2, .8, .2) , # values of theta
                            N = 0:n) , # possible number of delays
                p = round(dbinom(N, size=n, prob=theta), 3)) # probabilities for N given theta

## for LaTeX facet labels
label_theta <- function(string) {
  TeX(paste("$\\theta=$", string, sep = ""))
}

## plot distributions
ggplot(probs, aes(x=N, y=p)) + 
  geom_bar(stat="identity", color = "#0065BD", fill = "#0065BD", alpha=0.5) +
  facet_wrap(~theta, nrow = 2, labeller = as_labeller(label_theta, default = label_parsed)) +
  scale_x_continuous(breaks = 0:n) + 
  labs(x = "Number of Delays", 
       y = "Probability") +
  theme_minimal()

ggsave("plots/session_1_bin_theta.png", width = 6, height = 4)


# R 1.2. likelihoods associated with theta

# to obtain likelihoods
likelihoods <- tibble(expand_grid(N = c(0, 1, 5, 10), # observed number of delays
                                  theta = seq(0, 1, .1)) , # values of theta
                      like = round(dbinom(N, size=n, prob=theta), 3)) # probabilities for N given theta

## plot distributions
ggplot(likelihoods, aes(x=theta, y=like)) + 
  geom_bar(stat="identity", color = "#0065BD", fill = "#0065BD", alpha=0.5) +
  facet_wrap(~N, nrow = 2, labeller = "label_both") +
  scale_x_continuous(breaks = seq(0,1, .1)) + 
  labs(x = expression(theta), 
       y = "Likelihood") +
  theme_minimal()

ggsave("plots/session_1_likelihood_theta.png", width = 6, height = 4)

