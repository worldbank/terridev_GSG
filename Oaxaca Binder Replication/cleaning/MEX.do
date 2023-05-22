global user "C:\Users\wb486315\OneDrive - WBG/Inequality/LAC"

/* 
// Download data

dlw, coun(MEX) y(2018) t(SEDLAC-03) mod(ALL) verm(01) vera(02) sur(ENIGHNS) 
save "$user/_OaxacaBlinder_replication/SEDLAC/MEX_SEDLAC2018.dta", replace

dlw, coun(MEX) y(2000 2002 2004 2005 2006 2008 2010 2012 2014 2016) t(SEDLAC-03) mod(ALL)
append using "$user/_OaxacaBlinder_replication/SEDLAC/MEX_SEDLAC2018.dta", force

save "$user/_OaxacaBlinder_replication/SEDLAC/MEX_SEDLACall.dta", replace
*/

**********************************************************************************

*datalibweb_inventory, coun(MEX) t(SEDLAC-03) sur(ENIGHNS) 


use "$user/_OaxacaBlinder_replication/SEDLAC/MEX/MEX_SEDLACall.dta", clear
	
gen countrycode = upper(pais)
rename encuesta survey  

tab year

tab region_est1 // region
tab region_est2 // state
tab region_est3 // municipality (?)

// State 
tab region_est2_old year // 2000 - 2012
tab region_est2 year // only for 2014 and 2016
tab region_est2_prev year // 2018

split region_est2_prev, parse(" - ")

label define region_est2 15 "Mexico", modify
label define region_est2 16 "Michoacan", modify
label define region_est2 19 "Nuevo Leon", modify
label define region_est2 22 "Queretaro de Arteaga", modify
label define region_est2 24 "San Luis Potosi", modify
label define region_est2 31 "Yucatan", modify

decode region_est2_old, gen(state1)
decode region_est2, gen(state2)
encode region_est2_prev2, gen(state3)

gen state = state1 
replace state = state2 if state == ""
replace state = region_est2_prev2 if state == ""

replace state = "Guanajuato" if state == "Guanjuato"


tab state year 

// municipality 

split region_est3_prev, parse(" - ")

tostring region_est3_old, gen(muni1)
tostring region_est3, gen(muni2)

tostring region_est2_old, gen(states1)
tostring region_est2, gen(states2)
gen state3n = real(region_est2_prev1)

** Catálogo Único de Claves de Áreas Geoestadísticas Estatales, Municipales y Localidades

// State CODE (all years)
gen AGEE = region_est2_prev1 if state3n >= 10 
replace AGEE = "0" + region_est2_prev1 if state3n < 10 

replace AGEE = "0" + states2 if region_est2 < 10 & (year == 2014 | year == 2016)
replace AGEE = states2 if region_est2 >= 10 & (year == 2014 | year == 2016)

replace AGEE = "0" + states1 if region_est2_old < 10 & year < 2014
replace AGEE = states1 if region_est2_old >= 10 & year < 2014

tab AGEE

// MUNI CODE (all years but 2018)
 
gen AGM = "00" + muni2 if region_est3 < 10 & (year == 2014 | year == 2016)
replace AGM = "0" + muni2 if region_est3 >= 10 & region_est3 < 100 & (year == 2014 | year == 2016)
replace AGM = muni2 if region_est3 >= 100 & (year == 2014 | year == 2016)

replace AGM = "00" + muni1 if region_est3_old < 10  & year < 2014
replace AGM = "0" + muni1 if region_est3_old >= 10 & region_est3_old < 100  & year < 2014
replace AGM = muni1 if region_est3_old >= 100  & year < 2014

tab AGM

// States and Muni codes

gen AGEM = AGEE+AGM if year != 2018
replace AGEM = region_est3_prev1 if year == 2018

tab AGEM

// matching ID and names
gen name_1 = ""
replace name_1 = "Aguascalientes" if AGEE == "01"
replace name_1 = "Baja California" if AGEE == "02"
replace name_1 = "Baja California Sur" if AGEE == "03"
replace name_1 = "Campeche" if AGEE == "04"
replace name_1 = "Coahuila de Zaragoza" if AGEE == "05"
replace name_1 = "Colima" if AGEE == "06"
replace name_1 = "Chiapas" if AGEE == "07"
replace name_1 = "Chihuahua" if AGEE == "08"
replace name_1 = "Ciudad de México" if AGEE == "09"
replace name_1 = "Durango" if AGEE == "10"
replace name_1 = "Guanajuato" if AGEE == "11"
replace name_1 = "Guerrero" if AGEE == "12"
replace name_1 = "Hidalgo" if AGEE == "13"
replace name_1 = "Jalisco" if AGEE == "14"
replace name_1 = "México" if AGEE == "15"
replace name_1 = "Michoacán de Ocampo" if AGEE == "16"
replace name_1 = "Morelos" if AGEE == "17"
replace name_1 = "Nayarit" if AGEE == "18"
replace name_1 = "Nuevo León" if AGEE == "19"
replace name_1 = "Oaxaca" if AGEE == "20"
replace name_1 = "Puebla" if AGEE == "21"
replace name_1 = "Querétaro" if AGEE == "22"
replace name_1 = "Quintana Roo" if AGEE == "23"
replace name_1 = "San Luis Potosí" if AGEE == "24"
replace name_1 = "Sinaloa" if AGEE == "25"
replace name_1 = "Sonora" if AGEE == "26"
replace name_1 = "Tabasco" if AGEE == "27"
replace name_1 = "Tamaulipas" if AGEE == "28"
replace name_1 = "Tlaxcala" if AGEE == "29"
replace name_1 = "Veracruz de Ignacio de la Llave" if AGEE == "30"
replace name_1 = "Yucatán" if AGEE == "31"
replace name_1 = "Zacatecas" if AGEE == "32"

