* 04: After codepersons.
* Basic stuff.
cd "H:/Startups/Random"
set more off, permanently

* Startup list...
use "H:/Startups/Raw/datastartup.dta", clear
keep finorg_id
duplicates drop finorg_id, force
rename finorg_id finorg_id_random
generate original = 1
save temp, replace

* Matching randomly to get list of assignments.
* Very brute force-ish method here - will take some time.
use "H:/Startups/Raw/datastartup.dta", clear
keep startup_id finorg_id original
joinby original using temp
generate basis = startup_id + finorg_id
drop if finorg_id == finorg_id_random
drop finorg_id
rename finorg_id_random finorg_id
save temp, replace
use temp, replace
set seed 1729
generate random = runiform()
drop if random < 0.99
bysort basis: egen rank = rank(random)
drop if rank > 5
drop basis random rank
replace original = 0
save temp, replace

* Merge the assignments back.
use "H:/Startups/Raw/datastartup.dta", clear
keep startup_id finorg_id original
append using temp
save datastartuplist, replace


* Get the gender and average cultural values for startups.
use "H:/Startups/Raw/datastartuppersonsfull.dta", clear
duplicates drop startup_id person_id, force
sort startup_id
by startup_id: egen female_startup_total = total(female)
by startup_id: generate people_startup_total = _N
generate female_startup_pct = female_startup_total / people_startup_total
* Saving temp here for later calculation of the population variances.
save temp, replace

* Calculate organisational averages and keeping the correct data. 
use temp, replace
foreach var in rawpdi rawidv rawmas rawuai rawltowvs rawivr rawautonomy rawimmigrants rawimmigrant_econ rawrace rawfreedom rawgender_equality rawrespect rawunselfishness rawincome_equality rawcompetition rawreligion rawtrust rawproud_country rawfight_country{
	by startup_id: egen average_`var' = mean(`var')
	}

duplicates drop startup_id, force
keep startup_id female_startup_total people_startup_total female_startup_pct average_*
* Rename for later use.
foreach var in rawpdi rawidv rawmas rawuai rawltowvs rawivr rawautonomy rawimmigrants rawimmigrant_econ rawrace rawfreedom rawgender_equality rawrespect rawunselfishness rawincome_equality rawcompetition rawreligion rawtrust rawproud_country rawfight_country{
	rename average_`var' `var'
	}
save datastartupgenderculture, replace

* Get the gender and average cultural values for finorgs.
use "H:/Startups/Raw/datafinorgpersonsfull.dta", clear
duplicates drop finorg_id person_id, force
sort finorg_id
by finorg_id: generate female_finorg_total = sum(female)
by finorg_id: generate people_finorg_total = _N
generate female_finorg_pct = female_finorg_total / people_finorg_total
save temp, replace

* Calculate organisational averages and keeping the correct data. 
use temp, replace
foreach var in rawpdi rawidv rawmas rawuai rawltowvs rawivr rawautonomy rawimmigrants rawimmigrant_econ rawrace rawfreedom rawgender_equality rawrespect rawunselfishness rawincome_equality rawcompetition rawreligion rawtrust rawproud_country rawfight_country{
	by finorg_id: egen average_`var' = mean(`var')
	}
duplicates drop finorg_id, force
keep finorg_id female_finorg_total people_finorg_total female_finorg_pct average_*
* Rename for later use.
foreach var in rawpdi rawidv rawmas rawuai rawltowvs rawivr rawautonomy rawimmigrants rawimmigrant_econ rawrace rawfreedom rawgender_equality rawrespect rawunselfishness rawincome_equality rawcompetition rawreligion rawtrust rawproud_country rawfight_country{
	rename average_`var' `var'_finorg
	}
save datafinorggenderculture, replace

