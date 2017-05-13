coyname = read.csv("H:/Startups/abc_startup_persons.csv", quote = "\"", encoding = "UTF-8")
coycol = unique(coyname[c("person_id", "person_name")])

finname = read.csv("H:/Startups/abc_finorg_persons.csv", quote = "\"", encoding = "UTF-8")
fincol = unique(finname[c("person_id", "person_name")])

namefile = unique(rbind(coycol, fincol))

# encoding issues...
namefile$person_name = iconv(namefile$person_name, from = "UTF-8", to = "ASCII//TRANSLIT")

# convert to upper...
namefile$person_name = toupper(namefile$person_name)
namefile$person_name = gsub(" ii", "", namefile$person_name,ignore.case = F)

# edits
namefile$person_name = gsub(", MD", "", namefile$person_name)
namefile$person_name = gsub(", M.D.", "", namefile$person_name)
namefile$person_name = gsub(", F.A.C.S.", "", namefile$person_name)
namefile$person_name = gsub("DR. ", "", namefile$person_name)
namefile$person_name = gsub(", JD", "", namefile$person_name)
namefile$person_name = gsub(", V", "", namefile$person_name)
namefile$person_name = gsub(", IV", "", namefile$person_name)
namefile$person_name = gsub(", III", "", namefile$person_name)
namefile$person_name = gsub(" III", "", namefile$person_name)
namefile$person_name = gsub(", II", "", namefile$person_name)
namefile$person_name = gsub(", SR.", "", namefile$person_name)
namefile$person_name = gsub(", SR", "", namefile$person_name)
namefile$person_name = gsub(", JR.", "", namefile$person_name)
namefile$person_name = gsub(", JR", "", namefile$person_name)
namefile$person_name = gsub(",JR.", "", namefile$person_name)
namefile$person_name = gsub(",JR", "", namefile$person_name)
namefile$person_name = gsub(" JR", "", namefile$person_name)
namefile$person_name = gsub(", ESQ", "", namefile$person_name)
namefile$person_name = gsub(", PH.D", "", namefile$person_name)
namefile$person_name = gsub(", PHD", "", namefile$person_name)
namefile$person_name = gsub(", CPA", "", namefile$person_name)
namefile$person_name = gsub(", CFA", "", namefile$person_name)
namefile$person_name = gsub(", MBA", "", namefile$person_name)
namefile$person_name = gsub(", CCIM", "", namefile$person_name)
namefile$person_name = gsub(", M.ED", "", namefile$person_name)
namefile$person_name = gsub(", M.S.", "", namefile$person_name)
namefile$person_name = gsub(", F.R.C.S.C. F.A.C.S.", "", namefile$person_name)
namefile$person_name = gsub(", RPH", "", namefile$person_name)
namefile$person_name = gsub(", MPH", "", namefile$person_name)
namefile$person_name = gsub(", MFT", "", namefile$person_name)
namefile$person_name = gsub(" MD, FACS", "", namefile$person_name)
namefile$person_name = gsub(", M.B.A.", "", namefile$person_name)
namefile$person_name = gsub(" ( STORAGE, NETWORK & COMPLIANCE)", "", namefile$person_name, fixed = T)
namefile$person_name = gsub(", DMD", "", namefile$person_name)
namefile$person_name = gsub(", PMP, SSGB", "", namefile$person_name)
namefile$person_name = gsub(", D.D.S., P.A.", "", namefile$person_name)
namefile$person_name = gsub(", PH. D.", "", namefile$person_name)