gen name_2 = "" 
	do "$user/_OaxacaBlinder_replication/cleaning/MEX_muninames.do"
		
			
			gen CVE_ENT = AGEE
			gen CVEGEO = AGEM   
			
			// 1. Greater Mexico (IGENI)
			
			gen greatermex = 0
				replace greatermex = 1 if CVEGEO == "09007"   // Iztapalapa
				replace greatermex = 1 if CVEGEO == "15033"   // Ecatepec de Morelos
				replace greatermex = 1 if CVEGEO == "09005"   // Gustavo A. Madero
				replace greatermex = 1 if CVEGEO == "15058"   // Nezahualcóyotl
				replace greatermex = 1 if CVEGEO == "15057"   // Naucalpan de Juárez
				replace greatermex = 1 if CVEGEO == "09010"   // Álvaro Obregón
				replace greatermex = 1 if CVEGEO == "15104"   // Tlalnepantla de Baz
				replace greatermex = 1 if CVEGEO == "09012"   // Tlalpan
				replace greatermex = 1 if CVEGEO == "09003"   // Coyoacán
				replace greatermex = 1 if CVEGEO == "15031"   // Chimalhuacán
				replace greatermex = 1 if CVEGEO == "09015"   // Cuauhtémoc
				replace greatermex = 1 if CVEGEO == "15109"   // Tultitlán
				replace greatermex = 1 if CVEGEO == "15121"   // Cuautitlán Izcalli
				replace greatermex = 1 if CVEGEO == "15013"   // Atizapán de Zaragoza
				replace greatermex = 1 if CVEGEO == "15039"   // Ixtapaluca
				replace greatermex = 1 if CVEGEO == "09017"   // Venustiano Carranza
				replace greatermex = 1 if CVEGEO == "09013"   // Xochimilco
				replace greatermex = 1 if CVEGEO == "09002"   // Azcapotzalco
				replace greatermex = 1 if CVEGEO == "09014"   // Benito Juárez
				replace greatermex = 1 if CVEGEO == "09006"   // Iztacalco
				replace greatermex = 1 if CVEGEO == "09016"   // Miguel Hidalgo
				replace greatermex = 1 if CVEGEO == "15060"   // Nicolás Romero
				replace greatermex = 1 if CVEGEO == "15081"   // Tecámac
				replace greatermex = 1 if CVEGEO == "09011"   // Tláhuac
				replace greatermex = 1 if CVEGEO == "15122"   // Valle de Chalco Solidaridad
				replace greatermex = 1 if CVEGEO == "15025"   // Chalco
				replace greatermex = 1 if CVEGEO == "15020"   // Coacalco de Berriozábal
				replace greatermex = 1 if CVEGEO == "15070"   // La Paz
				replace greatermex = 1 if CVEGEO == "15037"   // Huixquilucan
				replace greatermex = 1 if CVEGEO == "09008"   // La Magdalena Contreras
				replace greatermex = 1 if CVEGEO == "15099"   // Texcoco
				replace greatermex = 1 if CVEGEO == "09004"   // Cuajimalpa de Morelos
				replace greatermex = 1 if CVEGEO == "15029"   // Chicoloapan
				replace greatermex = 1 if CVEGEO == "15120"   // Zumpango
				replace greatermex = 1 if CVEGEO == "15024"   // Cuautitlán
				replace greatermex = 1 if CVEGEO == "15002"   // Acolman
				replace greatermex = 1 if CVEGEO == "09009"   // Milpa Alta
				replace greatermex = 1 if CVEGEO == "15035"   // Huehuetoca
				replace greatermex = 1 if CVEGEO == "13069"   // Tizayuca
				replace greatermex = 1 if CVEGEO == "15108"   // Tultepec
				replace greatermex = 1 if CVEGEO == "15095"   // Tepotzotlán
				replace greatermex = 1 if CVEGEO == "15091"   // Teoloyucan
				replace greatermex = 1 if CVEGEO == "15011"   // Atenco
				replace greatermex = 1 if CVEGEO == "15092"   // Teotihuacán
				replace greatermex = 1 if CVEGEO == "15053"   // Melchor Ocampo
				replace greatermex = 1 if CVEGEO == "15009"   // Amecameca
				replace greatermex = 1 if CVEGEO == "15103"   // Tlalmanalco
				replace greatermex = 1 if CVEGEO == "15112"   // Villa del Carbón
				replace greatermex = 1 if CVEGEO == "15036"   // Hueypoxtla
				replace greatermex = 1 if CVEGEO == "15023"   // Coyotepec
				replace greatermex = 1 if CVEGEO == "15084"   // Temascalapa
				replace greatermex = 1 if CVEGEO == "15100"   // Tezoyuca
				replace greatermex = 1 if CVEGEO == "15059"   // Nextlalpan
				replace greatermex = 1 if CVEGEO == "15065"   // Otumba
				replace greatermex = 1 if CVEGEO == "15096"   // Tequixquiac
				replace greatermex = 1 if CVEGEO == "15093"   // Tepetlaoxtoc
				replace greatermex = 1 if CVEGEO == "15015"   // Atlautla
				replace greatermex = 1 if CVEGEO == "15010"   // Apaxco
				replace greatermex = 1 if CVEGEO == "15068"   // Ozumba
				replace greatermex = 1 if CVEGEO == "15044"   // Jaltenco
				replace greatermex = 1 if CVEGEO == "15028"   // Chiautla
				replace greatermex = 1 if CVEGEO == "15016"   // Axapusco
				replace greatermex = 1 if CVEGEO == "15075"   // San Martín de las Pirámides
				replace greatermex = 1 if CVEGEO == "15050"   // Juchitepec
				replace greatermex = 1 if CVEGEO == "15030"   // Chiconcuac
				replace greatermex = 1 if CVEGEO == "15094"   // Tepetlixpa
				replace greatermex = 1 if CVEGEO == "15046"   // Jilotzingo
				replace greatermex = 1 if CVEGEO == "15022"   // Cocotitlán
				replace greatermex = 1 if CVEGEO == "15083"   // Temamatla
				replace greatermex = 1 if CVEGEO == "15089"   // Tenango del Aire
				replace greatermex = 1 if CVEGEO == "15038"   // Isidro Fabela
				replace greatermex = 1 if CVEGEO == "15125"   // Tonanitla
				replace greatermex = 1 if CVEGEO == "15034"   // Ecatzingo
				replace greatermex = 1 if CVEGEO == "15061"   // Nopaltepec
				replace greatermex = 1 if CVEGEO == "15017"   // Ayapango
				replace greatermex = 1 if CVEGEO == "15069"   // Papalotla

			
			// 2. Secondary metro areas 
			
			gen metro = 0
			
			// 1. UCDB

				replace metro = 1 if CVEGEO == "02004"   // Tijuana
				replace metro = 1 if CVEGEO == "05017"   // Matamoros
				replace metro = 1 if CVEGEO == "05035"   // Torreón
				replace metro = 1 if CVEGEO == "08037"   // Juárez
				replace metro = 1 if CVEGEO == "09002"   // Azcapotzalco
				replace metro = 1 if CVEGEO == "09003"   // Coyoacán
				replace metro = 1 if CVEGEO == "09004"   // Cuajimalpa de Morelos
				replace metro = 1 if CVEGEO == "09005"   // Gustavo A. Madero
				replace metro = 1 if CVEGEO == "09006"   // Iztacalco
				replace metro = 1 if CVEGEO == "09007"   // Iztapalapa
				replace metro = 1 if CVEGEO == "09008"   // La Magdalena Contreras
				replace metro = 1 if CVEGEO == "09009"   // Milpa Alta
				replace metro = 1 if CVEGEO == "09010"   // Álvaro Obregón
				replace metro = 1 if CVEGEO == "09011"   // Tláhuac
				replace metro = 1 if CVEGEO == "09012"   // Tlalpan
				replace metro = 1 if CVEGEO == "09013"   // Xochimilco
				replace metro = 1 if CVEGEO == "09014"   // Benito Juárez
				replace metro = 1 if CVEGEO == "09015"   // Cuauhtémoc
				replace metro = 1 if CVEGEO == "09016"   // Miguel Hidalgo
				replace metro = 1 if CVEGEO == "09017"   // Venustiano Carranza
				replace metro = 1 if CVEGEO == "10007"   // Gómez Palacio
				replace metro = 1 if CVEGEO == "10012"   // Lerdo
				replace metro = 1 if CVEGEO == "11020"   // León
				replace metro = 1 if CVEGEO == "14039"   // Guadalajara
				replace metro = 1 if CVEGEO == "14070"   // El Salto
				replace metro = 1 if CVEGEO == "14101"   // Tonalá
				replace metro = 1 if CVEGEO == "14120"   // Zapopan
				replace metro = 1 if CVEGEO == "14097"   // Tlajomulco de Zúñiga
				replace metro = 1 if CVEGEO == "14098"   // San Pedro Tlaquepaque
				replace metro = 1 if CVEGEO == "15002"   // Acolman
				replace metro = 1 if CVEGEO == "15005"   // Almoloya de Juárez
				replace metro = 1 if CVEGEO == "15011"   // Atenco
				replace metro = 1 if CVEGEO == "15013"   // Atizapán de Zaragoza
				replace metro = 1 if CVEGEO == "15020"   // Coacalco de Berriozábal
				replace metro = 1 if CVEGEO == "15022"   // Cocotitlán
				replace metro = 1 if CVEGEO == "15024"   // Cuautitlán
				replace metro = 1 if CVEGEO == "15025"   // Chalco
				replace metro = 1 if CVEGEO == "15028"   // Chiautla
				replace metro = 1 if CVEGEO == "15029"   // Chicoloapan
				replace metro = 1 if CVEGEO == "15031"   // Chimalhuacán
				replace metro = 1 if CVEGEO == "15033"   // Ecatepec de Morelos
				replace metro = 1 if CVEGEO == "15037"   // Huixquilucan
				replace metro = 1 if CVEGEO == "15039"   // Ixtapaluca
				replace metro = 1 if CVEGEO == "15044"   // Jaltenco
				replace metro = 1 if CVEGEO == "15053"   // Melchor Ocampo
				replace metro = 1 if CVEGEO == "15055"   // Mexicaltzingo
				replace metro = 1 if CVEGEO == "15057"   // Naucalpan de Juárez
				replace metro = 1 if CVEGEO == "15058"   // Nezahualcóyotl
				replace metro = 1 if CVEGEO == "15059"   // Nextlalpan
				replace metro = 1 if CVEGEO == "15060"   // Nicolás Romero
				replace metro = 1 if CVEGEO == "15062"   // Ocoyoacac
				replace metro = 1 if CVEGEO == "15067"   // Otzolotepec
				replace metro = 1 if CVEGEO == "15070"   // La Paz
				replace metro = 1 if CVEGEO == "15081"   // Tecámac
				replace metro = 1 if CVEGEO == "15091"   // Teoloyucan
				replace metro = 1 if CVEGEO == "15095"   // Tepotzotlán
				replace metro = 1 if CVEGEO == "15099"   // Texcoco
				replace metro = 1 if CVEGEO == "15100"   // Tezoyuca
				replace metro = 1 if CVEGEO == "15104"   // Tlalnepantla de Baz
				replace metro = 1 if CVEGEO == "15106"   // Toluca
				replace metro = 1 if CVEGEO == "15108"   // Tultepec
				replace metro = 1 if CVEGEO == "15109"   // Tultitlán
				replace metro = 1 if CVEGEO == "15118"   // Zinacantepec
				replace metro = 1 if CVEGEO == "15121"   // Cuautitlán Izcalli
				replace metro = 1 if CVEGEO == "15122"   // Valle de Chalco Solidaridad
				replace metro = 1 if CVEGEO == "15125"   // Tonanitla
				replace metro = 1 if CVEGEO == "15051"   // Lerma
				replace metro = 1 if CVEGEO == "15054"   // Metepec
				replace metro = 1 if CVEGEO == "15076"   // San Mateo Atenco
				replace metro = 1 if CVEGEO == "15018"   // Calimaya
				replace metro = 1 if CVEGEO == "19006"   // Apodaca
				replace metro = 1 if CVEGEO == "19018"   // García
				replace metro = 1 if CVEGEO == "19019"   // San Pedro Garza García
				replace metro = 1 if CVEGEO == "19021"   // General Escobedo
				replace metro = 1 if CVEGEO == "19026"   // Guadalupe
				replace metro = 1 if CVEGEO == "19031"   // Juárez
				replace metro = 1 if CVEGEO == "19039"   // Monterrey
				replace metro = 1 if CVEGEO == "19041"   // Pesquería
				replace metro = 1 if CVEGEO == "19046"   // San Nicolás de los Garza
				replace metro = 1 if CVEGEO == "19048"   // Santa Catarina
				replace metro = 1 if CVEGEO == "21015"   // Amozoc
				replace metro = 1 if CVEGEO == "21034"   // Coronango
				replace metro = 1 if CVEGEO == "21041"   // Cuautlancingo
				replace metro = 1 if CVEGEO == "21090"   // Juan C. Bonilla
				replace metro = 1 if CVEGEO == "21106"   // Ocoyucan
				replace metro = 1 if CVEGEO == "21114"   // Puebla
				replace metro = 1 if CVEGEO == "21119"   // San Andrés Cholula
				replace metro = 1 if CVEGEO == "21125"   // San Gregorio Atzompa
				replace metro = 1 if CVEGEO == "21126"   // San Jerónimo Tecuanipan
				replace metro = 1 if CVEGEO == "21140"   // San Pedro Cholula
				replace metro = 1 if CVEGEO == "24028"   // San Luis Potosí
				replace metro = 1 if CVEGEO == "24035"   // Soledad de Graciano Sánchez
				replace metro = 1 if CVEGEO == "29025"   // San Pablo del Monte

			
			// 2. IGENI 
			
				replace metro = 1 if CVEGEO == "15118"   // Zinacantepec
				replace metro = 1 if CVEGEO == "15115"   // Xonacatlán
				replace metro = 1 if CVEGEO == "15106"   // Toluca
				replace metro = 1 if CVEGEO == "15087"   // Temoaya
				replace metro = 1 if CVEGEO == "15076"   // San Mateo Atenco
				replace metro = 1 if CVEGEO == "15073"   // San Antonio la Isla
				replace metro = 1 if CVEGEO == "15072"   // Rayón
				replace metro = 1 if CVEGEO == "15067"   // Otzolotepec
				replace metro = 1 if CVEGEO == "15062"   // Ocoyoacac
				replace metro = 1 if CVEGEO == "15055"   // Mexicaltzingo
				replace metro = 1 if CVEGEO == "15054"   // Metepec
				replace metro = 1 if CVEGEO == "15051"   // Lerma
				replace metro = 1 if CVEGEO == "15027"   // Chapultepec
				replace metro = 1 if CVEGEO == "15018"   // Calimaya
				replace metro = 1 if CVEGEO == "15005"   // Almoloya de Juárez
				replace metro = 1 if CVEGEO == "17020"   // Tepoztlán
				replace metro = 1 if CVEGEO == "17018"   // Temixco
				replace metro = 1 if CVEGEO == "17007"   // Cuernavaca
				replace metro = 1 if CVEGEO == "17028"   // Xochitepec
				replace metro = 1 if CVEGEO == "17009"   // Huitzilac
				replace metro = 1 if CVEGEO == "17008"   // Emiliano Zapata
				replace metro = 1 if CVEGEO == "17011"   // Jiutepec
				replace metro = 1 if CVEGEO == "17024"   // Tlaltizapán
				replace metro = 1 if CVEGEO == "02004"   // Tijuana
				replace metro = 1 if CVEGEO == "02003"   // Tecate
				replace metro = 1 if CVEGEO == "02005"   // Playas de Rosarito
				replace metro = 1 if CVEGEO == "02002"   // Mexicali
				replace metro = 1 if CVEGEO == "14039"   // Guadalajara
				replace metro = 1 if CVEGEO == "14044"   // Ixtlahuacán de los Membrillos
				replace metro = 1 if CVEGEO == "14120"   // Zapopan
				replace metro = 1 if CVEGEO == "14070"   // El Salto
				replace metro = 1 if CVEGEO == "14098"   // Tlaquepaque
				replace metro = 1 if CVEGEO == "14101"   // Tonalá
				replace metro = 1 if CVEGEO == "14051"   // Juanacatlán
				replace metro = 1 if CVEGEO == "14097"   // Tlajomulco de Zúñiga
				replace metro = 1 if CVEGEO == "10007"   // Gómez Palacio
				replace metro = 1 if CVEGEO == "10012"   // Lerdo
				replace metro = 1 if CVEGEO == "08037"   // Juárez
				replace metro = 1 if CVEGEO == "22011"   // El Marqués
				replace metro = 1 if CVEGEO == "22014"   // Querétaro
				replace metro = 1 if CVEGEO == "22008"   // Huimilpan
				replace metro = 1 if CVEGEO == "22006"   // Corregidora
				replace metro = 1 if CVEGEO == "24035"   // Soledad de Graciano Sánchez
				replace metro = 1 if CVEGEO == "24028"   // San Luis Potosí
				replace metro = 1 if CVEGEO == "11037"   // Silao
				replace metro = 1 if CVEGEO == "11020"   // León
				replace metro = 1 if CVEGEO == "01005"   // Jesús María
				replace metro = 1 if CVEGEO == "01011"   // San Francisco de los Romo
				replace metro = 1 if CVEGEO == "01001"   // Aguascalientes
				replace metro = 1 if CVEGEO == "29059"   // Santa Cruz Quilehtla
				replace metro = 1 if CVEGEO == "29058"   // Santa Catarina Ayometla
				replace metro = 1 if CVEGEO == "29057"   // Santa Apolonia Teacalco
				replace metro = 1 if CVEGEO == "29056"   // Santa Ana Nopalucan
				replace metro = 1 if CVEGEO == "29054"   // San Lorenzo Axocomanitla
				replace metro = 1 if CVEGEO == "29053"   // San Juan Huactzinco
				replace metro = 1 if CVEGEO == "29051"   // San Jerónimo Zacualpan
				replace metro = 1 if CVEGEO == "29044"   // Zacatelco
				replace metro = 1 if CVEGEO == "29042"   // Xicohtzinco
				replace metro = 1 if CVEGEO == "29041"   // Papalotla de Xicohténcatl
				replace metro = 1 if CVEGEO == "29032"   // Tetlatlahuca
				replace metro = 1 if CVEGEO == "29029"   // Tepeyanco
				replace metro = 1 if CVEGEO == "29028"   // Teolocholco
				replace metro = 1 if CVEGEO == "29027"   // Tenancingo
				replace metro = 1 if CVEGEO == "29025"   // San Pablo del Monte
				replace metro = 1 if CVEGEO == "29023"   // Natívitas
				replace metro = 1 if CVEGEO == "29022"   // Acuamanala de Miguel Hidalgo
				replace metro = 1 if CVEGEO == "29019"   // Tepetitla de Lardizábal
				replace metro = 1 if CVEGEO == "29017"   // Mazatecochco de José María Morelos
				replace metro = 1 if CVEGEO == "29015"   // Ixtacuixtla de Mariano Matamoros
				replace metro = 1 if CVEGEO == "21001"   // Acajete
				replace metro = 1 if CVEGEO == "21015"   // Amozoc
				replace metro = 1 if CVEGEO == "21034"   // Coronango
				replace metro = 1 if CVEGEO == "21041"   // Cuautlancingo
				replace metro = 1 if CVEGEO == "21048"   // Chiautzingo
				replace metro = 1 if CVEGEO == "21060"   // Domingo Arenas
				replace metro = 1 if CVEGEO == "21074"   // Huejotzingo
				replace metro = 1 if CVEGEO == "21090"   // Juan C. Bonilla
				replace metro = 1 if CVEGEO == "21106"   // Ocoyucan
				replace metro = 1 if CVEGEO == "21114"   // Puebla
				replace metro = 1 if CVEGEO == "21119"   // San Andrés Cholula
				replace metro = 1 if CVEGEO == "21122"   // San Felipe Teotlalcingo
				replace metro = 1 if CVEGEO == "21125"   // San Gregorio Atzompa
				replace metro = 1 if CVEGEO == "21132"   // San Martín Texmelucan
				replace metro = 1 if CVEGEO == "21136"   // San Miguel Xoxtla
				replace metro = 1 if CVEGEO == "21140"   // San Pedro Cholula
				replace metro = 1 if CVEGEO == "21143"   // San Salvador el Verde
				replace metro = 1 if CVEGEO == "21163"   // Tepatlaxco de Hidalgo
				replace metro = 1 if CVEGEO == "21181"   // Tlaltenango
				replace metro = 1 if CVEGEO == "19026"   // Guadalupe
				replace metro = 1 if CVEGEO == "19031"   // Juárez
				replace metro = 1 if CVEGEO == "19049"   // Santiago
				replace metro = 1 if CVEGEO == "19018"   // García
				replace metro = 1 if CVEGEO == "19048"   // Santa Catarina
				replace metro = 1 if CVEGEO == "19039"   // Monterrey
				replace metro = 1 if CVEGEO == "19019"   // San Pedro Garza García
				replace metro = 1 if CVEGEO == "19010"   // Carmen
				replace metro = 1 if CVEGEO == "19021"   // Gral. Escobedo
				replace metro = 1 if CVEGEO == "19045"   // Salinas Victoria
				replace metro = 1 if CVEGEO == "19006"   // Apodaca
				replace metro = 1 if CVEGEO == "19046"   // San Nicolás de los Garza
				replace metro = 1 if CVEGEO == "19009"   // Cadereyta Jiménez
				replace metro = 1 if CVEGEO == "95035"   // Torreón
				replace metro = 1 if CVEGEO == "105017"   // Matamoros
				replace metro = 1 if CVEGEO == "31050"   // Mérida
				replace metro = 1 if CVEGEO == "31041"   // Kanasín
				replace metro = 1 if CVEGEO == "31101"   // Umán
				replace metro = 1 if CVEGEO == "31100"   // Ucú
				replace metro = 1 if CVEGEO == "31013"   // Conkal

			

