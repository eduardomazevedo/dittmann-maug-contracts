# Data Construction Explained: A Manual Guide for Verification

**Purpose:** This document breaks down the critical parts of the Dittman & Maug (2007) data construction methodology in plain language so you can manually verify our Python implementation matches the original logic.

**Related Files:**
- `docs/dittman-maug-code/Dataset Construction Macro V4.sas` - Original SAS code
- `docs/references/dittman-maug-2007.md` - Original DM paper in markdown.

---

## Part 1: DM's parametrization of contracts

### What We're Trying to Do

The researchers want to model CEO wealth as a **function of firm performance**:

$$W_T = f(P_T; \text{contract parameters})$$

Where:
- **$W_T$** = CEO's end-of-period wealth (what they're worth at the end of the year)
- **$P_T$** = Stock price at end of period
- **Contract parameters** = Things the firm can control (salary, shares, options)

### The Wealth Formula

$$W_T = (\phi + W_0) \cdot e^{rf \cdot T} + n_s \cdot P_T + n_o \cdot \max(P_T - K, 0)$$

**Plain English Breakdown:**

1. **$(\phi + W_0) \cdot e^{rf \cdot T}$** - "Safe money that grows"
   - $\phi$ = Salary + Bonus for the year (guaranteed, risk-free)
   - $W_0$ = CEO's outside wealth (savings, other investments)
   - $e^{rf \cdot T}$ = Growth factor at risk-free rate over time $T$
   - **This part doesn't depend on stock price** - it's guaranteed

2. **$n_s \cdot P_T$** - "Money from shares they own"
   - $n_s$ = Fraction of total shares the CEO owns (e.g., 0.005 = 0.5%)
   - $P_T$ = Stock price at end of year
   - If stock goes up, this goes up; if it goes down, this goes down
   - **This part is at-risk**

