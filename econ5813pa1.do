***********************
*** econ5813pa1.do  ***
*** --------------- ***
*** Brian Duncan    ***
***********************

********************************************************
*** This program creates variables and estimates     ***
*** regressions for ECON 5813 Project Assignment #1  ***
********************************************************

**************************
*** Begin the log file ***
**************************

   set more off
   set linesize 255
   set varabbrev off

   capture log close
   log using econ5813pa1.log, replace

*************************************************
*** Load the ACS data (2010 - 2020)           ***
*** ----------------------------------------- ***
*** Downloaded from https://usa.ipums.org/usa ***
*************************************************

   clear all
   use ./ECON5813_09-28-2022/econ5813_acs_d1.dta
   describe, short

****************************************************
*** Data integrity checks                        ***
*** -------------------------------------------- ***
*** Modify this to be consistent with your data. ***
*** Add additional data integrity checks as you  ***
*** think of them.                               ***
****************************************************

* Data includes years 2009 through 2016
   tab year, missing
   assert year>=2000 & year<=2020 & r(r)==11

* Data includes individuals between the ages of 25 and 59
   tab age, missing
   assert inrange(age,25,59)==1

* Data includes individuals who are employed
   tab empstat, missing
   assert empstat==1

* Data includes Elementary, Middle, and Secondary School Teachers
   tab occ, missing
   assert inlist(occ,2310,2320)==1

*******************
*** Question #3 ***
*******************

   describe, short
   list age sex statefip in 1/20
   sort statefip age
   list age sex statefip in 1/20

*******************
*** Question #4 ***
*******************

   drop empstat

* Weeks Worked Last Year
   gen     weeksworked  = .
   replace weeksworked  = 7    if wkswork2==1
   replace weeksworked  = 20   if wkswork2==2
   replace weeksworked  = 33   if wkswork2==3
   replace weeksworked  = 43.5 if wkswork2==4
   replace weeksworked  = 48.5 if wkswork2==5
   replace weeksworked  = 51   if wkswork2==6
   label variable weeksworked "Weeks worked"
   tab weeksworked, missing
   assert inlist(weeksworked,7,20,33,43.5,48.5,51)==1

   drop if wkswork2<=2
   drop if uhrswork<20 | uhrswork>60
   describe, short

* Create male and female dummy variables
* Note: this code is incomplete.  Correct it!
   generate female      = 1 if sex==2
   generate male        = 1 if sex==1
   label variable female "Female indicator variable"
   label variable male   "Male indicator variable"
   tabulate female male, missing
   assert male+female==1

**************************
*** Close the log file ***
**************************

   log close
   set more on

*************************
*** Open the log file ***
*************************

   view econ5813pa1.log
