* 02: After SQL and R.
* Basic stuff.
cd "H:/Startups/Raw/"
set more off

* Load data.
use WV6_Stata_V_2016_01_01, replace
drop autonomy
generate autonomy = (V19 + V21) - (V12 + V18) if V19 >= 0 & V21 >= 0 & V12 >= 0 & V18 >= 0

* Keep and rename vars.
keep V2 autonomy V39 V46 V37 V55 V45 V16 V20 V96 V99 V9 V24 V211 V66

rename V2 country
generate immigrants = .
replace immigrants = V39 if V39 == 1 | V39 == 2
generate immigrant_econ = .
replace immigrant_econ = V46 if V46 >= 1 & V46 <= 3
generate race = .
replace race = V37 if V37 == 1 | V37 == 2
generate freedom = .
replace freedom = V55 if V55 >= 1 & V55 <= 10
generate gender_equality = .
replace gender_equality = V45 if V45 >= 1 & V45 <= 3
generate respect = .
replace respect = V16 if V16 == 1 | V16 == 2
generate unselfishness = .
replace unselfishness = V20 if V20 == 1 | V20 == 2
generate income_equality = .
replace income_equality = V96 if V96 >= 1 & V96 <= 10
generate competition = .
replace competition = V99 if V99 >= 1 & V99 <= 10
generate religion = .
replace religion = V9 if V9 >= 1 & V9 <= 4
generate trust = .
replace trust = V24 if V24 == 1 | V24 == 2
generate proud_country = .
replace proud_country = V211 if V211 >= 1 & V211 <= 4
generate fight_country = .
replace fight_country = V66 if V66 == 1 | V66 == 2

drop V39 V46 V37 V55 V45 V16 V20 V96 V99 V9 V24 V211 V66
save temp, replace

* Find national means for the wvs.
use temp, replace
collapse (mean) autonomy immigrants immigrant_econ race freedom gender_equality respect unselfishness income_equality competition religion trust proud_country fight_country, by(country)
rename country countryraw
decode countryraw, generate(country)
replace country = lower(country)
drop countryraw
save temp, replace

* Hofstede.
import excel using "H:\Startups\Cultural\hofstede.xls", clear firstrow
replace country = lower(country)
replace country = subinstr(country, "korea south", "south korea", .)
replace country = subinstr(country, "u.s.a.", "united states", .)
replace country = subinstr(country, "kyrgyz rep", "kyrgyzstan", .)
merge 1:1 country using temp
sort country
drop if _merge == 2
drop _merge
save temp, replace
export delimited using dataculturalraw.csv, replace

* Now to reshape the data.
use temp, replace
drop ctr
replace country = "britain" if country == "great britain"
replace country = "arab" if country == "arab countries"
replace country = "czechrep" if country == "czech rep"
replace country = "southkorea" if country == "south korea"
replace country = "slovakrep" if country == "slovak rep"
drop if inlist(country, "africa east", "africa west", "albania", "algeria", "andorra")
drop if inlist(country, "argentina", "australia", "austria", "azerbaijan", "bahrain")
drop if inlist(country, "bangladesh", "belarus", "belgium", "belgium french", "belgium netherl")
drop if inlist(country, "bosnia", "brazil", "burkina faso", "canada", "canada french", "chile")
drop if inlist(country, "colombia", "costa rica", "cyprus", "dominican rep", "ecuador", "egypt")
drop if inlist(country, "el salvador", "estonia", "georgia", "germany east", "ghana", "guatemala")
drop if inlist(country, "hong kong", "iceland", "indonesia", "iran", "iraq", "jamaica", "jordan")
drop if inlist(country, "kazakhstan", "kuwait", "kyrgyzstan", "latvia", "lebanon", "libya")
drop if inlist(country, "luxembourg", "macedonia rep", "malaysia", "mali", "malta", "mexico")
drop if inlist(country, "moldova", "montenegro", "morocco", "new zealand", "nigeria", "pakistan")
drop if inlist(country, "palestine", "panama", "peru", "puerto rico", "qatar", "romania", "rwanda")
drop if inlist(country, "saudi arabia", "singapore", "south africa", "south africa white")
drop if inlist(country, "suriname", "switzerland", "switzerland french", "switzerland german")
drop if inlist(country, "taiwan", "tanzania", "thailand", "trinidad and tobago", "tunisia")
drop if inlist(country, "turkey", "uganda", "united states", "uruguay", "uzbekistan", "venezuela")
drop if inlist(country, "yemen", "zambia", "zimbabwe")
generate abcd = 1
reshape wide pdi idv mas uai ltowvs ivr autonomy immigrants immigrant_econ race freedom gender_equality respect unselfishness income_equality competition religion trust proud_country fight_country, i(abcd) j(country) string
save temp, replace

