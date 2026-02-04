Recent Changes in Execucomp:
FAS 123 New reporting requirements

Objective

• Learn about New ExecuComp content and structure due to

the new FASB123 reporting requirements.
– The changes affect companies with fiscal year end  after Dec 2005.

Hence, for year 2006 not all companies have already reported in the
new format (i.e.MSFT) and the two reporting formats coexist.

On ExecuComp

• Universe: 2,872 companies both active or inactive. S&P 1500 plus

companies removed from the index but still trading.

• Data is collected from each company annual proxy DEF14A, which must be

filed 120 days after the company’s fiscal year end.

• How many executives?

Up to 9, though most companies only report 5.

• How are they identified?

EXECID is permanent id for each executive through out her career.
CO_PER_ROL identifies executive/company combination.

• Data on executives:

– Individual characteristics: title, age, gender, date became/left as CEO.
– Compensation: Salary, Bonus, Restricted Stock Awards, Option Awards, Non‐

Equity Incentive Plan, Deferred Compensation, Pension Plan.

– Shares Owned.

• Data on directors’ compensation (new!).

New Reporting Requirements FAS 123

•

FAS 123 (R) :
Equity based compensation has to be expensed and be reflected in the financial
statements based on fair value of the awards.
Companies with fiscal year end  after Dec 2005 have to adjust to new rules.
All data available in the past continues to be available; NO info has been purged.

• DEF14A (SEC doc) is organized in 6 new tables:

1.

Summary Compensation: discloses salary, bonus, stock awards, option awards, change
in pension value other compensation. Option exercises and Stock vested.

2. Plan Based Table: contains details on option awards, restricted stock awards,  and

estimated payouts for equity and non‐equity incentive plans.

3. Outstanding awards Table: information on unexercised options, stock that has not

vested and equity incentive plan awards outstanding.

4. Deferred Compensation Table: reports the executive or company contributions,
earnings and withdrawals and account balances for the deferral programs.

5. Pension Benefits Table: information regarding each plan of the company that provides

payments in connection with retirement.

6. Directors compensation Table: fees, stock and options awards, non‐equity incentive

plan

ExecuComp Structure for 2006 fiscal year

•

For year 2006, Execucomp data is delivered in 6 main tables, mapping the
“original” tables in the SEC doc.
1. AnnComp: summary compensation data + other.
2. PlanBasedAwards : Contains data on awarded options and stock grants

during the filled fiscal year.

3. OutstandingAwards: Describes the outstanding stock options and unvested

stock awards held by officers as of the end of fiscal year.

4. DeferredComp: contains deferred compensation.
5. Pension: contains all details on pension benefits.
6. DirectorComp: contains new details on the director compensation.

• Prior to 2006,  the reporting of stock option grants and long incentive
plans are in the following two tables – the data goes up to 2005.
1. Stgrttab: Stock Options Grants.
2. Ltawdtab: Long Term Incentive Plan Awards.

ExecuComp in WRDS

• The web‐query now presents the data in several queries:
(cid:153) Aggregate compensation items: salary, bonus, total options…
(cid:153) Disaggregate compensation items:

–
–
–
–

Individual options and preferred stock granted and outstanding.
Individual deferred plans.
Individual pension plans.
Directors compensation.

• Datasets in WRDS Unix: /wrds/comp/sasdata/execcomp/

All sets provided by Compustat are available, plus the aggregate file

created by WRDS.

Two Main Questions

1.

How are the main aggregated compensation items affected?

2.

Stock‐based compensation: how to identify a unique row. Difference
between the aggregated and disaggregated data for restricted stock
awards and option awards.

1. Old Compensation Items

• Pre FAS 123:  The variables TDC1 & TDC2 were the two most

encompassing compensation measures. There is continuity with these
measures but the definition has changed slightly.

– Using the 1992 format: TDC1= Salary +Bonus+ Other Annual + Total

Value Restricted Stock granted + Total Value Stock Options granted +
Long‐Term Incentive Payouts + All Other Total

