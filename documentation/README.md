# UNICEF-Assessment-2025



UNICEF Assessment 2025

This repository contains the code and data for the UNICEF assessment to analyze population-weighted coverage of at least four antenatal care visits (ANC4) and skilled birth attendance (SBA) by under-five mortality rate (U5MR) status for 2022, using projected births as weights.

Repository Structure

data/: Stores raw, cleaned, and intermediate files.

•	GLOBAL\_DATAFLOW\_2018\_ANC4.xlsx- Raw ANC4 coverage data (2018–2022).

•	GLOBAL\_DATAFLOW\_SBA.xlsx- Raw SBA coverage data (2018–2022).

•	WPP2022\_GEN\_F01\_DEMOGRAPHIC\_INDICATORS\_COMPACT\_REV1.xlsx- Projected births data for 2022.

•	On-track and off-track countries.xlsx- U5MR status data (Achieved, On Track, or Acceleration Needed).

•	anc4\_cleaned.dta- Cleaned ANC4 dataset with most recent 2018–2022 estimates.

•	sba\_cleaned.dta- Cleaned SBA dataset with most recent 2018–2022 estimates.

•	births\_cleaned.dta- Cleaned 2022 births dataset.

•	status\_cleaned.dta- Cleaned U5MR status dataset with binary on\_track.

•	merged\_data.dta- Final merged dataset with ANC4, SBA, births\_2022, and on\_track.

•	weighted\_coverage.dta- Population-weighted ANC4 and SBA averages by on\_track.

output/: Stores output files.

•	report.pdf- Final report with visualizations comparing ANC4 and SBA coverage for on-track vs. off-track countries and an interpretation paragraph with caveats.

•	visualization.png- Visualization comparing population-weighted ANC4 and SBA coverage by on-track/off-track status.

scripts/: Contains Stata scripts for the workflow.

•	user\_profile.do- Sets working directory and environment.

•	run\_project.do- Executes end-to-end workflow (Steps 1–3).

documentation/: Documentation files.

•	README.md- This file describes the repository and reproduction instructions.

Reproduction Instructions

•	Clone the repository- git clone https://github.com/UNICEFAssessment2025/UNICEF-Assessment-2025.git

•	Prerequisites- Install Stata (version 17 or later) with putpdf support.

•	Ensure the four raw data files (GLOBAL\_DATAFLOW\_2018\_ANC4.xlsx, GLOBAL\_DATAFLOW\_SBA.xlsx, WPP2022\_GEN\_F01\_DEMOGRAPHIC\_INDICATORS\_COMPACT\_REV1.xlsx, On-track and off-track countries.xlsx) are in the data/ folder.

•	Set Working Directory- Edit user\_profile.do to set the working directory to the local repository path

•	Run the Analysis- Execute the main script in Stata

do scripts/run\_project.do

This runs the entire workflow, producing report.pdf and visualization.png in the output/ folder.

Workflow Steps

•	Data Preparation- Cleans and merges datasets using Geographicarea, retaining 2018–2022 ANC4 and SBA estimates (most recent year per country) and 2022 projected births. Outputs merged\_data.dta.

•	Population-Weighted Coverage- Calculates population-weighted ANC4 and SBA averages for on-track and off-track countries using 2022 births as weights. Outputs weighted\_coverage.dta.

•	Reporting- Produces a visualization (output/coverage\_comparison.png) and a PDF report (output/coverage\_report.pdf) comparing population-weighted coverage of at least four antenatal care visits (ANC4) and skilled birth attendance (SBA) by U5MR status, with an interpretive paragraph highlighting caveats such as incomplete data, projected births, varying estimate years, and simplified U5MR classification.

Notes

•	Only countries with complete data for ANC4, SBA, 2022 births, and under-five mortality status are included to ensure accurate population-weighted averages.

•	The report.pdf includes a visualization (also saved as visualization.png) and a paragraph interpreting results with caveats about data limitations.



&nbsp;

Positions Applied for -

Learning and Skills Data Analyst Consultant – Req. #581598

Household Survey Data Analyst Consultant – Req. #581656

Microdata Harmonization Consultant – Req. #581699

