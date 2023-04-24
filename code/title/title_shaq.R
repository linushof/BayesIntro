# load packages 
pacman::p_load(tidyverse, rethinking, ggpubr)

# Load Shaquille O’Neal game data
shaq <- read_csv("data/shaq.csv")


# plot distribution of points per game 
maxPTS <- max(shaq$PTS)
p1 <- shaq %>% 
  ggplot(aes(x=PTS)) + 
  geom_bar(color = "#552583", fill = "#552583", alpha = .7) + 
  scale_x_continuous(breaks=seq(0, maxPTS, 5)) + 
  labs(x = "Points Per Game",
       y = "Number of Games") + 
  theme_minimal()

# plot association of field goal attempts and points per game

# perform simple linear regression
## plot 20 posterior lines for different sample sizes to display reduction in uncertainty (see McElreath, 2020)

smp <- 20

## fit model with N = 10 random samples from the original data
N <- 10
shaq10 <- shaq[sample(1:nrow(shaq), N), ] # draw random samples

# fit the model with rethinking::quap() 
m1_shaq <- quap(
  alist(
    PTS ~ dnorm(mu, sd), # likelihood
    mu <- a + b * (FGA), # linear model
    a ~ dnorm(20,10), # prior intercept
    b ~ dlnorm(0,1), # prior rate of change (slope)
    sd ~ dunif(0,10) # prior sd
  ),
  data = shaq10
)

set.seed(89)
post_shaq10 <- extract.samples(m1_shaq, smp)

p2 <- shaq10 %>% 
  ggplot(aes(x=FGA, y=PTS)) + 
  geom_jitter(color = "#552583", fill = "#552583",  size = 3) + 
  geom_abline(data = post_shaq10, aes(intercept = a, slope = b), color = "#FDB927", linewidth = .1) + # plotting posterior lines 
  theme_minimal()


# fit entire model
N <- 82
shaq82 <- shaq[sample(1:nrow(shaq), N), ]
m2_shaq <- quap(
  alist(
    PTS ~ dnorm(mu, sd),
    mu <- a + b * (FGA),
    a ~ dnorm(20,10),
    b ~ dlnorm(0,1),
    sd ~ dunif(0,10)
  ),
  data = shaq82
)

post_shaq82 <- extract.samples(m2_shaq, smp)

p3 <- shaq82 %>% 
  ggplot(aes(x=FGA, y=PTS)) + 
  geom_jitter(color = "#552583", fill = "#552583", alpha = .5, size = 3) + 
  geom_abline(data = post_shaq82, aes(intercept = a, slope = b), color = "#FDB927", linewidth = .1) + # plotting posterior lines 
  theme_minimal()


## whole model
m3_shaq <- quap(
  alist(
    PTS ~ dnorm(mu, sd), # likelihood
    mu <- a + b * (FGA), # linear model
    a ~ dnorm(20,10), # prior intercept
    b ~ dlnorm(0,1), # prior rate of change (slope)
    sd ~ dunif(0,10) # prior sd
  ),
  data = shaq
)

post_shaq <- extract.samples(m3_shaq, smp)

p4 <- shaq %>% 
  ggplot(aes(x=FGA, y=PTS)) + 
  geom_jitter(color = "#552583", fill = "#552583", alpha = .5, size = 3) + 
  geom_abline(data = post_shaq, aes(intercept = a, slope = b), color = "#FDB927", size = .1) + # plotting posterior lines 
  theme_minimal()

ggarrange(p1, p2, p3, p4)
ggsave(file = "plots/title_shaq.png", width = 10, height = 7)
ggsave(file = "code/title/title_shaq.png", width = 10, height = 7)
