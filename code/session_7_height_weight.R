library(rethinking)
data("Howell1")
dat <- Howell1

height_bar <- round(mean(dat$height), 2)
age_bar <- round(mean(dat$age), 2)

m1 <- quap(
  alist(
    weight ~ dnorm(mu, sd), 
    mu <- a + b * (height-height_bar),
    a ~ dnorm(70, 10),
    b ~ dnorm(0, 3) ,
    sd ~ dunif(0,10)
  ),
  data = dat)
precis(m1)

m2 <- quap(
  alist(
    weight ~ dnorm(mu, sd), 
    mu <- a + b * (height-height_bar) + b2 * (age-age_bar),
    a ~ dnorm(70, 10),
    b ~ dnorm(0, 3) ,
    b2 ~ dnorm(0, 3) ,
    sd ~ dunif(0,10)
  ),
  data = dat)
precis(m2)

plot(dat$weight, dat$height)
plot(dat$height, dat$weight)
plot(dat$age, dat$height)
plot(dat$age, dat$weight)

m3 <- quap(
  alist(
    weight ~ dnorm(mu, sd), 
    mu <- a + b*(age-age_bar) + b2*(age-age_bar)^2 ,
    a ~ dnorm(40, 7),
    b ~ dnorm(0, 3) ,
    b2 ~ dnorm(0, 3) ,
    sd ~ dunif(0,10)
  ),
  data = dat)
precis(m3)

m3 <- quap(
  alist(
    weight ~ dnorm(mu, sd), 
    mu <- a + b*(age-age_bar) ,
    a ~ dnorm(40, 7),
    b ~ dnorm(0, 3) ,
    sd ~ dunif(0,20)
  ),
  data = dat)
precis(m3)

dat_a <- dat %>% filter(age >= 18)
plot(dat_a$weight, dat_a$height)
plot(dat_a$age, dat_a$height)
plot(dat_a$age, dat_a$weight)