3. **$n_o \cdot \max(P_T - K, 0)$** - "Money from stock options"
   - $n_o$ = Number of options the CEO holds (as fraction of total shares)
   - $\max(P_T - K, 0)$ = Option payoff (only profit if stock > strike price)
   - $K$ = Strike price (exercise price)
   - **This part is also at-risk and nonlinear** (doesn't make money until stock exceeds $K$)

---

## Part 2: Data Sources - Where Everything Comes From

### The Three Data Tables

All data comes from **ExecuComp** (ExecuComp is a database of executive compensation):

| Table | Contains | Used For |
|-------|----------|----------|
| **AnnComp** | Annual compensation (salary, bonus, stock grants, option grants) | Salary, bonus, LTI payouts, RSU values |
| **CoDirFin** | Director/company financials (stock price, dividend yield, volatility) | $P_0$, $d$, $\sigma$ |
| **StGrtTab** | Stock grant details (option grants with strike prices, maturity) | Option details for aggregation |

### Time Periods: Very Important!

**Key Concept:** We construct data for a **measurement year** (e.g., 2000) based on data from the **measurement year AND prior years**.

Example for year **2000**:
- **Measurement Year:** 2000 (the year we're analyzing)
- **Reference Year:** 1999 (fiscal year-end before measurement year starts)
  - Stock price $P_0$ comes from fiscal year-end **1999**
  - Dividend yield comes from fiscal year-end **1999**
  - Volatility comes from fiscal year-end **1999**
  - **This is why variables have "_a" suffix** (adjusted/year-before reference)
- **History:** All data from 1995-1999 (5 prior years)
  - Used to calculate $W_0$ (accumulated wealth)
  - Used to check CEO continuity (hasn't left the firm)

---

## Part 3: The Six Key Variables

### Variable 1: $\phi$ (Base Salary + Bonus + Some Other Compensation)

**What it represents:** Guaranteed, fixed compensation

**Formula from SAS code (line 564-566):**
```
phi = salary + bonus + othann + allothtot
```

**ExecuComp variables:**
- `salary` - Base salary
- `bonus` - Annual bonus (cash)
- `othann` - Other annual compensation (perks, etc.)
- `allothtot` - All other total (miscellaneous)

**IMPORTANT - What's NOT included:**
- **NOT `ltip`** (Long-Term Incentive Plan payouts) - This is treated separately in $W_0$ calculation
- **NOT value of option grants** - Options are handled separately
- **NOT value of stock grants** - Grants are handled separately

**Why this matters:** We want to separate the **guaranteed** part of pay ($\phi$) from the **at-risk** parts (shares, options). The firm can guarantee $\phi$ no matter what the stock does.

**Verification Check:**
```
✓ Is salary + bonus the main component?
✓ Are option grants excluded?
✓ Are stock grants excluded?
```

---

### Variable 2: $P_0$ (Market Value of the Firm)

**What it represents:** Total dollar value of the company at fiscal year-end (before the measurement year)

**Formula (SAS lines 543-544):**
```
P0 = price_fiscal_yearend * shares_outstanding

Where:
  price = prccf / ajex  (adjust for stock splits)
  shares = shrsout * 1000 * ajex  (convert to individual shares, adjust for splits)
```

**In plain English:**
- Get the stock **price** on the last day of the fiscal year
- Multiply by the **number of shares outstanding**
- Adjust both for any **stock splits** that happened

**Example:**
- Stock price on 12/31/1999: $50
- Shares outstanding: 100 million
- Stock split adjusted: $50 × 100M = $5 billion firm value

**Verification Check:**
```
✓ Is this from fiscal year-end (1999 for measurement year 2000)?
✓ Are stock splits accounted for?
✓ Is it total firm value, not per-share?
```

---

### Variable 3: $d$ (Dividend Yield)

**What it represents:** Annual dividend as a percentage of stock price

**Formula (SAS line 547):**
```
d = divyield / 100
```

**Simple:** ExecuComp provides `divyield` as a percentage (e.g., 2.5), we convert to decimal (0.025)

**Why it matters:**
- Used in Black-Scholes option pricing
- If CEO owns shares, dividends are part of their returns
- Higher dividends = lower option value (less upside potential)

**Example:**
- ExecuComp reports: `divyield = 2.5` (2.5%)
- We calculate: `d = 0.025`

**Verification Check:**
```
✓ Is dividend yield from ExecuComp divyield field?
✓ Is it converted to decimal form (divide by 100)?
✓ Is it around 0-5% typically?
```

---

### Variable 4: $\sigma$ (Stock Volatility)

**What it represents:** 60-month historical stock volatility, annualized

**Formula (SAS lines 177, 546):**
```
sigma = bs_volatility
```

**Simple:** ExecuComp already provides this; we just use it directly

**Important detail:** ExecuComp calculates `bs_volatility` using:
- 60 months of prior stock returns
- Annualized to percentage form
- Already in the form needed for Black-Scholes

**Why it matters:**
- Measures stock **risk/uncertainty**
- Higher volatility = options are more valuable
- Different from actual stock return volatility; this is what ExecuComp pre-calculated

**Example:**
- ExecuComp reports: `bs_volatility = 0.45` (45% annualized volatility)
- We use: `sigma = 0.45`

**Verification Check:**
```
✓ Is this from ExecuComp bs_volatility field?
✓ Is it typically 0.20 - 0.80 (20-80%)?
✓ Is it already in decimal form (not percentage)?
```

---

### Variable 5: $rf$ (Risk-Free Rate)

**What it represents:** Interest rate on US government bonds, used as discount rate

**How it's set (SAS lines 553-559):**
```
For year 2000 (measurement year), use 6-year Treasury yield from January 2000
rf = 0.0664  (6.64%)
```

**Why 6-year?** The average option maturity is ~6 years, so use 6-year Treasury rate

**Hardcoded by year:**
- Year 1992: rf = 0.0340
- Year 1999: rf = 0.0545
- Year 2000: rf = 0.0664
- etc.

**Why it matters:**
- Used to discount future cash flows in Black-Scholes
- Used to grow $W_0$ forward to future value
- Higher rates → lower option value

**Verification Check:**
```
✓ Is rf set to the appropriate Treasury yield for the measurement year?
✓ Is it in decimal form (0.0664 not 6.64)?
✓ Does it match historical Treasury rates for that year?
```

---

### Variable 6: $n_s$ (Fraction of Shares Held by CEO)

**What it represents:** CEO's shares as a percentage of total shares

**Formula (SAS lines 538-539):**
```
ns = shrown_adjusted / shrsout_adjusted

Where:
  shrown_adjusted = shrown * ajex  (CEO shares, adjusted for stock splits)
  shrsout_adjusted = shrsout * 1000 * ajex  (all shares, adjusted for stock splits)
```

**In plain English:**
```
ns = (number of shares CEO owns) / (total number of shares in company)
```

**Example:**
- CEO owns: 1 million shares
- Company has: 200 million shares outstanding
- ns = 1M / 200M = 0.005 (0.5% ownership)

**Important Notes:**
- This is a **fraction**, not a percentage
- Stock splits are already accounted for
- This is snapshot as of fiscal year-end

**Verification Check:**
```
✓ Is ns typically 0.0001 to 0.05 (0.01% to 5%)?
✓ Are stock splits accounted for?
✓ Is it the CEO's personal shares (not options)?
```

---

## Part 4: The Most Complex Variables

### Variable 7a: $W_0$ (Non-Firm Wealth) - Year 1 Calculation

**What it represents:** CEO's accumulated outside wealth (not tied to this company's stock)

**This is the HARD part.** Here's how it's calculated:

#### Step 1: First Year in Database ($t_E$)

For the CEO's first year in the ExecuComp database:
$$W_0^{t_E} = (salary + bonus + othann + ltip + allothtot + option\_exercise\_value) \times (1 - \tau)$$

**Breaking it down:**
- Take all **cash compensation** (note: includes `ltip` here, unlike $\phi$!)
- Add **gains from exercising options** (if any)
- Multiply by **(1 - tax rate)** to get after-tax value
- This is assumed to be **zero** before the CEO joins

**Tax rates (hardcoded):**
- 1992: $\tau = 0.31$ (31%)
- 1993: $\tau = 0.396$ (39.6%)
- 1994 onward: $\tau = 0.42$ (42%)

**Example (Year 1 in database: 1995):**
- Salary: $500K
- Bonus: $100K
- Other: $50K
- LTIP: $200K
- Option exercises: $300K
- **Total before tax:** $1,150K
- **Tax rate:** 0.42
- **After-tax:** $1,150K × (1 - 0.42) = $667K
- **$W_0^{1995}$ = $667K**

---

#### Step 2: Subsequent Years (Wealth Accumulation)

For each year $t$ after the first year:

$$W_0^{t} = W_0^{t-1} \times (1 + R_t) + \text{(after-tax income and adjustments)}$$

**This has THREE components:**

**A) Prior wealth grows at risk-free rate:**
$$W_0^{t-1} \times (1 + R_t)$$

Where $R_t$ is the **1-year Treasury yield** for year $t$ (hardcoded table)

**Example:** If $W_0^{1995} = $667K and 1996 rate = 5%
- Growth: $667K × 1.05 = $700.35K

**B) CEO receives new cash income (after-tax):**
$$(salary + bonus + othann + ltip + allothtot + option\_exercises) \times (1 - \tau)$$

