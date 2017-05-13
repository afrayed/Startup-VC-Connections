* 03: After codefinorg.
* Basic stuff.
cd "H:/Startups/Raw/"
set more off

* Test VentureXpert fund company variables.
import excel using fundfirms.xlsx, clear firstrow
save datasdcfundfirms, replace

* Drop variables that are totally empty...
use datasdcfundfirms, clear
drop FirmsAvgCompanyInvestment-TotalKnownAmtInvestedbyFirm
drop if year(FirmFoundingDate) > 2013

* Drop variables that probably won't be used.
drop StandardUSVentureBuyout FirmAreaCode FirmMSA FirmMSACode PWCMoneytreeDealsYN StandardUSVentureDisbursement FirmMembershipAffiliations
save datasdcfundfirms, replace

* Rename...
use datasdcfundfirms, clear
rename N RowN
rename FirmFoundingDate firm_found_date
rename FirmCapitalunderMgmt0Mil firm_aum
rename FirmCity firm_city
rename FirmFeesChargedtoCompany firm_coy_fee_type
rename FirmInvestmentStatus firm_status
rename FirmMinCompanySalesRequdfo firm_min_coy_sales
rename FirmName firm_name
rename FirmNationCode firm_nation
rename FirmStateRegion firm_state_region
rename FirmsFundsGeneralWorldRegi firm_fund_world_region
rename FirmsFundsSpecificWorldReg firm_fund_world_region_spec
rename FirmGeographyPreference firm_geog_pref
rename FirmIndustryPreference firm_ind_pref
rename FirmPreferredInvestmntRoleC firm_inv_role_pref
rename FirmInvestmentStagePreference firm_inv_stage_pref
rename FirmPreferredMaxInvestmentU firm_max_inv_pref
rename FirmPreferredMinInvestmentU firm_min_inv_pref
rename FirmStateCode firm_state
rename FirmType firm_type
rename FirmGeneralWorldRegion firm_world_region
rename FirmSpecificWorldRegion firm_world_region_spec
rename FirmZipCode firm_zip_code
replace firm_geog_pref = "United States" if firm_geog_pref == "All U.S."
save datasdcfundfirms, replace


/* Likely variables to use:
### firm_aum
firm_name
### firm_nation
### firm_state_region
firm_fund_world_region
firm_fund_world_region_spec
### firm_geog_pref
### firm_ind_pref
### firm_inv_role_pref
### firm_inv_stage_pref
firm_max_inv_pref
firm_min_inv_pref
### firm_state
### firm_type
### firm_world_region
### firm_world_region_spec
firm_zip_code
*/

*** Now figure out reclink...
* Clean the text.
use datasdcfundfirms, clear 
generate fund_name_norm = firm_name
replace fund_name_norm = lower(fund_name_norm)
replace fund_name_norm = subinstr(fund_name_norm, " and ", " & ", .)
replace fund_name_norm = subinstr(fund_name_norm, ".", "", .)
replace fund_name_norm = subinstr(fund_name_norm, ",", "", .)
replace fund_name_norm = subinstr(fund_name_norm, "(", "", .)
replace fund_name_norm = subinstr(fund_name_norm, ")", "", .)
replace fund_name_norm = subinstr(fund_name_norm, "_", "", .)
replace fund_name_norm = subinstr(fund_name_norm, "-", "", .)
replace fund_name_norm = subinstr(fund_name_norm, "*", "", .)
replace fund_name_norm = subinstr(fund_name_norm, "#", "", .)
replace fund_name_norm = subinstr(fund_name_norm, "corporation", "corp", .)
replace fund_name_norm = subinstr(fund_name_norm, " cp", " corp", .)
replace fund_name_norm = subinstr(fund_name_norm, "international", "intl", .)
replace fund_name_norm = subinstr(fund_name_norm, "company", "co", .)
replace fund_name_norm = subinstr(fund_name_norm, "brothers", "Bros", .)
replace fund_name_norm = subinstr(fund_name_norm, "[", "", .)
replace fund_name_norm = subinstr(fund_name_norm, "]", "", .)
replace fund_name_norm = subinstr(fund_name_norm, "holding", "hldg", .)
replace fund_name_norm = subinstr(fund_name_norm, "holdings", "hldg", .)
replace fund_name_norm = subinstr(fund_name_norm, " hld ", " hldg ", .)
replace fund_name_norm = subinstr(fund_name_norm, "partners", "prtrs", .)
replace fund_name_norm = subinstr(fund_name_norm, " prt ", " prtrs ", .)
replace fund_name_norm = subinstr(fund_name_norm, " group", " gp", .)
replace fund_name_norm = subinstr(fund_name_norm, " limited", " ltd", .)
replace fund_name_norm = subinstr(fund_name_norm, " llc", "", .)
replace fund_name_norm = subinstr(fund_name_norm, " l l c", "", .)
replace fund_name_norm = subinstr(fund_name_norm, " llp", "", .)
replace fund_name_norm = subinstr(fund_name_norm, " l l p", "", .)
replace fund_name_norm = subinstr(fund_name_norm, " lp", "", .)
replace fund_name_norm = subinstr(fund_name_norm, " l p", "", .)
replace fund_name_norm = subinstr(fund_name_norm, " usa ", " us", .)
replace fund_name_norm = subinstr(fund_name_norm, "properties", "pptys", .)
replace fund_name_norm = subinstr(fund_name_norm, "solutions", "solutn", .)
replace fund_name_norm = subinstr(fund_name_norm, "soltns", "solutn", .)