– Using the 2006 format: TDC1= Salary + Bonus + Non‐Equity Incentive
Plan Compensation + Grant‐Date Fair Value Stock Awards + Grant‐
date fair Value of Option Awards + Deferred Compensation + Other
Comp.

1. New Compensation Items: FAS 123(R)

• New compensation items are reported by companies. Hence only

available from 2006 onwards.
– TOTAL_SEC, Total Compensation as Reported to SEC: Salary, Bonus, Stock
Awards, Option Awards, Non Equity Incentives, Pension and Deferred
Compensation Changes, Other Comp.

(cid:190) Cost recorded by the company on its income statement.

– Total_ALT1:  same definition as TOTAL_SEC  except that stock & options are

valued using grant‐date fair value .
(cid:190) Compensation as of grant date.

– Total_ALT2: same definition as TOTAL_SEC except that stock & options are
valued using stock vesting (SHRS_VEST_VAL) and value realized from option
exercise (OPT_EXER_VAL).
(cid:190) Actual compensation.

2. Stock‐based Compensation Items

Firms may grant options and restricted stock several times a year. Hence,
this type of compensation is delivered at an aggregated or disaggregated
level.

• Aggregated variables:  1 record per (firm, co_per_rol, year)
• Disaggregated variables: produce several records for (firm, co_per_rol,

year). Need to add ID variable.

(cid:190) Before FAS 123: GRNTNUM allows to identify each option grant.
(cid:190) FAS 123 : Plan Based Awards table contains all disaggregated data.
GRNTNUM applies to all types of awards reported in the table: i.e.
shares , equity and non‐equity incentive plan awards and options.
And  all of these plans can have several instances.

2. Stock‐based Compensation: Options

•

Stock options awarded during the fiscal year
(cid:190) OPTION_AWARDS_BLK_VALUE (before FAS 123)
(cid:190) OPTION_AWARDS_FV (FAS 123, i.e. data from 2006 onwards)
At company level?
Companies do not report all stock options awarded to all employees.
From the DEF14A filling can only be computed for executives.

• Options exercised during the fiscal year:
– OPT_EXER_NUM  & OPT_EXER_VAL

• Options outstanding:

– OPT_UNEX_EXER_EST_VAL: Estimated value of in the money

unexercised vested options.  (OPT_UNEX_EXER_NUM)

– OPT_UNEX_UNEXER_EST_VAL : Estimated value of in the money

unexercised unvested options. (OPT_UNEX_UNEXER_NUM)

Aggregated and Individual Options Data – Before FAS 123
Data from 1992‐2005 plus few companies still reporting old format for 2006 fiscal
year.
Available via Web‐query. All data items in Execcomp.

Aggregated Options data

Individual Option data

CO_PER_R
OL

SALARY

OPTION_AWA
RDS_NUM

OPTION_AWA
RDS_BLK_VAL
UE

OPTION_AW
ARDS_RPT_
VALUE

GRNTN
UM

NUMSECU
R

BLKSHVAL EXEC_LNAME YEAR

28409
28409
30178
30178
32109
32109
32109
32110
32110

375
375
365.28
365.28
265.035
265.035
265.035
263.333
263.333

106.251
106.251
173.334
173.334
56.25
56.25
56.25
510.417
510.417

293.073
293.073
401.205
401.205
130.28
130.28
130.28
1217.435
1217.435

66.227
66.227
291.137
291.137
94.413
94.413
94.413
1036.274
1036.274

1
2
1
2
1
2
3
1
2

66.667
39.584
73.334
100
40
12.25
4
160.417
350

157.584 Jaworski
135.489 Jaworski
164.831 Whiting
236.374 Whiting
85.078 Deranleau
32.618 Deranleau
12.584 Deranleau

360.566 Grewal
856.869 Grewal

2006
2006
2006
2006
2006
2006
2006
2006
2006

