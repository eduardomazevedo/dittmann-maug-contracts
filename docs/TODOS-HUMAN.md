# Dhiraj

- download the Core and Guay paper, to understand it and add to dropbox references and to our docs. Core, John and Wayne Guay, 2002, Estimating the value of employee stock option portfolios and their sensitivities to price and volatility, Journal of Accounting Research 40, 613-630
- probably good idea for you to manually see the important parts of the data construction docs so that claude is not mega confused.
- Goal for next meeting:
    - Have good working version. With good docs, so that we both really understand what is going on.
    - The main contract construction w(P) should be implemented. We should be able to take a ceo year, and see the contract params, and draw w(p) function.
    - Do some barebones html viz so that we can choose the ceo year and see the result, because that is a way for us to interactively test it together. i think some libraries that do this nice html viz are like streamlit and shiny. When you do that, it would be nice to see also what is the raw data from execucomp that was used to come up with the contract. good for our manual debugging.
    - if possible, look for stuff in the dittman and maug paper that they report. And if so create a test that asserts that what we are doing matches the number they report.


# Notes

- the file Dataset Construction Macro V4.sas seems to be the main script that they used to construct the data. So seems like the main script to flag to claude to translate to python.
- the format of compustat changed I think in 2006. I imagine these guys have been mostly using the old format, but who knows. So you will have to really understand compustat and what they did to make sure it is correct and works for all years, old and new.
- one thing we will do different, is that DM first find all of the options held by CEO, then aggregate into single representative option. But we dont care. We are fine with having a whole bunch. So first we reproduce their data, because we always want to reproduce first and be able to test versus their results, but in our actual paper we will basically always use all of the options.