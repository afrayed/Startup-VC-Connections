* 01: After SQL.
* Basic stuff.
cd "H:/Startups/Raw/"
set more off

*** Finorg data.
* Import.
import delimited using abc_finorg_data, clear

* Cut the extra zip code and drop lines which are completely the same.
replace finorg_zip_code = substr(finorg_zip_code,1,5)
unab vlist: _all
sort `vlist'
quietly by `vlist': gen duplicate = cond(_N == 1, 0, _n)
drop if duplicate > 1
drop duplicate
save datafinorg, replace

* Remove non-valid zips and generate a zip code list for matching later.
use datafinorg, replace
drop if finorg_zip_code == ""
drop if length(finorg_zip_code) != 5
duplicates drop finorg_city finorg_country, force
rename finorg_zip_code tempzip
save temp, replace

* Final base finorg data file.
use datafinorg, replace
merge m:1 finorg_city finorg_country using temp
replace finorg_zip_code = tempzip if finorg_zip_code == ""
drop if _merge == 1
drop tempzip _merge
generate finorg_founding_date_t = date(finorg_founding_date, "YMD")
duplicates drop finorg_id, force
generate RowN = _n
* drop if year(finorg_founding_date_t) > 2008
save datafinorg, replace
