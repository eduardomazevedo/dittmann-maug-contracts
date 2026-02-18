# Agents (AI Generated)

This file will document the roles and responsibilities of various agents involved in the project, including human and AI agents, their specific tasks, and interaction protocols.

## AI Agent (Current Instance)

*   **Role:** Facilitator for project setup, documentation generation, code analysis, and future implementation.
*   **Responsibilities:**
    *   Generate initial project documentation and plan drafts.
    *   Analyze existing research papers and code to extract methodologies.
    *   Translate methodologies into detailed procedural documents.
    *   Assist in setting up the Python development environment.
    *   Implement Python code for data processing and contract construction.
    *   Develop and execute tests to ensure replication accuracy.
    *   Maintain adherence to project conventions (e.g., file paths, naming, style).
    *   Provide clear and concise communication regarding progress, challenges, and proposed solutions.
*   **Operating Principles:**
    *   Prioritize thorough planning and reporting before action.
    *   Flag all AI-generated documentation at the top.
    *   Flag all AI-generated commit messages with "(model)" at the end.
    *   **Code Location:** Python files are located in `src/py/`.
    *   **Script Execution:** All scripts are run from the project root directory.
    *   **Data Storage:** Data is stored on dropbox. The script `src/bash/download_raw_data.sh` downloads the data using rclone. User has to set up rclone once to do this with .env file, or has to copy data manually.
    *   Utilize `uv` for Python package management.
    *   Strive for replication accuracy and code quality.

## Important Project Documentation

*   `docs/prd.md`: Project Requirement Document (draft). Outlines the high-level goals and approach for replicating the Dittman and Maug (2007) paper.
*   `agents.md`: Defines roles and responsibilities for human and AI agents, project conventions, and available documentation.
*   `docs/dittman-maug-key-excerpts.md`: Key excerpts from the original paper that explain data construction.
*   `docs/references/dittman-maug-2007.md`: Markdown dump of the original Dittman and Maug (2007) research paper with detailed information.
*   `docs/references/dittman-maug-zhang-2011.md`: Markdown dump of the Dittman, Maug, and Zhang (2011) research paper with additional details.
*   `docs/dittman-maug-code/Dataset Construction Macro V4.sas`: Original SAS code from the authors; this is the key file in their codebase for constructing contracts from the data.
*   `docs/dittman-maug-contract-construction-procedure.md`: Joint human-and-AI document and a very important reference detailing how optimal contracts are calculated.
*   `docs/execucomp-docs/Execucomp_Data_Definitions.md`: Detailed definitions of ExecuComp data items.
*   `docs/execucomp-docs/Execucomp_changes_2006_FAS_123_.md`: Information on changes in ExecuComp reporting due to FAS 123(R).
*   `docs/dittman-maug-contract-construction-working.md`: Working document for iterative contract-construction notes and refinements.