replace fund_name_norm = subinstr(fund_name_norm, "investment", "invt", .)
replace fund_name_norm = subinstr(fund_name_norm, " invst", " invt", .)
replace fund_name_norm = subinstr(fund_name_norm, " inv ", " invt ", .)
replace fund_name_norm = subinstr(fund_name_norm, " partners", " prtrs", .)

replace fund_name_norm = subinstr(fund_name_norm, " financial ", " finl ", .)
replace fund_name_norm = subinstr(fund_name_norm, " trust ", " tr ", .)
replace fund_name_norm = subinstr(fund_name_norm, " system ", " systm ", .)
replace fund_name_norm = subinstr(fund_name_norm, " sys ", " systm ", .)
replace fund_name_norm = subinstr(fund_name_norm, " products", " prods", .)
replace fund_name_norm = subinstr(fund_name_norm, " cooperative", "coop", .)
replace fund_name_norm = subinstr(fund_name_norm, "real estate investment", "re investment", .)
replace fund_name_norm = subinstr(fund_name_norm, "logistics", "lgs", .)
replace fund_name_norm = subinstr(fund_name_norm, "infrastructure", "infrastr", .)
replace fund_name_norm = subinstr(fund_name_norm, "building", "bldg", .)
replace fund_name_norm = subinstr(fund_name_norm, " metals", "metls", .)
replace fund_name_norm = subinstr(fund_name_norm, "utilities", "util", .)
replace fund_name_norm = subinstr(fund_name_norm, " development", " dev", .)

replace fund_name_norm = subinstr(fund_name_norm, " bank corporation", " bk", .)
replace fund_name_norm = subinstr(fund_name_norm, " bancorporation", " bk", .)
replace fund_name_norm = subinstr(fund_name_norm, " bank corp", " bk", .)
replace fund_name_norm = subinstr(fund_name_norm, " bancorp", " bk", .)
replace fund_name_norm = subinstr(fund_name_norm, " bancshares", " bk", .)
replace fund_name_norm = subinstr(fund_name_norm, " banks", " bk", .)
replace fund_name_norm = subinstr(fund_name_norm, " bank", " bk", .)

replace fund_name_norm = subinstr(fund_name_norm, " sdn bhd", "", .)
replace fund_name_norm = subinstr(fund_name_norm, " gmbh", "", .)

replace fund_name_norm = subinstr(fund_name_norm, " ", "", .)
generate state = lower(firm_state)
generate country = lower(substr(firm_nation, 1, 2))
generate fund_name_first_10 = substr(fund_name_norm, 1, 10)
rename RowN URowN
save datasdcfundfirmsmatch, replace