gen geo_level2 = .
replace geo_level2 = 1 if AGEE == "01"
replace geo_level2 = 2 if AGEE == "02"
replace geo_level2 = 3 if AGEE == "03"
replace geo_level2 = 4 if AGEE == "04"
replace geo_level2 = 5 if AGEE == "05"
replace geo_level2 = 6 if AGEE == "06"
replace geo_level2 = 7 if AGEE == "07"
replace geo_level2 = 8 if AGEE == "08"
replace geo_level2 = 9 if AGEE == "09"
replace geo_level2 = 10 if AGEE == "10"
replace geo_level2 = 11 if AGEE == "11"
replace geo_level2 = 12 if AGEE == "12"
replace geo_level2 = 13 if AGEE == "13"
replace geo_level2 = 14 if AGEE == "14"
replace geo_level2 = 15 if AGEE == "15"
replace geo_level2 = 16 if AGEE == "16"
replace geo_level2 = 17 if AGEE == "17"
replace geo_level2 = 18 if AGEE == "18"
replace geo_level2 = 19 if AGEE == "19"
replace geo_level2 = 20 if AGEE == "20"
replace geo_level2 = 21 if AGEE == "21"
replace geo_level2 = 22 if AGEE == "22"
replace geo_level2 = 23 if AGEE == "23"
replace geo_level2 = 24 if AGEE == "24"
replace geo_level2 = 25 if AGEE == "25"
replace geo_level2 = 26 if AGEE == "26"
replace geo_level2 = 27 if AGEE == "27"
replace geo_level2 = 28 if AGEE == "28"
replace geo_level2 = 29 if AGEE == "29"
replace geo_level2 = 30 if AGEE == "30"
replace geo_level2 = 31 if AGEE == "31"
replace geo_level2 = 32 if AGEE == "32"
		
