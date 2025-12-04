*************************************
*** Problem Set #4.do ***
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
log using econ5813ProblemSet4.log, replace
set more off
set linesize 255
set varabbrev off

**#


 **** PROBLEM # 2 and 3. 
**#


*********************
*** Load in data  ***
*********************
use 5813data1.dta, clear

reg y x

*********************
*** Load in data  ***
*********************
use 5813data2.dta, clear

reg y x


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

generate male = .
replace male = 0 if sex == 2
replace male = 1 if sex == 1


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
* Problem #1
*-------------------------------------------------------------*

reg wage age

reg age wage

*-------------------------------------------------------------*
* Problem #5
*-------------------------------------------------------------*

reg wage female

reg wage male

*-------------------------------------------------------------*
* Problem #6
*-------------------------------------------------------------*
gen female2 = female^2
generate age2 = age^2
gen lnfemale =log(female)
gen lnage = log(age)
gen lnage2 = log(age2)


reg wage female female2 age 
reg wage lnfemale age
reg wage female lnage lnage2
reg wage schoolyr exp age 


*-------------------------------------------------------------*
* Problem #7
*-------------------------------------------------------------*

gen lnschoolyr = log(schoolyr)
reg wage lnschoolyr

twoway (scatter wage schoolyr) ///
       (lfit wage lnschoolyr, sort), ///
       ytitle("Wage") xtitle("Years of Schooling") ///
       title("Regression of Wage on ln(School Years)")
	   
predict wagehat
predict ehat, resid

display 20 - (_b[_cons] + _b[lnschoolyr]*log(17))

display _b[lnschoolyr] / 17

display 0.01 * _b[lnschoolyr] * 100


*-------------------------------------------------------------*
* Problem #9
*-------------------------------------------------------------*

gen exp2 = exp^2
gen fem_exp = female*exp
gen fem_exp2 = female*exp2
gen fem_married = female*married
gen mar_age = married*age


reg wage exp exp2 female fem_exp fem_exp2
test fem_exp fem_exp2


reg wage exp exp2 schoolyr married female fem_married
test fem_married


reg wage schoolyr exp
test schoolyr = exp


reg wage schoolyr age married mar_age if female == 0
test married + 25*mar_age = 0

reg wage college hs exp
test college = 10*exp