**C) CEO buys more shares or receives restricted stock (adjusted):**
$$+ RSU\_grant\_value - RSU\_tax\_withholding - (shares\_increase\_value)$$

---

#### Why This is Complex

The SAS code essentially implements a **wealth accumulation model**:
- CEO starts with nothing
- Each year receives cash compensation
- Invests excess cash at risk-free rate
- Buys/sells shares
- Eventually has accumulated wealth $W_0$ at the measurement year

**Key insight:** $W_0$ is meant to capture the fact that a long-tenured CEO has built up outside wealth and is not purely dependent on current-year compensation.

**Verification Check:**
```
✓ Does W0 grow from year to year?
✓ Is prior W0 grown at risk-free rate?
✓ Are annual cash income and tax adjustments added?
✓ Is W0 typically much larger than annual phi?
```

---

### Variable 7b: $n_o$, $K$, $T$ (Options) - The Hardest Part

**What it represents:** CEO's option portfolio, reduced to a **single representative option**

**The challenge:** CEOs hold dozens of option grants with different strike prices and maturity dates. How do we summarize this into one number?

**Answer:** Use the **Core & Guay (2002) algorithm** (see separate document)

**High-level summary:**
1. Collect all options held by CEO from multiple years
2. Calculate value ($BS_i$) and delta ($\Delta_i$) for each
3. Find a single option with strike $K^*$ and maturity $T^*$ that matches:
   - **Average option value** (weighted by number)
   - **Average option delta** (sensitivity to price)
