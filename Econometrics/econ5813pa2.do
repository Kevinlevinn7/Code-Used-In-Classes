*************************************
*** econ5813pa2.do ***
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
log using econ5813pa2.log, replace
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
* Summary statistics by gender
*-------------------------------------------------------------*
mean wage age exp private govt otheemp married foreign white black asian hisp other_race elem hs college ma phd, over(female)

* Overall means
mean wage age exp private govt otheemp married foreign white black asian hisp other_race elem hs college ma phd

*-------------------------------------------------------------*
* Simple regression: wage on experience
*-------------------------------------------------------------*
reg wage exp
display _b[exp] / _se[exp]

*-------------------------------------------------------------*
* Calcualting Predictions and confidence levels
*-------------------------------------------------------------*

predict wage_hat
sum wage_hat
sum wage


*-------------------------------------------------------------*
* Graph: Fitted line by sex
*-------------------------------------------------------------*
twoway lfit wage exp, by(sex)

*-------------------------------------------------------------*
* Regression B
*-------------------------------------------------------------*

reg wage exp female c.exp##female 


*-------------------------------------------------------------*
* Estimating The Interaction Regression
*-------------------------------------------------------------*

regress wage i.female##c.exp 

*-------------------------------------------------------------*
* Creating centered age
*-------------------------------------------------------------*
summarize age
generate age_centered = age - r(mean)

egen age_std_egen = std(age)

summarize age
generate age_std = (age - r(mean)) / r(sd)

assert age_std_egen == age_std


*-------------------------------------------------------------*
* Estimating Models with Centered Age
*-------------------------------------------------------------*
reg wage female##c.age
reg wage female##c.age_centered
reg wage female##c.age_std

* Regression (i)
 regress wage female age i.female#c.age
 di _b[_cons]
 di _b[female]
 di _b[age]
 di _b[1.female#c.age]
 sum age if e(sample)==1
 di r(mean)
 
* Calculate coefficients from (ii) using output from (i)
summarize age 
 local alpha_b = 15.191934 + .11424921* r(mean)
 local beta1_b = -3.5619577  + .01758346* r(mean)
 di "`alpha_b'"
 di "`beta1_b'"
 
* Regression (ii)
 reg wage female##c.age_centered
 assert float(_b[_cons])==float(`alpha_b')
 assert round(float(_b[1.female]), .001) == round(float(`beta1_b'), .001)

 
 
*-------------------------------------------------------------*
*Estiamteing Models with Logs
*-------------------------------------------------------------*
generate ln_wage = ln(wage)
generate ln_exp  = ln(exp)
*Model i
regress ln_wage schoolyr ln_exp
*Model ii
regress ln_wage schoolyr ln_exp
*Model iii
regress ln_wage schoolyr exp
*Model iv
regress wage schoolyr ln_exp
*Model vi
generate exp2 = exp^2
regress wage schoolyr exp exp2

*-------------------------------------------------------------*
*Estiamteing Models with Logs
*-------------------------------------------------------------*
*** base for hs but also dropping PhD since i have none and perfect multicolinarity

regress wage ib2.educ_cat5 

regress wage ib3.educ_cat5

*-------------------------------------------------------------*
*Estiamteing Models Question 9
*-------------------------------------------------------------*

regress wage exp exp2 i.female##ib3.educ_cat5












