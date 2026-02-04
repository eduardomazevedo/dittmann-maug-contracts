# AI Generated: Dittman and Maug (2007) CEO Compensation Contract Construction Procedure

This document provides a comprehensive description of the methodology used by Dittman and Maug (2007) to construct CEO compensation contracts from ExecuComp data. It is intended to be a detailed guide for replicating the dataset construction. This procedure is derived from the paper's "Empirical Methodology and Data" section (Section II), Appendix B, and is thoroughly informed by the logic in the `Dataset Construction Macro V4.sas` script.

## 1. CEO Compensation Formula

The core of the paper's analysis is a model of the CEO's end-of-period wealth (`WT`), which is a function of firm performance (end-of-period stock price `PT`). The contract is defined by a set of parameters: base salary (`phi`), number of shares (`ns`), and number of options (`no`).

**Formula for End-of-Period Wealth (`WT`):**

```
WT = (phi + W0) * e^(rf * T) + ns * PT + no * max(PT - K, 0)
```

Where:
*   `WT`: CEO's end-of-period wealth at time `T`.
*   `phi`: Base salary + bonus for the `considered year`.
*   `W0`: CEO's initial non-firm wealth.
*   `rf`: Risk-free rate of interest.
*   `T`: Maturity of the representative option.
*   `ns`: Number of shares held by the CEO (as a fraction of total shares).
*   `PT`: End-of-period market value of the firm.
*   `no`: Number of options held by the CEO (as a fraction of total shares).
*   `K`: Strike price of the representative option.

*(Source: Dittman & Maug (2007), Section I, Equation (2))*

## 2. Data Sources and Sample Selection

*   **Primary Data Source:** Compustat ExecuComp Database (1992-2000 for the original paper). The SAS script accesses these via a library named `dir`, referencing tables like `comptabl` (AnnComp), `coperol`, `codirfin`, and `stgrttab`.
*   **Sample:** The SAS macro is designed to be called as `%construct(year, history)`. For the paper, this was `%construct(1999, 5)`, which selects CEOs in the `considered year` 2000 who have a continuous data history from 1995-1999.
    *(Source: Dataset Construction Macro V4.sas, lines 3-4)*
*   **Exclusions:**
    *   CEOs with missing `salary` in the `considered year`. *(SAS script, line 68)*
    *   Observations where `shrown` (shares owned) is missing or `pinclopt='TRUE'` (shares and exercisable options are not separated). If `pinclopt` is true for any year, that executive's data for that year and all prior years are excluded. *(SAS script, lines 88-100)*
    *   CEOs who do not have the required `history` of data. *(SAS script, lines 105-139)*
    *   CEOs who appear as an executive for more than one company in the same year. *(SAS script, lines 144-159)*
    *   Final dataset excludes observations with missing `W0`, `W0 < 0`, missing `sigma` (`bs_volatility`), or errors during the option calculation. *(SAS script, lines 525-530, 545-546)*

## 3. Key Variable Definitions and Construction

The following variables are constructed for each CEO for a specific `considered year` (e.g., 2000).

### 3.1. `P0` (Market Value of the Firm)

*   **Definition:** The market value of the firm at the fiscal year-end of the measurement year (e.g., 1999).
*   **Formula:** `P0 = prccf_a * NumOfShares`
    *   `prccf_a`: Company's fiscal year-end close price (`prccf`), adjusted for stock splits (`prccf / ajex`).
    *   `NumOfShares`: `shrsout_a * 1000`, where `shrsout_a` is the company's common shares outstanding (`shrsout`), adjusted for stock splits (`shrsout * ajex`).
*   *(Source: Dataset Construction Macro V4.sas, lines 543-544)*

### 3.2. `d` (Dividend Yield)

*   **Definition:** The dividend yield at fiscal-year end.
*   **Formula:** `d = divyield / 100`
*   **ExecuComp Variable:** `divyield` from `codirfin`.
*   *(Source: Dataset Construction Macro V4.sas, line 547)*

### 3.3. `sigma` (Stock Volatility)

*   **Definition:** The 60-month stock volatility figure used by ExecuComp for its own Black-Scholes calculations.
*   **ExecuComp Variable:** `bs_volatility` from `codirfin`.
*   *(Source: Dataset Construction Macro V4.sas, lines 177, 546)*

### 3.4. `rf` (Risk-Free Rate)

*   **Definition:** The risk-free rate used for valuation, corresponding to the maturity of the instrument. The paper uses a 6-year rate for option valuation to match the average option maturity.
*   **Value:** `rf = 0.0664` for the year 2000.
*   **Source:** Hardcoded in the SAS script, based on U.S. government bond yields from January of the `considered year`.
*   *(Source: Paper Appendix B; SAS script lines 553-559)*

### 3.5. `phi` (Base Salary + Bonus)

*   **Definition:** The fixed component of compensation for the `considered year` (e.g., 2000).
*   **Formula:** `phi = salary + bonus + othann + allothtot`
*   **ExecuComp Variables:** `salary`, `bonus`, `othann`, `allothtot` from the `AnnComp` table. Note that Long-Term Incentive Plan payouts (`ltip`) are excluded from this variable.
*   *(Source: Paper Section II.B; SAS script lines 564-566)*

### 3.6. `W0` (Non-Firm Wealth)

