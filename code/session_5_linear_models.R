# load packages
pacman::p_load(tidyverse, rethinking)


# The normal distribution -------------------------------------------------

hist(replicate(1000, sum(runif(16,-1,1))))
hist(replicate(1000, sum(rbern(1000, .5))))
hist(rbinom(1000, 1000, .5))
hist(replicate(1000, sum(rnorm(1000, 20,5))))
hist(replicate(1000, sum(rbeta(100, 2,2))))

# Gaussian model ----------------------------------------------------------


# shaq's scoring record 

## load data
shaq <- read_csv("data/shaq.csv")
names(shaq)
shaq %>% ggplot(aes(x=PTS)) + 
  facet_wrap(~Season) + 
  geom_histogram(fill = "#552583", alpha = .5, color = "#552583", bins = 20) + 
  theme_minimal()



## generative model

## Gaussian variation in points from career history
PTS_static <- tibble(PTS = round(rnorm(1000, 25, 10), 0))
data %>% ggplot(aes(x = PTS)) + 
  geom_histogram(fill = "#552583", alpha = .5, color = "#552583", bins = 40) + 
  scale_x_continuous(limits = c(0, 70), breaks = seq(0,70,10))

## Dynamic: 

shot_perc <- shaq %>% 
  select(FGA, `3PA`, FTA) %>% 
  mutate(shots = FGA + `3PA` + FTA,
         FGA_rel = FGA/shots, 
         PT3_rel = `3PA`/shots, 
         FTA_rel = FTA/shots) %>% 
  summarise(FGA_mean = mean(FGA_rel, na.rm = TRUE), 
            PT3_mean = mean(PT3_rel, na.rm = TRUE), 
            FTA_mean = mean(FTA_rel, na.rm = TRUE))


PTS_dynamic <- function(N_games, N_shots, p1, p2, p3){ 
  
  # 2PA  
  p2 <- rbinom(N_games, round(.65 * N_shots, 0), prob = p2)*2
  
  # 3PA  
  p3 <- rbinom(N_games, round(0 * N_shots, 0), prob = p3)*3

  # FTA
  p1 <- rbinom(N_games, round(.35 * N_shots, 0), prob = p1)
  
  tibble(PTS = p1 +  p2 +  p3)
  
}      


PTS_sim <- PTS_dynamic(N_games = 1e4, N_shots = 30, p1 = .5, p2 = .6, p3 = .1)

# mu = (.65*shots*p2*2) + (.35*shots*p1)
# sd = ( (.65*shots*p2*2) * (1-p2) ) + ( (.35*shots*p1) * (1-p1) )


(.65*25*.6*2) + (.35*25*.5) # 28.65
( (.65*30*.6*2) * (1-.6) ) + ( (.35*30*.5) * (1-.5) ) # 11.985

PTS_sim %>% ggplot(aes(x = PTS)) + 
  geom_histogram(fill = "#552583", alpha = .5, color = "#552583", bins = 40) + 
  scale_x_continuous(limits = c(0, 70), breaks = seq(0,70,10))
PTS_sim
(.65*40*.6*2) + (.35*40*.5)

## statistical model 

round(0.35*23 , 0)
round(0.65*23 , 0)

### prior predictive check 

mu_samples <- rnorm(1e4, 25, 5)
sd_samples <- runif(1e4, 0, 10)


data <- tibble(PTS = rnorm(1e4, mu_samples, sd_samples))
data %>% ggplot(aes(x = PTS)) + 
  geom_histogram(fill = "#552583", alpha = .5, color = "#552583", bins = 40) + 
  scale_x_continuous(limits = c(0, 70), breaks = seq(0,70,10))


## test the model 

#### grid_approximation 
  
mu.list <- seq( from=150, to=160 , length.out=100 ) 
sigma.list <- seq( from=7 , to=9 , length.out=100 )
post <- expand.grid( mu=mu.list , sigma=sigma.list )
post$LL <- sapply( 1:nrow(post) , function(i) sum(
  dnorm( d2$height , post$mu[i] , post$sigma[i] , log=TRUE ) ) )
post$prod <- post$LL + dnorm( post$mu , 178 , 20 , TRUE ) +
  dunif( post$sigma , 0 , 50 , TRUE )
post$prob <- exp( post$prod - max(post$prod) )


# quadratic approximation 

gmodel <- alist(PTS ~ dnorm( mu , sigma ) ,
                mu ~ dnorm( 25 , 5 ) ,
                sigma ~ dunif( 0 , 10 )
)
model.fit.sim <- quap( gmodel , data=PTS_sim )
precis(model.fit)
model.fit <- quap( gmodel , data=shaq )
precis(model.fit)



# posterior predictive check 

vcov(model.fit)
post <- extract.samples(model.fit, 1e4)
precis(post)
plot(post)

