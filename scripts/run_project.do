
		
		* run_project.do: Execute end-to-end workflow
		clear all
		set more off
		* Run user_profile to set environment
		do user_profile.do 
		
		
		/*------------------------------------------------------------------
		Step 1: Data Preparation
		- Clean and merge all datasets using consistent country identifiers
		- For ANC4 and SBA, filter for coverage estimates from 2018 to 2022
			- Use the most recent estimate within this range per country
		-----------------------------------------------------------------------*/
{		
		* Import ANC4 dataset
		import excel "data/GLOBAL_DATAFLOW_2018_ANC4.xlsx", firstrow clear
		* Convert string vars to numeric
		destring, replace
		* Filter to years of interest
		keep if TIME_PERIOD >= 2018 & TIME_PERIOD <= 2022
		* Keep most recent year per Geographicarea with highest OBS_VALUE
		gsort Geographicarea -TIME_PERIOD -OBS_VALUE
		by Geographicarea: keep if _n == 1
		* Generate clean ANC4 variable
		gen ANC4 = OBS_VALUE
		label variable ANC4 "% of women (aged 15–49) with at least 4 antenatal care visits"
		* Save cleaned dataset
		save "data/anc4_cleaned.dta", replace

		* Import SBA dataset
		import excel "data/GLOBAL_DATAFLOW_SBA.xlsx", firstrow clear
		* Convert string vars to numeric
		destring, replace
		* Filter to years of interest
		keep if TIME_PERIOD >= 2018 & TIME_PERIOD <= 2022
		* Keep most recent year per Geographicarea with highest OBS_VALUE
		gsort Geographicarea -TIME_PERIOD -OBS_VALUE
		by Geographicarea: keep if _n == 1
		* Generate clean SBA variable
		gen SBA = OBS_VALUE
		label variable SBA "% of deliveries attended by skilled health personnel"
		* Save cleaned dataset
		save "data/sba_cleaned.dta", replace

		* Import births dataset from 'Projections' sheet
		import excel "data/WPP2022_GEN_F01_DEMOGRAPHIC_INDICATORS_COMPACT_REV1.xlsx", sheet("Projections") cellrange(A17) firstrow clear
		* Rename variables for consistency
		rename (Regionsubregioncountryorar Birthsthousands) (Geographicarea births_2022)
		* Keep only 2022 projected births
		keep if Year == 2022
		* Replace any value in 'births' that is NOT a valid number with missing
		replace births_2022 = "." if real(births_2022) == .
		* Keep variables of interest
		keep Geographicarea births_2022
		* Convert string vars to numeric
		destring, replace
		* Adjust spelling for merge
		replace Geographicarea="Africa" if Geographicarea=="AFRICA"
		replace Geographicarea="Europe" if Geographicarea=="EUROPE"
		* Drop duplicates
		duplicates drop Geographicarea, force
		* Save cleaned dataset
		save "data/births_cleaned.dta", replace

		* Import on-track/off-track dataset
		import excel "data/On-track and off-track countries.xlsx", firstrow clear
		* Generate binary variable for on-track status
		gen on_track = (StatusU5MR == "Achieved" | StatusU5MR == "On Track")
		* Harmonize geographic area naming
		rename OfficialName Geographicarea
		* Adjust spellings for merge
		replace Geographicarea="Antigua and Barbuda" if Geographicarea=="Antigua And Barbuda"
		replace Geographicarea="Bolivia (Plurinational State of)" if Geographicarea=="Bolivia (Plurinational State Of)"
		replace Geographicarea="Bosnia and Herzegovina" if Geographicarea=="Bosnia And Herzegovina"
		replace Geographicarea="Dem. People's Republic of Korea" if Geographicarea=="Democratic People's Republic of Korea"
		replace Geographicarea="Democratic Republic of the Congo" if Geographicarea=="Democratic Republic Of The Congo"
		replace Geographicarea="Iran (Islamic Republic of)" if Geographicarea=="Iran (Islamic Republic Of)"
		replace Geographicarea="Kosovo (under UNSC res. 1244)" if Geographicarea=="Kosovo (Unscr 1244)"
		replace Geographicarea="Lao People's Democratic Republic" if Geographicarea=="Lao People'S Democratic Republic"
		replace Geographicarea="Micronesia (Fed. States of)" if Geographicarea=="Micronesia (Federated States of)"
		replace Geographicarea="Netherlands" if Geographicarea=="Netherlands (Kingdom of the)"
		replace Geographicarea="Republic of Korea" if Geographicarea=="Republic Of Korea"
		replace Geographicarea="Republic of Moldova" if Geographicarea=="Republic Of Moldova"
		replace Geographicarea="Saint Kitts and Nevis" if Geographicarea=="Saint Kitts And Nevis"
		replace Geographicarea="Saint Vincent and the Grenadines" if Geographicarea=="Saint Vincent And The Grenadines"
		replace Geographicarea="Sao Tome and Principe" if Geographicarea=="Sao Tome And Principe"
		replace Geographicarea="State of Palestine" if Geographicarea=="State Of Palestine"
		replace Geographicarea="Trinidad and Tobago" if Geographicarea=="Trinidad And Tobago"
		replace Geographicarea="United Republic of Tanzania" if Geographicarea=="United Republic Of Tanzania"
		replace Geographicarea="Venezuela (Bolivarian Republic of)" if Geographicarea=="Venezuela (Bolivarian Republic Of)"
		replace Geographicarea="Türkiye" if Geographicarea=="TüRkiye"
		* Keep relevant variables
		keep Geographicarea on_track
		* Save cleaned dataset
		save "data/status_cleaned.dta", replace

		* Merge datasets
		* Merge ANC4 and SBA on Geographicarea and TIME_PERIOD
		use "data/anc4_cleaned.dta", clear
		merge 1:1 Geographicarea TIME_PERIOD using "data/sba_cleaned.dta"
		* Check merge results
		tab _merge
		list Geographicarea TIME_PERIOD ANC4 if _merge == 1 /* ANC4 only */
		list Geographicarea TIME_PERIOD SBA if _merge == 2 /* SBA only */
		keep if _merge == 3 /* Keeping only merged values because both ANC4 and SBA data are required for accurate population-weighted coverage calculations */
		drop _merge
		* Merge with births dataset
		merge m:1 Geographicarea using "data/births_cleaned.dta"
		* Check merge results
		tab _merge
		list Geographicarea TIME_PERIOD ANC4 SBA if _merge == 1 /* ANC4-SBA only */
		list Geographicarea births if _merge == 2 /* Births only */
		keep if _merge == 3 /* Keeping only merged values because birth data is essential for weighting the coverage estimates */
		drop _merge
		* Merge with status dataset
		merge m:1 Geographicarea using "data/status_cleaned.dta"
		* Check merge results
		tab _merge
		list Geographicarea TIME_PERIOD ANC4 SBA if _merge == 1 /* ANC4-SBA only */
		list Geographicarea births if _merge == 2 /* Births only */
		keep if _merge == 3 /* Keeping only merged values because birth data is essential for weighting the coverage estimates */
		drop _merge
		* Save final merged dataset
		save "data/merged_data.dta", replace
		}
		
			/*------------------------------------------------------------------
		Step 2: Calculate Population-Weighted Coverage
		- For each group (on-track and off-track), calculate population-weighted averages for ANC4 and SBA
		- Use projected births for 2022 as weights
		-----------------------------------------------------------------------*/
		{ 
		* Load merged dataset
		use "data/merged_data.dta", clear
		* Calculate population-weighted averages for ANC4 and SBA by on_track group
		collapse (mean) ANC4_wt = ANC4 SBA_wt = SBA [aweight=births_2022], by(on_track)
		* Label weighted variables
		label variable ANC4_wt "Population-weighted % of women (aged 15–49) with at least 4 antenatal care visits"
		label variable SBA_wt "Population-weighted % of deliveries attended by skilled health personnel"
		* Label on_track
		label define on_track_lbl 0 "Off-track" 1 "On-track"
		label values on_track on_track_lbl
		* Save weighted averages
		save "data/weighted_coverage.dta", replace
		* Display results
		list on_track ANC4_wt SBA_wt
		}


			/*------------------------------------------------------------------
		Step 3: Reporting
		- Create a PDF / HTML / DOCX report including:
			- A visualization comparing coverage for on-track vs. off-track countries
			- A short paragraph interpreting the results, highlighting any caveats or assumptions
		-----------------------------------------------------------------------*/
	{	
		* Load population-weighted coverage data
		use "data/weighted_coverage.dta", clear

		* Create graph with smaller fonts
		graph bar ANC4_wt SBA_wt, over(on_track, label(angle(0) labsize(small))) blabel(bar, format(%5.1f) size(small))legend(label(1 "≥4 Antenatal Visits (ANC4)") label(2 "Skilled Birth Attendance (SBA)") size(small)) title("Population-Weighted Coverage by On-Track Status", size(medsmall)) ytitle("Coverage (%)", size(small)) ylabel(, angle(horizontal)) bar(1, color(navy)) bar(2, color(maroon)) name(coverage_graph, replace)
		* Export sharper PNG (high resolution)
		graph export "output/visualization.png",  replace
  
		* Create report
		putpdf begin
		* Title
		putpdf paragraph, halign(center)
		putpdf text ("Population-Weighted Health Coverage by On-Track Status"), bold  
		* Spacer paragraph
		putpdf paragraph
		* Image
		putpdf paragraph, halign(center)
		putpdf image "output/visualization.png", width(5)   
		* Interpretation text
		putpdf paragraph
		* Interpretation text
		putpdf paragraph
		putpdf text ("Interpretation"), bold
		putpdf paragraph
		putpdf text ("The bar chart shows the population-weighted coverage of at least four antenatal care visits (ANC4) and skilled birth attendance (SBA) for countries classified as on-track or off-track for under-five mortality rate (U5MR) reduction, based on 2022 projected births as weights. It illustrates that countries on-track for U5MR reduction consistently achieve higher coverage of at least four antenatal care visits (ANC4) and skilled birth attendance (SBA) compared to off-track countries, signaling stronger maternal and child health systems and better access to essential prenatal and delivery care. This disparity underscores the linkage between effective health interventions and progress toward U5MR goals, with on-track countries likely benefiting from robust healthcare infrastructure, policy prioritization, or resource allocation.")
		putpdf paragraph
		putpdf text ("However, several caveats warrant caution in interpreting these results. First, incomplete data due to non-matching countries across ANC4, SBA, births, and U5MR status datasets may introduce selection bias, as only countries with complete data contribute to the weighted averages. Second, the use of 2022 projected births as weights, derived from demographic models, may deviate from actual birth counts due to unforeseen demographic shifts or data inaccuracies. Third, ANC4 and SBA estimates span 2018–2022, with varying years per country, potentially reducing comparability if health system changes occurred over time. Fourth, the binary classification of U5MR status (on-track vs. off-track) oversimplifies progress, as countries near the threshold may differ minimally in health outcomes. These limitations suggest that while the observed trends are indicative, further validation with complete and contemporaneous data is needed to ensure robust conclusions.")

		* Save as PDF
		putpdf save "output/report.pdf", replace
	}
	
 

			/*------------------------------------------------------------------
		End file
		-----------------------------------------------------------------------*/
 
		 
		 
		 
		 
		 
		 
		 
		 
		 
		 
		 
		 
		 
		 
		 
		 
		 
		 
		 
		 
		 
		 
		 
		 
		 