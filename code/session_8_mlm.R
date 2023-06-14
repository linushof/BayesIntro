# load packages 
pacman::p_load(rethinking, tidyverse)


# Binary categories: Height, Weight, Sex  -------------------------------------------------------

# generative simulation
sim_HW <- function(S, b, a) { 
  N <- length(S) 
  H <- ifelse(S=="f", 150, 160) + rnorm(N,0,5)
  W <- a[S] + b[S]*H + rnorm(N,0,5)  # for each value of S, there is (possibly) a different value for a and b
  data.frame(S, H, W)
}

S <- as.factor(sample(c("m", "f"), 100, replace = T))
d <- sim_HW(S, b = c(.5, .6), a = c(0 ,0))

head(d, 5)


# modeling the synthetic data 

# using an indicator variable 

dat_indicator <- list(
  S = ifelse(d$S=="m", 0, 1) , 
  H = d$H ,
  W = d$W , 
  H_bar = mean(d$H)
) 

m1 <- ulam(
  alist( 
    W ~ dnorm(mu, sigma) ,
    mu <- a + b*S , 
    a ~ dnorm(60, 10) , 
    b ~ dnorm(0, 5) , 
    sigma ~ dunif(0,10) 
  ), data = dat_indicator, chains = 4, cores = 4
)
precis(m1)


# using index variables 
dat_index <- list(
  S = ifelse(d$S=="m", 1, 2) , 
  H = d$H ,
  W = d$W , 
  H_bar = mean(d$H)
) 

m2 <- ulam(
  alist( 
    W ~ dnorm(mu, sigma) ,
    mu <- a[S] , 
    a[S] ~ dnorm(60, 10) , # assume the same prior
    sigma ~ dunif(0,10) 
  ), data = dat_index, chains = 4, cores = 4
)
precis(m2, depth = 2)



# modeling real data

data(Howell1)
d <- Howell1
d_adult <- Howell1 %>% filter(age >= 18)

dat <- list( 
  S = d_adult$male + 1 , # female = 1, male = 2
  H = d_adult$height , 
  W = d_adult$weight ,
  H_bar = mean(d_adult$height)
  )

m3 <- ulam(
  alist( 
    W ~ dnorm(mu, sigma) ,
    mu <- a[S] , 
    a[S] ~ dnorm(60, 10) , # assume the same prior
    sigma ~ dunif(0,10) 
  ), data = dat, chains = 4, cores = 4
)

precis(m3, depth = 2)
post <- extract.samples(m3)

### posterior means
m_1 <- tibble(S = "1" , W = post$a[,1]) 
m_2 <- tibble(S = "2" , W = post$a[,2]) 
post_m <- bind_rows(m_1, m_2)
ggplot(post_m, aes(x = W, fill = S)) + 
  geom_density(alpha = .5) + 
  theme_minimal()

### posterior predictions
W_1 <- tibble(S = "1" , W = rnorm(1000, post$a[, 1], post$sigma)) 
W_2 <- tibble(S = "2" , W = rnorm(1000, post$a[, 2], post$sigma)) 
pred_W <- bind_rows(W_1, W_2)
ggplot(pred_W, aes(x = W, fill = S, color = S)) + 
  geom_density(alpha = .5) + 
  theme_minimal()


# contrast of means 
post_m_diff <- tibble(diff = post$a[,1] - post$a[,2])
post_m_diff
ggplot(post_m_diff, aes(x = diff)) + 
  geom_density(color = "#0065BD", fill = "#0065BD", alpha=0.5) + 
  theme_minimal()

# contrast predictions

W_1 <- rnorm(1000, post$a[, 1], post$sigma)
W_2 <- rnorm(1000, post$a[, 2], post$sigma)

dens_W_diff <- density(W_2 - W_1)
pred_W_diff <- tibble(x = dens_W_diff$x, 
                      y = dens_W_diff$y, 
                      heavier = as.factor(ifelse(x < 0, 1, 2)))

ggplot(pred_W_diff, aes(x = x, y = y, fill = heavier, color = heavier)) +
  geom_line() + 
  geom_ribbon(data = subset(pred_W_diff, x < 0), aes(ymin = 0, ymax = y), alpha = .5) + 
  geom_ribbon(data = subset(pred_W_diff, x > 0), aes(ymin = 0, ymax = y), alpha = .5) +
  theme_minimal()

# direct effect of gender 

m4 <- ulam(
  alist( 
    W ~ dnorm(mu, sigma) ,
    mu <- a[S] + b[S]*(H-H_bar) , 
    a[S] ~ dnorm(60, 10) , 
    b[S] ~ dnorm(0, 2) , 
    sigma ~ dunif(0,10)
  ) , data = dat, chains = 4, cores = 4, iter = 2e3)
precis(m4, depth = 2)
traceplot_ulam(m2)

# Many categories: Wines  -------------------------------------------------------

data("Wines2012")
d <- Wines2012

dat <- list(
  S = standardize(d$score) , 
  J = as.numeric(d$judge) , 
  W = as.numeric(d$wine) , 
  X = ifelse(d$wine.amer==1,1,2) , 
  Z = ifelse(d$judge.amer==1,1,2)
)

mQ <- ulam(
  alist(
    S ~ dnorm(mu, sigma), 
    mu <- Q[W] , 
    Q[W] ~ dnorm(0,1) , 
    sigma ~ dexp(1)
  ), data = dat, chains = 4, cores = 4
)
 
precis(mQ, depth = 2) 
plot(precis(mQ, depth = 2) )
traceplot(mQ)


mQO <- ulam(
  alist(
    S ~ dnorm(mu, sigma), 
    mu <- Q[W] + O[X], 
    Q[W] ~ dnorm(0,1) ,
    O[X] ~ dnorm(0,1) , 
    sigma ~ dexp(1)
  ), data = dat, chains = 4, cores = 4, iter = 2000
)

precis(mQO, depth = 2) 
plot(precis(mQO, depth = 2) )
traceplot(mQO)

mQOJ <- ulam(
  alist(
    S ~ dnorm(mu, sigma), 
    mu <- (Q[W] + O[X] - H[J]) * D[J], 
    Q[W] ~ dnorm(0,1) ,
    O[X] ~ dnorm(0,1) , 
    H[J] ~ dnorm(0,1) , 
    D[J] ~ dexp(1) , 
    sigma ~ dexp(1)
  ), data = dat, chains = 4, cores = 4, iter = 2000
)
precis(mQOJ, depth = 3) 
plot( precis(mQOJ, depth = 2) )  