gen urban_rural = urbano
		recode urban_rural (0 = 2)
			
merge m:1 year urban_rural geo_level2 using "$user/_OaxacaBlinder_replication/cleaning/MEX_spdef"
				keep if _merge == 3
				drop _merge
						
** Incomes 
		
sum ila // total labor inide (individual)
sum ilpc // per capita labor income ** (based on hh)
sum ii // individual total income

** correct income before deflating properly

foreach inc in ila ilpc ii ipcf_sr{
	replace `inc' = `inc'*0.8695 if urbano == 0
}

	* prices 
	
// for international comparison	
	
gen ipcc_11 =   ipc11_sedlac
gen ipcc_05  =  ipc05_sedlac
gen ppp_05  =  ppp05
gen ppp_11  =  ppp11

tab year, sum(ipc_sedlac) // for time comparison

// household labor income 
	gen  hh_labinc_pc_11 = ilpc/(ipc_sedlac/ipcc_11)
	gen  hh_labinc_pc_ppp11 = (hh_labinc_pc_11/defla_inegi_11_pline)/ppp_11

	
// individual labor income 
	gen  ind_labinc_11 = ila/(ipc_sedlac/ipcc_11)
	gen  ind_labinc_ppp11 = (ind_labinc_11/defla_inegi_11_pline)/ppp_11
	
