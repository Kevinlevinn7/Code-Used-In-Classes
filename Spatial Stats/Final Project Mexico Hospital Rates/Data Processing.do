*************************************
*** Work For Project Spatial Stats.do ***
*** ------------------------------- ***
*** Created by Kevin Ruiz ***
***************************************
********************************************************
*** Aggregates Health Resoruces By Municipality ***
***********************************
********************************************************
**************************
*** Begin the log file ***
**************************
capture log close
log using "Data_Aggregation_for_Health_Resources.log", replace
set more off
set linesize 255
set varabbrev off
 
***************************************************************************************** Lets append all of the Health Resources Datasets Togetehr ***********************
****************************************************************************************

clear all
set more off

local path "Recursos De Salud Y CLUES 202509"
local years 2001/2010

************************************************************
* Load In Orignial CLUES 2025 ********************************
* ************************************************************

import excel "ESTABLECIMIENTO_SALUD_202509.xlsx", sheet("CLUES_202509") firstrow clear 

***** Lets make sure we pick the right vairables that we are working wtih ********

keep CLUES  CLAVEDELAENTI~D ENTIDAD CLAVEESTRATOU~D CLAVEDELMUNIC~O MUNICIPIO ESTRATOUNIDAD LATITUD LONGITUD 

destring CLAVEDELAENTIDAD, replace
destring CLAVEDELMUNICIPIO, replace

* ************************************************************
* Count number of CLUES in each state_municipality ***********
* ************************************************************

gen State_Municipality = CLAVEDELAENTIDAD*1000 + CLAVEDELMUNICIPIO

bysort State_Municipality CLUES: gen tag = _n == 1

bysort State_Municipality : egen num_of_total = total(tag)

bysort State_Municipality : egen num_of_total_urban = ///
    total(tag * (ESTRATOUNIDAD == "URBANO"))
	
bysort State_Municipality : egen num_of_total_rural = ///
    total(tag * (ESTRATOUNIDAD == "RURAL"))
	
assert num_of_total == num_of_total_urban + num_of_total_rural

local vars num_of_total num_of_total_rural num_of_total_urban

collapse (first) `vars', by(State_Municipality)