* Add the ethnicity and gender data...
set seed 1729
import delimited using "H:\Startups\Names\namesgender.csv", clear
drop if oxfordmatch == -999 & gender == "NA"
generate abcd = 1
merge m:1 abcd using temp
drop _merge abcd
rename gender male
replace male = "1" if male == "male"
replace male = "0" if male == "female"
save temp, replace

* Make the string variables numeric...
use temp, replace
foreach var of varlist arabic-year_max {
replace `var' = "" if `var' == "NA"
}
destring arabic-year_max, replace
save temp, replace

* Extra stuff.
use temp, replace
gen test = male
generate female = 1
replace female = 0 if male == 1
replace female = . if male == .
drop muslim scandinavian

* Create multis.
generate british = 0
replace british = . if oxfordmatch == -999
replace british = 1 if inlist(1, english, manx, cornish, welsh, scottish)
drop english manx cornish welsh scottish
rename dutch netherlands
generate dutch = 0
replace dutch = . if oxfordmatch == -999
replace dutch = 1 if inlist(1, netherlands, frisian)
drop netherlands frisian
rename spanish spain
generate spanish = 0
replace spanish = . if oxfordmatch == -999
replace spanish = 1 if inlist(1, asturianleonese, basque, hispanic, catalan, galician)
drop spain asturianleonese basque hispanic catalan galician
drop v1
save temp, replace

* Now to clean up and get person specific culture scores.
use temp, replace
egen ethnicnum = rowtotal(arabic-slovenian british dutch spanish)
rename arabic arab
rename armenian armenia
rename british britain
rename bulgarian bulgaria
rename chinese china
rename croatian croatia
rename czech czechrep
rename danish denmark
rename ethiopian ethiopia
rename finnish finland
rename french france
rename german germany
rename greek greece
rename hungarian hungary
rename indian india
rename irish ireland
rename jewish israel
rename italian italy
rename japanese japan
rename lithuanian lithuania
rename dutch netherlands
rename norwegian norway
rename filipino philippines
rename polish poland
rename portuguese portugal
rename russian russia
rename serbian serbia
rename slovak slovakrep
rename slovenian slovenia
rename korean southkorea
rename spanish spain
rename swedish sweden
rename ukrainian ukraine
rename vietnamese vietnam
save temp, replace

* Generating the person specific scores based on ethnic distribution...
use temp, replace
foreach var in pdi idv mas uai ltowvs ivr autonomy immigrants immigrant_econ race freedom gender_equality respect unselfishness income_equality competition religion trust proud_country fight_country{
	foreach country of varlist (arab-slovenia britain netherlands spain) {
		generate `var'temp`country' = `country' * `var'`country' if `var'`country'
		}
	egen raw`var' = rowtotal(`var'temp*), missing
	replace raw`var' = raw`var' / ethnicnum
	drop `var'*
}

* Cleaning up the 0s which should be empty.
foreach var in rawpdi rawidv rawmas rawuai rawltowvs rawivr rawautonomy rawimmigrants rawimmigrant_econ rawrace rawfreedom rawgender_equality rawrespect rawunselfishness rawincome_equality rawcompetition rawreligion rawtrust rawproud_country rawfight_country {
	replace `var' = . if `var' == 0
}	

replace first_name = "" if first_name == "NA"
drop freqcount
save datacultural, replace