namefile$person_name = gsub(" VAN ", " VAN", namefile$person_name)
namefile$person_name = gsub(" VON ", " VON", namefile$person_name)
namefile$person_name = gsub(" DA ", " DA", namefile$person_name)
namefile$person_name = gsub(" DE ", " DE", namefile$person_name)
namefile$person_name = gsub(" DU ", " DU", namefile$person_name)
namefile$person_name = gsub(" DER ", " DER", namefile$person_name)
namefile$person_name = gsub(" DE LA ", " DELA", namefile$person_name)
namefile$person_name = gsub(" DELA ", " DELA", namefile$person_name)
namefile$person_name = gsub(" DEL ", " DEL", namefile$person_name)
namefile$person_name = gsub(" DOS ", " DOS", namefile$person_name)
namefile$person_name = gsub("WIKITUBETV (FOUNDER, MICHAEL TROUT)", "MICHAEL TROUT", namefile$person_name, fixed = T)
namefile$person_name = gsub(" ( APPLICATION DEVELOPMENT ,INTEGRATION . MODERNATION )", "", namefile$person_name, fixed = T)
namefile$person_name = gsub("MARK NIELSEN, WIRELESS 21, INC./CAPISTRANO VENTURES", "MARK NIELSEN", namefile$person_name)
namefile$person_name = gsub("OSTHUES, JENS", "JENS OSTHUES", namefile$person_name)
namefile$person_name = gsub("AVILA, HERN", "HERN AVILA", namefile$person_name)
namefile$person_name = gsub("ALEXANBEAUVOIS", "ALEXAN BEAUVOIS", namefile$person_name)
namefile$person_name = gsub(",I", "", namefile$person_name)
namefile$person_name = gsub(" ( JJ )", "", namefile$person_name, fixed = T)

namefile$person_name = gsub(".", "", namefile$person_name, fixed = T)
namefile$person_name = gsub(", ", " ", namefile$person_name)
namefile$person_name = gsub(",", "", namefile$person_name)
namefile$person_name = gsub("?", "", namefile$person_name, fixed = T)
namefile$person_name = gsub("_ ", "", namefile$person_name, fixed = T)
namefile$person_name = gsub("\'", "", namefile$person_name)
namefile$person_name = gsub("\`", "", namefile$person_name)
namefile$person_name = gsub("'", "", namefile$person_name)
namefile$person_name = gsub("\"", "", namefile$person_name)
namefile$person_name = gsub("\"", "", namefile$person_name)

namefile$person_name = tolower(namefile$person_name)

# extract first and last name here.
namefile$last_name = sapply(strsplit(namefile$person_name, ' '), function(x) x[length(x)])
namefile$first_name <- sapply(strsplit(as.character(substr(namefile$person_name, 1, (nchar(namefile$person_name)-nchar(namefile$last_name)-1))),' '), "[", 1)


##### matching begins here.
# install.packages("stringdist")
require(stringdist)
library(stringdist)

# loading the names
numnames = nrow(namefile)

oxfordsurname = read.csv("H:/Ethnicity/namedictionary.csv")
oxfordsurname$Last_Name = tolower(oxfordsurname$Last_Name)

oxfordmatch = vector(length = numnames)

progressbar = txtProgressBar(min = 0, max = numnames, style = 3)
for(i in 1:numnames){
  oxfordmatch[i] = amatch(namefile[i, 3], oxfordsurname$Last_Name, nomatch = -999, matchNA = F, method = c("lv"))
  Sys.sleep(0.1)
  # update progress bar
  setTxtProgressBar(progressbar, i)
}
close(progressbar)

test <- data.frame(lapply(namefile, as.character), stringsAsFactors=FALSE)
write.csv(test, "H:/Startups/Names/namefile.csv")

write.csv(oxfordmatch, "H:/Startups/Names/oxfordmatch.csv")
write.csv(oxfordsurname, "H:/Startups/Names/oxfordsurname.csv")

install.packages("gender")
require(gender)
gender = unique(gender(namefile$first_name, years = c(1940, 2000), method = "ssa"))
write.csv(gender, "H:/Startups/Names/gender.csv")

abcd = cbind(test, oxfordmatch)
#abcd[27139, 2] = "MARK NIELSEN"
#abcd[27139, 4] = "MARK"