* Get the variance of each of the culture numbers for later use.
use datastartupgenderculture, replace
append using temp
keep raw*
* Get SD.
collapse (sd) *
foreach var of varlist _all {
	label var `var' ""
	}
* Calculate variance.
foreach var in rawpdi rawidv rawmas rawuai rawltowvs rawivr rawautonomy rawimmigrants rawimmigrant_econ rawrace rawfreedom rawgender_equality rawrespect rawunselfishness rawincome_equality rawcompetition rawreligion rawtrust rawproud_country rawfight_country{
	rename `var' variance_`var'
	replace variance_`var' = (variance_`var')^2
	}
save dataculturevariance, replace


















* Okay, now the stuff that needs cross-stuff...
* Combinatorial matching for the ethnic and education calculations.

* Get the finorg person data renamed.
use "H:/Startups/Raw/datafinorgpersonsfull.dta", replace
keep finorg_id person_id arab armenia bulgaria china czechrep denmark ethiopia philippines finland france germany greece hungary india ireland italy japan israel southkorea lithuania norway poland portugal russia slovakrep sweden ukraine vietnam serbia croatia slovenia britain netherlands spain uidc countryc namec bachelors mba masters med phd law
foreach var in person_id arab armenia bulgaria china czechrep denmark ethiopia philippines finland france germany greece hungary india ireland italy japan israel southkorea lithuania norway poland portugal russia slovakrep sweden ukraine vietnam serbia croatia slovenia britain netherlands spain uidc countryc namec bachelors mba masters med phd law{
	rename `var' `var'_finorg
	}
save temp, replace

* Start with the startup person data - get startup people in.
use datastartuplist, replace
joinby startup_id using "H:/Startups/Raw/datastartuppersonsfull.dta"
keep startup_id finorg_id person_id original arab armenia bulgaria china czechrep denmark ethiopia philippines finland france germany greece hungary india ireland italy japan israel southkorea lithuania norway poland portugal russia slovakrep sweden ukraine vietnam serbia croatia slovenia britain netherlands spain uidc countryc namec bachelors mba masters med phd law

* Then get combinations of finorg people in.
joinby finorg_id using temp
sort startup_id finorg_id person_id person_id_finorg
duplicates drop startup_id finorg_id person_id uidc bachelors mba masters med phd law person_id_finorg uidc_finorg bachelors_finorg mba_finorg masters_finorg med_finorg phd_finorg law_finorg, force
save temp, replace

* Get the ethnic match raw numbers.
use temp, replace
foreach var in arab armenia bulgaria china czechrep denmark ethiopia philippines finland france germany greece hungary india ireland italy japan israel southkorea lithuania norway poland portugal russia slovakrep sweden ukraine vietnam serbia croatia slovenia britain netherlands spain{
	generate `var'_match = 0
	replace `var'_match = 1 if `var' == 1 & `var'_finorg == 1
	drop `var' `var'_finorg
	}
save temp, replace

