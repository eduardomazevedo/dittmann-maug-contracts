# Some key parts of original paper that describe contracts considered and data construction
## Contract specification
Permissible Contracts. We initially assume that the contract can be described
 by three parameters, namely a base salary 0, the number of shares in the
 company ns (expressed as a fraction of all shares outstanding), and the number
 of options on the company's stock no (also expressed in terms of the number of
 shares outstanding). We further assume that all options granted to the CEO
 have identical maturity T and strike price K. Below we discuss extensions of our
 base model to allow for multiple strike prices. The strike price K is expressed
 as the strike price for no = 1, that is, for the whole company. We denote by Wo
 the wealth of the CEO that is not invested in the firm's securities as of time
 t = 0 and refer to it as "nonfirm wealth." We assume that she invests all her

 nonfirm wealth at the risk-free rate rf, so her end-of-period wealth (at date T)
 is

 WT = (0 + Wo)exp{rf T} + nsPT(u, e) + no max{PT(u,e) - K, 0). (2)

 Note that this specification implicitly assumes that base pay (including bonus
 payments) is paid out today and invested, while all other components of pay
 lead to cash flows to the CEO at date T.

 ## Data section
  B. Data Set

 To implement (16), we need data on the contract parameters 0d, nd, and

 no, the CEO's wealth Wo, the firm value Po, the dividend yield d, the option
 maturity T, the strike price K, the stock volatility a, and the risk-free rate rf.
 Our data are constructed from the Compustat ExecuComp Database, which
 contains compensation data on 21,086 executives from 2,448 firms over the
 period 1992 to 2000. We first identify all executives in the database who are
 CEO in 2000 and have a continuous history (as CEO or as another executive
 with data on ExecuComp) of at least 5 years (1995 to 1999) in the database.
 We focus on CEOs in order to prevent correlations due to multiple observations
 from the same firm.

 We match Po to the market capitalization at the 1999 fiscal year-end and

 take the 1999 values of the dividend yield d and the volatility a directly from
 the database. The fixed salary qd is determined as the sum of salary and bonus



 in 2000 and includes all types of compensation other than stock and options.19
 Hence, we implicitly assume that bonus payments have no relevance for the
 CEO's incentives.20 We only use current-period data to estimate od. This ignores
 the fact that the CEO receives base salary payments every year between now
 and T. Incorporating this feature would have the same numerical impact as an
 increase in nonfirm wealth Wo, which we study below. We therefore abstract
 from this feature.

 The variables nd and nd are the numbers of shares and options, respectively,
 held by the CEO at the end of the 1999 fiscal year. ExecuComp does not provide
 details of all option parameters, so we approximate the option portfolios held
 at the end of 1999 using the algorithm described by Core and Guay (2002a). Ac-
 cording to this algorithm, we approximate options granted before 1999 by two
 hypothetical option grants that are calculated from information on exercisable
 and unexercisable options. We add the options granted in 1999 to these two
 hypothetical option grants in order to arrive at an estimate of the option port-
 folio held at the end of the 1999 fiscal year. Then we calculate the exercise price
 K and the maturity T of a representative option that aggregates the salient
 features (value and sensitivity to price) of the CEO's option portfolio. We refer
 the reader to Appendix B for further details. Appendix B also describes the
 procedure we use to estimate nonfirm wealth from the CEO's past income.21
 Below we perform robustness checks in order to establish that our results do
 not depend on potential estimation errors.

 From the initial 1,696 CEOs in 2000, we lose 103 CEOs for whom necessary

 data items (stock volatility in 1999 or adjustment factor) are missing, and 886
 CEOs due to the 5-year history requirement.22 The 5-year cutoff provides a rea-
 sonable balance between the accuracy of our estimates and sample size.23 An-
 other 27 CEOs are lost because they are executives in more than one company
 in at least 1 year of their history. For the remaining 680 CEOs we estimate their
 option portfolio and their wealth from the ExecuComp database as described
 in Appendix B. At this stage, we lose 17 CEOs because of inconsistent or miss-
 ing data on their option holdings, and 65 CEOs because our wealth estimate is
 negative, which can happen if the amounts deducted for the purchase of stock
 are large. Our final sample satisfying all our data requirements consists of 598

 19 More precisely, 0d is the sum of the following four ExecuComp data types: Salary, Bonus,

 Other Annual, and All Other Total. We do not include LTIP (long-term incentive pay), as these are
 typically not awarded annually.

 20 This seems defensible. Hall and Liebman (1998) argue that the impact of stock options and

 stock on CEO wealth dwarfs the impact of bonus payments.

 21 The only study we know of that uses an estimate of wealth is Becker (2006), who uses a

 Swedish data set based on tax filings. No such information is available for the U.S.

 22 We do not require that the CEOs have been the acting CEO during the entire 5 years. We only

 require that they be CEO in 2000.

 23 If we required instead 8 years of continuous history, we would retain only 360 CEOs compared
 to our current sample of 598. By shortening the length of continuous history, we bias our wealth
 estimates downward. Indeed, requiring an 8-year history would increase our median estimate of
 Wo by 27% (mean: 21%). We compensate for this bias with appropriate robustness checks (see
 Section V).



 Table I

 Description of the Data Set

 This table displays the mean, median, standard deviation, minimum, and maximum of 12 variables.
 Panel A describes our sample of 598 U.S. CEOs. Panel B describes all 1,417 executives who are CEO
 in 2000 according to the ExecuComp database. Panel B also contains the statistic of the two-sample
 t-test for equal means (allowing for different variances). Before calculating this statistic, we remove
 all observations from the sample in Panel B that are also contained in the sample in Panel A.

 Panel A: Data Set with 598 U.S. CEOs

 Variable Symbol Mean Median Std. Dev. Minimum Maximum

 Base salary ($ '000) 2,037 1,261 2,57 97 22,109
 Stock (%) ns 2.29% 0.29% 6.00% 0.00% 46.34%
 Options (%) no 1.29% 0.84% 1.82% 0.00% 24.32%
 Options adjusted (%) noexp{-dT) 1.22% 0.76% 1.79% 0.00% 24.32%
 Value of stock ($ m) nsPo 91.98 6.62 571.95 0.00 11,814.08
 Value of options ($ m) noBS 29.47 6.11 104.42 0.00 1,334.43
 Market value ($ m) Po 9,857 1,668 27,845 7 280,114
 Wealth ($ m) Wo 34.60 6.86 234.79 0.03 5,431.72
 Option delta N(dl) 0.834 0.856 0.126 0.001 1.000
 Maturity (years) T 5.89 5.54 1.96 1.20 22.18
 Volatility a 0.377 0.335 0.196 0.136 3.487
 Age of CEO 57 57 7 36 84

 Panel B: All 1,417 ExecuComp CEOs in 2000

 Variable Symbol Mean Median Std. Dev. Min. Max. t-Test statistic

 Base salary ($ '000) 0 1,718 1,059 3,150 0 90,000 3.43
 Stock (%) ns 2.97% 0.35% 6.78% 0.00% 56.42% -3.32
 Options (%) no 1.45% 0.96% 1.88% 0.00% 27.93% -2.74
 Value of stock ($ m) nsPo 132.44 6.45 1,385.87 0.00 47,838.75 -1.07
 Market value ($ m) P0 8,012 1,256 27,551 7 508,329 2.15
 Stock price volatility a 0.435 0.384 0.205 0.136 3.487 -9.36
 Age of CEO 55 55 8 29 86 7.41

 CEOs, of which 21 (3.5%) have no options in their compensation package, and
 254 (42%) have options on more than 1% of their company.

 Table I, Panel A provides descriptive statistics for the main parameters and

 Table I, Panel B displays similar statistics for the larger group of executives in
 the ExecuComp database who are CEO in 2000. We need to adjust the number
 of options for dividend payments because the CEO receives no options on a
 share with end-of-period value PT exp(-dT) and ns shares with end-of-period
 value PT. In order to render our statements on stock holdings and option hold-
 ings comparable, we refer to ns as the number of shares and to no exp(-dT)
 as the number of options. (See also footnote 12.) While the CEOs in our sample
 are similar with respect to the value of their stock holdings, our data require-
 ments have a tendency to exclude CEOs with more options (mean of 1.3% in
 the sample, 1.5% in ExecuComp) and lower salaries (mean of $2 million in the



 sample, $1.7 million in ExecuComp). Also, CEOs in our sample are somewhat
 more experienced (age 57 in our sample, 55 in the database). Finally, note that
 the stock volatility is lower in our sample (38%) than in the full ExecuComp
 database (44%). In view of our results, the sample is biased in favor of the model:
 The savings from recontracting predicted by our model are higher for higher
 volatility, higher option holdings, and younger, less wealthy CEOs. We would
 therefore expect even stronger results if we could establish reliable parameter
 estimates for the larger sample.