// household total inc 

	gen  hh_totinc_pc_11 = ipcf_sr/(ipc_sedlac/ipcc_11)
	gen  hh_totinc_pc_ppp11 = (hh_totinc_pc_11/defla_inegi_11_pline)/ppp_11
	
// individual total income 

	gen  ind_totinc_11 = ii/(ipc_sedlac/ipcc_11)
	gen  ind_totinc_ppp11 = (ind_totinc_11/defla_inegi_11_pline)/ppp_11

// 	logs
	gen lind_labinc_ppp11 = log(ind_labinc_ppp11)
	gen lhh_labinc_pc_ppp11 = log(hh_labinc_pc_ppp11)
	gen lhh_totinc_pc_ppp11 = log(hh_totinc_pc_ppp11)
	gen lind_totinc_11 = log(ind_totinc_ppp11)	
	
	
save MEX_SEDLACall_names.dta, replace	
	
** determining leading region 	
*collapse (mean) ilpc,  by(year region dep dist urbano) 

	*merge m:1 AGEE AGEM using LAC/MEX_metros_m

	gen leading1 = 0
	replace leading1 = 1 if greatermex == 1 & urbano == 1 // only City of Mexico, urban
	
	gen leading2 = 0
	replace leading2 = 1 if (leading1 == 1 | metro == 1) & urbano == 1 
	
	gen leading3 = 0 
	replace leading3 = 1 if AGEE == "09" & urbano == 1
	
	tab state leading3
	
	gen noleading1 = leading1
	gen noleading2 = leading2
	
	recode noleading1 (0 = 1)(1 = 0)
	recode noleading2 (0 = 1)(1 = 0)	
	
	
