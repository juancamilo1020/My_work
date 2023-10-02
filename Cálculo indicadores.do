********************************************************************************
********************************************************************************
********************************************************************************
****** PERU - ENPOVE 2022
	
	clear all
	set more off, perm
	set maxvar 15000
	scalar drop _all

	** BASE DE DATOS
	cd "/Users/juancamiloperdomo/Library/CloudStorage/OneDrive-Inter-AmericanDevelopmentBankGroup/Otros/ENPOVE-Mercado laboral"
	use "ENPOVE22.dta", replace

	gen uno=1
	replace factor_ci=round(factor_ci)
	replace migrante_ci = 0 if migrante_ci == .
	
	****************************************************************************
	** LOCALS
		local 1_label = "migr"
		local 0_label = "nat"
		
	gen p307n = substr(p307,1,2)
	destring p307n, replace
		
******************************************************************* ESTADÍSTICAS
********************************************************************************
********************************************************************************

** CÁLCULO DE INDICADORES
		
* Población total
sum uno if migrante_ci!=. [fw=factor_ci]
scalar migr_pop = `=r(N)'
		
* Grupos de edades
sum uno if inrange(edad_ci,0,14) & migrante_ci!=. [fw=factor_ci]
scalar pop_migr_014 = `=r(N)' // 0 - 14 years
		
sum uno if inrange(edad_ci,15,24) & migrante_ci!=. [fw=factor_ci]
scalar pop_migr_1524 = `=r(N)' // 15 - 24 years

sum uno if inrange(edad_ci,25,39) & migrante_ci!=. [fw=factor_ci]
scalar pop_migr_2539 = `=r(N)' // 25 - 39 years
		
sum uno if inrange(edad_ci,40,54) & migrante_ci!=. [fw=factor_ci]
scalar pop_migr_4054 = `=r(N)' // 40 - 54 years

sum uno if inrange(edad_ci,55,64) & migrante_ci!=. [fw=factor_ci]
scalar pop_migr_5564 = `=r(N)'	//55 - 64 years
		
sum uno if inrange(edad_ci,65,.) & migrante_ci!=. [fw=factor_ci]
scalar pop_migr_65older = `=r(N)'  // 65 older years
		
* Mujeres
sum uno if sexo_ci==2 [fw=factor_ci]
scalar female_migr_pop =`=r(N)'	
		
** LABOUR MARKET INDICATORS
		
* Activos
sum uno if edad_ci>=18 & pea_ci==1 & p208=="1.Sí" & (relacion_ci==1|relacion_ci==2) & p303_anio>=2019 & p307n!=13 [fw=factor_ci]
scalar econoAct_migr_pop = `=r(N)'
		
sum uno if edad_ci>=18 & p208=="1.Sí" & (relacion_ci==1|relacion_ci==2) & p303_anio>=2019 & p307n!=13 [fw=factor_ci]
scalar workAge_migr_pop = `=r(N)'
		
* Ocupados
sum uno if edad_ci>=18 & p208=="1.Sí" & (relacion_ci==1|relacion_ci==2) & emp_ci==1 & p303_anio>=2019 & p307n!=13 [fw=factor_ci]
scalar job_migr_pop = `=r(N)'

* Asalariados
sum uno if (categopri_ci==3) & edad_ci>=18 & p208=="1.Sí" & (relacion_ci==1|relacion_ci==2) & p303_anio>=2019 & p307n!=13 [fw=factor_ci]
scalar asala_migr_pop = `=r(N)'
		
* Independientes
sum uno if (categopri_ci==2) & edad_ci>=18 & p208=="1.Sí" & (relacion_ci==1|relacion_ci==2) & p303_anio>=2019 & p307n!=13 [fw=factor_ci]
scalar selfEmp_migr_pop = `=r(N)'
		
* Formales
sum uno if edad_ci>=18 & p208=="1.Sí" & (relacion_ci==1|relacion_ci==2) & afiliado_ci==1 & p303_anio>=2019 & p307n!=13 [fw=factor_ci]
scalar formal_migr_pop = `=r(N)'

* Desempleados
sum uno if edad_ci>=18 & p208=="1.Sí" & (relacion_ci==1|relacion_ci==2) & desemp_ci==1 & p303_anio>=2019 & p307n!=13 [fw=factor_ci] 
scalar unemp_migr_pop = `=r(N)'
		
	
******************************************************** EXCEL OUTPUTS

	putexcel set "/Users/juancamiloperdomo/Library/CloudStorage/OneDrive-Inter-AmericanDevelopmentBankGroup/Otros/ENPOVE-Mercado laboral/Resultados.xlsx", sheet("Hoja 1") modify
	putexcel describe
	
	
	** DEMOGRAFICOS
	
	putexcel C5 = (`=pop_migr_014'/`=migr_pop') // 0 - 14
	
	putexcel C6 = (`=pop_migr_1524'/`=migr_pop') // 15 - 24
	
	putexcel C7 = (`=pop_migr_2539'/`=migr_pop') // 25 - 39
	
	putexcel C8 = (`=pop_migr_4054'/`=migr_pop') // 40 - 54
	
	putexcel C9 = (`=pop_migr_5564'/`=migr_pop') // 55 - 64
	
	putexcel C10 = (`=pop_migr_65older'/`=migr_pop') // 65+
	
	putexcel C11 = (`=female_migr_pop'/`=migr_pop') // Mujeres
	
	
	** LABOUR MARKET INDICATORS

	putexcel C12 = (`=econoAct_migr_pop'/`=workAge_migr_pop') // Activos

	putexcel C13 = (`=job_migr_pop'/`=econoAct_migr_pop') // Ocupados
	
	putexcel C14 = (`=asala_migr_pop'/`=job_migr_pop') // Asalariados	
	
	putexcel C15 = (`=selfEmp_migr_pop'/`=job_migr_pop') // Independientes
	
	putexcel C16 = (`=formal_migr_pop'/`=job_migr_pop') // Formales

	putexcel C17 = (`=unemp_migr_pop'/`=econoAct_migr_pop') // Desempleados
