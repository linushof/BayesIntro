# load packages

pacman::p_load(tidyverse, rethinking)

# introductory example 

data(WaffleDivorce)
d <- WaffleDivorce

d$D <- standardize(d$Divorce)
d$M <- standardize(d$Marriage)
d$A <- standardize(d$MedianAgeMarriage)

ggplot(d, aes(x = M, y = D)) + 
  geom_point(size = 3, color = "#0065BD") + 
  geom_smooth(method = "lm") +
  labs(x = "Marriage Rate", 
       y = "Divorce Rate") + 
  theme_minimal()
View(d)

m1_intro <- quap(
  alist( D ~ dnorm(mu, sigma), 
         mu ~ a + bM * M, 
         a ~ dnorm(0, .2), 
         bM ~ dnorm(0, .5), 
         sigma ~ dexp(1)), 
  data = d
)
precis(m1_intro)

ggplot(d, aes(x = A, y = M)) + 
  geom_point(size = 3, color = "#0065BD") + 
  geom_smooth(method = "lm") +
  labs(y = "Marriage Rate", 
       x = "Median Age Marriage") + 
  theme_minimal()

ggplot(d, aes(x = A, y = D)) + 
  geom_point(size = 3, color = "#0065BD") + 
  geom_smooth(method = "lm") +
  labs(y = "Divorce Rate", 
       x = "Median Age Marriage") + 
  theme_minimal()

m2_intro <- quap(
  alist( D ~ dnorm(mu, sigma), 
         mu ~ a + bM * M + bA * A, 
         a ~ dnorm(0, .2), 
         bM ~ dnorm(0, .5),
         bA ~ dnorm(0, .5), 
         sigma ~ dexp(1)), 
  data = d
)
precis(m2_intro)

# load and prepare data 

shaq <- read_csv("data/shaq.csv")
dat <- list(FGA = shaq$FGA,
            FTA = shaq$FTA, 
            PTS = shaq$PTS,
            Min = shaq$Minutes)

# simple regression

m1_shaq <- quap(
  alist(
    PTS ~ dnorm(mu, sd), 
    mu <- a + b * FGA,
    a ~ dunif(0,10), 
    b ~ dunif(0,3),
    sd ~ dunif(0,10)
  ),
  data = dat)
precis(m1_shaq)

# multiple regression

## generative simulation 

sim_pts_dynamic <- function(N_games, FGA, FTA, hFG, hFT){ 
  
  # FTA
  FT <- rbinom(N_games, FTA, prob = hFT)
  
  # 2PA  
  FG <- rbinom(N_games, FGA, prob = hFG)*2
  
  FT + FG
  
}     

pts_dynamic <- tibble(pts = sim_pts_dynamic(N_games = 1e3, 
                                            FGA = 20, 
                                            FTA = 7, 
                                            hFG = .5, 
                                            hFT = .83))


ggplot(pts_dynamic, aes(x = pts)) + 
  geom_histogram(fill = "#552583", alpha = .5, color = "#552583", bins = 30) + 
  labs(x = "PTS", 
       y = "Frequency") + 
  theme_minimal()

m2_shaq <- quap(
  alist(
    PTS ~ dnorm(mu, sd), 
    mu <- a + b_1 * FGA + b_2 * FTA,
    a ~ dunif(0,10),
    b_1 ~ dunif(0, 3),
    b_2 ~ dunif(0, 1),
    sd ~ dunif(0,10)
  ),
  data = dat)
precis(m2_shaq)

## mean-centering

FGA_bar <- round(mean(dat$FGA),0)
FTA_bar <- round(mean(dat$FTA),0)

m3_shaq <- quap(
  alist(
    PTS ~ dnorm(mu, sd), 
    mu <- a + b_1 * (FGA-FGA_bar) + b_2 * (FTA-FTA_bar), 
    a ~ dnorm(20,8), 
    b_1 ~ dunif(0, 3),
    b_2 ~ dunif(0, 1),
    sd ~ dunif(0,10) 
  ),
  data = dat)
precis(m3_shaq)

m4_shaq <- quap(
  alist(
    PTS ~ dnorm(mu, sd),
    mu <- a + b_1 * (FGA-FGA_bar) * 2 + b_2 * (FTA-FTA_bar), 
    a ~ dnorm(20,8),
    b_1 ~ dunif(0, 1),
    b_2 ~ dunif(0, 1),
    sd ~ dunif(0,10)
  ),
  data = dat)