** Bottom 40%

	foreach year in 2000 2002 2004 2005 2006 2008 2010 2012 2014 2016 2018{
	_pctile hh_totinc_pc_ppp11 [aweight=pondera_i] if year == `year', p(40) 
	return list
	gen b40_`year' = r(r1)
	}
	
	gen b40 = .
	foreach year in 2000 2002 2004 2005 2006 2008 2010 2012 2014 2016 2018{
	replace b40 = b40_`year' if year == `year'
	}
	
	drop b40_*
	
	gen b40d = 0
	replace b40d = 1 if hh_totinc_pc_ppp11 < b40

** skilled 
gen skilled=(nivel>=5)    

** Urban/Rural 
sum urbano

** Demographics

// gender
gen gender = hombre 

// age
gen  age =  edad
gen  agesq = age^2 

// family size and age idposition
bysort year id: egen  hhsize = count(id)
reg miembros hhsize

egen  hh_s_02 = count(id)  if age<=2 & age~=. , by(id year) 
egen  hh_size_02 = mean(hh_s_02), by(id year) 
replace  hh_size_02=0 if  hh_size_02==.
gen   hh_size_02_sq = hh_size_02^2
drop  hh_s_02

egen  hh_s_311 = count(id)  if age>2 &  age<=11  & age~=., by(id year) 
egen  hh_size_311 = mean(hh_s_311)   , by(id year) 
replace  hh_size_311=0 if  hh_size_311==.
gen   hh_size_311_sq = hh_size_311^2
drop  hh_s_311