4. Use **numerical optimization** to find $K^*$ and $T^*$

**Why it matters:**
- Options are the **most important** variable for incentive alignment
- More volatile stock → option value increases → CEO incentive increases
- Options create **nonlinear payoff** (only valuable if stock > strike)

**Verification Check:**
```
✓ Are all option grants collected (current + prior years)?
✓ Is maturity adjusted for early exercise (×0.7)?
✓ Is optimization done correctly (BS and delta matching)?
✓ Do the results match the original SAS output?
```

---

## Part 5: Data Filtering and Exclusions

### Who's Excluded and Why?

The dataset construction has **several filters** that remove CEOs from the sample. Understanding these is crucial for replication:

#### Filter 1: Missing Salary (SAS line 68)
```
EXCLUDE: CEOs with missing salary in measurement year
Reason: Can't calculate phi without salary
```

#### Filter 2: Pinclopt Flag (SAS lines 88-100)
```
EXCLUDE: CEOs where pinclopt = 'TRUE' in ANY year

What is pinclopt?
  'TRUE' = shares and exercisable options are NOT separated in the data
  'FALSE' = data is clean (shares and options are separate)

Reason: If we can't distinguish shares from options, we can't build accurate model
```

**This is IMPORTANT:**
- If a CEO appears with `pinclopt='TRUE'` in year 1996
- Then exclude that CEO for years 1996, 1997, 1998, 1999, 2000 (measurement year)
- This is because prior data quality issues contaminate the full period

#### Filter 3: Insufficient History (SAS lines 105-139)
```
EXCLUDE: CEOs who don't have continuous data for required history

Example for measurement year 2000 with history=5:
  Need data for: 1995, 1996, 1997, 1998, 1999, 2000
  If missing any year → EXCLUDE
```

#### Filter 4: Multiple Company Affiliations (SAS lines 144-159)
```
EXCLUDE: If CEO appears as an executive for >1 company in same year

Reason: Can't tell if person is jumping between firms or has dual role
```

#### Filter 5: Final Data Quality (SAS lines 525-530, 545-546)
```
EXCLUDE if any of the following:
  - Missing W0 (can't calculate outside wealth)
  - W0 < 0 (negative wealth doesn't make sense)
  - Missing sigma (can't price options)
  - Options calculation errors
```

### Verification Checklist

When you verify our Python code matches the SAS code:

```
✓ Are missing salaries excluded?
✓ Are pinclopt='TRUE' flagged CEOs excluded?
✓ Are CEOs checked for continuous history?
✓ Are multi-company CEOs excluded?
✓ Are final data quality checks applied?

Expected result: ~30-50% of raw ExecuComp records → ~10-15% survive filtering
```

---

## Part 6: The SAS Code Structure

### The Main Macro

```sas
%construct(year, history)

Example: %construct(1999, 5)
  - year = 1999 (not 2000!)
  - history = 5 (years of data required before measurement year)
  
What this does:
  - Selects CEOs in measurement year 2000 (year + 1)
  - Checks continuous data from 1995-1999 (history of 5)
  - Constructs all variables (phi, ns, p0, d, sigma, rf, W0, no, K, T)
  - Outputs final dataset for year 2000
```

### Key Code Sections

| Lines | Purpose |
|-------|---------|
| 1-10 | Macro definition and comments |
| 68 | Exclude missing salary |
| 88-100 | Check pinclopt flag |
| 105-139 | Check history continuity |
| 144-159 | Check multiple company affiliations |
| 177 | Get volatility from codirfin |
| 235 | Adjust option maturity (×0.7) |
| 273-370 | Option aggregation logic |
| 463-522 | IML block: W0 wealth calculation |
| 525-530 | Final data quality checks |
| 538-546 | Calculate phi, ns, p0, d, sigma |
| 553-559 | Set risk-free rate |
| 564-566 | Final output |