OPTION_AWARDS_NUM: Total number of stock options awarded during the year, as detailed in Plan Based awards.
OPTION_AWARDS_BLK_VALUE: Aggregate value of stock options granted during the year –valued  using S&P Black‐Scholes
Methodology. Applies to 1992 reporting format only. (OPTION_AWARDS_FV  for FASB123 reporting)
OPTION_AWARDS_RPT_VALUE: Aggregate value for all options granted during fiscal year as valued by company. Applies to 1992
reporting forma t only.

GNTNUM: Grant Number Identifier (Stgrttab).
NUMSECUR: Number of securities in the option grant. Applies to 1992 only.  (Stgrttab).
BLKSHVAL: Value of the option grant using the S&P modified Black‐Scholes Method. Applies to 1992 reporting format only
(Stgrttab).

Aggregated and Individual Options Data – FAS 123
Data for 2006 fiscal year only.  Aggregated data available through Web‐query.
Individual option data in Planbasedawards dataset.

Details on individual options granted are reported in  Plan Based Awards table.

Estimated Future
Payouts Under Equity
Incentive Plan Awards (a)

Date
Approved by
Compensation
Committee

Target
(#)

Maximum
(#)

Al l Other
Option
Awards:
Number of
Securities
Underlying
Options (#)
OPTS_GRT

Exercise or
Base Price
of Option
Awards
($/SH) (b)

Closing
Market
Price on
Grant Date

12/07/05
12/07/05
04/24/02
04/28/04
12/07/05
12/07/05
12/07/05
12/07/05
12/04/02
12/07/05
12/07/05
04/30/03
12/07/05
12/07/05
12/07/05
12/07/05

25,140

50,280

12,233

7,551

24,466

15,102

7,551

15,102

6,872

3,460

13,744

6,920

$
196,058
277,637 (c) $
167,004 (c) $

57.81 $
56.43 $
56.43 $

46,990

$

57.81 $

$
29,003
31,771 (c) $

29,003
$
17,799 (c) $

26,395

13,289

$

$

57.81 $
58.83 $

57.81 $
55.84 $

57.81 $

57.81 $

Grant Date
Fai r Value
of Stock
and
Option
Awards
FAIR_VALUE
$ 2,906,687
57.51 $ 2,950,673
56.64 $ 3,555,001
56.64 $ 2,138,402
$ 1,414,379
57.51 $ 707,200
$ 873,047
57.51 $ 436,495
59.05 $ 423,225
$ 873,047
57.51 $ 436,495
56.42 $ 225,857
$ 794,541
57.51 $ 397,245
$ 400,045
57.51 $ 199,999

Name

H. McGraw III

R. J. Bahash
D. Sharma

D. L. Murphy

K. M. Vittor
B. D. Marcus

Grant
Date

   4/3/06
   4/3/06
   3/23/06
   3/23/06
   4/3/06
   4/3/06
   4/3/06
   4/3/06
   3/16/06
   4/3/06
   4/3/06
   3/14/06
   4/3/06
   4/3/06
   4/3/06
   4/3/06

GRNT_NUM: Identifies entry in table. Hence it can refer to any Equity and non‐equity plan! No longer count for
number of options grants.
When OPTS_GRT > 0, then entry corresponds to option grant.
OPTS_GRT: Number of stock options granted
Fair_Value: Grant date Fair value of stock and option Awards.

SUM(OPTS_GRT)=  OPTIONS_AWARDS_NUM    Total number of stock options awarded during the year.
SUM(FAIR_VALUE)= OPTIONS_AWARDS_FV       Aggregate value of stock options granted during the year.

2. Stock Based Compensation: Restricted Stock

• Restricted Stock awarded during the fiscal year

(cid:190) RSTKGRNT (before FAS 123, only applies for 1992 format)
(cid:190) STOCK_AWARDS_FV (FAS 123, i.e. data from 2006 onwards)
Stock vested during the fiscal year:
– SHRS_VEST_NUM  & SHRS_VEST_VAL

•

• Restricted Stock Outstanding :

– STOCK_UNVEST_VAL : Aggregate market value of restricted shares

held by executive (STOCK_UNVEST_NUM)

• All details on the stock awarded is contained in the Plan based table.

