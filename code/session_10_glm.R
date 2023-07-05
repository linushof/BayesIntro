pacman::p_load(rethinking)

# admission rates UBC Berkeley: Part 1

data("UCBadmit")
d <- UCBadmit
rates <- d %>% 
  group_by(applicant.gender) %>% 
  summarise(admitted = sum(admit) , 
            applied = sum(applications) ,
            rate = round(admitted/applied , 2))
print(rates)

aging <- read_csv("data/Aging.csv")
kable(head(aging))
kable(head(risky))


## Logit link

## Interpretation
logit_p <- seq(-6,6, length.out = 100)
logistic_x <- inv_logit(logit_p)
plot(logit_p, logistic_x, type = "l")


## Prior for logistic regression

### a

x1 <- rnorm(1e4, 0,5)
y1 <- inv_logit(x1)
x2 <- rnorm(1e4, 0,1)
y2 <- inv_logit(x2)
x3 <- rnorm(1e4, 0,.1)
y3 <- inv_logit(x3)

par(mfrow=c(3,2))
dens(x1)
dens(y1)
dens(x2)
dens(y2)
dens(x3)
dens(y3)


### a + b

par(mfrow=c(1,2))

#### wide

a <- rnorm(1e4, 0, 5)
b <- rnorm(1e4, 0, 5)
xseq <- seq(-3,3, len=100)
p <- sapply(xseq, function(x) inv_logit(a+b*x)) 
plot(NULL, xlim= c(-2.5,2.5), ylim=c(0,1), xlab = "x value", ylab = "probability")
for(i in 1:10){ 
  lines(xseq, p[i,])
}

#### narrow
a <- rnorm(1e4, 0, .5)
b <- rnorm(1e4, 0, .5)
xseq <- seq(-3,3, len=100)
p <- sapply(xseq, function(x) inv_logit(a+b*x)) 
plot(NULL, xlim= c(-2.5,2.5), ylim=c(0,1), xlab = "x value", ylab = "probability")
for(i in 1:10){ 
  lines(xseq, p[i,])
}


# admission rates UBC Berkeley: Part 2

## generative simulation

### without direct discrimination but structural effect
N <- 1000 # number of applicants 
G <- sample(1:2, size = N, replace = TRUE)
D1 <- rbern(N, ifelse(G==1, .3, .8)) + 1 
accept_rate <- matrix( c(.1, .3, .1, .3), nrow = 2) 
A1 <- rbern(N, accept_rate[D1, G])
dat_sim1 <- list(A=A1, D=D1, G=G)

table(G,D1)
table(G,A1)

### with direct discrimination and structural effect
N <- 1000 # number of applicants 
G <- sample(1:2, size = N, replace = TRUE)
D2 <- rbern(N, ifelse(G==1, .3, .8)) + 1 
accept_rate <- matrix( c(.05, .2, .1, .3), nrow = 2) 
A2 <- rbern(N, accept_rate[D2, G])
dat_sim2 <- list(A=A2, D=D2, G=G)

table(G,D2)
table(G,A2)

## test model

### total effect of G
m1 <- ulam(
  alist(
    A ~ bernoulli(p) , 
    logit(p) <- a[G] , 
    a[G] ~ normal(0,1) 
    ) , data = dat_sim2, chains = 4, cores = 4
  )
precis(m1, depth = 2) # coefficients on log odds scale
inv_logit(coef(m1)) # interpret as probability 
traceplot(m1)


### direct effect of G
m2 <- ulam(
    alist(
      A ~ bernoulli(p) , 
      logit(p) <- a[G, D] , 
      matrix[G, D]:a ~ normal(0,1) 
    ) , data = dat_sim2, chains = 4, cores = 4
  )

precis(m2, depth = 3)  
inv_logit(coef(m2))
traceplot(m2)

## analyze real data

dat <- list(
  A = d$admit , 
  N = d$applications , 
  G = ifelse(d$applicant.gender=="female", 1, 2) , 
  D = as.integer(d$dept)
  )

### total effect
m3 <- ulam(
  alist(
    A ~ binomial(N, p) ,
    logit(p) <- a[G] ,
    a[G] ~ normal(0,1) 
  ) , data = dat, chains = 4, cores = 4
)
precis(m3, depth = 2)
inv_logit(coef(m3))
traceplot(m3)

#### posterior distribution of differences
post1 <- extract.samples(m3)
PrA_G1 <- inv_logit(post1$a[,1])
PrA_G2 <- inv_logit(post1$a[,2])
diff_prob <- PrA_G1 - PrA_G2
dens(diff_prob, lwd=4, col =2)

### direct effect 
m4 <- ulam(
  alist(
    A ~ binomial(N, p) ,
    logit(p) <- a[G, D] ,
    matrix[G, D]:a ~ normal(0,1) 
  ) , data = dat, chains = 4, cores = 4
)

precis(m4, depth = 3)
inv_logit(coef(m4))
traceplot(m4)

#### posterior distribution of differences
post2 <- extract.samples(m4)
PrA <- inv_logit(post2$a)
post2
diff_prob_D <- sapply(1:6, function(i) PrA[, 1, i] - PrA[, 2, i])
dens(diff_prob, lwd=4, col =2)

plot(NULL, xlim = c(-.2, .3),
     ylim = c(0,25) , 
     xlab = "Gender contrast (probability)" , 
     ylab="Density")
for(i in 1:6) dens(diff_prob_D[, i], lwd = 4, col = 1+i, add = TRUE)