---

## Part 7: Manual Verification Walkthrough

### Example: Verify Year 2000, One CEO

Let's say we pick a CEO: `GVKEY=1000, EXECID=123` and manually verify:

#### Step 1: Check Filters
```
✓ Does this CEO have salary in year 2000?
✓ Is pinclopt = 'FALSE' for all years 1995-2000?
✓ Does CEO appear in every year 1995-2000 (no gaps)?
✓ Does CEO work for only one company in each year?
```

#### Step 2: Calculate phi (Base Compensation)
```
From ExecuComp AnnComp table for year 2000:
  salary = $500K
  bonus = $150K
  othann = $50K
  allothtot = $100K
  
phi = 500 + 150 + 50 + 100 = $800K
```

#### Step 3: Calculate P0 (Firm Value)
```
From ExecuComp CoDirFin table for fiscal year 1999:
  prccf = $50  (stock price 12/31/1999)
  ajex = 1.0  (no stock splits)
  shrsout = 100  (shares in millions)
  
price_adjusted = 50 / 1.0 = $50
shares_adjusted = 100 × 1000 × 1.0 = 100 million shares

P0 = 50 × 100M = $5,000M = $5 billion
```

#### Step 4: Calculate ns (Ownership Fraction)
```
From ExecuComp AnnComp table for year 1999:
  shrown = 0.5  (CEO owns 500K shares)
  ajex = 1.0
  
shrown_adjusted = 0.5 × 1.0 = 0.5M shares
shrsout_adjusted = 100M shares

ns = 0.5M / 100M = 0.005 (0.5% ownership)
```

#### Step 5: Get d, sigma, rf (Simple Direct Values)
```
From ExecuComp CoDirFin for fiscal 1999:
  divyield = 2.5
  bs_volatility = 0.35

d = 2.5 / 100 = 0.025
sigma = 0.35  (as-is)

From hardcoded SAS table for year 2000:
  rf = 0.0664
```

#### Step 6: Calculate W0 (The Hard Part)
```
This requires data from 1995-1999, tracking wealth accumulation

Year 1995 (first year):
  Cash income: (salary + bonus + othann + ltip + allothtot + exercises) = $1.2M
  After-tax (0.42): $1.2M × 0.58 = $696K
  W0_1995 = $696K

Year 1996:
  Prior W0 grows: $696K × 1.05 = $730.8K
  New after-tax income: $800K × 0.58 = $464K
  Adjustments (RSUs, shares): +$200K
  W0_1996 = $730.8 + $464 + $200 = $1,394.8K

Year 1997: ... (repeat process)
Year 1998: ... (repeat process)
Year 1999: ... (repeat process)

Final W0 = cumulative wealth as of end of 1999
```

#### Step 7: Calculate no, K, T (Option Aggregation)
```
Collect all option holdings:
  From prior grants: 50K unexercisable options, 100K exercisable options
  From current grant (2000): 25K options
  Total: 175K options as of fiscal 1999
  
Maturity adjustment: T_adjusted = T_original × 0.7

Use Core & Guay algorithm:
  1. Calculate BS and delta for each grant
  2. Find weighted average BS and delta
  3. Numerically optimize K and T to match averages
  4. Output: K = $35, T = 4.5 years
  
no = total_option_qty / total_shares = 0.175M / 100M = 0.00175
```

#### Step 8: Compare to Original Output
```
Now compare your calculated values to what the SAS code produced:

Your calculation → Python output:
  phi = $800K ✓
  ns = 0.005 ✓
  p0 = $5,000M ✓
  d = 0.025 ✓
  sigma = 0.35 ✓
  rf = 0.0664 ✓
  W0 = ? (should match)
  no = 0.00175 ? (should match)
  K = $35 ? (should match)
  T = 4.5 ? (should match)

If all match → verification successful! ✅
If any differ → debug why
```

