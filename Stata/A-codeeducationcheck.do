* 01: After SQL.
* Basic stuff.
cd "H:/Startups/Raw/"
set more off

*** Education data.
* Import.
import delimited using abc_finorg_persons, clear varnames(1)
save test, replace

* Append startup people data.
import delimited using abc_startup_persons, clear varnames(1)
append using test

* Keep only stuff we want to check...
keep degree_institution degree_subject degree_type
drop if degree_institution == ""
sort degree_institution

* Count number of occurences of raw institution name...
quietly by degree_institution: gen institution_count = cond(_N==1,1,_N)
duplicates drop degree_institution, force
gsort - institution_count
save dataeduccount, replace

* Bring in Joonho's university code...
use kjhuniversitycode, replace
generate degree_institution = lower(institution_orig)
drop institution_orig
save temp, replace

* Merge.
use dataeduccount, replace
replace degree_institution = lower(degree_institution)
replace degree_type = lower(degree_type)
merge m:1 degree_institution using temp
drop if _merge == 2
drop _merge
sort university_level_id_USETHIS
rename university_level_id_USETHIS university_level_id
rename unisyslvl_univlvl_id_USETHIS unisyslvl_univlvl_id
save dataeduccount, replace

* Bring in Joonho's degree code...
use kjhdegreecode, replace
replace degree_type = lower(degree_type)
save temp, replace

* Merge.
use dataeduccount, replace
merge m:1 degree_type using temp
drop if _merge == 2
drop _merge
save dataeduccount, replace

* Counts.
use dataeduccount, replace
sort degree_type
quietly by degree_type: gen degree_type_count = cond(_N==1,1,_N)
sort university_level_id
quietly by university_level_id: gen university_level_id_count = cond(_N==1,1,_N)
sort degree_institution
quietly by degree_institution: gen degree_institution_count = cond(_N==1,1,_N)
save dataeduccount, replace
export excel dataeduccount.xlsx, replace firstrow(variables)

* Create degree files to check.
use dataeduccount, replace
keep degree_type bachelors mba masters med phd law degree_type_count
duplicates drop degree_type, force
save dataeduccountdegree, replace
export excel dataeduccountdegree.xlsx, replace firstrow(variables)
* Edit this file manually as needed and save as dataeduccountdegreechecked.xlsx.

* Bring in the cleaned degree data.
import excel using dataeduccountdegreechecked.xlsx, clear firstrow
drop degree_type_count degree_fill
save dataeducdegreecleanbase, replace

* Create institution files to check.
use dataeduccount, replace
keep degree_institution institution_count university_level_id unisyslvl_univlvl_id university_level_id_count degree_institution_count
duplicates drop degree_institution, force
save dataeduccountschool, replace
export excel dataeduccountschool.xlsx, replace firstrow(variables)
* Unfortunately too large for manual, reclink needed.

* Alternative method for the schools...
import delimited using "H:\Startups\Institutes\webometric-univ.csv", clear 
drop country3iso
egen degree_institution_raw = sieve(name), keep(a n)
replace degree_institution_raw = lower(degree_institution_raw)
rename id uid
save temp, replace

use dataeduccountschool, replace
generate id = _n
egen degree_institution_raw = sieve(degree_institution), keep(a n)
replace degree_institution_raw = lower(degree_institution_raw)
reclink degree_institution_raw using temp, gen(matchscore) idmaster(id) idusing(uid) wmatch(15)

sort degree_institution matchscore
duplicates drop degree_institution, force
save dataeduccountschoolwebo, replace
export excel dataeduccountschoolwebo.xlsx, replace firstrow(variables)
* Edit this file manually as needed and save as dataeduccountschoolweboedited.xlsx.
* Perhaps just the most common occurences...


* Bring in the cleaned school data.
import excel using dataeduccountschoolweboedited.xlsx, clear firstrow
keep degree_institution id editcode uidc countryc namec
drop if editcode == ""
drop if editcode == "check"
drop id editcode
save dataeduccleanbase, replace

