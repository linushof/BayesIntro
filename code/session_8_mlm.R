# categories

# generative simulation
sim_HW <- function(S, b, a) { 
  N <- length(S) 
  H <- ifelse(S==1, 150, 160) + rnorm(N,0,5)
  W <- a[S] + b[S]*H + rnorm(N,0,5) # for each value of S, there is possibly a different value for a and ba
  data.frame(S, H, W)
}

S <- rbern(100) + 1
d <- sim_HW(S, b = c(.5, .6), a = c(0,0))


dat <- list(
  S = d$S, 
  H = d$H,
  W = d$W , 
  H_bar = mean(d$H)
) 

m1 <- ulam(
  alist( 
    W ~ dnorm(mu, sigma) ,
    mu <- a[S] , 
    a[S] ~ dnorm(60, 10) , # assume the same prior
    sigma ~ dunif(0,10) 
    ), data = dat
  )
precis(m1, depth = 2)



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
traceplot(m3)

### checking the posterior 
post <- extract.samples(m3)
m_1 <- tibble(S = "1" , W = post$a[,1]) 
m_2 <- tibble(S = "2" , W = post$a[,2]) 

# means
post_m <- bind_rows(m_1, m_2)
ggplot(post_m, aes(x = W, fill = S, color = S)) + 
  geom_density(alpha = .5) + 
  theme_minimal()

# contrast of means 
post_m_diff <- tibble(diff = post$a[,1] - post$a[,2])
post_m_diff
ggplot(post_m_diff, aes(x = diff)) + 
  geom_density(color = "#0065BD", fill = "#0065BD", alpha=0.5) + 
  theme_minimal()

# predicted posterior distributions
W_1 <- tibble(S = "1" , W = rnorm(1000, post$a[, 1], post$sigma)) 
W_2 <- tibble(S = "2" , W = rnorm(1000, post$a[, 2], post$sigma)) 
pred_W <- bind_rows(W_1, W_2)
ggplot(pred_W, aes(x = W, fill = S, color = S)) + 
  geom_density(alpha = .5) + 
  theme_minimal()

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


m2 <- ulam(
  alist( 
    W ~ dnorm(mu, sigma) ,
    mu <- a[S] + b[S]*(H-H_bar) , 
    a[S] ~ dnorm(60, 10) , 
    b[S] ~ dnorm(0,5) , 
    sigma ~ dunif(0,10) 
  ), data = dat, chains = 4, cores = 4, iter = 2e3)
precis(m2, depth = 2)
traceplot_ulam(m2)
plot(precis(m2, depth = 4))