oxfordsurname$oxfordmatch = as.numeric(rownames(oxfordsurname))
names(oxfordsurname)[names(oxfordsurname) == 'Last_Name'] <- 'Oxford_Last_Name'

bcde = merge(abcd, oxfordsurname, by = "oxfordmatch", all.x = T)
names(gender)[names(gender) == 'name'] = 'first_name'
cdef = merge(bcde, gender, by = "first_name", all.x = T)
write.csv(cdef, "H:/Startups/Names/namesgender.csv")



# uai = read.csv("H:/Crunchbase/Names/uai.csv", quote = "\"")
# cdef = read.csv("H:/Crunchbase/Names/namesgender.csv")
# wxyz = 
# defg = cbind(cdef, uai)
# defg$total_valid = (defg$Arabic + defg$AsturianLeonese + defg$Basque + defg$Bulgarian + defg$Catalan + defg$Chinese + defg$Cornish + defg$Czech + defg$Danish + defg$Dutch + defg$English + defg$Ethiopian + defg$Filipino + defg$Finnish + defg$French + defg$Frisian + defg$Galician + defg$German + defg$Greek + defg$Hispanic + defg$Hungarian + defg$Indian + defg$Irish + defg$Italian +defg$Japanese + defg$Jewish + defg$Korean + defg$Lithuanian + defg$UAIManx * defg$Manx + defg$Muslim + defg$UAINorwegian * defg$Norwegian + defg$Polish + defg$Portuguese + defg$Russian + defg$Scandinavian + defg$Scottish + defg$Slovak + defg$Spanish + defg$Swedish + defg$Vietnamese + defg$Welsh + defg$Serbian + defg$Croatian + defg$Slovenian)
# uaiscore = ((defg$UAIArabic * defg$Arabic + defg$UAIAsturianLeonese * defg$AsturianLeonese + defg$UAIBasque * defg$Basque + defg$UAIBulgarian * defg$Bulgarian + defg$UAICatalan * defg$Catalan + defg$UAIChinese * defg$Chinese + defg$UAICornish * defg$Cornish + defg$UAICzech * defg$Czech + defg$UAIDanish * defg$Danish + defg$UAIDutch * defg$Dutch + defg$UAIEnglish * defg$English + defg$UAIEthiopian * defg$Ethiopian + defg$UAIFilipino * defg$Filipino + defg$UAIFinnish * defg$Finnish + defg$UAIFrench * defg$French + defg$UAIFrisian * defg$Frisian + defg$UAIGalician * defg$Galician + defg$UAIGerman * defg$German + defg$UAIGreek * defg$Greek + defg$UAIHispanic * defg$Hispanic + defg$UAIHungarian * defg$Hungarian + defg$UAIIndian * defg$Indian + defg$UAIIrish * defg$Irish + defg$UAIItalian * defg$Italian + defg$UAIJapanese * defg$Japanese + defg$UAIJewish * defg$Jewish + defg$UAIKorean * defg$Korean + defg$UAILithuanian * defg$Lithuanian + defg$UAIManx * defg$Manx + defg$UAIMuslim * defg$Muslim + defg$UAINorwegian * defg$Norwegian + defg$UAIPolish * defg$Polish + defg$UAIPortuguese * defg$Portuguese + defg$UAIRussian * defg$Russian + defg$UAIScandinavian * defg$Scandinavian + defg$UAIScottish * defg$Scottish + defg$UAISlovak * defg$Slovak + defg$UAISpanish * defg$Spanish + defg$UAISwedish * defg$Swedish + defg$UAIVietnamese * defg$Vietnamese + defg$UAIWelsh * defg$Welsh + defg$UAISerbian * defg$Serbian + defg$UAICroatian * defg$Croatian + defg$UAISlovenian * defg$Slovenian) / (defg$total_valid * 100))
# efgh = defg[, c("person_id", "proportion_male", "proportion_female")]
# fghi = cbind(efgh, as.data.frame(uaiscore))
# write.csv(fghi, "H:/Crunchbase/Names/genderuai.csv")
