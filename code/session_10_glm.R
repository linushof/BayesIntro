## Admissions rates 

# generative model of admission rates

library(rethinking)

N <- 1000 # number of applicants 
G <- sample(1:2, size = N, replace = TRUE) # even gender distribution 
D <- rbern(N, ifelse(G==1, .3, .8)) + 1 #  gender 1 tends to apply to department 1, 2 to 2
accept_rate <- matrix( c(.1, .3, .1, .3), nrow = 2) # no direct discrimination
accept_rate
A <- rbern(N, accept_rate[D, G])
table(G,D)
table(G,A)

View(accept_rate[D,G])

N <- 1000 # number of applicants 
G <- sample(1:2, size = N, replace = TRUE) # even gender distribution 
D <- rbern(N, ifelse(G==1, .3, .8)) + 1 #  gender 1 tends to apply to department 1, 2 to 2
accept_rate <- matrix( c(.05, .2, .1, .3), nrow = 2) # direct discrimination
accept_rate
A <- rbern(N, accept_rate[D, G])
table(G,D)
table(G,A)


# prior predictives 

a <- rnorm(1e4, 0, 10)
b <- rnorm(1e4, 0, 10)
xseq <- seq(-3,3, len=100)
p <- sapply(xseq, function(x) inv_logit(a+b*x)) 
p

plot(NULL, xlim= c(-2.5,2.5), ylim=c(0,1), xlab = "x value", ylab = "probability")
for(i in 1:10){ 
  lines(xseq, p[i,])
  }


a <- rnorm(1e4, 0, 1.5)
b <- rnorm(1e4, 0, 0.5)
xseq <- seq(-3,3, len=100)
p <- sapply(xseq, function(x) inv_logit(a+b*x)) 
p

plot(NULL, xlim= c(-2.5,2.5), ylim=c(0,1), xlab = "x value", ylab = "probability")
for(i in 1:10){ 
  lines(xseq, p[i,])
}


# statistical model

# total effect of G

dat_sim <- list(A=A, D=D, G=G)
dat_sim

m1 <- ulam(
  alist(
    A ~ bernoulli(p) , 
    logit(p) <- a[G] , 
    a[G] ~ normal(0,1) 
    ) , data = dat_sim, chains = 4, cores = 4
  )
precis(m1, depth = 2) # coefficients on log odds scale
traceplot(m1)
inv_logit(coef(m1)) # interpret as probability 

# direct effect of G, stratified by Department

m2 <- ulam(
    alist(
      A ~ bernoulli(p) , 
      logit(p) <- a[G, D] , 
      matrix[G, D]:a ~ normal(0,1) 
    ) , data = dat_sim, chains = 4, cores = 4
  )
precis(m2, depth = 3)  
  
data("UCBadmit")
d <- UCBadmit
d
dat <- list(
  A = d$admit , 
  N = d$applications , 
  G = ifelse(d$applicant.gender=="female", 1, 2) , 
  D = as.integer(d$dept)
  )

# total effect gender
m3 <- ulam(
  alist(
    A ~ binomial(N, p) ,
    logit(p) <- a[G] ,
    a[G] ~ normal(0,1) 
  ) , data = dat, chains = 4, cores = 4
)
traceplot(m3)
precis(m3, depth = 2)
inv_logit(coef(m3))

post1 <- extract.samples(m3)
PrA_G1 <- inv_logit(post1$a[,1])
PrA_G2 <- inv_logit(post1$a[,2])
diff_prob <- PrA_G1 - PrA_G2
dens(diff_prob, lwd=4, col =2)

# direct effect gender 
m4 <- ulam(
  alist(
    A ~ binomial(N, p) ,
    logit(p) <- a[G, D] ,
    matrix[G, D]:a ~ normal(0,1) 
  ) , data = dat, chains = 4, cores = 4
)
traceplot(m4)
precis(m4, depth = 3)
inv_logit(coef(m4))

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

### post stratification ###

### post stratification ###


## Aging Data Set 
head(data)
data <- read.csv2("data/Burnout.csv")
dat <- list( 
  burnout = ifelse(data$BurnOut == "Burnt Out", 1, 0) , 
  research = standardize(as.numeric(data$stressResearch)) , 
  teach = standardize(as.numeric(data$stressTeaching)) , 
  pastoral = standardize(as.numeric(data$stressPastoral))
)
dat

mburn1 <- ulam(
  alist(
    burnout ~ bernoulli(p) , 
    logit(p) <- a + bT * teach + bR * research + bP * pastoral, 
    a ~ normal(0, .1), 
    bT ~ normal(0, .1), 
    bR ~ normal(0, .1),
    bP ~ normal(0, .1) ), data = dat, chains = 4, cores = 4, iter = 1000 
  )
traceplot(mburn1)
precis(mburn1)
inv_logit(coef(mburn1))

inv_logit(-.54+.22+.16)

# risky choice
risky <- read.csv2("data/RiskyChoice.csv")
risky <- na.omit(risky)
names(risky)
dat3 <- list( 
 AG = ifelse(risky$AgeGroup == "younger", 1, 0) , 
 choice = risky$CorrectChoice , 
 naffect = standardize(as.numeric(risky$NegativeAffect)) , 
 numeracy = standardize(as.numeric(risky$Numeracy))
  )
dat3


mrisky1 <- ulam(
  alist(
    choice ~ bernoulli(p) , 
    logit(p) <- a + bN * numeracy, 
    a ~ normal(0, .1), 
    bN ~ normal(0, .1) ), data = dat3, chains = 4, cores = 4, iter = 1000 
)
traceplot(mrisky1)
precis(mrisky1)
inv_logit(sum(coef(mrisky1)))