egen  hh_s_1217 = count(id)  if age>11 &  age<=17 & age~=., by(id year) 
egen  hh_size_1217 = mean(hh_s_1217)   , by(id year) 
replace  hh_size_1217=0 if  hh_size_1217==.
gen   hh_size_1217_sq = hh_size_1217^2
drop  hh_s_1217

egen  hh_s_1859 = count(id)  if age>17 &  age<=59 & age~=., by(id year) 
egen  hh_size_1859 = mean(hh_s_1859 )   , by(id year) 
replace  hh_size_1859=0 if  hh_size_1859==.
gen   hh_size_1859_sq = hh_size_1859^2
drop  hh_s_1859

egen  hh_s_60 = count(id)  if age>59  & age~=. , by(id year) 
egen  hh_size_60 = mean(hh_s_60 )   , by(id year) 
replace  hh_size_60=0 if  hh_size_60==.
gen   hh_size_60_sq = hh_size_60^2
drop  hh_s_60
 	


// Female had 
gen   hh_fhead= .
replace hh_fhead = 1 if relacion==1  & gender==0
replace hh_fhead = 0 if relacion!=1  | gender==1
	
// education 

gen edattain = 1        if  nivel==0  | nivel==1
replace  edattain = 2   if  nivel==2  | nivel==3
replace  edattain = 3   if  nivel==4  | nivel==5
replace  edattain = 4   if  nivel==6

