Introduction to Bayesian Data Analysis
================

*Last update*: 2023-07-05

# General Information

*Class hours*: Wednesdays, 9:45 am - 1 pm ([Room
0514](https://portal.mytum.de/campus/roomfinder/roomfinder_viewmap?mapid=193&roomid=0514@0505))

*Office hours*: Tuesdays, 2 pm - 3 pm ([Room
2531](https://portal.mytum.de/campus/roomfinder/roomfinder_viewmap?mapid=196&roomid=2531@0505))

*E-Mail*: <linus.hof@tum.de>

*General announcements*: Will be made
[here](https://www.moodle.tum.de/mod/forum/view.php?id=2429843). (*Make
sure to turn on the Moodle notifications.*)

*Materials*: Can be found
[here](https://github.com/linushof/BayesIntro).

*Communication*: In class and written communication, just call me Linus.
For data protection reasons, please use your TUM E-Mail when writing me.
Questions of general interest can be posted and discussed in the Moodle
forums
[*Contents*](https://www.moodle.tum.de/mod/forum/view.php?id=2569419)
and
[*Organization*](https://www.moodle.tum.de/mod/forum/view.php?id=2569420).

# Schedule

*Check regularly for updates!*

<table style="width:99%;">
<colgroup>
<col style="width: 7%" />
<col style="width: 36%" />
<col style="width: 42%" />
<col style="width: 12%" />
</colgroup>
<tbody>
<tr class="odd">
<td><h3 id="date">Date</h3></td>
<td><h3 id="topic">Topic</h3></td>
<td><h3 id="homework1">Homework<a href="#fn1" class="footnote-ref"
id="fnref1" role="doc-noteref"><sup>1</sup></a></h3>
<h3 id="section"></h3></td>
<td><h3 id="assignment2">Assignment<a href="#fn2" class="footnote-ref"
id="fnref2" role="doc-noteref"><sup>2</sup></a></h3></td>
</tr>
<tr class="even">
<td>19 April</td>
<td>Intro</td>
<td></td>
<td></td>
</tr>
<tr class="odd">
<td>26 April</td>
<td>Scientific data analysis as amateur software development</td>
<td><ul>
<li><p>Read <span class="citation"
data-cites="bryanExcuseMeYou2018">Bryan (2018)</span></p></li>
<li><p>Install <code>R</code>, <code>RStudio</code>,
<code>Git</code></p></li>
<li><p>Create <code>GitHub</code> account</p></li>
</ul></td>
<td></td>
</tr>
<tr class="even">
<td>03 May</td>
<td>Cancelled</td>
<td></td>
<td></td>
</tr>
<tr class="odd">
<td>10 May</td>
<td>Scientific inference and Bayesian updating</td>
<td><ul>
<li>Read <span class="citation"
data-cites="kruschkeBayesianDataAnalysis2018">Kruschke and Liddell
(2018)</span></li>
<li>Solve sheet: <code>session_2_exercise.Rmd</code></li>
<li>Create new <code>GitHub</code> repo and sync with RStudio</li>
</ul></td>
<td>Assignment 1</td>
</tr>
<tr class="even">
<td>17 May</td>
<td>Workflow for Bayesian parameter estimation</td>
<td><ul>
<li>Read <span class="citation"
data-cites="gabryVisualizationBayesianWorkflow2019">Gabry et al.
(2019)</span></li>
</ul></td>
<td></td>
</tr>
<tr class="odd">
<td>24 May</td>
<td>Linear models Part 1</td>
<td><ul>
<li><p>Install <code>RStan</code> and the <code>rethinking</code>
package</p>
<p><a
href="https://github.com/stan-dev/rstan/wiki/RStan-Getting-Started"
class="uri">https://github.com/stan-dev/rstan/wiki/RStan-Getting-Started</a></p>
<p><a href="https://github.com/rmcelreath/rethinking"
class="uri">https://github.com/rmcelreath/rethinking</a></p></li>
<li><p>Install <code>JASP</code></p></li>
</ul></td>
<td>Assignment 2</td>
</tr>
<tr class="even">
<td>31 May</td>
<td>Linear models Part 2</td>
<td></td>
<td></td>
</tr>
<tr class="odd">
<td>07 June</td>
<td>Markov Chain Monte Carlo Methods</td>
<td><ul>
<li>Read <span class="citation"
data-cites="vanravenzwaaijSimpleIntroductionMarkov2018">van Ravenzwaaij,
Cassey, and Brown (2018)</span></li>
</ul></td>
<td>Assignment 3</td>
</tr>
<tr class="even">
<td>14 June</td>
<td>Multilevel models Part 1</td>
<td></td>
<td></td>
</tr>
<tr class="odd">
<td>21 June</td>
<td>Multilevel models Part 2</td>
<td></td>
<td></td>
</tr>
<tr class="even">
<td>28 June</td>
<td>No session</td>
<td></td>
<td></td>
</tr>
<tr class="odd">
<td>05 July</td>
<td>Generalized linear models</td>
<td></td>
<td>Assignment 4</td>
</tr>
<tr class="even">
<td>12 July</td>
<td>Model comparison</td>
<td><ul>
<li>Read <span class="citation"
data-cites="navarroDevilDeepBlue2019">Navarro (2019)</span></li>
</ul></td>
<td></td>
</tr>
<tr class="odd">
<td>19 July</td>
<td>Outro and Evaluation</td>
<td></td>
<td></td>
</tr>
</tbody>
</table>
<section id="footnotes" class="footnotes footnotes-end-of-document"
role="doc-endnotes">
<hr />
<ol>
<li id="fn1"><p>Homework should be completed by the start of the
respective session.<a href="#fnref1" class="footnote-back"
role="doc-backlink">↩︎</a></p></li>
<li id="fn2"><p>Assignments start at the end of the respective session
and should be completed by the start of the subsequent session (9:45
am).<a href="#fnref2" class="footnote-back"
role="doc-backlink">↩︎</a></p></li>
</ol>
</section>

# Homework, Assignments and Other Hassles

### Homework

I’m a fan of homework because it helps you learn. Learning comes from
*repetition* and *exercise*. Chances are high that you forget at least
some of the things we cover and practice in class if you don’t review
and practice them. Since we’ll continuously be progressing, forgetting
is undesirable at this point. One purpose of the homework is therefore
repetition by exercise. Actively engaging in the exercises also allows
you to track and celebrate the progress you made so far and to uncover
remaining problems. Not everything will be clear right away - use the
problems during exercise to figure out where you should take a step back
and reiterate.

Another purpose of homework is *preparation*. Learning is most effective
when done without distractions. Distractions like missing software keep
you busy while causing you to lose focus on what you are here for in the
first place - the analysis part. Therefore, you’ll occasionally be asked
to set up your software environment in advance to be prepared for the
next analysis steps. Lastly, when learning something completely new, it
can sometimes be a lot at once. To reduce the bulk of new information
that comes at a time, you’ll sometimes be asked to read a short paper
that teases some new ideas we’ll cover in the upcoming session(s). This
gives you some edge and the opportunity to form an expectation that
helps you navigate more easily through the sessions.

### Assignments and Grade

I’m not a big fan of graded assignments because they suggest that a
learning process is finished and can be captured in just a number. This
is almost never the case. However, grades can be informative and
rewarding to some extent. Here, assignments will be naturally integrated
in the course as small milestones down the road. They will look a lot
like the homework in that they take the form of little coding and
analysis exercises. Specifically, assignments consists of a
questionnaire alongside a submitted analysis script (e.g., `script.R`)
that produced the answers. We will have 4 assignments, where the 3 best
assignments are weighted equally to obtain the overall course grade.

### Attendance

You won’t be forced to attend the classes - ultimately, it’s your
decision to be here. Also, life can be difficult at times and there is a
chance that you won’t manage to attend all sessions for good reasons.
Don’t worry about that: You can check the slides, examine the code, talk
to the other students, ask questions, and be certain that core ideas
will be reiterated in the next session. That said, I strongly recommend
to come to the class whenever you can. The slides and scripts won’t be
comprehensive summaries of the sessions and the hands-on exercises are
considered an integral part of this course. In the end, sustainable
learning takes time and requires to overcome challenge by challenge.
Take this course as an opportunity to stay persistent and to learn in a
structured and collaborative manner.

### Resources

<div id="refs" class="references csl-bib-body hanging-indent">

<div id="ref-bryanExcuseMeYou2018" class="csl-entry">

Bryan, Jennifer. 2018. “Excuse Me, Do You Have a Moment to Talk about
Version Control?” *The American Statistician* 72 (1): 20–27.
<https://doi.org/10.1080/00031305.2017.1399928>.

</div>

<div id="ref-gabryVisualizationBayesianWorkflow2019" class="csl-entry">

Gabry, Jonah, Daniel Simpson, Aki Vehtari, Michael Betancourt, and
Andrew Gelman. 2019. “Visualization in Bayesian Workflow.” *Journal of
the Royal Statistical Society Series A: Statistics in Society* 182 (2):
389–402. <https://doi.org/10.1111/rssa.12378>.

</div>

<div id="ref-kruschkeBayesianDataAnalysis2018" class="csl-entry">

Kruschke, John K., and Torrin M. Liddell. 2018. “Bayesian Data Analysis
for Newcomers.” *Psychonomic Bulletin & Review* 25 (1): 155–77.
<https://doi.org/10.3758/s13423-017-1272-1>.

</div>

<div id="ref-navarroDevilDeepBlue2019" class="csl-entry">

Navarro, Danielle J. 2019. “Between the Devil and the Deep Blue Sea:
Tensions Between Scientific Judgement and Statistical Model Selection.”
*Computational Brain & Behavior* 2 (1): 28–34.
<https://doi.org/10.1007/s42113-018-0019-z>.

</div>

<div id="ref-vanravenzwaaijSimpleIntroductionMarkov2018"
class="csl-entry">

van Ravenzwaaij, Don, Pete Cassey, and Scott D. Brown. 2018. “A Simple
Introduction to Markov Chain Monte Sampling.” *Psychonomic Bulletin &
Review* 25 (1): 143–54. <https://doi.org/10.3758/s13423-016-1015-8>.

</div>

</div>