*   **Definition:** The CEO's accumulated non-firm wealth, calculated iteratively over the CEO's history in the database, assuming all surplus cash is invested at the risk-free rate.
*   **Initial `W0` (First year in database, `tE`):** Assumed to be 0 before the first year. For year `tE`, wealth is `(total_salary_tE + soptexer_tE) * (1 - tau_tE)`.
    *   `total_salary`: `salary + bonus + othann + ltip + allothtot`. Note: this **includes `ltip`**.
    *   `soptexer`: Net value realized from exercising options.
    *   `tau`: Personal tax rate (0.31 for 1992, 0.396 for 1993, 0.42 from 1994 onwards).
*   **Wealth Accumulation in Subsequent Years:**
    1.  **Growth of Invested Wealth:** `W0_current = W0_previous * (1 + R_year_t / 100)`.
        *   `R_year_t`: 1-year U.S. government bond yields (hardcoded in `R` vector in SAS script).
    2.  **Add After-Tax Income & Adjust for Investments:**
        `W0_current = W0_current + rstkgrnt_current - rst_tax + (W0_previous_nS * dps_a_current + total_salary_current + soptexer_current) * (1 - tau_current) - (current_nS - W0_previous_nS) * current_prccf_a`.
        *   This formula effectively adds the value of new restricted stock grants, subtracts taxes on vesting stock, adds after-tax cash income (dividends, salary, option exercises), and subtracts the cost of purchasing new shares.
*   *(Source: Paper Appendix B; SAS script IML block, lines 463-522)*

### 3.7. `ns` (Total Shares Held)

*   **Definition:** The fraction of the company's total outstanding shares held by the CEO.
*   **Formula:** `ns = shrown_a / (shrsout_a * 1000)`
    *   `shrown_a`: Total number of shares owned by the CEO (in thousands), adjusted for stock splits (`shrown * ajex`).
    *   `shrsout_a`: Total shares outstanding (in millions), adjusted for stock splits.
*   *(Source: Dataset Construction Macro V4.sas, lines 538-539)*

### 3.8. `no`, `K`, `T` (Options Held and Representative Option Parameters)

*   **Definition:** The CEO's entire option portfolio is aggregated into a single **representative option** defined by a number of options (`no`), a strike price (`K`), and a maturity (`T`). This is done using the Core & Guay (2002a) algorithm.
*   **Algorithm Steps:**
    1.  **Identify Option Portfolio:** The portfolio consists of:
        *   **Newly granted options** from `stgrttab` for the measurement year.
        *   **Previously granted options**, approximated as two hypothetical grants: one for unexercisable options (`uexnumun_a`, `inmonun`) and one for exercisable options (`uexnumex_a`, `inmonex`).
    2.  **Estimate Parameters for Hypothetical Grants:**
        *   The number of options is taken directly from `uexnumun_a` and `uexnumex_a` (after adjusting for new grants).
        *   Strike prices are estimated as `S0 - (realizable_value / num_options)`.
        *   Maturities are estimated based on the average maturity of new grants (e.g., `new_avg_mat - 1` for unexercisable, `new_avg_mat - 3` for exercisable).
    3.  **Adjust All Maturities:** The maturity `T` of every option grant in the portfolio is multiplied by `mat_red = 0.7` to account for early exercise. *(Source: SAS script, line 235)*
    4.  **Calculate Portfolio Value and Delta:** For each individual option grant `i` in the portfolio, calculate its Black-Scholes value `BS_i` and delta `N(d1)_i`. Then, calculate the value-weighted average `BSq` and `Nd1q` for the entire portfolio:
        *   `BSq = SUM(n_i * BS_i) / SUM(n_i)`
        *   `Nd1q = SUM(n_i * N(d1)_i) / SUM(n_i)`
    5.  **Solve for Representative `K` and `T`:** Use a numerical optimization routine (Nelder-Mead simplex) to find the Strike Price `K` and Maturity `T` for a single option that minimizes the deviation from the portfolio averages:
        *   `min ((BS_rep - BSq)/BSq)^2 + ((N(d1)_rep - Nd1q)/Nd1q)^2`
    6.  **Final `no` and `K`:**
        *   `no` is the total number of options held (`uexnumun + uexnumex`), normalized by total shares outstanding. *(SAS script, line 542)*
        *   `K` is the strike price found in step 5, scaled by the total number of shares outstanding. *(SAS script, line 544)*
*   **Default for No Options:** If a CEO holds no options, `K` is set to the current stock price (`P0`) and `T` is set to 10 years. *(SAS script, line 400)*
*   *(Source: Paper Appendix B; Dataset Construction Macro V4.sas, `calc_opt` module, lines 240-302)*

## 4. Output Dataset and Final Variables

The final dataset (`CEO_YYYY_HYRS`) contains one row per CEO for the `considered year` with all the constructed variables, ready for the economic analysis part of the paper. All fractional ownership variables (`nS`, `nO`) and the total strike price `K` are scaled to represent the entire firm.

## 5. Considerations for Old vs. New ExecuComp Formats

This procedure is based entirely on the **pre-FAS 123 (1992 reporting format)**. Replicating this for **post-FAS 123 (2006 onwards) data** would require careful mapping of variables. For example, option details would need to be extracted from `PlanBasedAwards` and `OutstandingAwards` tables instead of `stgrttab`, and the logic for identifying exercisable vs. unexercisable options would need to adapt to the new data structure.