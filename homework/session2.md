# Resources

The following list of resources may help you with the tasks:

-   [Slides Session
    2](https://www.moodle.tum.de/pluginfile.php/4527976/mod_resource/content/2/session_2_software.pdf)
-   [Software
    Primer](https://github.com/linushof/BayesIntro/blob/main/setup/software_primer.md)

# Exercise 1: Creating and cloning the course repository

1.  Create a new *GitHub* repo which you will retain throughout this
    course.
2.  Clone the repo to your machine by creating a new *RStudio* project
    with version control.
3.  In your local repo, create a new folder `exercises` and a new R
    script `session_2_exercise.R`.
4.  Push the `exercise` folder and `session_2_exercise.R` to *GitHub*.
5.  Write the code for the remaining exercises in `session_2_exercise.R`
    and commit and push regularly. Use commented out code (`#`) to add
    notes to your script and document your code.

# Exercise 2: Working with vectors and functions

## 2.1

Consider the following lines of code:

    x <- runif(100, 1, 100)
    mean_x <- round(mean(x), 2)

1.  Try to understand what the code is doing by running it and
    investigating the outputs.
2.  Check your intuition by looking up the help pages of the functions
    `runif`, `mean`, and `round`.
3.  Run the above code repeatedly and check `mean_x` after each run. Why
    does the value change?
4.  Search the internet for a command that allows you to obtain the same
    value for `mean_x` every time you rerun the two code lines. Fix the
    code to obtain the desired results.

## 2.2

1.  Generate a vector `x` that entails all integers between 1 and 1000.
2.  Find at least one more way to generate the same vector `x`.
3.  Generate a vector `y` such that the output of `x + y` returns a
    vector that only contains 1000s.
4.  Assume `x` and `y` contain the amounts in dollars that 2000
    different people possess. How much money do all people possess
    together?

## 2.3

The following code draws 10,000 random values from a beta distribution
with the shape parameters `a = 4` and `b = 4` and multiplies them by a
scale parameter `scale = 15,000`.

    n <- 1e4
    scale <- 1.5e4
    income <- round( rbeta(n=n, shape1=2, shape2=12) * scale, 2)

Let’s assume these simulated values represent the gross income in US$ of
10,000 people. The following lines of code plot a histogram, which
displays the counts of people that obtain an income in the respective
range.

    library(ggplot2) # only load (run) once

    # Plot the resulting curve
    ggplot(data.frame(x = income), aes(x=x)) +
      geom_histogram(color = "#0065BD", fill = "#0065BD", alpha=0.5, bins = 100) +
      scale_x_continuous(breaks = seq(0, scale, 1e3)) + 
      labs(x = "Gross income", 
           y = "Counts") + 
      theme_minimal()

1.  From what you know or assume about how income is distributed in a
    population, do you think the simulated data is realistic? Change the
    scale and shape parameters in the function `rbeta` to simulate new
    data and generate a new plot. Play a bit around and see what the
    parameters do to your data by investigating the resulting
    histograms. Try to use the above code to simulate the data which
    reflects your knowledge or assumptions about income distributions.
    (*Tipp: If you overwrite the object `income`, the code for the plot
    must not be changed. If you create a new object, substitute `income`
    in the function `ggplot()` with the new object.*)

2.  Use the income distribution `income` that you came up with to
    compute each person’s share of the total income of all people.

3.  Investigating the individual share values may not be very
    enlightening. You may instead create more comprehensive summaries of
    income distributions as does the following code. By investigating
    and running the code, try to understand it and comment the code
    lines and/or blocks using commented out lines (`#`).

<!-- -->

    income_s <- sort(income)
    group <- c("Lower 1%", "Lower 50%", "Top 10%", "Top 1%")
    p <- c(.1, .5, .9, .99)

    boundary <- round(income_s[p*n], 0)

    low10_m <- mean( income_s[c(1:(.1*n))] )
    low50_m <- mean( income_s[c(1:(.5*n))] )
    top10_m <- mean( income_s[c((.9*n):n)] )
    top1_m <- mean( income_s[c((.99*n):n)] )

    means <-  round( c(low10_m, low50_m, top10_m, top1_m) , 0)

    income_summary <- data.frame(group, boundary, means)
    income_summary

    ##       group boundary means
    ## 1  Lower 1%      625   401
    ## 2 Lower 50%     1901  1102
    ## 3   Top 10%     4015  4988
    ## 4    Top 1%     6160  6874

1.  Considering the above summary table and what you know or assume
    about how income is distributed in a population, do you still think
    the simulated data is realistic? Change the scale and shape
    parameters in the function `rbeta` to simulate new data and generate
    new plots and summaries.

# Exercise 3: Working with data frames

1.  Create a data frame with 5 variables and 5 rows.
2.  Computes the arithmetic mean of each variable in the data set and
    store all 5 means in one vector.
3.  *Bonus*: If you copied and pasted the code for each variable, try to
    come up with a solution, that omits copy and pasting and does the
    entire operation in one line. Make sure that the output shows only
    the computed names and not also the respective variable names.

Below, you can see the first 10 rows of the `diamonds` data set from the
*tidyverse*.

    head(diamonds, 10)

    ## # A tibble: 10 × 10
    ##    carat cut       color clarity depth table price     x     y     z
    ##    <dbl> <ord>     <ord> <ord>   <dbl> <dbl> <int> <dbl> <dbl> <dbl>
    ##  1  0.23 Ideal     E     SI2      61.5    55   326  3.95  3.98  2.43
    ##  2  0.21 Premium   E     SI1      59.8    61   326  3.89  3.84  2.31
    ##  3  0.23 Good      E     VS1      56.9    65   327  4.05  4.07  2.31
    ##  4  0.29 Premium   I     VS2      62.4    58   334  4.2   4.23  2.63
    ##  5  0.31 Good      J     SI2      63.3    58   335  4.34  4.35  2.75
    ##  6  0.24 Very Good J     VVS2     62.8    57   336  3.94  3.96  2.48
    ##  7  0.24 Very Good I     VVS1     62.3    57   336  3.95  3.98  2.47
    ##  8  0.26 Very Good H     SI1      61.9    55   337  4.07  4.11  2.53
    ##  9  0.22 Fair      E     VS2      65.1    61   337  3.87  3.78  2.49
    ## 10  0.23 Very Good H     VS1      59.4    61   338  4     4.05  2.39

1.  Load the tidyverse package with `library(tidyverse)` to obtain the
    full data set. Get an overview of the data set with the commands
    `names(diamonds)` and `View(diamonds)`.

2.  Try to obtain all exemplars (rows) that have an ideal cut. First try
    to use the matrix notation together which the function `which`. Then
    visit the help pages for the function `filter` from the *dplyr*
    package that is attached to the *tidyverse*. Use the filter function
    to solve the problem and also play a bit around with *dplyr*’s
    function `select`.
