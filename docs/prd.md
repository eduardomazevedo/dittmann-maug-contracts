# Project Plan Draft (AI Generated)

This document outlines the initial draft of the project plan for replicating the Dittman and Maug 2007 paper's construction of CEO compensation contracts from Execucomp data.

## Goal
The primary goal is to replicate the methodology for constructing CEO compensation contracts (a function that maps stock price into CEO compensation) as described in Dittman and Maug (2007). This replication should initially focus on the old Execucomp data format.

## Key Considerations

*   **Replication Focus:** Strictly follow the methodology for contract construction, excluding the economic theory of optimal contracts for now.
*   **Execucomp Data Formats:** Address compatibility with both old and new Execucomp data formats. Initial focus will be on the old format.
*   **Option Portfolio Simplification:** Replicate the simplification of the option portfolio into one representative option as done in the paper. A future enhancement will include an option to retain the entire portfolio.
*   **Technology Stack:** The project will exclusively use Python, managed by `uv`.
*   **Code Structure:** Python files will reside in `src/py/`. All scripts will be run from the project root.

## Initial Steps (Phase 1)

1.  **Deep Dive into Methodology:**
    *   Thoroughly read and understand the Dittman and Maug (2007) paper.
    *   Analyze the provided Execucomp documentation for data definitions and format changes.
    *   Examine the SAS replication code to identify exact variable usage and procedural steps for contract construction.
    *   Generate a detailed, AI-generated markdown document (`docs/dittman-maug-contract-construction-procedure.md`) outlining the exact procedure, Execucomp variables used, and steps for contract finding. This document will be carefully reviewed for accuracy.

## Future Phases (TBD after initial review)

Further planning for implementation, testing, and extension to new Execucomp formats and full option portfolios will be conducted after the initial methodology deep dive is complete and reviewed.