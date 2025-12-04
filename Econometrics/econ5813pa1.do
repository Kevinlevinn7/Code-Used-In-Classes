*************************************
*** econ5813pa1.do ***
*** ------------------------------- ***
*** Created by Kevin Ruiz ***
***************************************
********************************************************
*** This program creates variables and estimates ***
*** regressions for ECON 5813 Project Assignment #1 ***
********************************************************
**************************
*** Begin the log file ***
**************************
capture log close
log using econ5813pa1.log, replace
set more off
set linesize 255
set varabbrev off

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

*********************
*** Question 3 ***
*********************

***** Part a *****

*describes our data set well 
*enough with detailed labels of vairables and observations. 
describe 

compress 

describe
***** Part b ******

*** Using the list and in functions allow us to only index the first 20
list age sex statefip in 1/20

***** Part c *******
**lets sort our data by statefip and age
sort statefip age
***new first 20
list age sex statefip in 1/20

***** Part d ****
*First lets sort by sex which will put the males at the top thus 
*we can then just list them and we will get the first 10 males 
sort sex

list age sex statefip incwage if sex == 1 in 1/10

** similarly for females we can just sort by sex in the opposite direction
*then we can just list the first 10
gsort -sex

list age sex statefip incwage if sex == 2 in 1/10


*********************
*** Question 4 ***
*********************
use econ5813_IPUMS_EXTRACT.dta, clear

**** Part a *****
*lets drop the variable
drop empstatd

**** Part b *****
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
 
 
**** Part c *****
** lets now drop any indvidauls with less than 26 weeks worked 
drop if weeksworked <= 26

**** Part d ****
*** using the variable uhrswork we can check how many hours worked per weeks lets now drop anyone with few hours worked or extra horus worked

drop if uhrswork <20 | uhrswork >60


**** Part e ***
* Lets create the dummy variable for female
generate female = .
replace female = 1 if sex == 2
replace female = 0 if sex == 1

* Lets create the dummy variable for male
generate male = .
replace male = 1 if sex == 1
replace male = 0 if sex == 2


*** Part f ****
*lets check if they are mutually exlusive 
tab female male, missing


*********************
*** Question 5***
*********************

***** Part a ****
*looks at a table of occupations 
tab occ


***** Part b ****
*genreates wage mathematically 
generate wage = incwage / (uhrswork * weeksworked)

**** Part c ****
*find average wage
sum wage

**** Part d ****
* this finds the average but with the condition of age between 20 and 30
sum wage if age >= 20 & age <= 30

*********************
*** Question 6***
*********************

**** Part a ****

sum wage if male == 1
sum wage if male == 0


**** Part b ****
*** Calculate t stat directly 
display (19.45184 - 16.25848) / sqrt(((270018-1)*14.51561^2 + (18954-1)*15.01778^2)/(270018+18954-2) * (1/270018 + 1/18954))

**** Now t stat from stata command 
ttest wage, by(sex) level(90)
  

**** Part c ****
**** T stat for 5 
display ((19.45184 - 16.25848)-5) / sqrt(((270018-1)*14.51561^2 + (18954-1)*15.01778^2)/(270018+18954-2) * (1/270018 + 1/18954))

*** now since we can't use a built in option we need an extra wage where it is shifter by 5 if male baisaclly asking the same question just differently 

generate wage_adj = wage - 5*(sex==1)
ttest wage_adj, by(sex) level(90)

*********************
*** Question 6***
*********************

**** Part a ****
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
 
 
**** Part b *****
*** lets calculate the regressions
regress wage schoolyr
  
*** Part c *****
regress wage schoolyr age

**** Part d ******
* we first need to create our squared variables and then we can regress on them 
generate schoolyr2 = schoolyr^2
generate age2 = age^2
regress wage schoolyr schoolyr2 age age2

**** Part e ****
*regression for males

regress wage schoolyr schoolyr2 age age2 if male == 1
*regression for females

regress wage schoolyr schoolyr2 age age2 if male == 0

**** Pard e *****
* First lets create the variables 
generate schoolyr12 = schoolyr - 12
generate age20 = ln(age - 20)
*Then lets run the regressions
regress wage c.schoolyr12##c.age20

** to find marginal and elacticity 

* Marginal effect of age at mean education
display 2.440129 + 0.1028435*0.1529612

* Elasticity of age at mean age20 and mean wage
display (2.440129 + 0.1028435*0.1529612) * (3.084371 / 19.24238)


*********************
*** Question 6***
*********************
*** Lets run the regression
regress wage schoolyr age, robust

** lets run the commands creading an ID for each person and 

generate PersonID = _n
expand 2

** Lets run the regression again
regress wage schoolyr age, robust

**Finally lets run the regression but with clustering
regress wage schoolyr age, vce(cluster PersonID)


*********************
*** Question 7***
*********************
*** run the regressions
reg schoolyr age female
*** Now lets calcualte our residuals 
predict schoolyr_resid, residuals

*** run the regressions
reg wage age female
*** Now lets calcualte our residuals 
predict wage_resid, residuals




*** Lets run a regression on them
reg wage_resid schoolyr_resid

*** Lets run the final regression 
reg wage schoolyr age female



