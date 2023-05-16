# prior distributions -----------------------------------------------------


## uniform distribution 

# create density distribution
x_min <- 0
x_max <- 1
range <- seq(x_min, x_max, length.out = 100) # sample space
d <- dunif(range, min = x_min, max = x_max) # densities
UNI <- data.frame(range, d)

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
  labs(x = "x", 
       y = "Density") +
  theme_minimal()


## beta distribution

# create density distributions
range <- seq(0, 1, length.out = 100)
d <- dbeta(range, shape1 = 2, shape2 = 2)
BETA <- data.frame(range, d)

# plot
ggplot(BETA, aes(x = x, y = d)) +
  geom_line(size = 2) +
  labs(x = "x", 
       y = "Density") +
  theme_minimal()

## exponential distribution

# create density distributions
x_min <- 0
x_max <- 10 
range <- seq(x_min, x_max, length.out = 100)
d <- dexp(range, rate = 1)
EXP <- data.frame(range, d)

# plot
ggplot(EXP, aes(x = x, y = d)) +
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
