cd "/Users/juancamiloperdomo/Library/CloudStorage/OneDrive-Inter-AmericanDevelopmentBankGroup/Indicadores DataMIG/01 Raw/"
*cd "C:\Users\JCAMILOP\OneDrive - Inter-American Development Bank Group\Indicadores DataMIG\01 Raw"

********************************************************************************
********************************************************************************
********************************************************************************
********************************************************************** ARGENTINA
	clear all
	set more off, perm
	set maxvar 15000
	scalar drop _all

	** DATASET
	use "ARG_2021s2_BID.dta", replace

	gen uno=1
	replace factor_ci=round(factor_ci) // Applies when the expansion factor is a non-integer numbers
	
	****************************************************************************
	** LOCALS
		local 1_label = "migr"
		local 0_label = "nat"
		
		local 1_sexo = "masc_"
		local 2_sexo = "fem_"
		
********************************************************************* STATISTICS
********************************************************************************
********************************************************************************

	** CALCULATION OF INDICATORS
	
	** POPULATION
	
	* Total population calculated according to expansion factor
	sum uno if migrante_ci!=. [fw=factor_ci]
	scalar tot_pop = `=r(N)'
	
	* Migrant population calculated according to expansion factor
	sum uno if migrante_ci==1 [fw=factor_ci]
	scalar migr_pop = `=r(N)'
	
	* Native population calculated according to expansion factor
	sum uno if migrante_ci==0 [fw=factor_ci]
	scalar nat_pop = `=r(N)'
	

	** CALCULATION OF INDICATORS BY MIGRANTS AND NATIVES
	
	foreach var in 1 0 {
		
		foreach sexo in 1 2 {
		
		** DEMOGRAPHIC
		
		* Genders
		
		sum uno if migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar ``var'_label'_``sexo'_sexo'pop = `=r(N)' // 0 - 5 years
		
		* Age groups
		
		sum uno if inrange(edad_ci,0,5) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar pop_``var'_label'_``sexo'_sexo'05 = `=r(N)' // 0 - 5 years
		
		sum uno if inrange(edad_ci,6,15) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar pop_``var'_label'_``sexo'_sexo'615 = `=r(N)' // 6 - 15 years

		sum uno if inrange(edad_ci,16,34) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar pop_``var'_label'_``sexo'_sexo'1634 = `=r(N)'	//16 - 34 years
		
		sum uno if inrange(edad_ci,35,64) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar pop_``var'_label'_``sexo'_sexo'3564 = `=r(N)'	//35 - 64 years
		
		sum uno if inrange(edad_ci,65,.) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar pop_``var'_label'_``sexo'_sexo'65older = `=r(N)'  // 65 older years
		
		* Sex population
		sum uno if sexo_ci==1 & migrante_ci==`var' [fw=factor_ci]
		scalar male_``var'_label'_pop =`=r(N)'
		
		sum uno if sexo_ci==2 & migrante_ci==`var' [fw=factor_ci]
		scalar female_``var'_label'_pop =`=r(N)'
		
		
		** LABOUR MARKET INDICATORS
		
		* Share of population with a job
		sum uno if inrange(edad_ci,15,64) & emp_ci==1 & migrante_ci==`var' [fw=factor_ci]
		scalar job_``var'_label'_pop = `=r(N)'
		
		* Unemployment: Share of population who were unemployed
		sum uno if inrange(edad_ci,15,64) & desemp_ci==1 & migrante_ci==`var' [fw=factor_ci] 
		scalar unemp_``var'_label'_pop = `=r(N)'
		
		sum uno if (pea_ci==1) & inrange(edad_ci,15,64) & migrante_ci==`var' [fw=factor_ci]
		scalar econoActWorkAge_``var'_label'_pop = `=r(N)'
		

		** EDUCATION AND SKILLS
		
		* Share of children attending schooling, 5 - 16 years group
		sum uno if asiste_ci==1 & inrange(edad_ci,5,16) & migrante_ci==`var' [fw=factor_ci]
		scalar attending_5to16_``var'_label'_pop = `=r(N)'
		
		sum uno if asiste_ci==0 & inrange(edad_ci,5,16) & migrante_ci==`var' [fw=factor_ci]
		scalar noedu_5to16_``var'_label'_pop = `=r(N)'
		
		sum uno if inrange(edad_ci,5,16) & migrante_ci==`var' [fw=factor_ci] 
		scalar pop_``var'_label'_516 = `=r(N)'
		
	}
	
		}
	
******************************************************** EXCEL OUTPUTS

	*putexcel set "/Users/juancamiloperdomo/Library/CloudStorage/OneDrive-Inter-AmericanDevelopmentBankGroup/Indicadores DataMIG/01 Raw/Resultados.xlsx", sheet("Hoja 1") modify
	putexcel set "C:\Users\JCAMILOP\OneDrive - Inter-American Development Bank Group\Indicadores DataMIG\Resultados.xlsx", sheet("Hoja1") modify
	putexcel describe
	
	
	** DEMOGRAPHIC
	
	putexcel F2 = (`=female_migr_pop'/`=migr_pop') F3 = (`=male_migr_pop'/`=migr_pop') 	// Sex 
	
	putexcel F4 = (`=pop_migr_fem_05'/`=migr_fem_pop') F9 = (`=pop_migr_masc_05'/`=migr_masc_pop') // 0 - 5
	
	putexcel F5 = (`=pop_migr_fem_615'/`=migr_fem_pop') F10 = (`=pop_migr_masc_615'/`=migr_masc_pop') // 16 - 34
	
	putexcel F6 = (`=pop_migr_fem_1634'/`=migr_fem_pop') F11 = (`=pop_migr_masc_1634'/`=migr_masc_pop') // 25 - 39
	
	putexcel F7 = (`=pop_migr_fem_3564'/`=migr_fem_pop') F12 = (`=pop_migr_masc_3564'/`=migr_masc_pop') // 40 - 54
	
	putexcel F8 = (`=pop_migr_fem_65older'/`=migr_fem_pop') F13 = (`=pop_migr_masc_65older'/`=migr_masc_pop') // 65 Older
	
	
	** LABOUR MARKET INDICATORS
	
	putexcel F14 = (`=job_migr_pop'/`=econoActWorkAge_migr_pop') // Share of population with a job
	
	putexcel F15 = (`=unemp_migr_pop'/`=econoActWorkAge_migr_pop') // Unemployed population
	
	
	** EDUCATION AND SKILLS
	
	putexcel F16 = (`=attending_5to16_migr_pop'/`=pop_migr_516') // Share of children attending schooling, 5 - 16 years group

	putexcel F17 = (`=noedu_5to16_migr_pop'/`=pop_migr_516') // Share of children NO attending schooling, 5 - 16 years group

********************************************************************************
********************************************************************************
********************************************************************************
************************************************************************ BAHAMAS
	clear all
	set more off, perm
	set maxvar 15000
	scalar drop _all

	** DATASET
	use "BHS_2014a_BID.dta", replace

	gen uno=1
	replace factor_ci=round(factor_ci) // Applies when the expansion factor is a non-integer numbers
	
	****************************************************************************
	** LOCALS
		local 1_label = "migr"
		local 0_label = "nat"
		
		local 1_sexo = "masc_"
		local 2_sexo = "fem_"
		
********************************************************************* STATISTICS
********************************************************************************
********************************************************************************

	** CALCULATION OF INDICATORS
	
	** POPULATION
	
	* Total population calculated according to expansion factor
	sum uno if migrante_ci!=. [fw=factor_ci]
	scalar tot_pop = `=r(N)'
	
	* Migrant population calculated according to expansion factor
	sum uno if migrante_ci==1 [fw=factor_ci]
	scalar migr_pop = `=r(N)'
	
	* Native population calculated according to expansion factor
	sum uno if migrante_ci==0 [fw=factor_ci]
	scalar nat_pop = `=r(N)'
	

	** CALCULATION OF INDICATORS BY MIGRANTS AND NATIVES
	
	foreach var in 1 0 {
		
		foreach sexo in 1 2 {
		
		** DEMOGRAPHIC
		
		* Genders
		
		sum uno if migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar ``var'_label'_``sexo'_sexo'pop = `=r(N)' // 0 - 5 years
		
		* Age groups
		
		sum uno if inrange(edad_ci,0,5) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar pop_``var'_label'_``sexo'_sexo'05 = `=r(N)' // 0 - 5 years
		
		sum uno if inrange(edad_ci,6,15) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar pop_``var'_label'_``sexo'_sexo'615 = `=r(N)' // 6 - 15 years

		sum uno if inrange(edad_ci,16,34) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar pop_``var'_label'_``sexo'_sexo'1634 = `=r(N)'	//16 - 34 years
		
		sum uno if inrange(edad_ci,35,64) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar pop_``var'_label'_``sexo'_sexo'3564 = `=r(N)'	//35 - 64 years
		
		sum uno if inrange(edad_ci,65,.) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar pop_``var'_label'_``sexo'_sexo'65older = `=r(N)'  // 65 older years
		
		* Sex population
		sum uno if sexo_ci==1 & migrante_ci==`var' [fw=factor_ci]
		scalar male_``var'_label'_pop =`=r(N)'
		
		sum uno if sexo_ci==2 & migrante_ci==`var' [fw=factor_ci]
		scalar female_``var'_label'_pop =`=r(N)'
		
		
		** LABOUR MARKET INDICATORS
		
		* Share of population with a job
		sum uno if inrange(edad_ci,15,64) & emp_ci==1 & migrante_ci==`var' [fw=factor_ci]
		scalar job_``var'_label'_pop = `=r(N)'
		
		* Unemployment: Share of population who were unemployed
		sum uno if inrange(edad_ci,15,64) & desemp_ci==1 & migrante_ci==`var' [fw=factor_ci] 
		scalar unemp_``var'_label'_pop = `=r(N)'
		
		sum uno if (pea_ci==1) & inrange(edad_ci,15,64) & migrante_ci==`var' [fw=factor_ci]
		scalar econoActWorkAge_``var'_label'_pop = `=r(N)'
		

		** EDUCATION AND SKILLS
		
		* Share of children attending schooling, 5 - 16 years group
		sum uno if asiste_ci==1 & inrange(edad_ci,5,16) & migrante_ci==`var' [fw=factor_ci]
		scalar attending_5to16_``var'_label'_pop = `=r(N)'
		
		sum uno if asiste_ci==0 & inrange(edad_ci,5,16) & migrante_ci==`var' [fw=factor_ci]
		scalar noedu_5to16_``var'_label'_pop = `=r(N)'
		
		sum uno if inrange(edad_ci,5,16) & migrante_ci==`var' [fw=factor_ci] 
		scalar pop_``var'_label'_516 = `=r(N)'
		
	}
	
		}
	
******************************************************** EXCEL OUTPUTS

	*putexcel set "/Users/juancamiloperdomo/Library/CloudStorage/OneDrive-Inter-AmericanDevelopmentBankGroup/Indicadores DataMIG/01 Raw/Resultados.xlsx", sheet("Hoja 1") modify
	putexcel set "C:\Users\JCAMILOP\OneDrive - Inter-American Development Bank Group\Indicadores DataMIG\Resultados.xlsx", sheet("Hoja1") modify
	putexcel describe
	
	
	** DEMOGRAPHIC
	
	putexcel F18 = (`=female_migr_pop'/`=migr_pop') F19 = (`=male_migr_pop'/`=migr_pop') 	// Sex 
	
	putexcel F20 = (`=pop_migr_fem_05'/`=migr_fem_pop') F25 = (`=pop_migr_masc_05'/`=migr_masc_pop') // 0 - 5
	
	putexcel F21 = (`=pop_migr_fem_615'/`=migr_fem_pop') F26 = (`=pop_migr_masc_615'/`=migr_masc_pop') // 16 - 34
	
	putexcel F22 = (`=pop_migr_fem_1634'/`=migr_fem_pop') F27 = (`=pop_migr_masc_1634'/`=migr_masc_pop') // 25 - 39
	
	putexcel F23 = (`=pop_migr_fem_3564'/`=migr_fem_pop') F28 = (`=pop_migr_masc_3564'/`=migr_masc_pop') // 40 - 54
	
	putexcel F24 = (`=pop_migr_fem_65older'/`=migr_fem_pop') F29 = (`=pop_migr_masc_65older'/`=migr_masc_pop') // 65 Older
	
	
	** LABOUR MARKET INDICATORS
	
	putexcel F30 = (`=job_migr_pop'/`=econoActWorkAge_migr_pop') // Share of population with a job
	
	putexcel F31 = (`=unemp_migr_pop'/`=econoActWorkAge_migr_pop') // Unemployed population
	
	
	** EDUCATION AND SKILLS
	
	putexcel F32 = (`=attending_5to16_migr_pop'/`=pop_migr_516') // Share of children attending schooling, 5 - 16 years group

	putexcel F33 = (`=noedu_5to16_migr_pop'/`=pop_migr_516') // Share of children NO attending schooling, 5 - 16 years group

********************************************************************************
********************************************************************************
********************************************************************************
*********************************************************************** BARBADOS
	clear all
	set more off, perm
	set maxvar 15000
	scalar drop _all

	** DATASET
	use "BRB_2016m1_m6_BID.dta", replace

	gen uno=1
	replace factor_ci=round(factor_ci) // Applies when the expansion factor is a non-integer numbers
	
	****************************************************************************
	** LOCALS
		local 1_label = "migr"
		local 0_label = "nat"
		
		local 1_sexo = "masc_"
		local 2_sexo = "fem_"
		
********************************************************************* STATISTICS
********************************************************************************
********************************************************************************

	** CALCULATION OF INDICATORS
	
	** POPULATION
	
	* Total population calculated according to expansion factor
	sum uno if migrante_ci!=. [fw=factor_ci]
	scalar tot_pop = `=r(N)'
	
	* Migrant population calculated according to expansion factor
	sum uno if migrante_ci==1 [fw=factor_ci]
	scalar migr_pop = `=r(N)'
	
	* Native population calculated according to expansion factor
	sum uno if migrante_ci==0 [fw=factor_ci]
	scalar nat_pop = `=r(N)'
	

	** CALCULATION OF INDICATORS BY MIGRANTS AND NATIVES
	
	foreach var in 1 0 {
		
		foreach sexo in 1 2 {
		
		** DEMOGRAPHIC
		
		* Genders
		
		sum uno if migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar ``var'_label'_``sexo'_sexo'pop = `=r(N)' // 0 - 5 years
		
		* Age groups
		
		sum uno if inrange(edad_ci,0,5) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar pop_``var'_label'_``sexo'_sexo'05 = `=r(N)' // 0 - 5 years
		
		sum uno if inrange(edad_ci,6,15) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar pop_``var'_label'_``sexo'_sexo'615 = `=r(N)' // 6 - 15 years

		sum uno if inrange(edad_ci,16,34) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar pop_``var'_label'_``sexo'_sexo'1634 = `=r(N)'	//16 - 34 years
		
		sum uno if inrange(edad_ci,35,64) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar pop_``var'_label'_``sexo'_sexo'3564 = `=r(N)'	//35 - 64 years
		
		sum uno if inrange(edad_ci,65,.) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar pop_``var'_label'_``sexo'_sexo'65older = `=r(N)'  // 65 older years
		
		* Sex population
		sum uno if sexo_ci==1 & migrante_ci==`var' [fw=factor_ci]
		scalar male_``var'_label'_pop =`=r(N)'
		
		sum uno if sexo_ci==2 & migrante_ci==`var' [fw=factor_ci]
		scalar female_``var'_label'_pop =`=r(N)'
		
		
		** LABOUR MARKET INDICATORS
		
		* Share of population with a job
		sum uno if inrange(edad_ci,15,64) & emp_ci==1 & migrante_ci==`var' [fw=factor_ci]
		scalar job_``var'_label'_pop = `=r(N)'
		
		* Unemployment: Share of population who were unemployed
		sum uno if inrange(edad_ci,15,64) & desemp_ci==1 & migrante_ci==`var' [fw=factor_ci] 
		scalar unemp_``var'_label'_pop = `=r(N)'
		
		sum uno if (pea_ci==1) & inrange(edad_ci,15,64) & migrante_ci==`var' [fw=factor_ci]
		scalar econoActWorkAge_``var'_label'_pop = `=r(N)'
		

		** EDUCATION AND SKILLS
		
		* Share of children attending schooling, 5 - 16 years group
		sum uno if asiste_ci==1 & inrange(edad_ci,5,16) & migrante_ci==`var' [fw=factor_ci]
		scalar attending_5to16_``var'_label'_pop = `=r(N)'
		
		sum uno if asiste_ci==0 & inrange(edad_ci,5,16) & migrante_ci==`var' [fw=factor_ci]
		scalar noedu_5to16_``var'_label'_pop = `=r(N)'
		
		sum uno if inrange(edad_ci,5,16) & migrante_ci==`var' [fw=factor_ci] 
		scalar pop_``var'_label'_516 = `=r(N)'
		
	}
	
		}
	
******************************************************** EXCEL OUTPUTS

	*putexcel set "/Users/juancamiloperdomo/Library/CloudStorage/OneDrive-Inter-AmericanDevelopmentBankGroup/Indicadores DataMIG/01 Raw/Resultados.xlsx", sheet("Hoja 1") modify
	putexcel set "C:\Users\JCAMILOP\OneDrive - Inter-American Development Bank Group\Indicadores DataMIG\Resultados.xlsx", sheet("Hoja1") modify
	putexcel describe
	
	
	** DEMOGRAPHIC
	
	putexcel F34 = (`=female_migr_pop'/`=migr_pop') F35 = (`=male_migr_pop'/`=migr_pop') 	// Sex 
	
	putexcel F36 = (`=pop_migr_fem_05'/`=migr_fem_pop') F41 = (`=pop_migr_masc_05'/`=migr_masc_pop') // 0 - 5
	
	putexcel F37 = (`=pop_migr_fem_615'/`=migr_fem_pop') F42 = (`=pop_migr_masc_615'/`=migr_masc_pop') // 16 - 34
	
	putexcel F38 = (`=pop_migr_fem_1634'/`=migr_fem_pop') F43 = (`=pop_migr_masc_1634'/`=migr_masc_pop') // 25 - 39
	
	putexcel F39 = (`=pop_migr_fem_3564'/`=migr_fem_pop') F44 = (`=pop_migr_masc_3564'/`=migr_masc_pop') // 40 - 54
	
	putexcel F40 = (`=pop_migr_fem_65older'/`=migr_fem_pop') F45 = (`=pop_migr_masc_65older'/`=migr_masc_pop') // 65 Older
	
	
	** LABOUR MARKET INDICATORS
	
	putexcel F46 = (`=job_migr_pop'/`=econoActWorkAge_migr_pop') // Share of population with a job
	
	putexcel F47 = (`=unemp_migr_pop'/`=econoActWorkAge_migr_pop') // Unemployed population
	
	
	** EDUCATION AND SKILLS
	
	putexcel F48 = (`=attending_5to16_migr_pop'/`=pop_migr_516') // Share of children attending schooling, 5 - 16 years group

	putexcel F49 = (`=noedu_5to16_migr_pop'/`=pop_migr_516') // Share of children NO attending schooling, 5 - 16 years group
	
********************************************************************************
********************************************************************************
********************************************************************************
************************************************************************** CHILE
	clear all
	set more off, perm
	set maxvar 15000
	scalar drop _all

	** DATASET
	use "CHL_2020m11_m12_m1_BID.dta", replace

	gen uno=1
	replace factor_ci=round(factor_ci) // Applies when the expansion factor is a non-integer numbers
	
	****************************************************************************
	** LOCALS
		local 1_label = "migr"
		local 0_label = "nat"
		
		local 1_sexo = "masc_"
		local 2_sexo = "fem_"
		
********************************************************************* STATISTICS
********************************************************************************
********************************************************************************

	** CALCULATION OF INDICATORS
	
	** POPULATION
	
	* Total population calculated according to expansion factor
	sum uno if migrante_ci!=. [fw=factor_ci]
	scalar tot_pop = `=r(N)'
	
	* Migrant population calculated according to expansion factor
	sum uno if migrante_ci==1 [fw=factor_ci]
	scalar migr_pop = `=r(N)'
	
	* Native population calculated according to expansion factor
	sum uno if migrante_ci==0 [fw=factor_ci]
	scalar nat_pop = `=r(N)'
	

	** CALCULATION OF INDICATORS BY MIGRANTS AND NATIVES
	
	foreach var in 1 0 {
		
		foreach sexo in 1 2 {
		
		** DEMOGRAPHIC
		
		* Genders
		
		sum uno if migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar ``var'_label'_``sexo'_sexo'pop = `=r(N)' // 0 - 5 years
		
		* Age groups
		
		sum uno if inrange(edad_ci,0,5) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar pop_``var'_label'_``sexo'_sexo'05 = `=r(N)' // 0 - 5 years
		
		sum uno if inrange(edad_ci,6,15) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar pop_``var'_label'_``sexo'_sexo'615 = `=r(N)' // 6 - 15 years

		sum uno if inrange(edad_ci,16,34) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar pop_``var'_label'_``sexo'_sexo'1634 = `=r(N)'	//16 - 34 years
		
		sum uno if inrange(edad_ci,35,64) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar pop_``var'_label'_``sexo'_sexo'3564 = `=r(N)'	//35 - 64 years
		
		sum uno if inrange(edad_ci,65,.) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar pop_``var'_label'_``sexo'_sexo'65older = `=r(N)'  // 65 older years
		
		* Sex population
		sum uno if sexo_ci==1 & migrante_ci==`var' [fw=factor_ci]
		scalar male_``var'_label'_pop =`=r(N)'
		
		sum uno if sexo_ci==2 & migrante_ci==`var' [fw=factor_ci]
		scalar female_``var'_label'_pop =`=r(N)'
		
		
		** LABOUR MARKET INDICATORS
		
		* Share of population with a job
		sum uno if inrange(edad_ci,15,64) & emp_ci==1 & migrante_ci==`var' [fw=factor_ci]
		scalar job_``var'_label'_pop = `=r(N)'
		
		* Unemployment: Share of population who were unemployed
		sum uno if inrange(edad_ci,15,64) & desemp_ci==1 & migrante_ci==`var' [fw=factor_ci] 
		scalar unemp_``var'_label'_pop = `=r(N)'
		
		sum uno if (pea_ci==1) & inrange(edad_ci,15,64) & migrante_ci==`var' [fw=factor_ci]
		scalar econoActWorkAge_``var'_label'_pop = `=r(N)'
		

		** EDUCATION AND SKILLS
		
		* Share of children attending schooling, 5 - 16 years group
		sum uno if asiste_ci==1 & inrange(edad_ci,5,16) & migrante_ci==`var' [fw=factor_ci]
		scalar attending_5to16_``var'_label'_pop = `=r(N)'
		
		sum uno if asiste_ci==0 & inrange(edad_ci,5,16) & migrante_ci==`var' [fw=factor_ci]
		scalar noedu_5to16_``var'_label'_pop = `=r(N)'
		
		sum uno if inrange(edad_ci,5,16) & migrante_ci==`var' [fw=factor_ci] 
		scalar pop_``var'_label'_516 = `=r(N)'
		
	}
	
		}
	
******************************************************** EXCEL OUTPUTS

	*putexcel set "/Users/juancamiloperdomo/Library/CloudStorage/OneDrive-Inter-AmericanDevelopmentBankGroup/Indicadores DataMIG/01 Raw/Resultados.xlsx", sheet("Hoja 1") modify
	putexcel set "C:\Users\JCAMILOP\OneDrive - Inter-American Development Bank Group\Indicadores DataMIG\Resultados.xlsx", sheet("Hoja1") modify
	putexcel describe
	
	
	** DEMOGRAPHIC
	
	putexcel F50 = (`=female_migr_pop'/`=migr_pop') F51 = (`=male_migr_pop'/`=migr_pop') 	// Sex 
	
	putexcel F52 = (`=pop_migr_fem_05'/`=migr_fem_pop') F57 = (`=pop_migr_masc_05'/`=migr_masc_pop') // 0 - 5
	
	putexcel F53 = (`=pop_migr_fem_615'/`=migr_fem_pop') F58 = (`=pop_migr_masc_615'/`=migr_masc_pop') // 16 - 34
	
	putexcel F54 = (`=pop_migr_fem_1634'/`=migr_fem_pop') F59 = (`=pop_migr_masc_1634'/`=migr_masc_pop') // 25 - 39
	
	putexcel F55 = (`=pop_migr_fem_3564'/`=migr_fem_pop') F60 = (`=pop_migr_masc_3564'/`=migr_masc_pop') // 40 - 54
	
	putexcel F56 = (`=pop_migr_fem_65older'/`=migr_fem_pop') F61 = (`=pop_migr_masc_65older'/`=migr_masc_pop') // 65 Older
	
	
	** LABOUR MARKET INDICATORS
	
	putexcel F62 = (`=job_migr_pop'/`=econoActWorkAge_migr_pop') // Share of population with a job
	
	putexcel F63 = (`=unemp_migr_pop'/`=econoActWorkAge_migr_pop') // Unemployed population
	
	
	** EDUCATION AND SKILLS
	
	putexcel F64 = (`=attending_5to16_migr_pop'/`=pop_migr_516') // Share of children attending schooling, 5 - 16 years group

	putexcel F65 = (`=noedu_5to16_migr_pop'/`=pop_migr_516') // Share of children NO attending schooling, 5 - 16 years group
	
********************************************************************************
********************************************************************************
********************************************************************************
*********************************************************************** COLOMBIA
	clear all
	set more off, perm
	set maxvar 15000
	scalar drop _all

	** DATASET
	use "COL_2021t3_BID.dta", replace

	gen uno=1
	replace factor_ci=round(factor_ci) // Applies when the expansion factor is a non-integer numbers
	
	****************************************************************************
	** LOCALS
		local 1_label = "migr"
		local 0_label = "nat"
		
		local 1_sexo = "masc_"
		local 2_sexo = "fem_"
		
********************************************************************* STATISTICS
********************************************************************************
********************************************************************************

	** CALCULATION OF INDICATORS
	
	** POPULATION
	
	* Total population calculated according to expansion factor
	sum uno if migrante_ci!=. [fw=factor_ci]
	scalar tot_pop = `=r(N)'
	
	* Migrant population calculated according to expansion factor
	sum uno if migrante_ci==1 [fw=factor_ci]
	scalar migr_pop = `=r(N)'
	
	* Native population calculated according to expansion factor
	sum uno if migrante_ci==0 [fw=factor_ci]
	scalar nat_pop = `=r(N)'
	

	** CALCULATION OF INDICATORS BY MIGRANTS AND NATIVES
	
	foreach var in 1 0 {
		
		foreach sexo in 1 2 {
		
		** DEMOGRAPHIC
		
		* Genders
		
		sum uno if migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar ``var'_label'_``sexo'_sexo'pop = `=r(N)' // 0 - 5 years
		
		* Age groups
		
		sum uno if inrange(edad_ci,0,5) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar pop_``var'_label'_``sexo'_sexo'05 = `=r(N)' // 0 - 5 years
		
		sum uno if inrange(edad_ci,6,15) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar pop_``var'_label'_``sexo'_sexo'615 = `=r(N)' // 6 - 15 years

		sum uno if inrange(edad_ci,16,34) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar pop_``var'_label'_``sexo'_sexo'1634 = `=r(N)'	//16 - 34 years
		
		sum uno if inrange(edad_ci,35,64) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar pop_``var'_label'_``sexo'_sexo'3564 = `=r(N)'	//35 - 64 years
		
		sum uno if inrange(edad_ci,65,.) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar pop_``var'_label'_``sexo'_sexo'65older = `=r(N)'  // 65 older years
		
		* Sex population
		sum uno if sexo_ci==1 & migrante_ci==`var' [fw=factor_ci]
		scalar male_``var'_label'_pop =`=r(N)'
		
		sum uno if sexo_ci==2 & migrante_ci==`var' [fw=factor_ci]
		scalar female_``var'_label'_pop =`=r(N)'
		
		
		** LABOUR MARKET INDICATORS
		
		* Share of population with a job
		sum uno if inrange(edad_ci,15,64) & emp_ci==1 & migrante_ci==`var' [fw=factor_ci]
		scalar job_``var'_label'_pop = `=r(N)'
		
		* Unemployment: Share of population who were unemployed
		sum uno if inrange(edad_ci,15,64) & desemp_ci==1 & migrante_ci==`var' [fw=factor_ci] 
		scalar unemp_``var'_label'_pop = `=r(N)'
		
		sum uno if (pea_ci==1) & inrange(edad_ci,15,64) & migrante_ci==`var' [fw=factor_ci]
		scalar econoActWorkAge_``var'_label'_pop = `=r(N)'
		

		** EDUCATION AND SKILLS
		
		* Share of children attending schooling, 5 - 16 years group
		sum uno if asiste_ci==1 & inrange(edad_ci,5,16) & migrante_ci==`var' [fw=factor_ci]
		scalar attending_5to16_``var'_label'_pop = `=r(N)'
		
		sum uno if asiste_ci==0 & inrange(edad_ci,5,16) & migrante_ci==`var' [fw=factor_ci]
		scalar noedu_5to16_``var'_label'_pop = `=r(N)'
		
		sum uno if inrange(edad_ci,5,16) & migrante_ci==`var' [fw=factor_ci] 
		scalar pop_``var'_label'_516 = `=r(N)'
		
	}
	
		}
	
******************************************************** EXCEL OUTPUTS

	*putexcel set "/Users/juancamiloperdomo/Library/CloudStorage/OneDrive-Inter-AmericanDevelopmentBankGroup/Indicadores DataMIG/01 Raw/Resultados.xlsx", sheet("Hoja 1") modify
	putexcel set "C:\Users\JCAMILOP\OneDrive - Inter-American Development Bank Group\Indicadores DataMIG\Resultados.xlsx", sheet("Hoja1") modify
	putexcel describe
	
	
	** DEMOGRAPHIC
	
	putexcel F66 = (`=female_migr_pop'/`=migr_pop') F67 = (`=male_migr_pop'/`=migr_pop') 	// Sex 
	
	putexcel F68 = (`=pop_migr_fem_05'/`=migr_fem_pop') F73 = (`=pop_migr_masc_05'/`=migr_masc_pop') // 0 - 5
	
	putexcel F69 = (`=pop_migr_fem_615'/`=migr_fem_pop') F74 = (`=pop_migr_masc_615'/`=migr_masc_pop') // 16 - 34
	
	putexcel F70 = (`=pop_migr_fem_1634'/`=migr_fem_pop') F75 = (`=pop_migr_masc_1634'/`=migr_masc_pop') // 25 - 39
	
	putexcel F71 = (`=pop_migr_fem_3564'/`=migr_fem_pop') F76 = (`=pop_migr_masc_3564'/`=migr_masc_pop') // 40 - 54
	
	putexcel F72 = (`=pop_migr_fem_65older'/`=migr_fem_pop') F77 = (`=pop_migr_masc_65older'/`=migr_masc_pop') // 65 Older
	
	
	** LABOUR MARKET INDICATORS
	
	putexcel F78 = (`=job_migr_pop'/`=econoActWorkAge_migr_pop') // Share of population with a job
	
	putexcel F79 = (`=unemp_migr_pop'/`=econoActWorkAge_migr_pop') // Unemployed population
	
	
	** EDUCATION AND SKILLS
	
	putexcel F80 = (`=attending_5to16_migr_pop'/`=pop_migr_516') // Share of children attending schooling, 5 - 16 years group

	putexcel F81 = (`=noedu_5to16_migr_pop'/`=pop_migr_516') // Share of children NO attending schooling, 5 - 16 years group
	
********************************************************************************
********************************************************************************
********************************************************************************
********************************************************************* COSTA RICA
	clear all
	set more off, perm
	set maxvar 15000
	scalar drop _all

	** DATASET
	use "CRI_2021m7_BID.dta", replace

	gen uno=1
	replace factor_ci=round(factor_ci) // Applies when the expansion factor is a non-integer numbers
	
	****************************************************************************
	** LOCALS
		local 1_label = "migr"
		local 0_label = "nat"
		
		local 1_sexo = "masc_"
		local 2_sexo = "fem_"
		
********************************************************************* STATISTICS
********************************************************************************
********************************************************************************

	** CALCULATION OF INDICATORS
	
	** POPULATION
	
	* Total population calculated according to expansion factor
	sum uno if migrante_ci!=. [fw=factor_ci]
	scalar tot_pop = `=r(N)'
	
	* Migrant population calculated according to expansion factor
	sum uno if migrante_ci==1 [fw=factor_ci]
	scalar migr_pop = `=r(N)'
	
	* Native population calculated according to expansion factor
	sum uno if migrante_ci==0 [fw=factor_ci]
	scalar nat_pop = `=r(N)'
	

	** CALCULATION OF INDICATORS BY MIGRANTS AND NATIVES
	
	foreach var in 1 0 {
		
		foreach sexo in 1 2 {
		
		** DEMOGRAPHIC
		
		* Genders
		
		sum uno if migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar ``var'_label'_``sexo'_sexo'pop = `=r(N)' // 0 - 5 years
		
		* Age groups
		
		sum uno if inrange(edad_ci,0,5) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar pop_``var'_label'_``sexo'_sexo'05 = `=r(N)' // 0 - 5 years
		
		sum uno if inrange(edad_ci,6,15) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar pop_``var'_label'_``sexo'_sexo'615 = `=r(N)' // 6 - 15 years

		sum uno if inrange(edad_ci,16,34) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar pop_``var'_label'_``sexo'_sexo'1634 = `=r(N)'	//16 - 34 years
		
		sum uno if inrange(edad_ci,35,64) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar pop_``var'_label'_``sexo'_sexo'3564 = `=r(N)'	//35 - 64 years
		
		sum uno if inrange(edad_ci,65,.) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar pop_``var'_label'_``sexo'_sexo'65older = `=r(N)'  // 65 older years
		
		* Sex population
		sum uno if sexo_ci==1 & migrante_ci==`var' [fw=factor_ci]
		scalar male_``var'_label'_pop =`=r(N)'
		
		sum uno if sexo_ci==2 & migrante_ci==`var' [fw=factor_ci]
		scalar female_``var'_label'_pop =`=r(N)'
		
		
		** LABOUR MARKET INDICATORS
		
		* Share of population with a job
		sum uno if inrange(edad_ci,15,64) & emp_ci==1 & migrante_ci==`var' [fw=factor_ci]
		scalar job_``var'_label'_pop = `=r(N)'
		
		* Unemployment: Share of population who were unemployed
		sum uno if inrange(edad_ci,15,64) & desemp_ci==1 & migrante_ci==`var' [fw=factor_ci] 
		scalar unemp_``var'_label'_pop = `=r(N)'
		
		sum uno if (pea_ci==1) & inrange(edad_ci,15,64) & migrante_ci==`var' [fw=factor_ci]
		scalar econoActWorkAge_``var'_label'_pop = `=r(N)'
		

		** EDUCATION AND SKILLS
		
		* Share of children attending schooling, 5 - 16 years group
		sum uno if asiste_ci==1 & inrange(edad_ci,5,16) & migrante_ci==`var' [fw=factor_ci]
		scalar attending_5to16_``var'_label'_pop = `=r(N)'
		
		sum uno if asiste_ci==0 & inrange(edad_ci,5,16) & migrante_ci==`var' [fw=factor_ci]
		scalar noedu_5to16_``var'_label'_pop = `=r(N)'
		
		sum uno if inrange(edad_ci,5,16) & migrante_ci==`var' [fw=factor_ci] 
		scalar pop_``var'_label'_516 = `=r(N)'
		
	}
	
		}
	
******************************************************** EXCEL OUTPUTS

	*putexcel set "/Users/juancamiloperdomo/Library/CloudStorage/OneDrive-Inter-AmericanDevelopmentBankGroup/Indicadores DataMIG/01 Raw/Resultados.xlsx", sheet("Hoja 1") modify
	putexcel set "C:\Users\JCAMILOP\OneDrive - Inter-American Development Bank Group\Indicadores DataMIG\Resultados.xlsx", sheet("Hoja1") modify
	putexcel describe
	
	
	** DEMOGRAPHIC
	
	putexcel F82 = (`=female_migr_pop'/`=migr_pop') F83 = (`=male_migr_pop'/`=migr_pop') 	// Sex 
	
	putexcel F84 = (`=pop_migr_fem_05'/`=migr_fem_pop') F89 = (`=pop_migr_masc_05'/`=migr_masc_pop') // 0 - 5
	
	putexcel F85 = (`=pop_migr_fem_615'/`=migr_fem_pop') F90 = (`=pop_migr_masc_615'/`=migr_masc_pop') // 16 - 34
	
	putexcel F86 = (`=pop_migr_fem_1634'/`=migr_fem_pop') F91 = (`=pop_migr_masc_1634'/`=migr_masc_pop') // 25 - 39
	
	putexcel F87 = (`=pop_migr_fem_3564'/`=migr_fem_pop') F92 = (`=pop_migr_masc_3564'/`=migr_masc_pop') // 40 - 54
	
	putexcel F88 = (`=pop_migr_fem_65older'/`=migr_fem_pop') F93 = (`=pop_migr_masc_65older'/`=migr_masc_pop') // 65 Older
	
	
	** LABOUR MARKET INDICATORS
	
	putexcel F94 = (`=job_migr_pop'/`=econoActWorkAge_migr_pop') // Share of population with a job
	
	putexcel F95 = (`=unemp_migr_pop'/`=econoActWorkAge_migr_pop') // Unemployed population
	
	
	** EDUCATION AND SKILLS
	
	putexcel F96 = (`=attending_5to16_migr_pop'/`=pop_migr_516') // Share of children attending schooling, 5 - 16 years group

	putexcel F97 = (`=noedu_5to16_migr_pop'/`=pop_migr_516') // Share of children NO attending schooling, 5 - 16 years group
	
********************************************************************************
********************************************************************************
********************************************************************************
************************************************************************ ECUADOR
	clear all
	set more off, perm
	set maxvar 15000
	scalar drop _all

	** DATASET
	use "ECU_2021a_BID.dta", replace

	gen uno=1
	replace factor_ci=round(factor_ci) // Applies when the expansion factor is a non-integer numbers
	
	****************************************************************************
	** LOCALS
		local 1_label = "migr"
		local 0_label = "nat"
		
		local 1_sexo = "masc_"
		local 2_sexo = "fem_"
		
********************************************************************* STATISTICS
********************************************************************************
********************************************************************************

	** CALCULATION OF INDICATORS
	
	** POPULATION
	
	* Total population calculated according to expansion factor
	sum uno if migrante_ci!=. [fw=factor_ci]
	scalar tot_pop = `=r(N)'
	
	* Migrant population calculated according to expansion factor
	sum uno if migrante_ci==1 [fw=factor_ci]
	scalar migr_pop = `=r(N)'
	
	* Native population calculated according to expansion factor
	sum uno if migrante_ci==0 [fw=factor_ci]
	scalar nat_pop = `=r(N)'
	

	** CALCULATION OF INDICATORS BY MIGRANTS AND NATIVES
	
	foreach var in 1 0 {
		
		foreach sexo in 1 2 {
		
		** DEMOGRAPHIC
		
		* Genders
		
		sum uno if migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar ``var'_label'_``sexo'_sexo'pop = `=r(N)' // 0 - 5 years
		
		* Age groups
		
		sum uno if inrange(edad_ci,0,5) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar pop_``var'_label'_``sexo'_sexo'05 = `=r(N)' // 0 - 5 years
		
		sum uno if inrange(edad_ci,6,15) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar pop_``var'_label'_``sexo'_sexo'615 = `=r(N)' // 6 - 15 years

		sum uno if inrange(edad_ci,16,34) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar pop_``var'_label'_``sexo'_sexo'1634 = `=r(N)'	//16 - 34 years
		
		sum uno if inrange(edad_ci,35,64) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar pop_``var'_label'_``sexo'_sexo'3564 = `=r(N)'	//35 - 64 years
		
		sum uno if inrange(edad_ci,65,.) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar pop_``var'_label'_``sexo'_sexo'65older = `=r(N)'  // 65 older years
		
		* Sex population
		sum uno if sexo_ci==1 & migrante_ci==`var' [fw=factor_ci]
		scalar male_``var'_label'_pop =`=r(N)'
		
		sum uno if sexo_ci==2 & migrante_ci==`var' [fw=factor_ci]
		scalar female_``var'_label'_pop =`=r(N)'
		
		
		** LABOUR MARKET INDICATORS
		
		* Share of population with a job
		sum uno if inrange(edad_ci,15,64) & emp_ci==1 & migrante_ci==`var' [fw=factor_ci]
		scalar job_``var'_label'_pop = `=r(N)'
		
		* Unemployment: Share of population who were unemployed
		sum uno if inrange(edad_ci,15,64) & desemp_ci==1 & migrante_ci==`var' [fw=factor_ci] 
		scalar unemp_``var'_label'_pop = `=r(N)'
		
		sum uno if (pea_ci==1) & inrange(edad_ci,15,64) & migrante_ci==`var' [fw=factor_ci]
		scalar econoActWorkAge_``var'_label'_pop = `=r(N)'
		

		** EDUCATION AND SKILLS
		
		* Share of children attending schooling, 5 - 16 years group
		sum uno if asiste_ci==1 & inrange(edad_ci,5,16) & migrante_ci==`var' [fw=factor_ci]
		scalar attending_5to16_``var'_label'_pop = `=r(N)'
		
		sum uno if asiste_ci==0 & inrange(edad_ci,5,16) & migrante_ci==`var' [fw=factor_ci]
		scalar noedu_5to16_``var'_label'_pop = `=r(N)'
		
		sum uno if inrange(edad_ci,5,16) & migrante_ci==`var' [fw=factor_ci] 
		scalar pop_``var'_label'_516 = `=r(N)'
		
	}
	
		}
	
******************************************************** EXCEL OUTPUTS

	*putexcel set "/Users/juancamiloperdomo/Library/CloudStorage/OneDrive-Inter-AmericanDevelopmentBankGroup/Indicadores DataMIG/01 Raw/Resultados.xlsx", sheet("Hoja 1") modify
	putexcel set "C:\Users\JCAMILOP\OneDrive - Inter-American Development Bank Group\Indicadores DataMIG\Resultados.xlsx", sheet("Hoja1") modify
	putexcel describe
	
	
	** DEMOGRAPHIC
	
	putexcel F98 = (`=female_migr_pop'/`=migr_pop') F99 = (`=male_migr_pop'/`=migr_pop') 	// Sex 
	
	putexcel F100 = (`=pop_migr_fem_05'/`=migr_fem_pop') F105 = (`=pop_migr_masc_05'/`=migr_masc_pop') // 0 - 5
	
	putexcel F101 = (`=pop_migr_fem_615'/`=migr_fem_pop') F106 = (`=pop_migr_masc_615'/`=migr_masc_pop') // 16 - 34
	
	putexcel F102 = (`=pop_migr_fem_1634'/`=migr_fem_pop') F107 = (`=pop_migr_masc_1634'/`=migr_masc_pop') // 25 - 39
	
	putexcel F103 = (`=pop_migr_fem_3564'/`=migr_fem_pop') F108 = (`=pop_migr_masc_3564'/`=migr_masc_pop') // 40 - 54
	
	putexcel F104 = (`=pop_migr_fem_65older'/`=migr_fem_pop') F109 = (`=pop_migr_masc_65older'/`=migr_masc_pop') // 65 Older
	
	
	** LABOUR MARKET INDICATORS
	
	putexcel F110 = (`=job_migr_pop'/`=econoActWorkAge_migr_pop') // Share of population with a job
	
	putexcel F111 = (`=unemp_migr_pop'/`=econoActWorkAge_migr_pop') // Unemployed population
	
	
	** EDUCATION AND SKILLS
	
	putexcel F112 = (`=attending_5to16_migr_pop'/`=pop_migr_516') // Share of children attending schooling, 5 - 16 years group

	putexcel F113 = (`=noedu_5to16_migr_pop'/`=pop_migr_516') // Share of children NO attending schooling, 5 - 16 years group
	
********************************************************************************
********************************************************************************
********************************************************************************
************************************************************************* GUYANA
	clear all
	set more off, perm
	set maxvar 15000
	scalar drop _all

	** DATASET
	use "GUY_2021.dta", replace

	gen uno=1
	replace factor_ci=round(factor_ci) // Applies when the expansion factor is a non-integer numbers
	
	****************************************************************************
	** LOCALS
		local 1_label = "migr"
		local 0_label = "nat"
		
		local 1_sexo = "masc_"
		local 2_sexo = "fem_"
		
********************************************************************* STATISTICS
********************************************************************************
********************************************************************************

	** CALCULATION OF INDICATORS
	
	** POPULATION
	
	* Total population calculated according to expansion factor
	sum uno if migrante_ci!=. [fw=factor_ci]
	scalar tot_pop = `=r(N)'
	
	* Migrant population calculated according to expansion factor
	sum uno if migrante_ci==1 [fw=factor_ci]
	scalar migr_pop = `=r(N)'
	
	* Native population calculated according to expansion factor
	sum uno if migrante_ci==0 [fw=factor_ci]
	scalar nat_pop = `=r(N)'
	

	** CALCULATION OF INDICATORS BY MIGRANTS AND NATIVES
	
	foreach var in 1 0 {
		
		foreach sexo in 1 2 {
		
		** DEMOGRAPHIC
		
		* Genders
		
		sum uno if migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar ``var'_label'_``sexo'_sexo'pop = `=r(N)' // 0 - 5 years
		
		* Age groups
		
		sum uno if inrange(edad_ci,0,5) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar pop_``var'_label'_``sexo'_sexo'05 = `=r(N)' // 0 - 5 years
		
		sum uno if inrange(edad_ci,6,15) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar pop_``var'_label'_``sexo'_sexo'615 = `=r(N)' // 6 - 15 years

		sum uno if inrange(edad_ci,16,34) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar pop_``var'_label'_``sexo'_sexo'1634 = `=r(N)'	//16 - 34 years
		
		sum uno if inrange(edad_ci,35,64) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar pop_``var'_label'_``sexo'_sexo'3564 = `=r(N)'	//35 - 64 years
		
		sum uno if inrange(edad_ci,65,.) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar pop_``var'_label'_``sexo'_sexo'65older = `=r(N)'  // 65 older years
		
		* Sex population
		sum uno if sexo_ci==1 & migrante_ci==`var' [fw=factor_ci]
		scalar male_``var'_label'_pop =`=r(N)'
		
		sum uno if sexo_ci==2 & migrante_ci==`var' [fw=factor_ci]
		scalar female_``var'_label'_pop =`=r(N)'
		
		
		** LABOUR MARKET INDICATORS
		
		* Share of population with a job
		sum uno if inrange(edad_ci,15,64) & emp_ci==1 & migrante_ci==`var' [fw=factor_ci]
		scalar job_``var'_label'_pop = `=r(N)'
		
		* Unemployment: Share of population who were unemployed
		sum uno if inrange(edad_ci,15,64) & desemp_ci==1 & migrante_ci==`var' [fw=factor_ci] 
		scalar unemp_``var'_label'_pop = `=r(N)'
		
		sum uno if (pea_ci==1) & inrange(edad_ci,15,64) & migrante_ci==`var' [fw=factor_ci]
		scalar econoActWorkAge_``var'_label'_pop = `=r(N)'
		

		** EDUCATION AND SKILLS
		
		* Share of children attending schooling, 5 - 16 years group
		sum uno if asiste_ci==1 & inrange(edad_ci,5,16) & migrante_ci==`var' [fw=factor_ci]
		scalar attending_5to16_``var'_label'_pop = `=r(N)'
		
		sum uno if asiste_ci==0 & inrange(edad_ci,5,16) & migrante_ci==`var' [fw=factor_ci]
		scalar noedu_5to16_``var'_label'_pop = `=r(N)'
		
		sum uno if inrange(edad_ci,5,16) & migrante_ci==`var' [fw=factor_ci] 
		scalar pop_``var'_label'_516 = `=r(N)'
		
	}
	
		}
	
******************************************************** EXCEL OUTPUTS

	*putexcel set "/Users/juancamiloperdomo/Library/CloudStorage/OneDrive-Inter-AmericanDevelopmentBankGroup/Indicadores DataMIG/01 Raw/Resultados.xlsx", sheet("Hoja 1") modify
	putexcel set "C:\Users\JCAMILOP\OneDrive - Inter-American Development Bank Group\Indicadores DataMIG\Resultados.xlsx", sheet("Hoja1") modify
	putexcel describe
	
	
	** DEMOGRAPHIC
	
	putexcel F114 = (`=female_migr_pop'/`=migr_pop') F115 = (`=male_migr_pop'/`=migr_pop') 	// Sex 
	
	putexcel F116 = (`=pop_migr_fem_05'/`=migr_fem_pop') F121 = (`=pop_migr_masc_05'/`=migr_masc_pop') // 0 - 5
	
	putexcel F117 = (`=pop_migr_fem_615'/`=migr_fem_pop') F122 = (`=pop_migr_masc_615'/`=migr_masc_pop') // 16 - 34
	
	putexcel F118 = (`=pop_migr_fem_1634'/`=migr_fem_pop') F123 = (`=pop_migr_masc_1634'/`=migr_masc_pop') // 25 - 39
	
	putexcel F119 = (`=pop_migr_fem_3564'/`=migr_fem_pop') F124 = (`=pop_migr_masc_3564'/`=migr_masc_pop') // 40 - 54
	
	putexcel F120 = (`=pop_migr_fem_65older'/`=migr_fem_pop') F125 = (`=pop_migr_masc_65older'/`=migr_masc_pop') // 65 Older
	
	
	** LABOUR MARKET INDICATORS
	
	putexcel F126 = (`=job_migr_pop'/`=econoActWorkAge_migr_pop') // Share of population with a job
	
	putexcel F127 = (`=unemp_migr_pop'/`=econoActWorkAge_migr_pop') // Unemployed population
	
	
	** EDUCATION AND SKILLS
	
	putexcel F128 = (`=attending_5to16_migr_pop'/`=pop_migr_516') // Share of children attending schooling, 5 - 16 years group

	putexcel F129 = (`=noedu_5to16_migr_pop'/`=pop_migr_516') // Share of children NO attending schooling, 5 - 16 years group
	
********************************************************************************
********************************************************************************
********************************************************************************
*********************************************************************** HONDURAS
	clear all
	set more off, perm
	set maxvar 15000
	scalar drop _all

	** DATASET
	use "HND_2018m6_BID.dta", replace

	gen uno=1
	replace factor_ci=round(factor_ci) // Applies when the expansion factor is a non-integer numbers
	
	****************************************************************************
	** LOCALS
		local 1_label = "migr"
		local 0_label = "nat"
		
		local 1_sexo = "masc_"
		local 2_sexo = "fem_"
		
********************************************************************* STATISTICS
********************************************************************************
********************************************************************************

	** CALCULATION OF INDICATORS
	
	** POPULATION
	
	* Total population calculated according to expansion factor
	sum uno if migrante_ci!=. [fw=factor_ci]
	scalar tot_pop = `=r(N)'
	
	* Migrant population calculated according to expansion factor
	sum uno if migrante_ci==1 [fw=factor_ci]
	scalar migr_pop = `=r(N)'
	
	* Native population calculated according to expansion factor
	sum uno if migrante_ci==0 [fw=factor_ci]
	scalar nat_pop = `=r(N)'
	

	** CALCULATION OF INDICATORS BY MIGRANTS AND NATIVES
	
	foreach var in 1 0 {
		
		foreach sexo in 1 2 {
		
		** DEMOGRAPHIC
		
		* Genders
		
		sum uno if migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar ``var'_label'_``sexo'_sexo'pop = `=r(N)' // 0 - 5 years
		
		* Age groups
		
		sum uno if inrange(edad_ci,0,5) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar pop_``var'_label'_``sexo'_sexo'05 = `=r(N)' // 0 - 5 years
		
		sum uno if inrange(edad_ci,6,15) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar pop_``var'_label'_``sexo'_sexo'615 = `=r(N)' // 6 - 15 years

		sum uno if inrange(edad_ci,16,34) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar pop_``var'_label'_``sexo'_sexo'1634 = `=r(N)'	//16 - 34 years
		
		sum uno if inrange(edad_ci,35,64) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar pop_``var'_label'_``sexo'_sexo'3564 = `=r(N)'	//35 - 64 years
		
		sum uno if inrange(edad_ci,65,.) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar pop_``var'_label'_``sexo'_sexo'65older = `=r(N)'  // 65 older years
		
		* Sex population
		sum uno if sexo_ci==1 & migrante_ci==`var' [fw=factor_ci]
		scalar male_``var'_label'_pop =`=r(N)'
		
		sum uno if sexo_ci==2 & migrante_ci==`var' [fw=factor_ci]
		scalar female_``var'_label'_pop =`=r(N)'
		
		
		** LABOUR MARKET INDICATORS
		
		* Share of population with a job
		sum uno if inrange(edad_ci,15,64) & emp_ci==1 & migrante_ci==`var' [fw=factor_ci]
		scalar job_``var'_label'_pop = `=r(N)'
		
		* Unemployment: Share of population who were unemployed
		sum uno if inrange(edad_ci,15,64) & desemp_ci==1 & migrante_ci==`var' [fw=factor_ci] 
		scalar unemp_``var'_label'_pop = `=r(N)'
		
		sum uno if (pea_ci==1) & inrange(edad_ci,15,64) & migrante_ci==`var' [fw=factor_ci]
		scalar econoActWorkAge_``var'_label'_pop = `=r(N)'
		

		** EDUCATION AND SKILLS
		
		* Share of children attending schooling, 5 - 16 years group
		sum uno if asiste_ci==1 & inrange(edad_ci,5,16) & migrante_ci==`var' [fw=factor_ci]
		scalar attending_5to16_``var'_label'_pop = `=r(N)'
		
		sum uno if asiste_ci==0 & inrange(edad_ci,5,16) & migrante_ci==`var' [fw=factor_ci]
		scalar noedu_5to16_``var'_label'_pop = `=r(N)'
		
		sum uno if inrange(edad_ci,5,16) & migrante_ci==`var' [fw=factor_ci] 
		scalar pop_``var'_label'_516 = `=r(N)'
		
	}
	
		}
	
******************************************************** EXCEL OUTPUTS

	*putexcel set "/Users/juancamiloperdomo/Library/CloudStorage/OneDrive-Inter-AmericanDevelopmentBankGroup/Indicadores DataMIG/01 Raw/Resultados.xlsx", sheet("Hoja 1") modify
	putexcel set "C:\Users\JCAMILOP\OneDrive - Inter-American Development Bank Group\Indicadores DataMIG\Resultados.xlsx", sheet("Hoja1") modify
	putexcel describe
	
	
	** DEMOGRAPHIC
	
	putexcel F130 = (`=female_migr_pop'/`=migr_pop') F131 = (`=male_migr_pop'/`=migr_pop') 	// Sex 
	
	putexcel F132 = (`=pop_migr_fem_05'/`=migr_fem_pop') F137 = (`=pop_migr_masc_05'/`=migr_masc_pop') // 0 - 5
	
	putexcel F133 = (`=pop_migr_fem_615'/`=migr_fem_pop') F138 = (`=pop_migr_masc_615'/`=migr_masc_pop') // 16 - 34
	
	putexcel F134 = (`=pop_migr_fem_1634'/`=migr_fem_pop') F139 = (`=pop_migr_masc_1634'/`=migr_masc_pop') // 25 - 39
	
	putexcel F135 = (`=pop_migr_fem_3564'/`=migr_fem_pop') F140 = (`=pop_migr_masc_3564'/`=migr_masc_pop') // 40 - 54
	
	putexcel F136 = (`=pop_migr_fem_65older'/`=migr_fem_pop') F141 = (`=pop_migr_masc_65older'/`=migr_masc_pop') // 65 Older
	
	
	** LABOUR MARKET INDICATORS
	
	putexcel F142 = (`=job_migr_pop'/`=econoActWorkAge_migr_pop') // Share of population with a job
	
	putexcel F143 = (`=unemp_migr_pop'/`=econoActWorkAge_migr_pop') // Unemployed population
	
	
	** EDUCATION AND SKILLS
	
	putexcel F144 = (`=attending_5to16_migr_pop'/`=pop_migr_516') // Share of children attending schooling, 5 - 16 years group

	putexcel F145 = (`=noedu_5to16_migr_pop'/`=pop_migr_516') // Share of children NO attending schooling, 5 - 16 years group
	
********************************************************************************
********************************************************************************
********************************************************************************
************************************************************************* PANAMÁ
	clear all
	set more off, perm
	set maxvar 15000
	scalar drop _all

	** DATASET
	use "PAN_2019m3_BID.dta", replace

	gen uno=1
	replace factor_ci=round(factor_ci) // Applies when the expansion factor is a non-integer numbers
	
	****************************************************************************
	** LOCALS
		local 1_label = "migr"
		local 0_label = "nat"
		
		local 1_sexo = "masc_"
		local 2_sexo = "fem_"
		
********************************************************************* STATISTICS
********************************************************************************
********************************************************************************

	** CALCULATION OF INDICATORS
	
	** POPULATION
	
	* Total population calculated according to expansion factor
	sum uno if migrante_ci!=. [fw=factor_ci]
	scalar tot_pop = `=r(N)'
	
	* Migrant population calculated according to expansion factor
	sum uno if migrante_ci==1 [fw=factor_ci]
	scalar migr_pop = `=r(N)'
	
	* Native population calculated according to expansion factor
	sum uno if migrante_ci==0 [fw=factor_ci]
	scalar nat_pop = `=r(N)'
	

	** CALCULATION OF INDICATORS BY MIGRANTS AND NATIVES
	
	foreach var in 1 0 {
		
		foreach sexo in 1 2 {
		
		** DEMOGRAPHIC
		
		* Genders
		
		sum uno if migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar ``var'_label'_``sexo'_sexo'pop = `=r(N)' // 0 - 5 years
		
		* Age groups
		
		sum uno if inrange(edad_ci,0,5) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar pop_``var'_label'_``sexo'_sexo'05 = `=r(N)' // 0 - 5 years
		
		sum uno if inrange(edad_ci,6,15) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar pop_``var'_label'_``sexo'_sexo'615 = `=r(N)' // 6 - 15 years

		sum uno if inrange(edad_ci,16,34) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar pop_``var'_label'_``sexo'_sexo'1634 = `=r(N)'	//16 - 34 years
		
		sum uno if inrange(edad_ci,35,64) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar pop_``var'_label'_``sexo'_sexo'3564 = `=r(N)'	//35 - 64 years
		
		sum uno if inrange(edad_ci,65,.) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar pop_``var'_label'_``sexo'_sexo'65older = `=r(N)'  // 65 older years
		
		* Sex population
		sum uno if sexo_ci==1 & migrante_ci==`var' [fw=factor_ci]
		scalar male_``var'_label'_pop =`=r(N)'
		
		sum uno if sexo_ci==2 & migrante_ci==`var' [fw=factor_ci]
		scalar female_``var'_label'_pop =`=r(N)'
		
		
		** LABOUR MARKET INDICATORS
		
		* Share of population with a job
		sum uno if inrange(edad_ci,15,64) & emp_ci==1 & migrante_ci==`var' [fw=factor_ci]
		scalar job_``var'_label'_pop = `=r(N)'
		
		* Unemployment: Share of population who were unemployed
		sum uno if inrange(edad_ci,15,64) & desemp_ci==1 & migrante_ci==`var' [fw=factor_ci] 
		scalar unemp_``var'_label'_pop = `=r(N)'
		
		sum uno if (pea_ci==1) & inrange(edad_ci,15,64) & migrante_ci==`var' [fw=factor_ci]
		scalar econoActWorkAge_``var'_label'_pop = `=r(N)'
		

		** EDUCATION AND SKILLS
		
		* Share of children attending schooling, 5 - 16 years group
		sum uno if asiste_ci==1 & inrange(edad_ci,5,16) & migrante_ci==`var' [fw=factor_ci]
		scalar attending_5to16_``var'_label'_pop = `=r(N)'
		
		sum uno if asiste_ci==0 & inrange(edad_ci,5,16) & migrante_ci==`var' [fw=factor_ci]
		scalar noedu_5to16_``var'_label'_pop = `=r(N)'
		
		sum uno if inrange(edad_ci,5,16) & migrante_ci==`var' [fw=factor_ci] 
		scalar pop_``var'_label'_516 = `=r(N)'
		
	}
	
		}
	
******************************************************** EXCEL OUTPUTS

	*putexcel set "/Users/juancamiloperdomo/Library/CloudStorage/OneDrive-Inter-AmericanDevelopmentBankGroup/Indicadores DataMIG/01 Raw/Resultados.xlsx", sheet("Hoja 1") modify
	putexcel set "C:\Users\JCAMILOP\OneDrive - Inter-American Development Bank Group\Indicadores DataMIG\Resultados.xlsx", sheet("Hoja1") modify
	putexcel describe
	
	
	** DEMOGRAPHIC
	
	putexcel F146 = (`=female_migr_pop'/`=migr_pop') F147 = (`=male_migr_pop'/`=migr_pop') 	// Sex 
	
	putexcel F148 = (`=pop_migr_fem_05'/`=migr_fem_pop') F153 = (`=pop_migr_masc_05'/`=migr_masc_pop') // 0 - 5
	
	putexcel F149 = (`=pop_migr_fem_615'/`=migr_fem_pop') F154 = (`=pop_migr_masc_615'/`=migr_masc_pop') // 16 - 34
	
	putexcel F150 = (`=pop_migr_fem_1634'/`=migr_fem_pop') F155 = (`=pop_migr_masc_1634'/`=migr_masc_pop') // 25 - 39
	
	putexcel F151 = (`=pop_migr_fem_3564'/`=migr_fem_pop') F156 = (`=pop_migr_masc_3564'/`=migr_masc_pop') // 40 - 54
	
	putexcel F152 = (`=pop_migr_fem_65older'/`=migr_fem_pop') F157 = (`=pop_migr_masc_65older'/`=migr_masc_pop') // 65 Older
	
	
	** LABOUR MARKET INDICATORS
	
	putexcel F158 = (`=job_migr_pop'/`=econoActWorkAge_migr_pop') // Share of population with a job
	
	putexcel F159 = (`=unemp_migr_pop'/`=econoActWorkAge_migr_pop') // Unemployed population
	
	
	** EDUCATION AND SKILLS
	
	putexcel F160 = (`=attending_5to16_migr_pop'/`=pop_migr_516') // Share of children attending schooling, 5 - 16 years group

	putexcel F161 = (`=noedu_5to16_migr_pop'/`=pop_migr_516') // Share of children NO attending schooling, 5 - 16 years group
	
********************************************************************************
********************************************************************************
********************************************************************************
*********************************************************************** PARAGUAY
	clear all
	set more off, perm
	set maxvar 15000
	scalar drop _all

	** DATASET
	use "PRY_2020t4_BID.dta", replace

	gen uno=1
	replace factor_ci=round(factor_ci) // Applies when the expansion factor is a non-integer numbers
	
	****************************************************************************
	** LOCALS
		local 1_label = "migr"
		local 0_label = "nat"
		
		local 1_sexo = "masc_"
		local 2_sexo = "fem_"
		
********************************************************************* STATISTICS
********************************************************************************
********************************************************************************

	** CALCULATION OF INDICATORS
	
	** POPULATION
	
	* Total population calculated according to expansion factor
	sum uno if migrante_ci!=. [fw=factor_ci]
	scalar tot_pop = `=r(N)'
	
	* Migrant population calculated according to expansion factor
	sum uno if migrante_ci==1 [fw=factor_ci]
	scalar migr_pop = `=r(N)'
	
	* Native population calculated according to expansion factor
	sum uno if migrante_ci==0 [fw=factor_ci]
	scalar nat_pop = `=r(N)'
	

	** CALCULATION OF INDICATORS BY MIGRANTS AND NATIVES
	
	foreach var in 1 0 {
		
		foreach sexo in 1 2 {
		
		** DEMOGRAPHIC
		
		* Genders
		
		sum uno if migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar ``var'_label'_``sexo'_sexo'pop = `=r(N)' // 0 - 5 years
		
		* Age groups
		
		sum uno if inrange(edad_ci,0,5) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar pop_``var'_label'_``sexo'_sexo'05 = `=r(N)' // 0 - 5 years
		
		sum uno if inrange(edad_ci,6,15) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar pop_``var'_label'_``sexo'_sexo'615 = `=r(N)' // 6 - 15 years

		sum uno if inrange(edad_ci,16,34) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar pop_``var'_label'_``sexo'_sexo'1634 = `=r(N)'	//16 - 34 years
		
		sum uno if inrange(edad_ci,35,64) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar pop_``var'_label'_``sexo'_sexo'3564 = `=r(N)'	//35 - 64 years
		
		sum uno if inrange(edad_ci,65,.) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar pop_``var'_label'_``sexo'_sexo'65older = `=r(N)'  // 65 older years
		
		* Sex population
		sum uno if sexo_ci==1 & migrante_ci==`var' [fw=factor_ci]
		scalar male_``var'_label'_pop =`=r(N)'
		
		sum uno if sexo_ci==2 & migrante_ci==`var' [fw=factor_ci]
		scalar female_``var'_label'_pop =`=r(N)'
		
		
		** LABOUR MARKET INDICATORS
		
		* Share of population with a job
		sum uno if inrange(edad_ci,15,64) & emp_ci==1 & migrante_ci==`var' [fw=factor_ci]
		scalar job_``var'_label'_pop = `=r(N)'
		
		* Unemployment: Share of population who were unemployed
		sum uno if inrange(edad_ci,15,64) & desemp_ci==1 & migrante_ci==`var' [fw=factor_ci] 
		scalar unemp_``var'_label'_pop = `=r(N)'
		
		sum uno if (pea_ci==1) & inrange(edad_ci,15,64) & migrante_ci==`var' [fw=factor_ci]
		scalar econoActWorkAge_``var'_label'_pop = `=r(N)'
		

		** EDUCATION AND SKILLS
		
		* Share of children attending schooling, 5 - 16 years group
		sum uno if asiste_ci==1 & inrange(edad_ci,5,16) & migrante_ci==`var' [fw=factor_ci]
		scalar attending_5to16_``var'_label'_pop = `=r(N)'
		
		sum uno if asiste_ci==0 & inrange(edad_ci,5,16) & migrante_ci==`var' [fw=factor_ci]
		scalar noedu_5to16_``var'_label'_pop = `=r(N)'
		
		sum uno if inrange(edad_ci,5,16) & migrante_ci==`var' [fw=factor_ci] 
		scalar pop_``var'_label'_516 = `=r(N)'
		
	}
	
		}
	
******************************************************** EXCEL OUTPUTS

	*putexcel set "/Users/juancamiloperdomo/Library/CloudStorage/OneDrive-Inter-AmericanDevelopmentBankGroup/Indicadores DataMIG/01 Raw/Resultados.xlsx", sheet("Hoja 1") modify
	putexcel set "C:\Users\JCAMILOP\OneDrive - Inter-American Development Bank Group\Indicadores DataMIG\Resultados.xlsx", sheet("Hoja1") modify
	putexcel describe
	
	
	** DEMOGRAPHIC
	
	putexcel F162 = (`=female_migr_pop'/`=migr_pop') F163 = (`=male_migr_pop'/`=migr_pop') 	// Sex 
	
	putexcel F164 = (`=pop_migr_fem_05'/`=migr_fem_pop') F169 = (`=pop_migr_masc_05'/`=migr_masc_pop') // 0 - 5
	
	putexcel F165 = (`=pop_migr_fem_615'/`=migr_fem_pop') F170 = (`=pop_migr_masc_615'/`=migr_masc_pop') // 16 - 34
	
	putexcel F166 = (`=pop_migr_fem_1634'/`=migr_fem_pop') F171 = (`=pop_migr_masc_1634'/`=migr_masc_pop') // 25 - 39
	
	putexcel F167 = (`=pop_migr_fem_3564'/`=migr_fem_pop') F172 = (`=pop_migr_masc_3564'/`=migr_masc_pop') // 40 - 54
	
	putexcel F168 = (`=pop_migr_fem_65older'/`=migr_fem_pop') F173 = (`=pop_migr_masc_65older'/`=migr_masc_pop') // 65 Older
	
	
	** LABOUR MARKET INDICATORS
	
	putexcel F174 = (`=job_migr_pop'/`=econoActWorkAge_migr_pop') // Share of population with a job
	
	putexcel F175 = (`=unemp_migr_pop'/`=econoActWorkAge_migr_pop') // Unemployed population
	
	
	** EDUCATION AND SKILLS
	
	putexcel F176 = (`=attending_5to16_migr_pop'/`=pop_migr_516') // Share of children attending schooling, 5 - 16 years group

	putexcel F177 = (`=noedu_5to16_migr_pop'/`=pop_migr_516') // Share of children NO attending schooling, 5 - 16 years group
	
********************************************************************************
********************************************************************************
********************************************************************************
*************************************************************************** PERU
	clear all
	set more off, perm
	set maxvar 15000
	scalar drop _all

	** DATASET
	use "ENPOVE22.dta", replace

	gen uno=1
	replace factor_ci=round(factor_ci) // Applies when the expansion factor is a non-integer numbers
	
	****************************************************************************
	** LOCALS
		local 1_label = "migr"
		local 0_label = "nat"
		
		local 1_sexo = "masc_"
		local 2_sexo = "fem_"
		
********************************************************************* STATISTICS
********************************************************************************
********************************************************************************

	** CALCULATION OF INDICATORS
	
	** POPULATION
	
	* Total population calculated according to expansion factor
	sum uno if migrante_ci!=. [fw=factor_ci]
	scalar tot_pop = `=r(N)'
	
	* Migrant population calculated according to expansion factor
	sum uno if migrante_ci==1 [fw=factor_ci]
	scalar migr_pop = `=r(N)'
	
	* Native population calculated according to expansion factor
	sum uno if migrante_ci==0 [fw=factor_ci]
	scalar nat_pop = `=r(N)'
	

	** CALCULATION OF INDICATORS BY MIGRANTS AND NATIVES
	
	foreach var in 1 0 {
		
		foreach sexo in 1 2 {
		
		** DEMOGRAPHIC
		
		* Genders
		
		sum uno if migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar ``var'_label'_``sexo'_sexo'pop = `=r(N)' // 0 - 5 years
		
		* Age groups
		
		sum uno if inrange(edad_ci,0,5) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar pop_``var'_label'_``sexo'_sexo'05 = `=r(N)' // 0 - 5 years
		
		sum uno if inrange(edad_ci,6,15) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar pop_``var'_label'_``sexo'_sexo'615 = `=r(N)' // 6 - 15 years

		sum uno if inrange(edad_ci,16,34) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar pop_``var'_label'_``sexo'_sexo'1634 = `=r(N)'	//16 - 34 years
		
		sum uno if inrange(edad_ci,35,64) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar pop_``var'_label'_``sexo'_sexo'3564 = `=r(N)'	//35 - 64 years
		
		sum uno if inrange(edad_ci,65,.) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar pop_``var'_label'_``sexo'_sexo'65older = `=r(N)'  // 65 older years
		
		* Sex population
		sum uno if sexo_ci==1 & migrante_ci==`var' [fw=factor_ci]
		scalar male_``var'_label'_pop =`=r(N)'
		
		sum uno if sexo_ci==2 & migrante_ci==`var' [fw=factor_ci]
		scalar female_``var'_label'_pop =`=r(N)'
		
		
		** LABOUR MARKET INDICATORS
		
		* Share of population with a job
		sum uno if inrange(edad_ci,15,64) & emp_ci==1 & migrante_ci==`var' [fw=factor_ci]
		scalar job_``var'_label'_pop = `=r(N)'
		
		* Unemployment: Share of population who were unemployed
		sum uno if inrange(edad_ci,15,64) & desemp_ci==1 & migrante_ci==`var' [fw=factor_ci] 
		scalar unemp_``var'_label'_pop = `=r(N)'
		
		sum uno if (pea_ci==1) & inrange(edad_ci,15,64) & migrante_ci==`var' [fw=factor_ci]
		scalar econoActWorkAge_``var'_label'_pop = `=r(N)'
		

		** EDUCATION AND SKILLS
		
		* Share of children attending schooling, 5 - 16 years group
		sum uno if asiste_ci==1 & inrange(edad_ci,5,16) & migrante_ci==`var' [fw=factor_ci]
		scalar attending_5to16_``var'_label'_pop = `=r(N)'
		
		sum uno if asiste_ci==0 & inrange(edad_ci,5,16) & migrante_ci==`var' [fw=factor_ci]
		scalar noedu_5to16_``var'_label'_pop = `=r(N)'
		
		sum uno if inrange(edad_ci,5,16) & migrante_ci==`var' [fw=factor_ci] 
		scalar pop_``var'_label'_516 = `=r(N)'
		
	}
	
		}
	
******************************************************** EXCEL OUTPUTS

	*putexcel set "/Users/juancamiloperdomo/Library/CloudStorage/OneDrive-Inter-AmericanDevelopmentBankGroup/Indicadores DataMIG/01 Raw/Resultados.xlsx", sheet("Hoja 1") modify
	putexcel set "C:\Users\JCAMILOP\OneDrive - Inter-American Development Bank Group\Indicadores DataMIG\Resultados.xlsx", sheet("Hoja1") modify
	putexcel describe
	
	
	** DEMOGRAPHIC
	
	putexcel F178 = (`=female_migr_pop'/`=migr_pop') F179 = (`=male_migr_pop'/`=migr_pop') 	// Sex 
	
	putexcel F180 = (`=pop_migr_fem_05'/`=migr_fem_pop') F185 = (`=pop_migr_masc_05'/`=migr_masc_pop') // 0 - 5
	
	putexcel F181 = (`=pop_migr_fem_615'/`=migr_fem_pop') F186 = (`=pop_migr_masc_615'/`=migr_masc_pop') // 16 - 34
	
	putexcel F182 = (`=pop_migr_fem_1634'/`=migr_fem_pop') F187 = (`=pop_migr_masc_1634'/`=migr_masc_pop') // 25 - 39
	
	putexcel F183 = (`=pop_migr_fem_3564'/`=migr_fem_pop') F188 = (`=pop_migr_masc_3564'/`=migr_masc_pop') // 40 - 54
	
	putexcel F184 = (`=pop_migr_fem_65older'/`=migr_fem_pop') F189 = (`=pop_migr_masc_65older'/`=migr_masc_pop') // 65 Older
	
	
	** LABOUR MARKET INDICATORS
	
	putexcel F190 = (`=job_migr_pop'/`=econoActWorkAge_migr_pop') // Share of population with a job
	
	putexcel F191 = (`=unemp_migr_pop'/`=econoActWorkAge_migr_pop') // Unemployed population
	
	
	** EDUCATION AND SKILLS
	
	putexcel F192 = (`=attending_5to16_migr_pop'/`=pop_migr_516') // Share of children attending schooling, 5 - 16 years group

	putexcel F193 = (`=noedu_5to16_migr_pop'/`=pop_migr_516') // Share of children NO attending schooling, 5 - 16 years group
	
********************************************************************************
********************************************************************************
********************************************************************************
*********************************************************** REPUBLICA DOMINICANA
	clear all
	set more off, perm
	set maxvar 15000
	scalar drop _all

	** DATASET
	use "DOM_2021s1_BID.dta", replace

	gen uno=1
	replace factor_ci=round(factor_ci) // Applies when the expansion factor is a non-integer numbers
	
	****************************************************************************
	** LOCALS
		local 1_label = "migr"
		local 0_label = "nat"
		
		local 1_sexo = "masc_"
		local 2_sexo = "fem_"
		
********************************************************************* STATISTICS
********************************************************************************
********************************************************************************

	** CALCULATION OF INDICATORS
	
	** POPULATION
	
	* Total population calculated according to expansion factor
	sum uno if migrante_ci!=. [fw=factor_ci]
	scalar tot_pop = `=r(N)'
	
	* Migrant population calculated according to expansion factor
	sum uno if migrante_ci==1 [fw=factor_ci]
	scalar migr_pop = `=r(N)'
	
	* Native population calculated according to expansion factor
	sum uno if migrante_ci==0 [fw=factor_ci]
	scalar nat_pop = `=r(N)'
	

	** CALCULATION OF INDICATORS BY MIGRANTS AND NATIVES
	
	foreach var in 1 0 {
		
		foreach sexo in 1 2 {
		
		** DEMOGRAPHIC
		
		* Genders
		
		sum uno if migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar ``var'_label'_``sexo'_sexo'pop = `=r(N)' // 0 - 5 years
		
		* Age groups
		
		sum uno if inrange(edad_ci,0,5) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar pop_``var'_label'_``sexo'_sexo'05 = `=r(N)' // 0 - 5 years
		
		sum uno if inrange(edad_ci,6,15) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar pop_``var'_label'_``sexo'_sexo'615 = `=r(N)' // 6 - 15 years

		sum uno if inrange(edad_ci,16,34) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar pop_``var'_label'_``sexo'_sexo'1634 = `=r(N)'	//16 - 34 years
		
		sum uno if inrange(edad_ci,35,64) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar pop_``var'_label'_``sexo'_sexo'3564 = `=r(N)'	//35 - 64 years
		
		sum uno if inrange(edad_ci,65,.) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar pop_``var'_label'_``sexo'_sexo'65older = `=r(N)'  // 65 older years
		
		* Sex population
		sum uno if sexo_ci==1 & migrante_ci==`var' [fw=factor_ci]
		scalar male_``var'_label'_pop =`=r(N)'
		
		sum uno if sexo_ci==2 & migrante_ci==`var' [fw=factor_ci]
		scalar female_``var'_label'_pop =`=r(N)'
		
		
		** LABOUR MARKET INDICATORS
		
		* Share of population with a job
		sum uno if inrange(edad_ci,15,64) & emp_ci==1 & migrante_ci==`var' [fw=factor_ci]
		scalar job_``var'_label'_pop = `=r(N)'
		
		* Unemployment: Share of population who were unemployed
		sum uno if inrange(edad_ci,15,64) & desemp_ci==1 & migrante_ci==`var' [fw=factor_ci] 
		scalar unemp_``var'_label'_pop = `=r(N)'
		
		sum uno if (pea_ci==1) & inrange(edad_ci,15,64) & migrante_ci==`var' [fw=factor_ci]
		scalar econoActWorkAge_``var'_label'_pop = `=r(N)'
		

		** EDUCATION AND SKILLS
		
		* Share of children attending schooling, 5 - 16 years group
		sum uno if asiste_ci==1 & inrange(edad_ci,5,16) & migrante_ci==`var' [fw=factor_ci]
		scalar attending_5to16_``var'_label'_pop = `=r(N)'
		
		sum uno if asiste_ci==0 & inrange(edad_ci,5,16) & migrante_ci==`var' [fw=factor_ci]
		scalar noedu_5to16_``var'_label'_pop = `=r(N)'
		
		sum uno if inrange(edad_ci,5,16) & migrante_ci==`var' [fw=factor_ci] 
		scalar pop_``var'_label'_516 = `=r(N)'
		
	}
	
		}
	
******************************************************** EXCEL OUTPUTS

	*putexcel set "/Users/juancamiloperdomo/Library/CloudStorage/OneDrive-Inter-AmericanDevelopmentBankGroup/Indicadores DataMIG/01 Raw/Resultados.xlsx", sheet("Hoja 1") modify
	putexcel set "C:\Users\JCAMILOP\OneDrive - Inter-American Development Bank Group\Indicadores DataMIG\Resultados.xlsx", sheet("Hoja1") modify
	putexcel describe
	
	
	** DEMOGRAPHIC
	
	putexcel F194 = (`=female_migr_pop'/`=migr_pop') F195 = (`=male_migr_pop'/`=migr_pop') 	// Sex 
	
	putexcel F196 = (`=pop_migr_fem_05'/`=migr_fem_pop') F201 = (`=pop_migr_masc_05'/`=migr_masc_pop') // 0 - 5
	
	putexcel F197 = (`=pop_migr_fem_615'/`=migr_fem_pop') F202 = (`=pop_migr_masc_615'/`=migr_masc_pop') // 16 - 34
	
	putexcel F198 = (`=pop_migr_fem_1634'/`=migr_fem_pop') F203 = (`=pop_migr_masc_1634'/`=migr_masc_pop') // 25 - 39
	
	putexcel F199 = (`=pop_migr_fem_3564'/`=migr_fem_pop') F204 = (`=pop_migr_masc_3564'/`=migr_masc_pop') // 40 - 54
	
	putexcel F200 = (`=pop_migr_fem_65older'/`=migr_fem_pop') F205 = (`=pop_migr_masc_65older'/`=migr_masc_pop') // 65 Older
	
	
	** LABOUR MARKET INDICATORS
	
	putexcel F206 = (`=job_migr_pop'/`=econoActWorkAge_migr_pop') // Share of population with a job
	
	putexcel F207 = (`=unemp_migr_pop'/`=econoActWorkAge_migr_pop') // Unemployed population
	
	
	** EDUCATION AND SKILLS
	
	putexcel F208 = (`=attending_5to16_migr_pop'/`=pop_migr_516') // Share of children attending schooling, 5 - 16 years group

	putexcel F209 = (`=noedu_5to16_migr_pop'/`=pop_migr_516') // Share of children NO attending schooling, 5 - 16 years group
	
********************************************************************************
********************************************************************************
********************************************************************************
************************************************************************ SURINAM
	clear all
	set more off, perm
	set maxvar 15000
	scalar drop _all

	** DATASET
	use "SUR_2017m10_m9_BID.dta", replace

	gen uno=1
	replace factor_ci=round(factor_ci) // Applies when the expansion factor is a non-integer numbers
	
	****************************************************************************
	** LOCALS
		local 1_label = "migr"
		local 0_label = "nat"
		
		local 1_sexo = "masc_"
		local 2_sexo = "fem_"
		
********************************************************************* STATISTICS
********************************************************************************
********************************************************************************

	** CALCULATION OF INDICATORS
	
	** POPULATION
	
	* Total population calculated according to expansion factor
	sum uno if migrante_ci!=. [fw=factor_ci]
	scalar tot_pop = `=r(N)'
	
	* Migrant population calculated according to expansion factor
	sum uno if migrante_ci==1 [fw=factor_ci]
	scalar migr_pop = `=r(N)'
	
	* Native population calculated according to expansion factor
	sum uno if migrante_ci==0 [fw=factor_ci]
	scalar nat_pop = `=r(N)'
	

	** CALCULATION OF INDICATORS BY MIGRANTS AND NATIVES
	
	foreach var in 1 0 {
		
		foreach sexo in 1 2 {
		
		** DEMOGRAPHIC
		
		* Genders
		
		sum uno if migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar ``var'_label'_``sexo'_sexo'pop = `=r(N)' // 0 - 5 years
		
		* Age groups
		
		sum uno if inrange(edad_ci,0,5) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar pop_``var'_label'_``sexo'_sexo'05 = `=r(N)' // 0 - 5 years
		
		sum uno if inrange(edad_ci,6,15) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar pop_``var'_label'_``sexo'_sexo'615 = `=r(N)' // 6 - 15 years

		sum uno if inrange(edad_ci,16,34) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar pop_``var'_label'_``sexo'_sexo'1634 = `=r(N)'	//16 - 34 years
		
		sum uno if inrange(edad_ci,35,64) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar pop_``var'_label'_``sexo'_sexo'3564 = `=r(N)'	//35 - 64 years
		
		sum uno if inrange(edad_ci,65,.) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar pop_``var'_label'_``sexo'_sexo'65older = `=r(N)'  // 65 older years
		
		* Sex population
		sum uno if sexo_ci==1 & migrante_ci==`var' [fw=factor_ci]
		scalar male_``var'_label'_pop =`=r(N)'
		
		sum uno if sexo_ci==2 & migrante_ci==`var' [fw=factor_ci]
		scalar female_``var'_label'_pop =`=r(N)'
		
		
		** LABOUR MARKET INDICATORS
		
		* Share of population with a job
		sum uno if inrange(edad_ci,15,64) & emp_ci==1 & migrante_ci==`var' [fw=factor_ci]
		scalar job_``var'_label'_pop = `=r(N)'
		
		* Unemployment: Share of population who were unemployed
		sum uno if inrange(edad_ci,15,64) & desemp_ci==1 & migrante_ci==`var' [fw=factor_ci] 
		scalar unemp_``var'_label'_pop = `=r(N)'
		
		sum uno if (pea_ci==1) & inrange(edad_ci,15,64) & migrante_ci==`var' [fw=factor_ci]
		scalar econoActWorkAge_``var'_label'_pop = `=r(N)'
		

		** EDUCATION AND SKILLS
		
		* Share of children attending schooling, 5 - 16 years group
		sum uno if asiste_ci==1 & inrange(edad_ci,5,16) & migrante_ci==`var' [fw=factor_ci]
		scalar attending_5to16_``var'_label'_pop = `=r(N)'
		
		sum uno if asiste_ci==0 & inrange(edad_ci,5,16) & migrante_ci==`var' [fw=factor_ci]
		scalar noedu_5to16_``var'_label'_pop = `=r(N)'
		
		sum uno if inrange(edad_ci,5,16) & migrante_ci==`var' [fw=factor_ci] 
		scalar pop_``var'_label'_516 = `=r(N)'
		
	}
	
		}
	
******************************************************** EXCEL OUTPUTS

	*putexcel set "/Users/juancamiloperdomo/Library/CloudStorage/OneDrive-Inter-AmericanDevelopmentBankGroup/Indicadores DataMIG/01 Raw/Resultados.xlsx", sheet("Hoja 1") modify
	putexcel set "C:\Users\JCAMILOP\OneDrive - Inter-American Development Bank Group\Indicadores DataMIG\Resultados.xlsx", sheet("Hoja1") modify
	putexcel describe
	
	
	** DEMOGRAPHIC
	
	putexcel F210 = (`=female_migr_pop'/`=migr_pop') F211 = (`=male_migr_pop'/`=migr_pop') 	// Sex 
	
	putexcel F212 = (`=pop_migr_fem_05'/`=migr_fem_pop') F217 = (`=pop_migr_masc_05'/`=migr_masc_pop') // 0 - 5
	
	putexcel F213 = (`=pop_migr_fem_615'/`=migr_fem_pop') F218 = (`=pop_migr_masc_615'/`=migr_masc_pop') // 16 - 34
	
	putexcel F214 = (`=pop_migr_fem_1634'/`=migr_fem_pop') F219 = (`=pop_migr_masc_1634'/`=migr_masc_pop') // 25 - 39
	
	putexcel F215 = (`=pop_migr_fem_3564'/`=migr_fem_pop') F220 = (`=pop_migr_masc_3564'/`=migr_masc_pop') // 40 - 54
	
	putexcel F216 = (`=pop_migr_fem_65older'/`=migr_fem_pop') F221 = (`=pop_migr_masc_65older'/`=migr_masc_pop') // 65 Older
	
	
	** LABOUR MARKET INDICATORS
	
	putexcel F222 = (`=job_migr_pop'/`=econoActWorkAge_migr_pop') // Share of population with a job
	
	putexcel F223 = (`=unemp_migr_pop'/`=econoActWorkAge_migr_pop') // Unemployed population
	
	
	** EDUCATION AND SKILLS
	
	putexcel F224 = (`=attending_5to16_migr_pop'/`=pop_migr_516') // Share of children attending schooling, 5 - 16 years group

	putexcel F225 = (`=noedu_5to16_migr_pop'/`=pop_migr_516') // Share of children NO attending schooling, 5 - 16 years group
	
********************************************************************************
********************************************************************************
********************************************************************************
************************************************************** TRINIDAD Y TOBAGO
	clear all
	set more off, perm
	set maxvar 15000
	scalar drop _all

	** DATASET
	use "TTO_2015a_BID.dta", replace

	gen uno=1
	replace factor_ci=round(factor_ci) // Applies when the expansion factor is a non-integer numbers
	
	****************************************************************************
	** LOCALS
		local 1_label = "migr"
		local 0_label = "nat"
		
		local 1_sexo = "masc_"
		local 2_sexo = "fem_"
		
********************************************************************* STATISTICS
********************************************************************************
********************************************************************************

	** CALCULATION OF INDICATORS
	
	** POPULATION
	
	* Total population calculated according to expansion factor
	sum uno if migrante_ci!=. [fw=factor_ci]
	scalar tot_pop = `=r(N)'
	
	* Migrant population calculated according to expansion factor
	sum uno if migrante_ci==1 [fw=factor_ci]
	scalar migr_pop = `=r(N)'
	
	* Native population calculated according to expansion factor
	sum uno if migrante_ci==0 [fw=factor_ci]
	scalar nat_pop = `=r(N)'
	

	** CALCULATION OF INDICATORS BY MIGRANTS AND NATIVES
	
	foreach var in 1 0 {
		
		foreach sexo in 1 2 {
		
		** DEMOGRAPHIC
		
		* Genders
		
		sum uno if migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar ``var'_label'_``sexo'_sexo'pop = `=r(N)' // 0 - 5 years
		
		* Age groups
		
		sum uno if inrange(edad_ci,0,5) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar pop_``var'_label'_``sexo'_sexo'05 = `=r(N)' // 0 - 5 years
		
		sum uno if inrange(edad_ci,6,15) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar pop_``var'_label'_``sexo'_sexo'615 = `=r(N)' // 6 - 15 years

		sum uno if inrange(edad_ci,16,34) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar pop_``var'_label'_``sexo'_sexo'1634 = `=r(N)'	//16 - 34 years
		
		sum uno if inrange(edad_ci,35,64) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar pop_``var'_label'_``sexo'_sexo'3564 = `=r(N)'	//35 - 64 years
		
		sum uno if inrange(edad_ci,65,.) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar pop_``var'_label'_``sexo'_sexo'65older = `=r(N)'  // 65 older years
		
		* Sex population
		sum uno if sexo_ci==1 & migrante_ci==`var' [fw=factor_ci]
		scalar male_``var'_label'_pop =`=r(N)'
		
		sum uno if sexo_ci==2 & migrante_ci==`var' [fw=factor_ci]
		scalar female_``var'_label'_pop =`=r(N)'
		
		
		** LABOUR MARKET INDICATORS
		
		* Share of population with a job
		sum uno if inrange(edad_ci,15,64) & emp_ci==1 & migrante_ci==`var' [fw=factor_ci]
		scalar job_``var'_label'_pop = `=r(N)'
		
		* Unemployment: Share of population who were unemployed
		sum uno if inrange(edad_ci,15,64) & desemp_ci==1 & migrante_ci==`var' [fw=factor_ci] 
		scalar unemp_``var'_label'_pop = `=r(N)'
		
		sum uno if (pea_ci==1) & inrange(edad_ci,15,64) & migrante_ci==`var' [fw=factor_ci]
		scalar econoActWorkAge_``var'_label'_pop = `=r(N)'
		

		** EDUCATION AND SKILLS
		
		* Share of children attending schooling, 5 - 16 years group
		sum uno if asiste_ci==1 & inrange(edad_ci,5,16) & migrante_ci==`var' [fw=factor_ci]
		scalar attending_5to16_``var'_label'_pop = `=r(N)'
		
		sum uno if asiste_ci==0 & inrange(edad_ci,5,16) & migrante_ci==`var' [fw=factor_ci]
		scalar noedu_5to16_``var'_label'_pop = `=r(N)'
		
		sum uno if inrange(edad_ci,5,16) & migrante_ci==`var' [fw=factor_ci] 
		scalar pop_``var'_label'_516 = `=r(N)'
		
	}
	
		}
	
******************************************************** EXCEL OUTPUTS

	*putexcel set "/Users/juancamiloperdomo/Library/CloudStorage/OneDrive-Inter-AmericanDevelopmentBankGroup/Indicadores DataMIG/01 Raw/Resultados.xlsx", sheet("Hoja 1") modify
	putexcel set "C:\Users\JCAMILOP\OneDrive - Inter-American Development Bank Group\Indicadores DataMIG\Resultados.xlsx", sheet("Hoja1") modify
	putexcel describe
	
	
	** DEMOGRAPHIC
	
	putexcel F226 = (`=female_migr_pop'/`=migr_pop') F227 = (`=male_migr_pop'/`=migr_pop') 	// Sex 
	
	putexcel F228 = (`=pop_migr_fem_05'/`=migr_fem_pop') F233 = (`=pop_migr_masc_05'/`=migr_masc_pop') // 0 - 5
	
	putexcel F229 = (`=pop_migr_fem_615'/`=migr_fem_pop') F234 = (`=pop_migr_masc_615'/`=migr_masc_pop') // 16 - 34
	
	putexcel F230 = (`=pop_migr_fem_1634'/`=migr_fem_pop') F235 = (`=pop_migr_masc_1634'/`=migr_masc_pop') // 25 - 39
	
	putexcel F231 = (`=pop_migr_fem_3564'/`=migr_fem_pop') F236 = (`=pop_migr_masc_3564'/`=migr_masc_pop') // 40 - 54
	
	putexcel F232 = (`=pop_migr_fem_65older'/`=migr_fem_pop') F237 = (`=pop_migr_masc_65older'/`=migr_masc_pop') // 65 Older
	
	
	** LABOUR MARKET INDICATORS
	
	putexcel F238 = (`=job_migr_pop'/`=econoActWorkAge_migr_pop') // Share of population with a job
	
	putexcel F239 = (`=unemp_migr_pop'/`=econoActWorkAge_migr_pop') // Unemployed population
	
	
	** EDUCATION AND SKILLS
	
	putexcel F240 = (`=attending_5to16_migr_pop'/`=pop_migr_516') // Share of children attending schooling, 5 - 16 years group

	putexcel F241 = (`=noedu_5to16_migr_pop'/`=pop_migr_516') // Share of children NO attending schooling, 5 - 16 years group
	
********************************************************************************
********************************************************************************
********************************************************************************
************************************************************************ URUGUAY
	clear all
	set more off, perm
	set maxvar 15000
	scalar drop _all

	** DATASET
	use "URY_2019a_BID.dta", replace

	gen uno=1
	replace factor_ci=round(factor_ci) // Applies when the expansion factor is a non-integer numbers
	
	****************************************************************************
	** LOCALS
		local 1_label = "migr"
		local 0_label = "nat"
		
		local 1_sexo = "masc_"
		local 2_sexo = "fem_"
		
********************************************************************* STATISTICS
********************************************************************************
********************************************************************************

	** CALCULATION OF INDICATORS
	
	** POPULATION
	
	* Total population calculated according to expansion factor
	sum uno if migrante_ci!=. [fw=factor_ci]
	scalar tot_pop = `=r(N)'
	
	* Migrant population calculated according to expansion factor
	sum uno if migrante_ci==1 [fw=factor_ci]
	scalar migr_pop = `=r(N)'
	
	* Native population calculated according to expansion factor
	sum uno if migrante_ci==0 [fw=factor_ci]
	scalar nat_pop = `=r(N)'
	

	** CALCULATION OF INDICATORS BY MIGRANTS AND NATIVES
	
	foreach var in 1 0 {
		
		foreach sexo in 1 2 {
		
		** DEMOGRAPHIC
		
		* Genders
		
		sum uno if migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar ``var'_label'_``sexo'_sexo'pop = `=r(N)' // 0 - 5 years
		
		* Age groups
		
		sum uno if inrange(edad_ci,0,5) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar pop_``var'_label'_``sexo'_sexo'05 = `=r(N)' // 0 - 5 years
		
		sum uno if inrange(edad_ci,6,15) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar pop_``var'_label'_``sexo'_sexo'615 = `=r(N)' // 6 - 15 years

		sum uno if inrange(edad_ci,16,34) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar pop_``var'_label'_``sexo'_sexo'1634 = `=r(N)'	//16 - 34 years
		
		sum uno if inrange(edad_ci,35,64) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar pop_``var'_label'_``sexo'_sexo'3564 = `=r(N)'	//35 - 64 years
		
		sum uno if inrange(edad_ci,65,.) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar pop_``var'_label'_``sexo'_sexo'65older = `=r(N)'  // 65 older years
		
		* Sex population
		sum uno if sexo_ci==1 & migrante_ci==`var' [fw=factor_ci]
		scalar male_``var'_label'_pop =`=r(N)'
		
		sum uno if sexo_ci==2 & migrante_ci==`var' [fw=factor_ci]
		scalar female_``var'_label'_pop =`=r(N)'
		
		
		** LABOUR MARKET INDICATORS
		
		* Share of population with a job
		sum uno if inrange(edad_ci,15,64) & emp_ci==1 & migrante_ci==`var' [fw=factor_ci]
		scalar job_``var'_label'_pop = `=r(N)'
		
		* Unemployment: Share of population who were unemployed
		sum uno if inrange(edad_ci,15,64) & desemp_ci==1 & migrante_ci==`var' [fw=factor_ci] 
		scalar unemp_``var'_label'_pop = `=r(N)'
		
		sum uno if (pea_ci==1) & inrange(edad_ci,15,64) & migrante_ci==`var' [fw=factor_ci]
		scalar econoActWorkAge_``var'_label'_pop = `=r(N)'
		

		** EDUCATION AND SKILLS
		
		* Share of children attending schooling, 5 - 16 years group
		sum uno if asiste_ci==1 & inrange(edad_ci,5,16) & migrante_ci==`var' [fw=factor_ci]
		scalar attending_5to16_``var'_label'_pop = `=r(N)'
		
		sum uno if asiste_ci==0 & inrange(edad_ci,5,16) & migrante_ci==`var' [fw=factor_ci]
		scalar noedu_5to16_``var'_label'_pop = `=r(N)'
		
		sum uno if inrange(edad_ci,5,16) & migrante_ci==`var' [fw=factor_ci] 
		scalar pop_``var'_label'_516 = `=r(N)'
		
	}
	
		}
	
******************************************************** EXCEL OUTPUTS

	*putexcel set "/Users/juancamiloperdomo/Library/CloudStorage/OneDrive-Inter-AmericanDevelopmentBankGroup/Indicadores DataMIG/01 Raw/Resultados.xlsx", sheet("Hoja 1") modify
	putexcel set "C:\Users\JCAMILOP\OneDrive - Inter-American Development Bank Group\Indicadores DataMIG\Resultados.xlsx", sheet("Hoja1") modify
	putexcel describe
	
	
	** DEMOGRAPHIC
	
	putexcel F242 = (`=female_migr_pop'/`=migr_pop') F243 = (`=male_migr_pop'/`=migr_pop') 	// Sex 
	
	putexcel F244 = (`=pop_migr_fem_05'/`=migr_fem_pop') F249 = (`=pop_migr_masc_05'/`=migr_masc_pop') // 0 - 5
	
	putexcel F245 = (`=pop_migr_fem_615'/`=migr_fem_pop') F250 = (`=pop_migr_masc_615'/`=migr_masc_pop') // 16 - 34
	
	putexcel F246 = (`=pop_migr_fem_1634'/`=migr_fem_pop') F251 = (`=pop_migr_masc_1634'/`=migr_masc_pop') // 25 - 39
	
	putexcel F247 = (`=pop_migr_fem_3564'/`=migr_fem_pop') F252 = (`=pop_migr_masc_3564'/`=migr_masc_pop') // 40 - 54
	
	putexcel F248 = (`=pop_migr_fem_65older'/`=migr_fem_pop') F253 = (`=pop_migr_masc_65older'/`=migr_masc_pop') // 65 Older
	
	
	** LABOUR MARKET INDICATORS
	
	putexcel F254 = (`=job_migr_pop'/`=econoActWorkAge_migr_pop') // Share of population with a job
	
	putexcel F255 = (`=unemp_migr_pop'/`=econoActWorkAge_migr_pop') // Unemployed population
	
	
	** EDUCATION AND SKILLS
	
	putexcel F256 = (`=attending_5to16_migr_pop'/`=pop_migr_516') // Share of children attending schooling, 5 - 16 years group

	putexcel F257 = (`=noedu_5to16_migr_pop'/`=pop_migr_516') // Share of children NO attending schooling, 5 - 16 years group
	
********************************************************************************
********************************************************************************
********************************************************************************
********************************************************************** VENEZUELA
	clear all
	set more off, perm
	set maxvar 15000
	scalar drop _all

	** DATASET
	use "VEN_2019a_BID.dta", replace

	gen uno=1
	replace factor_ci=round(factor_ci) // Applies when the expansion factor is a non-integer numbers
	
	****************************************************************************
	** LOCALS
		local 1_label = "migr"
		local 0_label = "nat"
		
		local 1_sexo = "masc_"
		local 2_sexo = "fem_"
		
********************************************************************* STATISTICS
********************************************************************************
********************************************************************************

	** CALCULATION OF INDICATORS
	
	** POPULATION
	
	* Total population calculated according to expansion factor
	sum uno if migrante_ci!=. [fw=factor_ci]
	scalar tot_pop = `=r(N)'
	
	* Migrant population calculated according to expansion factor
	sum uno if migrante_ci==1 [fw=factor_ci]
	scalar migr_pop = `=r(N)'
	
	* Native population calculated according to expansion factor
	sum uno if migrante_ci==0 [fw=factor_ci]
	scalar nat_pop = `=r(N)'
	

	** CALCULATION OF INDICATORS BY MIGRANTS AND NATIVES
	
	foreach var in 1 0 {
		
		foreach sexo in 1 2 {
		
		** DEMOGRAPHIC
		
		* Genders
		
		sum uno if migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar ``var'_label'_``sexo'_sexo'pop = `=r(N)' // 0 - 5 years
		
		* Age groups
		
		sum uno if inrange(edad_ci,0,5) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar pop_``var'_label'_``sexo'_sexo'05 = `=r(N)' // 0 - 5 years
		
		sum uno if inrange(edad_ci,6,15) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar pop_``var'_label'_``sexo'_sexo'615 = `=r(N)' // 6 - 15 years

		sum uno if inrange(edad_ci,16,34) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar pop_``var'_label'_``sexo'_sexo'1634 = `=r(N)'	//16 - 34 years
		
		sum uno if inrange(edad_ci,35,64) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar pop_``var'_label'_``sexo'_sexo'3564 = `=r(N)'	//35 - 64 years
		
		sum uno if inrange(edad_ci,65,.) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar pop_``var'_label'_``sexo'_sexo'65older = `=r(N)'  // 65 older years
		
		* Sex population
		sum uno if sexo_ci==1 & migrante_ci==`var' [fw=factor_ci]
		scalar male_``var'_label'_pop =`=r(N)'
		
		sum uno if sexo_ci==2 & migrante_ci==`var' [fw=factor_ci]
		scalar female_``var'_label'_pop =`=r(N)'
		
		
		** LABOUR MARKET INDICATORS
		
		* Share of population with a job
		sum uno if inrange(edad_ci,15,64) & emp_ci==1 & migrante_ci==`var' [fw=factor_ci]
		scalar job_``var'_label'_pop = `=r(N)'
		
		* Unemployment: Share of population who were unemployed
		sum uno if inrange(edad_ci,15,64) & desemp_ci==1 & migrante_ci==`var' [fw=factor_ci] 
		scalar unemp_``var'_label'_pop = `=r(N)'
		
		sum uno if (pea_ci==1) & inrange(edad_ci,15,64) & migrante_ci==`var' [fw=factor_ci]
		scalar econoActWorkAge_``var'_label'_pop = `=r(N)'
		

		** EDUCATION AND SKILLS
		
		* Share of children attending schooling, 5 - 16 years group
		sum uno if asiste_ci==1 & inrange(edad_ci,5,16) & migrante_ci==`var' [fw=factor_ci]
		scalar attending_5to16_``var'_label'_pop = `=r(N)'
		
		sum uno if asiste_ci==0 & inrange(edad_ci,5,16) & migrante_ci==`var' [fw=factor_ci]
		scalar noedu_5to16_``var'_label'_pop = `=r(N)'
		
		sum uno if inrange(edad_ci,5,16) & migrante_ci==`var' [fw=factor_ci] 
		scalar pop_``var'_label'_516 = `=r(N)'
		
	}
	
		}
	
******************************************************** EXCEL OUTPUTS

	*putexcel set "/Users/juancamiloperdomo/Library/CloudStorage/OneDrive-Inter-AmericanDevelopmentBankGroup/Indicadores DataMIG/01 Raw/Resultados.xlsx", sheet("Hoja 1") modify
	putexcel set "C:\Users\JCAMILOP\OneDrive - Inter-American Development Bank Group\Indicadores DataMIG\Resultados.xlsx", sheet("Hoja1") modify
	putexcel describe
	
	
	** DEMOGRAPHIC
	
	putexcel F258 = (`=female_migr_pop'/`=migr_pop') F259 = (`=male_migr_pop'/`=migr_pop') 	// Sex 
	
	putexcel F260 = (`=pop_migr_fem_05'/`=migr_fem_pop') F265 = (`=pop_migr_masc_05'/`=migr_masc_pop') // 0 - 5
	
	putexcel F261 = (`=pop_migr_fem_615'/`=migr_fem_pop') F266 = (`=pop_migr_masc_615'/`=migr_masc_pop') // 16 - 34
	
	putexcel F262 = (`=pop_migr_fem_1634'/`=migr_fem_pop') F267 = (`=pop_migr_masc_1634'/`=migr_masc_pop') // 25 - 39
	
	putexcel F263 = (`=pop_migr_fem_3564'/`=migr_fem_pop') F268 = (`=pop_migr_masc_3564'/`=migr_masc_pop') // 40 - 54
	
	putexcel F264 = (`=pop_migr_fem_65older'/`=migr_fem_pop') F269 = (`=pop_migr_masc_65older'/`=migr_masc_pop') // 65 Older
	
	
	** LABOUR MARKET INDICATORS
	
	putexcel F270 = (`=job_migr_pop'/`=econoActWorkAge_migr_pop') // Share of population with a job
	
	putexcel F271 = (`=unemp_migr_pop'/`=econoActWorkAge_migr_pop') // Unemployed population
	
	
	** EDUCATION AND SKILLS
	
	putexcel F272 = (`=attending_5to16_migr_pop'/`=pop_migr_516') // Share of children attending schooling, 5 - 16 years group

	putexcel F273 = (`=noedu_5to16_migr_pop'/`=pop_migr_516') // Share of children NO attending schooling, 5 - 16 years group
	
********************************************************************************
********************************************************************************
********************************************************************************
************************************************************************* MEXICO
	clear all
	set more off, perm
	set maxvar 15000
	scalar drop _all

	** DATASET
	use "MEX_2020_censusBID.dta", replace

	gen uno=1
	replace factor_ci=round(factor_ci) // Applies when the expansion factor is a non-integer numbers
	
	****************************************************************************
	** LOCALS
		local 1_label = "migr"
		local 0_label = "nat"
		
		local 1_sexo = "masc_"
		local 2_sexo = "fem_"
		
********************************************************************* STATISTICS
********************************************************************************
********************************************************************************

	** CALCULATION OF INDICATORS
	
	** POPULATION
	
	* Total population calculated according to expansion factor
	sum uno if migrante_ci!=. [fw=factor_ci]
	scalar tot_pop = `=r(N)'
	
	* Migrant population calculated according to expansion factor
	sum uno if migrante_ci==1 [fw=factor_ci]
	scalar migr_pop = `=r(N)'
	
	* Native population calculated according to expansion factor
	sum uno if migrante_ci==0 [fw=factor_ci]
	scalar nat_pop = `=r(N)'
	

	** CALCULATION OF INDICATORS BY MIGRANTS AND NATIVES
	
	foreach var in 1 0 {
		
		foreach sexo in 1 2 {
		
		** DEMOGRAPHIC
		
		* Genders
		
		sum uno if migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar ``var'_label'_``sexo'_sexo'pop = `=r(N)' // 0 - 5 years
		
		* Age groups
		
		sum uno if inrange(edad_ci,0,5) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar pop_``var'_label'_``sexo'_sexo'05 = `=r(N)' // 0 - 5 years
		
		sum uno if inrange(edad_ci,6,15) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar pop_``var'_label'_``sexo'_sexo'615 = `=r(N)' // 6 - 15 years

		sum uno if inrange(edad_ci,16,34) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar pop_``var'_label'_``sexo'_sexo'1634 = `=r(N)'	//16 - 34 years
		
		sum uno if inrange(edad_ci,35,64) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar pop_``var'_label'_``sexo'_sexo'3564 = `=r(N)'	//35 - 64 years
		
		sum uno if inrange(edad_ci,65,.) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar pop_``var'_label'_``sexo'_sexo'65older = `=r(N)'  // 65 older years
		
		* Sex population
		sum uno if sexo_ci==1 & migrante_ci==`var' [fw=factor_ci]
		scalar male_``var'_label'_pop =`=r(N)'
		
		sum uno if sexo_ci==2 & migrante_ci==`var' [fw=factor_ci]
		scalar female_``var'_label'_pop =`=r(N)'
		
		
		** LABOUR MARKET INDICATORS
		
		* Share of population with a job
		sum uno if inrange(edad_ci,15,64) & emp_ci==1 & migrante_ci==`var' [fw=factor_ci]
		scalar job_``var'_label'_pop = `=r(N)'
		
		* Unemployment: Share of population who were unemployed
		sum uno if inrange(edad_ci,15,64) & desemp_ci==1 & migrante_ci==`var' [fw=factor_ci] 
		scalar unemp_``var'_label'_pop = `=r(N)'
		
		sum uno if (pea_ci==1) & inrange(edad_ci,15,64) & migrante_ci==`var' [fw=factor_ci]
		scalar econoActWorkAge_``var'_label'_pop = `=r(N)'
		

		** EDUCATION AND SKILLS
		
		* Share of children attending schooling, 5 - 16 years group
		sum uno if asiste_ci==1 & inrange(edad_ci,5,16) & migrante_ci==`var' [fw=factor_ci]
		scalar attending_5to16_``var'_label'_pop = `=r(N)'
		
		sum uno if asiste_ci==0 & inrange(edad_ci,5,16) & migrante_ci==`var' [fw=factor_ci]
		scalar noedu_5to16_``var'_label'_pop = `=r(N)'
		
		sum uno if inrange(edad_ci,5,16) & migrante_ci==`var' [fw=factor_ci] 
		scalar pop_``var'_label'_516 = `=r(N)'
		
	}
	
		}
	
******************************************************** EXCEL OUTPUTS

	*putexcel set "/Users/juancamiloperdomo/Library/CloudStorage/OneDrive-Inter-AmericanDevelopmentBankGroup/Indicadores DataMIG/01 Raw/Resultados.xlsx", sheet("Hoja 1") modify
	putexcel set "C:\Users\JCAMILOP\OneDrive - Inter-American Development Bank Group\Indicadores DataMIG\Resultados.xlsx", sheet("Hoja1") modify
	putexcel describe
	
	
	** DEMOGRAPHIC
	
	putexcel F274 = (`=female_migr_pop'/`=migr_pop') F275 = (`=male_migr_pop'/`=migr_pop') 	// Sex 
	
	putexcel F276 = (`=pop_migr_fem_05'/`=migr_fem_pop') F281 = (`=pop_migr_masc_05'/`=migr_masc_pop') // 0 - 5
	
	putexcel F277 = (`=pop_migr_fem_615'/`=migr_fem_pop') F282 = (`=pop_migr_masc_615'/`=migr_masc_pop') // 16 - 34
	
	putexcel F278 = (`=pop_migr_fem_1634'/`=migr_fem_pop') F283 = (`=pop_migr_masc_1634'/`=migr_masc_pop') // 25 - 39
	
	putexcel F279 = (`=pop_migr_fem_3564'/`=migr_fem_pop') F284 = (`=pop_migr_masc_3564'/`=migr_masc_pop') // 40 - 54
	
	putexcel F280 = (`=pop_migr_fem_65older'/`=migr_fem_pop') F285 = (`=pop_migr_masc_65older'/`=migr_masc_pop') // 65 Older
	
	
	** LABOUR MARKET INDICATORS
	
	putexcel F286 = (`=job_migr_pop'/`=econoActWorkAge_migr_pop') // Share of population with a job
	
	putexcel F287 = (`=unemp_migr_pop'/`=econoActWorkAge_migr_pop') // Unemployed population
	
	
	** EDUCATION AND SKILLS
	
	putexcel F288 = (`=attending_5to16_migr_pop'/`=pop_migr_516') // Share of children attending schooling, 5 - 16 years group

	putexcel F289 = (`=noedu_5to16_migr_pop'/`=pop_migr_516') // Share of children NO attending schooling, 5 - 16 years group
	
********************************************************************************
********************************************************************************
********************************************************************************
************************************************************************* BRASIL
	clear all
	set more off, perm
	set maxvar 15000
	scalar drop _all

	** DATASET
	use "BRA_2015m9_BID.dta", replace

	gen uno=1
	replace factor_ci=round(factor_ci) // Applies when the expansion factor is a non-integer numbers
	
	****************************************************************************
	** LOCALS
		local 1_label = "migr"
		local 0_label = "nat"
		
		local 1_sexo = "masc_"
		local 2_sexo = "fem_"
		
********************************************************************* STATISTICS
********************************************************************************
********************************************************************************

	** CALCULATION OF INDICATORS
	
	** POPULATION
	
	* Total population calculated according to expansion factor
	sum uno if migrante_ci!=. [fw=factor_ci]
	scalar tot_pop = `=r(N)'
	
	* Migrant population calculated according to expansion factor
	sum uno if migrante_ci==1 [fw=factor_ci]
	scalar migr_pop = `=r(N)'
	
	* Native population calculated according to expansion factor
	sum uno if migrante_ci==0 [fw=factor_ci]
	scalar nat_pop = `=r(N)'
	

	** CALCULATION OF INDICATORS BY MIGRANTS AND NATIVES
	
	foreach var in 1 0 {
		
		foreach sexo in 1 2 {
		
		** DEMOGRAPHIC
		
		* Genders
		
		sum uno if migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar ``var'_label'_``sexo'_sexo'pop = `=r(N)' // 0 - 5 years
		
		* Age groups
		
		sum uno if inrange(edad_ci,0,5) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar pop_``var'_label'_``sexo'_sexo'05 = `=r(N)' // 0 - 5 years
		
		sum uno if inrange(edad_ci,6,15) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar pop_``var'_label'_``sexo'_sexo'615 = `=r(N)' // 6 - 15 years

		sum uno if inrange(edad_ci,16,34) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar pop_``var'_label'_``sexo'_sexo'1634 = `=r(N)'	//16 - 34 years
		
		sum uno if inrange(edad_ci,35,64) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar pop_``var'_label'_``sexo'_sexo'3564 = `=r(N)'	//35 - 64 years
		
		sum uno if inrange(edad_ci,65,.) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar pop_``var'_label'_``sexo'_sexo'65older = `=r(N)'  // 65 older years
		
		* Sex population
		sum uno if sexo_ci==1 & migrante_ci==`var' [fw=factor_ci]
		scalar male_``var'_label'_pop =`=r(N)'
		
		sum uno if sexo_ci==2 & migrante_ci==`var' [fw=factor_ci]
		scalar female_``var'_label'_pop =`=r(N)'
		
		
		** LABOUR MARKET INDICATORS
		
		* Share of population with a job
		sum uno if inrange(edad_ci,15,64) & emp_ci==1 & migrante_ci==`var' [fw=factor_ci]
		scalar job_``var'_label'_pop = `=r(N)'
		
		* Unemployment: Share of population who were unemployed
		sum uno if inrange(edad_ci,15,64) & desemp_ci==1 & migrante_ci==`var' [fw=factor_ci] 
		scalar unemp_``var'_label'_pop = `=r(N)'
		
		sum uno if (pea_ci==1) & inrange(edad_ci,15,64) & migrante_ci==`var' [fw=factor_ci]
		scalar econoActWorkAge_``var'_label'_pop = `=r(N)'
		

		** EDUCATION AND SKILLS
		
		* Share of children attending schooling, 5 - 16 years group
		sum uno if asiste_ci==1 & inrange(edad_ci,5,16) & migrante_ci==`var' [fw=factor_ci]
		scalar attending_5to16_``var'_label'_pop = `=r(N)'
		
		sum uno if asiste_ci==0 & inrange(edad_ci,5,16) & migrante_ci==`var' [fw=factor_ci]
		scalar noedu_5to16_``var'_label'_pop = `=r(N)'
		
		sum uno if inrange(edad_ci,5,16) & migrante_ci==`var' [fw=factor_ci] 
		scalar pop_``var'_label'_516 = `=r(N)'
		
	}
	
		}
	
******************************************************** EXCEL OUTPUTS

	putexcel set "/Users/juancamiloperdomo/Library/CloudStorage/OneDrive-Inter-AmericanDevelopmentBankGroup/Indicadores DataMIG/Resultados.xlsx", sheet("Hoja1") modify
	*putexcel set "C:\Users\JCAMILOP\OneDrive - Inter-American Development Bank Group\Indicadores DataMIG\Resultados.xlsx", sheet("Hoja1") modify
	putexcel describe
	
	
	** DEMOGRAPHIC
	
	putexcel F290 = (`=female_migr_pop'/`=migr_pop') F291 = (`=male_migr_pop'/`=migr_pop') 	// Sex 
	
	putexcel F292 = (`=pop_migr_fem_05'/`=migr_fem_pop') F297 = (`=pop_migr_masc_05'/`=migr_masc_pop') // 0 - 5
	
	putexcel F293 = (`=pop_migr_fem_615'/`=migr_fem_pop') F298 = (`=pop_migr_masc_615'/`=migr_masc_pop') // 16 - 34
	
	putexcel F294 = (`=pop_migr_fem_1634'/`=migr_fem_pop') F299 = (`=pop_migr_masc_1634'/`=migr_masc_pop') // 25 - 39
	
	putexcel F295 = (`=pop_migr_fem_3564'/`=migr_fem_pop') F300 = (`=pop_migr_masc_3564'/`=migr_masc_pop') // 40 - 54
	
	putexcel F296 = (`=pop_migr_fem_65older'/`=migr_fem_pop') F301 = (`=pop_migr_masc_65older'/`=migr_masc_pop') // 65 Older
	
	
	** LABOUR MARKET INDICATORS
	
	putexcel F302 = (`=job_migr_pop'/`=econoActWorkAge_migr_pop') // Share of population with a job
	
	putexcel F303 = (`=unemp_migr_pop'/`=econoActWorkAge_migr_pop') // Unemployed population
	
	
	** EDUCATION AND SKILLS
	
	putexcel F304 = (`=attending_5to16_migr_pop'/`=pop_migr_516') // Share of children attending schooling, 5 - 16 years group

	putexcel F305 = (`=noedu_5to16_migr_pop'/`=pop_migr_516') // Share of children NO attending schooling, 5 - 16 years group
