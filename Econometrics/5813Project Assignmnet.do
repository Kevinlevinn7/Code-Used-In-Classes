*************************************
*** econ5813pa3.do ***
*** ------------------------------- ***
*** Created by Kevin Ruiz ***
***************************************
********************************************************
*** This program creates variables and estimates ***
*** regressions for ECON 5813 Project Assignment #2 ***
********************************************************
**************************
*** Begin the log file ***
**************************
capture log close
log using econ5813pa4.log, replace
set more off
set linesize 255
set varabbrev off

**#
*********************
*** Load in data ***
*********************
use econ5813_IPUMS_EXTRACT.dta, clear

****************************************************
*** Check that the data is correct ***
*** -------------------------------------------- ***
*** Modify this to be consistent with your data. ***
*** Add additional data integrity checks as you ***
*** think of them. ***
****************************************************
* Data includes years 2010 through 2023
tab year, missing
assert inrange(year,2010,2023)==1 & r(r)==14

* Data includes individuals between the ages of 25 and 59
tab age, missing
assert inrange(age,25,59)==1

* Data includes individuals who are employed
tab empstat, missing
assert empstat==1

*lets do the variable creation from the code given
generate weeksworked = .
 replace weeksworked = 7 if wkswork2==1
 replace weeksworked = 20 if wkswork2==2
 replace weeksworked = 33 if wkswork2==3
 replace weeksworked = 43.5 if wkswork2==4
 replace weeksworked = 48.5 if wkswork2==5
 replace weeksworked = 51 if wkswork2==6
 label variable weeksworked "Weeks worked"

 tab weeksworked, missing
 assert inlist(weeksworked,7,20,33,43.5,48.5,51)==1 & r(r)==6

 *generate wage variable
 generate wage = incwage / (uhrswork * weeksworked)



* Lets create the dummy variable for female
generate female = .
replace female = 1 if sex == 2
replace female = 0 if sex == 1

** creating schoolyr variable
 generate schoolyr = 0
 replace schoolyr = 2.5 if educd<=17
 replace schoolyr = 5.5 if educd>=20 & educd<=23
 replace schoolyr = 7.5 if educd>=24 & educd<=26
 replace schoolyr = 9 if educd==30
 replace schoolyr = 10 if educd==40
 replace schoolyr = 11 if educd==50
 replace schoolyr = 12 if educd>=60 & educd<=64
 replace schoolyr = 13 if educd>=65 & educd<=71
 replace schoolyr = 14 if educd>=80 & educd<=90
 replace schoolyr = 16 if educd>=100 & educd<=101
 replace schoolyr = 18 if educd>=110 & educd<=115
 replace schoolyr = 20 if educd==116
 
 tab schoolyr, missing
 assert inrange(schoolyr,2.5,20)==1 & r(r)==12

 *-------------------------------------------------------------*
* Experience variable
*-------------------------------------------------------------*
generate exp = age - schoolyr - 6
label variable exp "Assumed experience"
drop if exp == -1

*-------------------------------------------------------------*
* Class of worker dummies
*-------------------------------------------------------------*
generate govt = 0
replace govt = 1 if inlist(classwkrd, 21, 27, 28)

generate private = 0
replace private = 1 if inlist(classwkrd, 22)

generate otheemp = 0
replace otheemp = 1 if !inlist(classwkrd, 21,22,27,28)

assert private + govt + otheemp == 1

*-------------------------------------------------------------*
* Marital status dummy
*-------------------------------------------------------------*
generate married = 0
replace married = 1 if inlist(marst, 1,2)

*-------------------------------------------------------------*
* Foreign-born dummy
*-------------------------------------------------------------*
generate foreign = 0
replace foreign = 1 if !inlist(bpl, 1,2,4,5,6,8,9,10,11,12,13,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,44,45,46,47,48,49,50,51,53,54,55,56)

*-------------------------------------------------------------*
* Race and ethnicity categories
*-------------------------------------------------------------*
gen byte hisp = (hispand>=100 & hispand<=499)
label variable hisp "Hispanic"

gen byte white = (raced==100 | raced==110) & hisp==0
gen byte black = raced==200 & hisp==0
gen byte indian = inrange(raced,300,399)==1 & hisp==0
gen byte asian = inrange(raced,400,699)==1 & hisp==0
gen byte other_race = inrange(raced,700,996) & hisp==0

label variable white "White"
label variable black "Black"
label variable indian "Indian"
label variable asian "Asian"
label variable other_race "Other Race"

assert white+hisp+black+asian+indian+other_race==1

gen byte race_cat6 = 0
replace race_cat6 = 1 if white==1
replace race_cat6 = 2 if hisp==1
replace race_cat6 = 3 if black==1
replace race_cat6 = 4 if asian==1
replace race_cat6 = 5 if indian==1
replace race_cat6 = 6 if other_race==1
label variable race_cat6 "Race Category (race is non-Hispanic)"

#delimit ;
label define race_cat6_lbl
        0 "ERROR!"
        1 "White"
        2 "Hispanic"
        3 "Black"
        4 "Asian"
        5 "Indian"
        6 "Other race";