* Then the education match - with and without degree match.
use temp, replace
generate educ_inst_match = 0
replace educ_inst_match = 1 if uidc == uidc_finorg & uidc != ""
generate educ_inst_deg_match = 0
* Get the degree and educ match done.
foreach var in bachelors mba masters med phd law{
	replace educ_inst_deg_match = 1 if uidc == uidc_finorg & (`var' + `var'_finorg == 2) & uidc != ""
	}

* Here the variant of just US...
generate educ_inst_us_match = 0
replace educ_inst_us_match = 1 if uidc == uidc_finorg & countryc == "United States"
generate educ_inst_us_deg_match = 0
* Get the degree and educ match done.
foreach var in bachelors mba masters med phd law{
	replace educ_inst_us_deg_match = 1 if uidc == uidc_finorg & (`var' + `var'_finorg == 2) & countryc == "United States"
	}

* Here the variant of non-US...
generate educ_inst_nonus_match = 0
replace educ_inst_nonus_match = 1 if uidc == uidc_finorg & countryc != "United States"
generate educ_inst_nonus_deg_match = 0
* Get the degree and educ match done.
foreach var in bachelors mba masters med phd law{
	replace educ_inst_nonus_deg_match = 1 if uidc == uidc_finorg & (`var' + `var'_finorg == 2) & countryc != "United States"
	}
	
foreach var in bachelors mba masters med phd law{
	drop `var' `var'_finorg
	}
save dataeducationethnicraw, replace

use dataeducationethnicraw, replace
sort startup_id finorg_id person_id person_id_finorg
* Get the sum of matches.
collapse (sum) arab_match armenia_match bulgaria_match china_match czechrep_match denmark_match ethiopia_match philippines_match finland_match france_match germany_match greece_match hungary_match india_match ireland_match italy_match japan_match israel_match southkorea_match lithuania_match norway_match poland_match portugal_match russia_match slovakrep_match sweden_match ukraine_match vietnam_match serbia_match croatia_match slovenia_match britain_match netherlands_match spain_match educ_inst_match educ_inst_deg_match educ_inst_us_match educ_inst_us_deg_match educ_inst_nonus_match educ_inst_nonus_deg_match, by(startup_id finorg_id original)
foreach var of varlist _all {
	label var `var' ""
	}
* Get the raw numbers by startup and finorg pair.
save dataeducationethnicbase, replace

* Now cut if off to binary.
use dataeducationethnicbase, replace
foreach var in arab_match armenia_match bulgaria_match china_match czechrep_match denmark_match ethiopia_match philippines_match finland_match france_match germany_match greece_match hungary_match india_match ireland_match italy_match japan_match israel_match southkorea_match lithuania_match norway_match poland_match portugal_match russia_match slovakrep_match sweden_match ukraine_match vietnam_match serbia_match croatia_match slovenia_match britain_match netherlands_match spain_match educ_inst_match educ_inst_deg_match educ_inst_us_match educ_inst_us_deg_match educ_inst_nonus_match educ_inst_nonus_deg_match{
	replace `var' = 1 if `var' >= 2
	}
save dataeducationethnic, replace








* Okay, now let's build the data.
use dataculturevariance, replace
generate match = 1
save temp, replace

use dataeducationethnic, replace
* Add startup gender culture numbers.
merge m:1 startup_id using datastartupgenderculture
keep if _merge == 3
drop _merge
* Add finorg gender culture numbers.
merge m:1 finorg_id using datafinorggenderculture
keep if _merge == 3
drop _merge
generate match = 1
* Add the culture variance numbers.
merge m:1 match using temp
drop _merge match

* Calculate the euclidean stuff beginning here.
* Below is (x_startup - x_finorg)/(variance_x)...
foreach var in rawpdi rawidv rawmas rawuai rawltowvs rawivr rawautonomy rawimmigrants rawimmigrant_econ rawrace rawfreedom rawgender_equality rawrespect rawunselfishness rawincome_equality rawcompetition rawreligion rawtrust rawproud_country rawfight_country{
	generate calculate_`var' = ((`var' - `var'_finorg)^2) / (variance_`var')
	drop `var' `var'_finorg variance_`var'
	}
save temp, replace

* Generate cultural distance...
use temp, replace
egen hofstede_num = rownonmiss(calculate_rawpdi calculate_rawidv calculate_rawmas calculate_rawuai calculate_rawltowvs calculate_rawivr)
generate hofstede_cult_dist = sqrt((calculate_rawpdi + calculate_rawidv + calculate_rawmas + calculate_rawuai + calculate_rawltowvs + calculate_rawivr)/ hofstede_num)
egen cult_num = rownonmiss(calculate_rawpdi calculate_rawidv calculate_rawmas calculate_rawuai calculate_rawltowvs calculate_rawivr calculate_rawautonomy calculate_rawimmigrants calculate_rawimmigrant_econ calculate_rawrace calculate_rawfreedom calculate_rawgender_equality calculate_rawrespect calculate_rawunselfishness calculate_rawincome_equality calculate_rawcompetition calculate_rawreligion calculate_rawtrust calculate_rawproud_country calculate_rawfight_country)
generate cult_dist = sqrt((calculate_rawpdi + calculate_rawidv + calculate_rawmas + calculate_rawuai + calculate_rawltowvs + calculate_rawivr + calculate_rawautonomy + calculate_rawimmigrants + calculate_rawimmigrant_econ + calculate_rawrace + calculate_rawfreedom + calculate_rawgender_equality + calculate_rawrespect + calculate_rawunselfishness + calculate_rawincome_equality + calculate_rawcompetition + calculate_rawreligion + calculate_rawtrust + calculate_rawproud_country + calculate_rawfight_country)/ cult_num)
egen wvs_num = rownonmiss(calculate_rawautonomy calculate_rawimmigrants calculate_rawimmigrant_econ calculate_rawrace calculate_rawfreedom calculate_rawgender_equality calculate_rawrespect calculate_rawunselfishness calculate_rawincome_equality calculate_rawcompetition calculate_rawreligion calculate_rawtrust calculate_rawproud_country calculate_rawfight_country)
generate wvs_cult_dist = sqrt((calculate_rawautonomy + calculate_rawimmigrants + calculate_rawimmigrant_econ + calculate_rawrace + calculate_rawfreedom + calculate_rawgender_equality + calculate_rawrespect + calculate_rawunselfishness + calculate_rawincome_equality + calculate_rawcompetition + calculate_rawreligion + calculate_rawtrust + calculate_rawproud_country + calculate_rawfight_country)/ wvs_num)
drop calculate_*
drop hofstede_num cult_num wvs_num
gsort + startup_id - original + finorg_id
save datasimilarity, replace

* Merge into the startup data.
use "H:/Startups/Raw/datastartup.dta", clear
keep startup_id startup_exit_date_t startup_funding_date_t startup_exit startup_acq startup_ipo startup_exit_fund_5 startup_acq_fund_5 startup_ipo_fund_5 startup_exit_fund_7 startup_acq_fund_7 startup_ipo_fund_7 startup_ind_pred startup_funding_year_t geography
duplicates drop startup_id, force
save temp, replace

use datasimilarity, replace
merge m:1 startup_id using temp
keep if _merge == 3
drop _merge
save temp, replace

* OKAY.
* Data analysis.
use temp, replace
egen geography_c = group(geography)
egen startup_funding_year_t_c = group(startup_funding_year_t)
egen startup_ind_pred_c = group(startup_ind_pred)
generate female_startup = 0
replace female_startup = 1 if female_startup_total > 0
generate female_finorg = 0
replace female_finorg = 1 if female_finorg_total > 0
generate female_both = female_startup * female_finorg
generate ethnic_match = 0
foreach var in arab_match armenia_match bulgaria_match china_match czechrep_match denmark_match ethiopia_match philippines_match finland_match france_match germany_match greece_match hungary_match india_match ireland_match italy_match japan_match israel_match southkorea_match lithuania_match norway_match poland_match portugal_match russia_match slovakrep_match sweden_match ukraine_match vietnam_match serbia_match croatia_match slovenia_match britain_match netherlands_match spain_match{
	replace ethnic_match = 1 if `var' == 1
}
generate minority_match = 0
foreach var in china_match india_match japan_match israel_match southkorea_match russia_match vietnam_match spain_match{
	replace minority_match = 1 if `var' == 1
}
egen startup_c = group(startup_id)
egen finorg_c = group(finorg_id)
save datafinal, replace



*** TESTS HERE...?
* basic logit.

cd "H:/Startups/Random"
use datafinal, replace
drop if startup_funding_year_t < 2004

/*
eststo clear
eststo: quietly logistic original educ_inst_match, or vce(robust)
eststo: quietly logistic original educ_inst_deg_match, or vce(robust)
eststo: quietly logistic original ethnic_match, or vce(robust)
eststo: quietly logistic original minority_mach, or vce(robust)
eststo: quietly logistic original hofstede_cult_dist, or vce(robust)
eststo: quietly logistic original wvs_cult_dist, or vce(robust)
eststo: quietly logistic original cult_dist, or vce(robust)
eststo: quietly logistic original female_startup female_finorg female_both, or vce(robust)
eststo: quietly logistic original educ_inst_match ethnic_match cult_dist female_startup female_finorg female_both, or vce(robust)
eststo: quietly logistic original educ_inst_deg_match ethnic_match cult_dist female_startup female_finorg female_both, or vce(robust)
esttab using output-selectr-no.csv, replace eform pr2 star(* 0.10 ** 0.05 *** 0.01)
eststo clear
*/

eststo clear
eststo: quietly logistic original educ_inst_match i.geography_c i.startup_funding_year_t_c i.startup_ind_pred_c, or vce(robust)
eststo: quietly logistic original educ_inst_deg_match i.geography_c i.startup_funding_year_t_c i.startup_ind_pred_c, or vce(robust)
eststo: quietly logistic original ethnic_match i.geography_c i.startup_funding_year_t_c i.startup_ind_pred_c, or vce(robust)
eststo: quietly logistic original minority_match i.geography_c i.startup_funding_year_t_c i.startup_ind_pred_c, or vce(robust)
eststo: quietly logistic original hofstede_cult_dist i.geography_c i.startup_funding_year_t_c i.startup_ind_pred_c, or vce(robust)
eststo: quietly logistic original wvs_cult_dist i.geography_c i.startup_funding_year_t_c i.startup_ind_pred_c, or vce(robust)
eststo: quietly logistic original cult_dist i.geography_c i.startup_funding_year_t_c i.startup_ind_pred_c, or vce(robust)
eststo: quietly logistic original female_startup female_finorg female_both i.geography_c i.startup_funding_year_t_c i.startup_ind_pred_c, or vce(robust)
eststo: quietly logistic original educ_inst_match ethnic_match cult_dist female_startup female_finorg female_both i.geography_c i.startup_funding_year_t_c i.startup_ind_pred_c, or vce(robust)
eststo: quietly logistic original educ_inst_deg_match ethnic_match cult_dist female_startup female_finorg female_both i.geography_c i.startup_funding_year_t_c i.startup_ind_pred_c, or vce(robust)
eststo: quietly logistic original educ_inst_match minority_match cult_dist female_startup female_finorg female_both i.geography_c i.startup_funding_year_t_c i.startup_ind_pred_c, or vce(robust)
eststo: quietly logistic original educ_inst_deg_match minority_match cult_dist female_startup female_finorg female_both i.geography_c i.startup_funding_year_t_c i.startup_ind_pred_c, or vce(robust)
esttab using output-selectr-yes.csv, replace eform pr2 star(* 0.10 ** 0.05 *** 0.01)
eststo clear


*** SUMMARY STATS...
** Stuff that is based on the final data.
cd "H:/Startups/Random"
use datafinal, replace
drop if startup_funding_year_t < 2004
generate observations = 1
* keep if original == 1

* Variables that are count-ish.
estpost tabstat educ_inst_match educ_inst_deg_match ethnic_match minority_match female_startup female_finorg female_both observations, by(startup_funding_year_t) statistics(sum) columns(statistics) listwise
esttab . using output-summaryr-variables-count.csv, replace main("sum") nostar noobs unstack nonote

* Variables for calculating differences.
estpost summarize educ_inst_match educ_inst_deg_match ethnic_match minority_match female_startup female_finorg female_both hofstede_cult_dist wvs_cult_dist cult_dist
esttab . using output-summaryr-variables-diffs.csv, replace cells("mean Var count")

* Variables that we might want to see averages of...
estpost summarize hofstede_cult_dist wvs_cult_dist cult_dist, detail
esttab . using output-summaryr-variables-stats.csv, replace cells("mean sd p25 p50 p75 count")
