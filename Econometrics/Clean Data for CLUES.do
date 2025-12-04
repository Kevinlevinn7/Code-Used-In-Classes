*************************************
*** Clean Data for CLUES.do ***
*** ------------------------------- ***
*** Created by Kevin Ruiz ***
***************************************
********************************************************
*** This program cleans up the CLUES Dataset ***
********************************************************


**************************
*** Begin the log file ***
**************************
capture log close
log using Clean_Data_CLUES.log, replace
set more off
set linesize 255
set varabbrev off




***** Lets load in the data set******

import excel "ESTABLECIMIENTO_SALUD_202509.xlsx", sheet("CLUES_202509") firstrow clear 


***** Lets make sure we pick the right vairables that we are working wtih ********

keep CLUES CLAVEDELAINST~N CLAVEDELAENTI~D CLAVEDELMUNIC~O CLAVEDELALOCA~D CLAVEDELTIPOE~O CLAVEDETIPOLO~A CLAVEESTATUSD~N FECHADEINICIO~N CLAVEDELAINSADM CLAVENIVELATE~N CLAVEESTRATOU~D LATITUD LONGITUD CLAVEULTIMOMO~O

****** Now lets destring some of these variables *********
destring CLAVEDELAENTI~D CLAVEDELMUNIC~O CLAVEDELALOCA~D CLAVEDELTIPOE~O CLAVEESTATUSD~N CLAVENIVELATE~N CLAVEESTRATOU~D LATITUD LONGITUD, replace ignore(" ") force


***** Lets now translate them over to English ********

label variable CLUES                "Unique Health Establishment Code / CLUES (Clave Única de Establecimientos de Salud)"
label variable CLAVEDELAINST~N      "Institution Code / Clave de la Institución"
label variable CLAVEDELAENTI~D      "State Code (Federal Entity) / Clave de la Entidad"
label variable CLAVEDELMUNIC~O      "Municipality Code / Clave del Municipio"
label variable CLAVEDELALOCA~D      "Locality Code / Clave de la Localidad"
label variable CLAVEDELTIPOE~O      "Establishment Type Code / Clave del Tipo de Establecimiento"
label variable CLAVEDETIPOLO~A      "Typology Code / Clave de Tipología"
label variable CLAVEESTATUSD~N      "Operational Status Code / Clave de Estatus de Operación"
label variable FECHADEINICIO~N      "Start of Operation Date / Fecha de Inicio de Operación"
label variable CLAVEDELAINSADM      "Administrative Institution Code (SSA, IMSS, ISSSTE, etc.) / Clave de la Institución Administrativa"
label variable CLAVENIVELATE~N      "Level of Care Code (Primary, Secondary, Tertiary) / Clave de Nivel de Atención (Primario, Secundario, Terciario)"
label variable CLAVEESTRATOU~D      "Unit Stratum Code (Size or Classification) / Clave de Estrato de la Unidad (Tamaño o Clasificación)"
label variable LATITUD              "Latitude (decimal degrees) / Latitud (grados decimales)"
label variable LONGITUD             "Longitude (decimal degrees) / Longitud (grados decimales)"
label variable CLAVEULTIMOMO~O      "Last Administrative Movement Code / Clave del Último Movimiento"

******* Now lets make the variable names a little shorter ********
rename CLUES                 clues
rename CLAVEDELAINST~N       inst_code
rename CLAVEDELAENTI~D       state_code
rename CLAVEDELMUNIC~O       mun_code
rename CLAVEDELALOCA~D       loc_code
rename CLAVEDELTIPOE~O       est_type
rename CLAVEDETIPOLO~A       typology
rename CLAVEESTATUSD~N       status_code
rename FECHADEINICIO~N       start_date
rename CLAVEDELAINSADM       admin_inst
rename CLAVENIVELATE~N       care_level
rename CLAVEESTRATOU~D       unit_stratum
rename LATITUD               lat
rename LONGITUD              lon
rename CLAVEULTIMOMO~O       last_move




describe


****** Filters out clinics that would actually help indivdauls in Seguro Popular"
keep if inlist(admin_inst, "SSA", "SESA", "SS")

export excel using "Clean_CLUES.xlsx", firstrow(variables) replace