use datafinorg, replace
generate fund_name_norm = finorg_name_raw
replace fund_name_norm = lower(fund_name_norm)
replace fund_name_norm = subinstr(fund_name_norm, " and ", " & ", .)
replace fund_name_norm = subinstr(fund_name_norm, ".", "", .)
replace fund_name_norm = subinstr(fund_name_norm, ",", "", .)
replace fund_name_norm = subinstr(fund_name_norm, "(", "", .)
replace fund_name_norm = subinstr(fund_name_norm, ")", "", .)
replace fund_name_norm = subinstr(fund_name_norm, "_", "", .)
replace fund_name_norm = subinstr(fund_name_norm, "-", "", .)
replace fund_name_norm = subinstr(fund_name_norm, "*", "", .)
replace fund_name_norm = subinstr(fund_name_norm, "#", "", .)
replace fund_name_norm = subinstr(fund_name_norm, "corporation", "corp", .)
replace fund_name_norm = subinstr(fund_name_norm, " cp", " corp", .)
replace fund_name_norm = subinstr(fund_name_norm, "international", "intl", .)
replace fund_name_norm = subinstr(fund_name_norm, "company", "co", .)
replace fund_name_norm = subinstr(fund_name_norm, "brothers", "Bros", .)
replace fund_name_norm = subinstr(fund_name_norm, "[", "", .)
replace fund_name_norm = subinstr(fund_name_norm, "]", "", .)
replace fund_name_norm = subinstr(fund_name_norm, "holding", "hldg", .)
replace fund_name_norm = subinstr(fund_name_norm, "holdings", "hldg", .)
replace fund_name_norm = subinstr(fund_name_norm, " hld ", " hldg ", .)
replace fund_name_norm = subinstr(fund_name_norm, "partners", "prtrs", .)
replace fund_name_norm = subinstr(fund_name_norm, " prt ", " prtrs ", .)
replace fund_name_norm = subinstr(fund_name_norm, " group", " gp", .)
replace fund_name_norm = subinstr(fund_name_norm, " limited", " ltd", .)
replace fund_name_norm = subinstr(fund_name_norm, " llc", "", .)
replace fund_name_norm = subinstr(fund_name_norm, " l l c", "", .)
replace fund_name_norm = subinstr(fund_name_norm, " llp", "", .)
replace fund_name_norm = subinstr(fund_name_norm, " l l p", "", .)
replace fund_name_norm = subinstr(fund_name_norm, " lp", "", .)
replace fund_name_norm = subinstr(fund_name_norm, " l p", "", .)
replace fund_name_norm = subinstr(fund_name_norm, " usa ", " us", .)
replace fund_name_norm = subinstr(fund_name_norm, "properties", "pptys", .)
replace fund_name_norm = subinstr(fund_name_norm, "solutions", "solutn", .)
replace fund_name_norm = subinstr(fund_name_norm, "soltns", "solutn", .)

replace fund_name_norm = subinstr(fund_name_norm, "investment", "invt", .)
replace fund_name_norm = subinstr(fund_name_norm, " invst", " invt", .)
replace fund_name_norm = subinstr(fund_name_norm, " inv ", " invt ", .)
replace fund_name_norm = subinstr(fund_name_norm, " partners", " prtrs", .)

replace fund_name_norm = subinstr(fund_name_norm, " financial ", " finl ", .)
replace fund_name_norm = subinstr(fund_name_norm, " trust ", " tr ", .)
replace fund_name_norm = subinstr(fund_name_norm, " system ", " systm ", .)
replace fund_name_norm = subinstr(fund_name_norm, " sys ", " systm ", .)
replace fund_name_norm = subinstr(fund_name_norm, " products", " prods", .)
replace fund_name_norm = subinstr(fund_name_norm, " cooperative", "coop", .)
replace fund_name_norm = subinstr(fund_name_norm, "real estate investment", "re investment", .)
replace fund_name_norm = subinstr(fund_name_norm, "logistics", "lgs", .)
replace fund_name_norm = subinstr(fund_name_norm, "infrastructure", "infrastr", .)
replace fund_name_norm = subinstr(fund_name_norm, "building", "bldg", .)
replace fund_name_norm = subinstr(fund_name_norm, " metals", "metls", .)
replace fund_name_norm = subinstr(fund_name_norm, "utilities", "util", .)
replace fund_name_norm = subinstr(fund_name_norm, " development", " dev", .)

replace fund_name_norm = subinstr(fund_name_norm, " bank corporation", " bk", .)
replace fund_name_norm = subinstr(fund_name_norm, " bancorporation", " bk", .)
replace fund_name_norm = subinstr(fund_name_norm, " bank corp", " bk", .)
replace fund_name_norm = subinstr(fund_name_norm, " bancorp", " bk", .)
replace fund_name_norm = subinstr(fund_name_norm, " bancshares", " bk", .)
replace fund_name_norm = subinstr(fund_name_norm, " banks", " bk", .)
replace fund_name_norm = subinstr(fund_name_norm, " bank", " bk", .)

replace fund_name_norm = subinstr(fund_name_norm, " sdn bhd", "", .)
replace fund_name_norm = subinstr(fund_name_norm, " gmbh", "", .)

replace fund_name_norm = subinstr(fund_name_norm, " ", "", .)
generate state = lower(finorg_state)
generate country = lower(substr(finorg_country, 1, 2))
generate fund_name_first_10 = substr(fund_name_norm, 1, 10)
save temp, replace

* Match...
use temp, replace
reclink fund_name_first_10 fund_name_norm state country using datasdcfundfirmsmatch, gen(matchscore) idmaster(RowN) idusing(URowN) required(state) wmatch(10 7 10 10)
save datacbsdcfundmatchbackup, replace
use datacbsdcfundmatchbackup, replace
drop _merge
save datacbsdcfundmatch, replace
use datacbsdcfundmatch, replace
export delimited using datafinorg_sdc.csv, replace