data <- tibble(PTS = rnorm(1e4, post$mu, post$sigma))
data %>% ggplot(aes(x = PTS)) + 
  geom_histogram(fill = "#552583", alpha = .5, color = "#552583", bins = 40) + 
  scale_x_continuous(limits = c(0, 70), breaks = seq(0,70,10))



# Linear model ------------------------------------------------------------


# linear regression 

# generative model 

sim_pts <- function(FGA, b, sd){ 
  
  u <- rnorm(length(FGA), 0, sd)
  pts <- round(b*FGA + u,0)
  
  }

#simulate data
FGA <- round(rnorm(1e3, 30, 10), 0)
FGA
data <- sim_pts(FGA, 2, 5)


# statistical model / priors
n <- 1e3
priors
test <- tibble(a = rnorm(n, mean = 0, sd = .5), 
               b = rnorm(n, mean = 2, sd = .5))


test %>% ggplot(aes(x = seq(0,30,1))) + 
  scale_x_continuous(limits = c(0,40), breaks = seq(0,40,10)) + 
  scale_y_continuous(limits = c(0,80), breaks = seq(0,80,10)) + 
  labs(x = "FGA",
       y = "Points") + 
  geom_abline(aes(intercept = a, slope = b), color = "#FDB927", size = .1) + 
  theme_minimal()



# testing


# fitting

p3 <- shaq82 %>% 
  ggplot(aes(x=FGA, y=PTS)) + 
  geom_jitter(color = "#552583", fill = "#552583", alpha = .5, size = 3) + 
  geom_abline(data = post_shaq82, aes(intercept = a, slope = b), color = "#FDB927", linewidth = .1) + # plotting posterior lines 
  ggtitle(paste("N =", N)) + 
  theme_minimal() + 
  theme(plot.title = element_text(vjust = -11, hjust = 0.15)) 


### week prior

m_shaq <- quap(
  alist(
    PTS ~ dnorm(mu, sd), # likelihood
    mu <- a + b * FGA, # linear model
    a ~ dunif(0,10), # prior intercept
    b ~ dunif(0,3), # prior rate of change (slope)
    sd ~ dunif(0,10) # prior sd
  ),
  data = shaq
)
precis(m_shaq)

m_shaq <- quap(
  alist(
    PTS ~ dnorm(mu, sd), # likelihood
    mu <- a + b * FGA, # linear model
    a ~ dunif(0,10), # prior intercept
    b ~ dunif(0,3), # prior rate of change (slope)
    sd ~ dunif(0,10) # prior sd
  ),
  data = shaq
)
precis(m_shaq)


# centering
FGA_bar <- round(mean(shaq$FGA),0)
m_shaq_center <- quap(
  alist(
    PTS ~ dnorm(mu, sd), # likelihood
    mu <- a + b * (FGA-FGA_bar), # linear model
    a ~ dnorm(20,5), # prior intercept
    b ~ dunif(0,3), # prior rate of change (slope)
    sd ~ dunif(0,10) # prior sd
  ),
  data = shaq
)

precis(m_shaq_center)




m_shaq_center <- quap(
  alist(
    PTS ~ dnorm(mu, sd), # likelihood
    mu <- a + b * (FGA-FGA_bar), # linear model
    a ~ dnorm(20,5), # prior intercept
    b ~ dnorm(1,.2), # prior rate of change (slope)
    sd ~ dunif(0,10) # prior sd
  ),
  data = shaq
)
precis(m_shaq_center)









#### Field goal percentages


PTS_dynamic <- function(N_games, N_shots, p1, p2, p3){ 
  
  # 2PA  
  p2 <- rbinom(N_games, round(.65 * N_shots, 0), prob = p2)*2
  
  # 3PA  
  p3 <- rbinom(N_games, round(0 * N_shots, 0), prob = p3)*3
  
  # FTA
  p1 <- rbinom(N_games, round(.35 * N_shots, 0), prob = p1)
  
  tibble(PTS = p1 +  p2 +  p3)
  
}  

FGA_bar <- round(mean(shaq$FGA),0)
FTA_bar <- round(mean(shaq$FTA),0)
FTA_bar
m_shaq_center <- quap(
  alist(
    PTS ~ dnorm(mu, sd), # likelihood
    mu <- a + b * (FGA-FGA_bar) * 2 + c * (FTA - FTA_bar), # linear model
    a ~ dnorm(20,5), # prior intercept
    b ~ dunif(0,3), # prior rate of change (slope)
    c ~ dunif(0,3), 
    sd ~ dunif(0,10) # prior sd
  ),
  data = shaq
)
precis(m_shaq_center)

mean(shaq$`FG%`, na.rm = TRUE)

# posterior predictive checks




