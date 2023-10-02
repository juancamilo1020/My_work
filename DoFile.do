********************************************************************************
********************************************************************************
********************************************************************************
** ECUADOR ENEMDU 2021 DATOS DE TODO EL AÑO
	
	clear all
	set more off, perm
	set maxvar 15000
	scalar drop _all

	cd "C:\Users\JCAMILOP\OneDrive - Inter-American Development Bank Group\Otros\Ecuador\"
	use "ECU_2021a_BID.dta", replace

	gen uno=1
	replace factor_ci=round(factor_ci/4) // Se aplica, dado que se tienen los datos de los 4 trimestres unidos
	
	** Local para estadísticas
		local 3_label = "migrCol"
		local 2_label = "migrVen"		
		local 1_label = "migr"
		local 0_label = "nat"
		
	replace migrante_ci = 2 if p15ab == 862
	replace migrante_ci = 3 if p15ab == 170
	

	
		
******************************************************************* ESTADÍSTICAS
********************************************************************************
********************************************************************************

	** CÁLCULOS SEGÚN MIGRANTES, MIGRANTES VENEZOLANOS, COLOMBIANOS Y NATIVOS
	
	foreach var in 3 2 1 0 {
		
		** CARACTERÍSTICAS INICIALES
		
		* Población total en el país según factores de expansión 
		sum uno if migrante_ci==`var' [fw=factor_ci]
		scalar Pobla_``var'_label'_grupo = `=r(N)'
		
		* Porcentaje de habitantes entre 30 y 40 años según factores de expansión 
		sum uno if migrante_ci==`var' & inrange(edad_ci,30,40)  [fw=factor_ci]
		scalar Pobla_``var'_label'_30_40 = `=r(N)'		
		
		* Porcentaje de habitantes que sí terminó la primaria según factores de expansión 
		sum uno if migrante_ci==`var' & aedu_ci>=6 & inrange(edad_ci,30,40) [fw=factor_ci]
		scalar Pobla_``var'_label'_PriComp = `=r(N)'
		
		* Porcentaje de habitantes que sí terminó el bachillerato según factores de expansión 
		sum uno if migrante_ci==`var' & aedu_ci>=12 & inrange(edad_ci,30,40) [fw=factor_ci]
		scalar Pobla_``var'_label'_BachiComp = `=r(N)'
		
		* Porcentaje de habitantes con educación universitaria completa según factores de expansión 
		sum uno if migrante_ci==`var' & aedu_ci>12 & inrange(edad_ci,30,40) [fw=factor_ci]
		scalar Pobla_``var'_label'_UniverComp = `=r(N)'
		
		** Población total en el país sin factores de expansión (muestra)
		sum uno if migrante_ci==`var'
		scalar Muestra_``var'_label'_grupo = `=r(N)'
		
		** Porcentaje de habitantes entre 30 y 40 años sin factores de expansión (muestra)
		sum uno if migrante_ci==`var' & inrange(edad_ci,30,40)
		scalar Muestra_``var'_label'_30_40 = `=r(N)'		
		
		** Porcentaje de habitantes que sí terminó la primaria sin factores de expansión (muestra)
		sum uno if migrante_ci==`var' & aedu_ci>=6 & inrange(edad_ci,30,40)
		scalar Muestra_``var'_label'_PriComp = `=r(N)'
		
		** Porcentaje de habitantes que sí terminó el bachillerato sin factores de expansión (muestra)
		sum uno if migrante_ci==`var' & aedu_ci>=12 & inrange(edad_ci,30,40)
		scalar Muestra_``var'_label'_BachiComp = `=r(N)'
		
		** Porcentaje de habitantes con educación universitaria completa sin factores de expansión (muestra)
		sum uno if migrante_ci==`var' & aedu_ci>12 & inrange(edad_ci,30,40)
		scalar Muestra_``var'_label'_UniverComp = `=r(N)'
		
	}
	
	
******************************************************** OUTPUTS EN EXCEL

	putexcel set "C:\Users\jcamilop\OneDrive - Inter-American Development Bank Group\Otros\Ecuador\Resultados.xlsx", sheet("Sheet1") modify
	putexcel describe
	
	
	** VARIABLES DEMOGRÁFICAS
	
	* Población total en el país según factores de expansión 
	putexcel B4 = (`=Pobla_nat_grupo') C4 = (`=Pobla_migr_grupo')	D4 = (`=Pobla_migrVen_grupo')	  E4 = (`=Pobla_migrCol_grupo')
	
	* Porcentaje de habitantes entre 30 y 40 años según factores de expansión 
	putexcel B5 = (`=Pobla_nat_30_40') C5 = (`=Pobla_migr_30_40')	D5 = (`=Pobla_migrVen_30_40')	  E5 = (`=Pobla_migrCol_30_40')
	
	* Porcentaje de habitantes que sí terminó la primaria según factores de expansión
	putexcel B6 = (`=Pobla_nat_PriComp') C6 = (`=Pobla_migr_PriComp')	D6 = (`=Pobla_migrVen_PriComp')	  E6 = (`=Pobla_migrCol_PriComp')
	
	* Porcentaje de habitantes que sí terminó el bachillerato según factores de expansión
	putexcel B7 = (`=Pobla_nat_BachiComp') C7 = (`=Pobla_migr_BachiComp')	D7 = (`=Pobla_migrVen_BachiComp')	E7 = (`=Pobla_migrCol_BachiComp')
	
	* Porcentaje de habitantes con educación universitaria completa según factores de expansión 
	putexcel B8 = (`=Pobla_nat_UniverComp') C8 = (`=Pobla_migr_UniverComp')	D8 = (`=Pobla_migrVen_UniverComp')	E8 = (`=Pobla_migrCol_UniverComp')
	
	* Población total en el país sin factores de expansión (muestra)
	putexcel B9 = (`=Muestra_nat_grupo') C9 = (`=Muestra_migr_grupo')	D9 = (`=Muestra_migrVen_grupo')	  E9 = (`=Muestra_migrCol_grupo')
	
	* Porcentaje de habitantes entre 30 y 40 años sin factores de expansión (muestra) 
	putexcel B10 = (`=Muestra_nat_30_40') C10 = (`=Muestra_migr_30_40')	D10 = (`=Muestra_migrVen_30_40')	E10 = (`=Muestra_migrCol_30_40')
	
	* Porcentaje de habitantes que sí terminó la primaria sin factores de expansión (muestra)
	putexcel B11 = (`=Muestra_nat_PriComp') C11 = (`=Muestra_migr_PriComp')	D11 = (`=Muestra_migrVen_PriComp') E11 = (`=Muestra_migrCol_PriComp')
	
	* Porcentaje de habitantes que sí terminó el bachillerato sin factores de expansión (muestra)
	putexcel B12 = (`=Muestra_nat_BachiComp') C12 = (`=Muestra_migr_BachiComp')	D12 = (`=Muestra_migrVen_BachiComp') E12 = (`=Muestra_migrCol_BachiComp')
	
	* Porcentaje de habitantes con educación universitaria completa sin factores de expansión (muestra)
	putexcel B13 = (`=Muestra_nat_UniverComp') C13 = (`=Muestra_migr_UniverComp')	D13 = (`=Muestra_migrVen_UniverComp')	E13 = (`=Muestra_migrCol_UniverComp')
	