* 03: After codecultural values.
* Basic stuff.
cd "H:/Startups/Raw/"
set more off

* Here, we want to combine the two persons data with...
* (a) cultural data.
* (b) school data.
* (c) degree data.

* Import finorg people.
import delimited using abc_finorg_persons, clear varnames(1)

* Get cultural data.
merge m:1 person_id using datacultural
drop if _merge == 2
drop _merge
replace degree_institution = lower(degree_institution)
save temp, replace

* Get school data.
use temp, replace
merge m:1 degree_institution using dataeduccleanbase
drop if _merge == 2
drop _merge
replace degree_type = lower(degree_type)
save temp, replace

* Get degree data. 
use temp, replace
merge m:1 degree_type using dataeducdegreecleanbase
drop if _merge == 2
drop _merge
save datafinorgpersonsfull, replace




* Import startup people.
import delimited using abc_startup_persons, clear varnames(1)

* Get cultural data.
merge m:1 person_id using datacultural
drop if _merge == 2
drop _merge
replace degree_institution = lower(degree_institution)
save temp, replace

* Get school data.
use temp, replace
merge m:1 degree_institution using dataeduccleanbase
drop if _merge == 2
drop _merge
replace degree_type = lower(degree_type)
save temp, replace

* Get degree data. 
use temp, replace
merge m:1 degree_type using dataeducdegreecleanbase
drop if _merge == 2
drop _merge
save datastartuppersonsfull, replace




* Export data...
use datafinorgpersonsfull, replace
export delimited using datafinorgpersonsfull.csv, replace quote delimiter("|")
use datafinorg, replace
export delimited using datafinorg.csv, replace quote delimiter("|")
use datastartuppersonsfull, replace
export delimited using datastartuppersonsfull.csv, replace quote delimiter("|")
use datastartup, replace
export delimited using datastartup.csv, replace quote delimiter("|")