precis(m4_shaq)

# mediation / pipe

# without mediator

ggplot(shaq, aes(x = Minutes, y = PTS)) + 
  geom_point(size = 3, color =  "#552583", alpha = .2) +
  geom_smooth(method = "lm", color = "#FDB927") +
  labs(x = "Minutes", 
       y = "Points") + 
  theme_minimal()

Min_bar <- round(mean(dat$Min),0)
m5_shaq <- quap(
  alist(
    PTS ~ dnorm(mu, sd),
    mu <- a + b_1 * (Min - Min_bar),
    a ~ dnorm(20, 8),
    b_1 ~ dunif(0, 2), 
    sd ~ dunif(0,10) 
  ),
  data = dat)
precis(m5_shaq)

# with mediator

m6_shaq <- quap(
  alist(
    PTS ~ dnorm(mu, sd), 
    mu <- a + b_1 * (Min - Min_bar) + b_2 * (FGA - FGA_bar) + b_3 * (FTA - FTA_bar),
    a ~ dnorm(20, 8),
    b_1 ~ dnorm(0, 2), 
    b_2 ~ dunif(0, 2), 
    b_3 ~ dunif(0, 1), 
    sd ~ dunif(0,10)
  ),
  data = dat)
precis(m6_shaq)

# Fork
library(tidyverse)
ggplot(diamonds, aes(y = price, x = clarity, color = clarity)) + 
  geom_boxplot() +
  theme_minimal()

ggplot(diamonds, aes(y = price, x = cut, color = cut)) + 
  geom_boxplot() +
  theme_minimal()

ggplot(diamonds, aes(y = price, x = color, color = color)) + 
  geom_boxplot() +
  theme_minimal()

diamonds2 <- diamonds
diamonds2$clarity <- fct_recode(factor(diamonds2$clarity),
                           "1" = "I1", 
                           "2" = "SI2", 
                          "3" = "SI1", 
                          "4" = "VS2", 
                          "5" = "VS1", 
                          "6" = "VVS2", 
                          "7" = "VVS1", 
                          "8" = "IF")
diamonds2$clarity <- as.numeric(diamonds2$clarity)
cor(diamonds2$price, diamonds2$clarity)

dat <- list(
  p = standardize(diamonds2$price), 
  cl = standardize(diamonds2$clarity),
  ca = standardize(diamonds2$carat)
)

m1 <- quap(
  alist(
    p ~ dnorm(mu, sd),
    mu <- a + b * cl, 
    a ~ dnorm(0, .1), 
    b ~ dnorm(0, .5), 
    sd ~ dexp(1) 
  ),
  data = dat)
precis(m1)

ggplot(diamonds, aes(y = price, x = carat, color = clarity)) + 
  geom_point(alpha = .5) +
  theme_minimal()

m2 <- quap(
  alist(
    p ~ dnorm(mu, sd),
    mu <- a + b * ca,
    a ~ dnorm(0, .1), 
    b ~ dnorm(0, .5), 
    sd ~ dexp(1)
  ),
  data = dat)
precis(m2)


ggplot(diamonds, aes(y = carat, x = clarity, color = clarity)) + 
  geom_boxplot() +
  theme_minimal()

ggplot(diamonds, aes(y = carat, x = cut, color = cut)) + 
  geom_boxplot() +
  theme_minimal()

ggplot(diamonds, aes(y = carat, x = color, color = color)) + 
  geom_boxplot() +
  theme_minimal()


m3 <- quap(
  alist(
    cl ~ dnorm(mu, sd),
    mu <- a + b * ca,
    a ~ dnorm(0, .1), 
    b ~ dnorm(0, .5), 
    sd ~ dexp(1)),
  data = dat)
precis(m3)


m4 <- quap(
  alist(
    p ~ dnorm(mu, sd),
    mu <- a + b1 * cl + b2 * ca,
    a ~ dnorm(0, .1), 
    b1 ~ dnorm(0, .5), 
    b2 ~ dnorm(0, .5), 
    sd ~ dexp(1)
  ),
  data = dat)
precis(m4)