#delimit cr
label values race_cat6 race_cat6_lbl
tab race_cat6, missing
assert inlist(race_cat6,1,2,3,4,5,6)==1 & r(r)==6

*-------------------------------------------------------------*
* Education categories
*-------------------------------------------------------------*
** Lets just drop straight away the observations with missing educational attainment


gen elem = (schoolyr < 12)
gen hs = (schoolyr == 12)
gen college = (schoolyr > 12 & schoolyr < 18)
gen ma = (schoolyr >= 18 & schoolyr < 21)
gen phd = (schoolyr >= 21)




assert elem+hs+college+ma+phd == 1

gen byte educ_cat5 = 0
replace educ_cat5 = 1 if elem==1
replace educ_cat5 = 2 if hs==1
replace educ_cat5 = 3 if college==1
replace educ_cat5 = 4 if ma==1
replace educ_cat5 = 5 if phd==1
label variable educ_cat5 "Education Level"

#delimit ;
label define educ_cat5_lbl
        0 "ERROR!"
        1 "Less than a high school education"
        2 "High School"
        3 "College Degree"
        4 "Masters Degree"
        5 "PhD";
#delimit cr
label values educ_cat5 educ_cat5_lbl
tab educ_cat5, missing
assert inlist(educ_cat5,1,2,3,4,5)==1




*-------------------------------------------------------------*
* Tabulating Classwrkd
*-------------------------------------------------------------*

keep if weeksworked >= 26
keep if uhrswork >= 20 & uhrswork <= 60
keep if classwkrd == 22

tab classwkrd


*-------------------------------------------------------------*
* Data Integrity section
*-------------------------------------------------------------*



tab race_cat6, missing
assert inlist(race_cat6,1,2,3,4,5,6)==1 & r(r)==6

tab schoolyr, missing
assert inrange(schoolyr,2.5,20)==1 & r(r)==12

assert inlist(educ_cat5,1,2,3,4,5)==1

assert weeksworked >= 26

assert uhrswork >= 20 & uhrswork <= 60

assert classwkrd == 22

 
*-------------------------------------------------------------*
* Question 2
*-------------------------------------------------------------*

tab statefip, missing
assert inrange(statefip, 1, 56)

*-------------------------------------------------------------*
* Question 3
*-------------------------------------------------------------*

preserve
gen samplesize = 1
tabulate statefip year, missing
collapse (count) samplesize (mean) age, by(statefip year)
tsset statefip year
assert !missing(statefip, year)
restore


preserve
drop if statefip==8 & year==2012
tabulate statefip year, missing
gen samplesize = 1
collapse (count) samplesize (mean) age, by(statefip year)
tsset statefip year
assert !missing(statefip, year)
restore


*-------------------------------------------------------------*
* Question 4
*-------------------------------------------------------------*

keep if age >= 25 & age <= 30

gen year16 = year - (age-16)
assert inrange(year16, 1996, 2014)

** The way this is calculated is that we have our year of the survery which they were
** a specific age there then we figure out that the difference between when they were
** 16 up to their current years of age and this difference then in terms of years from the sruvey gives us year they were 16



*-------------------------------------------------------------*
* Question 5
*-------------------------------------------------------------*

gen statefips = string(statefip,"%02.0f")
label variable statefips "State FIPS code (str)"
describe statefip statefips


*-------------------------------------------------------------*
* Question 6
*-------------------------------------------------------------*

#delimit ;
d,s;
merge m:1 statefips year16
 using BLS-State-Annual-Unemployment_1976-2017.dta
 ,keep(master match) keepusing(unemployment_rate);
 
d,s;

assert _merge == 3 ;

drop _merge;
#delimit cr;

*-------------------------------------------------------------*
* Question 7
*-------------------------------------------------------------*

gen unemp_cat3 = .
replace unemp_cat3 = 1 if unemployment_rate < 4
replace unemp_cat3 = 2 if unemployment_rate >= 4   & unemployment_rate < 6
replace unemp_cat3 = 3 if unemployment_rate >= 6

label variable unemp_cat3 "Unemployment rate category"


label define unemp3 ///
    1 "Less than 4%" ///
    2 "4% to 5.9%" ///
    3 "6% or more"


label values unemp_cat3 unemp3

tab unemp_cat3, missing

assert inlist(unemp_cat3,1,2,3)==1 & r(r)==3

save econ5813_IPUMS_EXTRACT_merged.dta, replace 

*-------------------------------------------------------------*
* Question 8
*-------------------------------------------------------------*
use County_Population1996-2010.dta, replace

collapse (sum) population, by(statefip countyfip year)

collapse (sum) population, by(statefip year)

rename year year16

save County_Population1996-2010_cleaned.dta, replace

use econ5813_IPUMS_EXTRACT_merged, clear

keep if year16 >= 1996 & year16 <= 2010

merge m:1 statefip year16 using County_Population1996-2010_cleaned.dta ///
    , keep(master match) keepusing(population)

