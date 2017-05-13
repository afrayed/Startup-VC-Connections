* 01: After SQL.
* Basic stuff.
cd "H:/Startups/Raw/"
set more off

*** Startup data.
* Import.
import delimited using abc_startup_data, clear

* Cut the extra zip code and drop lines which are completely the same.
replace startup_zip_code = substr(startup_zip_code,1,5)
unab vlist: _all
sort `vlist'
quietly by `vlist': gen duplicate = cond(_N == 1, 0, _n)
drop if duplicate > 1
drop duplicate
save datastartup, replace

* Remove non-valid zips and generate a zip code list for matching later.
use datastartup, replace
drop if startup_zip_code == ""
drop if length(startup_zip_code) != 5
duplicates drop startup_city startup_country, force
rename startup_zip_code tempzip
save temp, replace

* Fill in zip codes.
use datastartup, replace
merge m:1 startup_city startup_country using temp
replace startup_zip_code = tempzip if startup_zip_code == ""
drop if _merge == 1
drop tempzip _merge
save datastartup, replace

* Some startups have multiple lines...
use datastartup, replace
sort startup_id startup_acq_date
drop if startup_acq_price > 0 & startup_acq_date == ""
sort startup_id startup_acq_date
duplicates drop startup_id, force
save datastartup, replace

* Merge in data rounds.
import delimited using abc_funding_rounds, clear
save temp, replace
use datastartup, replace
merge 1:m startup_id using temp
keep if _merge == 3
drop _merge startup_round_one
save datastartup, replace

* Taking care of those with both acquisition and ipo dates.
use datastartup, replace
replace startup_acq_date = "" if startup_acq_date > startup_ipo_date & startup_acq_date != "" & startup_ipo_date != ""
replace startup_ipo_date = "" if startup_acq_date < startup_ipo_date & startup_acq_date != "" & startup_ipo_date != ""
save datastartup, replace

* Generate the exit variables.
use datastartup, replace
generate startup_acq_date_t = date(startup_acq_date, "YMD")
generate startup_ipo_date_t = date(startup_ipo_date, "YMD")
generate startup_exit_date_t = startup_acq_date_t
replace startup_exit_date_t = startup_ipo_date_t if startup_ipo_date_t != . & startup_acq_date_t == .

generate startup_funding_date_t = date(startup_funding_date, "YMD")
generate startup_funding_year_t = year(startup_funding_date_t)
generate abcd = year(startup_acq_date_t)

generate startup_acq = ((startup_acq_date_t != .) & (startup_acq_date_t > startup_funding_date_t))
generate startup_acq_fund_5 = ((startup_acq_date_t < (startup_funding_date_t + (5 * 365))) & (startup_acq_date_t > startup_funding_date_t))
generate startup_acq_fund_7 = ((startup_acq_date_t < (startup_funding_date_t + (7 * 365))) & (startup_acq_date_t > startup_funding_date_t) & (year(startup_funding_date_t) < 2007))

generate startup_ipo = (startup_ipo_date_t != . & startup_ipo_date_t > startup_funding_date_t)
generate startup_ipo_fund_5 = (startup_ipo_date_t < (startup_funding_date_t + (5 * 365)) & startup_ipo_date_t > startup_funding_date_t)
generate startup_ipo_fund_7 = (startup_ipo_date_t < (startup_funding_date_t + (7 * 365)) & startup_ipo_date_t > startup_funding_date_t & year(startup_funding_date_t) < 2007)

generate startup_exit = (startup_exit_date_t != . & startup_exit_date_t > startup_funding_date_t)
generate startup_exit_fund_5 = (startup_exit_date_t < (startup_funding_date_t + (5 * 365)) & startup_exit_date_t > startup_funding_date_t)
generate startup_exit_fund_7 = (startup_exit_date_t < (startup_funding_date_t + (7 * 365)) & startup_exit_date_t > startup_funding_date_t & year(startup_funding_date_t) < 2007)

save datastartup, replace

* Merge in the industry predictions.
use datastartup, replace
import delimited using startupindpredictions, clear varnames(1)
rename sub1 startup_ind_pred
duplicates drop startup_id, force
save temp, replace
use datastartup, replace
merge m:1 startup_id using temp
keep if _merge == 3
drop _merge
sort startup_id
*drop if year(startup_funding_date_t) > 2008
save datastartup, replace

* Bringing in the MSA.
use datastartup, replace
generate geography = ""
replace geography = "Non-US" if startup_country != "USA"
replace geography = "Rest of US" if startup_country == "USA"
generate original = 1
save datastartup, replace

* Here, MSA.
import delimited using zcta5cbsa.csv, clear varnames(1) stringcols(_all)
rename zcta5 startup_zip_code
save temp, replace
use datastartup, replace
merge m:1 startup_zip_code using temp
drop if _merge == 2
replace geography = "Boston" if cbsa == "14460"
replace geography = "Chicago" if cbsa == "16980"
replace geography = "NYC" if cbsa == "35620"
replace geography = "SFSJ" if cbsa == "41860" | cbsa == "41940"
replace geography = "Seattle" if cbs == "42660"
save datastartup, replace