gen   hh_head_ed  = edattain       if edattain~=.  &  relacion==1   
egen  hh_head_edattain = mean(hh_head_ed), by(id year) 
drop hh_head_ed
	
egen  hh_max_ed = max(edattain) if  edattain~=.  & (relacion>= 2) , by(id year) 
egen  hh_max_edattain = mean(hh_max_ed), by(id year) 
drop hh_max_ed

// employment
sum ocupado
sum pea

tab pea ocupado

tab relab // type of occupation 

gen   empstat=.  
replace  empstat=1  if  ocupado==1
replace  empstat=2  if  desocupa==1
replace  empstat=3  if  pea==0

count

tab agua
tab elect 
tab cloacas
tab banio 

// utilities 
egen hh_elect = mean(elect), by(year id)  
egen  hh_sewage = mean(cloacas), by(year id) 
egen  hh_toilet = mean(banio), by(year id) 
egen hh_piped_to_prem = mean(agua), by(year id) // water

	
	tab year
	
	gen period = .
	
	replace period = 1 if year <= 2004
	*replace period = 2 if year > 2004 & year <= 2008
	*replace period = 3 if year > 2008 & year <= 2014
	replace period = 4 if year > 2014
	*replace period = 5 if year == 2020
		
	tab year 
	
		gen adm1 = name_1
	
		
	keep id com urbano reg* CVEGEO CVEGEO CVE_ENT greatermex name_1 name_2 AGEE AGEM state* geo_level2  year period leading* noleading* lind* lhh* ind_* hh_* ila ilf ilpc ii ipcf_sr itf p_reg b40* skilled* cohh cohi pondera* gender age agesq hhsize casado hh_size_02 hh_size_02_sq hh_size_311 hh_size_311_sq hh_size_1217 hh_size_1217_sq hh_size_1859 hh_size_1859_sq hh_size_60 hh_size_60_sq empstat* relab* edattain* hh_max_edattain* hh_piped_to_prem hh_elect hh_sewage hh_toilet lp_moderada adm1 jefe
	
		tab year leading1 [w=pondera], row nofreq
		tab year leading2 [w=pondera], row nofreq
		tab year leading3 [w=pondera], row nofreq
		
		tab state leading2

save "$user/_OaxacaBlinder_replication/inputs/MEX_SEDLACsmall.dta", replace