assert _merge == 3
drop _merge


gen population10 = population / 10000
label variable population10 "State population (in tens of thousands)"

assert float(population10)==float(432.6921) if year16==2000 & statefip==8

*-------------------------------------------------------------*
* Question 9
*-------------------------------------------------------------*
tabstat wage age, by(race_cat6) ///
    stats(n mean semean min max) ///
    longstub columns(statistics)

tabstat wage age, by(race_cat6) ///
    stats(n mean semean min max) ///
    longstub columns(variables)

tabstat wage age, by(race_cat6) ///
    stats(n mean semean min max) ///
    longstub columns(statistics) ///
    format(%9.3g)
	
*-------------------------------------------------------------*
* Question 11
*-------------------------------------------------------------*
preserve
collapse (mean) unemployment_rate schoolyr wage, by(year16)
#delimit ;
twoway line unemployment_rate year16,
 graphregion(color(white)) bgcolor(white) name(PanelA, replace) title("Panel A: Unemp vs Year") graphregion(color(white)) bgcolor(white);
twoway line wage year16,
 graphregion(color(white)) bgcolor(white) name(PanelB, replace) title("Panel B: Wage vs Year");
graph combine PanelA PanelB, col(1)
 graphregion(color(white)) name(Figure1, replace) title("Figure 1") note("U.S. State-Level Average, 1976–2017");
graph save Figure1 Econ5813PA3-Figure1.gph, replace;
#delimit cr;
restore



	
*-------------------------------------------------------------*
* Question 11
*-------------------------------------------------------------*

regress wage i.unemp_cat3 $rhs


global rhs "i.age i.race_cat6 female population10"
* (Model 1) Baseline wage regression.
eststo : regress wage i.unemp_cat3 $rhs, ///
 baselevels vce(cluster statefip)
estadd ysumm, mean
estadd local State_FE "No", replace
estadd local Year_FE "No", replace
test 2.unemp_cat3 3.unemp_cat3
* (Model 2) Add state fixed effects.
eststo : regress wage i.unemp_cat3 i.statefip $rhs, ///
 baselevels vce(cluster statefip)
estadd ysumm, mean
estadd local State_FE "Yes", replace
estadd local Year_FE "No", replace
test 2.unemp_cat3 3.unemp_cat3
* (Model 3) Add state and birth-year fixed effects.
eststo : regress wage i.unemp_cat3 i.statefip i.year16 $rhs, ///
 baselevels vce(cluster statefip)
estadd ysumm, mean
estadd local State_FE "Yes", replace
estadd local Year_FE "Yes", replace
test 2.unemp_cat3 3.unemp_cat3
* (Model 4) Add state and birth-year fixed effects.
eststo : regress schoolyr i.unemp_cat3 i.statefip i.year16 $rhs, ///
 baselevels vce(cluster statefip)
estadd ysumm, mean
estadd local State_FE "Yes", replace
estadd local Year_FE "Yes", replace
test 2.unemp_cat3 3.unemp_cat3///
 baselevels vce(cluster statefip
estadd ysumm, mean
estadd local State_FE "Yes", replace
estadd local Year_FE "Yes", replace
test 2.unemp_cat3 3.unemp_cat3
* (Model 4) Add state and birth-year fixed effects.
eststo : regress schoolyr i.unemp_cat3 i.statefip i.year16 $rhs, ///
 baselevels vce(cluster statefip)
estadd ysumm, mean
estadd local State_FE "Yes", replace
estadd local Year_FE "Yes", replace
test 2.unemp_cat3 3.unemp_cat3
**************************;
*** Output Regressions ***;
**************************;
#delimit ;
 esttab using Econ5813pa3-Table1.csv,
 replace label b(%9.3f) se(%9.3f) nogaps
 drop(1.unemp_cat3 25.age 1.race_cat6 *.year16 *.statefip)
 title("Table 1: Wage regressions")
 stats(State_FE Year_FE ymean r2 N,
 label("State fixed effects"
 "Year fixed effects"
 "Mean of dependent variable"
 "R-squared"
"Sample size") fmt(%9.3g));
#delimit cr;
eststo clear

*-------------------------------------------------------------*
* Question 19
*-------------------------------------------------------------*


gen birthyear = year - age
regress schoolyr i.unemp_cat3 i.statefip i.birthyear $rhs, baselevels vce(cluster statefip)

regress schoolyr i.unemp_cat3 i.statefip i.year16 $rhs, baselevels vce(cluster statefip)

*-------------------------------------------------------------*
* Question 20
*-------------------------------------------------------------*


eststo : regress wage i.unemp_cat3 i.statefip i.year16 population $rhs, baselevels vce(cluster statefip)
estadd ysumm, mean
estadd local State_FE "Yes", replace
estadd local Year_FE "Yes", replace

eststo : regress wage i.statefip i.year16 unemployment_~e $rhs, baselevels vce(cluster statefip)
estadd ysumm, mean
estadd local State_FE "Yes", replace
estadd local Year_FE "Yes", replace