---

## Part 8: Common Issues and How to Debug

### Issue 1: Too Many CEOs Excluded
```
Symptom: Python output has 10 CEOs, SAS output has 50 CEOs

Debug checklist:
  □ Are you checking pinclopt correctly?
  □ Are you requiring continuous history?
  □ Are you excluding multi-company CEOs?
  □ Are you handling missing values correctly?
```

### Issue 2: W0 Values Seem Too Large or Too Small
```
Symptom: W0 ranges from -$100K to +$50M in your data

Debug checklist:
  □ Are you growing prior W0 at risk-free rate?
  □ Are you applying tax rates correctly (0.42)?
  □ Are you including all cash income components (salary, bonus, ltip)?
  □ Are you handling share purchases/sales correctly?
```

### Issue 3: phi Doesn't Match
```
Symptom: Your phi = $800K but SAS = $900K

Debug checklist:
  □ Are you including salary, bonus, othann, allothtot?
  □ Are you excluding ltip? (it goes in W0, not phi)
  □ Are you excluding option grants? (they go in no, K, T)
  □ Are you using the right year's data?
```

### Issue 4: Options Parameters (no, K, T) Don't Match
```
Symptom: Your K = $40 but SAS = $38

Debug checklist:
  □ Are you maturity-adjusting by 0.7?
  □ Are you using Core & Guay algorithm correctly?
  □ Are you including all grants (new + prior)?
  □ Is your numerical optimizer converging?
  □ Are you using same Black-Scholes formula?
```

---

## Part 9: Testing Strategy

### Test 1: Spot-Check a Few CEOs
```python
# Pick 3-5 CEOs from output and manually verify:
# - Load raw ExecuComp data for that CEO
# - Hand-calculate phi, ns, p0, d, sigma
# - Compare to your Python output
# - If 5/5 match → you're probably correct
```

### Test 2: Check Ranges and Distributions
```python
# For year 2000 (36 CEOs):
# phi: should be $400K - $5M (mean ~$1.3M)
# ns: should be 0.0001 - 0.05 (mean ~0.005)
# p0: should be $100M - $100B (mean ~$5.4B)
# sigma: should be 0.15 - 0.80
# W0: should be > 0, often $1M - $100M
# no: should be 0.0001 - 0.02
# K: should be $20 - $80
# T: should be 2 - 6 years
```

### Test 3: Time-Series Consistency
```python
# For same CEO across multiple years:
# - W0 should generally increase over time (wealth accumulates)
# - phi might vary (compensation changes)
# - ns might vary (CEO buys/sells shares)
# - K and T should be reasonable for option maturities
```

### Test 4: Compare Against Original Results
```python
# If available, get SAS output for same years
# Compare row by row for several CEOs
# Flag any deviations > 1% as issues to investigate
```

---

## Summary: What to Verify

| Component | What to Check | Expected Result |
|-----------|---------------|-----------------|
| **Data Filtering** | 50-70% of raw → 30-40% of filtered | Match SAS exclusion counts |
| **phi** | Salary + bonus + other cash | $300K - $3M typically |
| **P0** | Stock price × shares outstanding | $100M - $100B |
| **d** | Dividend yield / 100 | 0.0 - 0.05 (0-5%) |
| **sigma** | Volatility from ExecuComp | 0.15 - 0.80 |
| **rf** | Risk-free rate for year | 0.03 - 0.07 |
| **ns** | CEO shares / total shares | 0.0001 - 0.05 |
| **W0** | Accumulated wealth over time | Positive, grows over years |
| **no, K, T** | Core & Guay aggregation | Match original algorithm |

---

## Next Steps for You

1. **Read the SAS code** - Focus on sections in Part 6 above
2. **Review our Python code** - Compare line-by-line to SAS logic
3. **Spot-check 3 CEOs** - Hand-verify calculations
4. **Run full dataset** - Check distributions match expected ranges
5. **Compare to original output** - If you have SAS output available
6. **Debug any mismatches** - Use the troubleshooting checklist

---

*Last Updated: February 10, 2026*
*Document Type: Educational Manual | AI-Generated*
