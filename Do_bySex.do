********************************************************************************
********************************************************************************
********************************************************************************
****** ECUADOR - HOUSEHOLD SURVEY ENEMDU 2021
	
	clear all
	set more off, perm
	set maxvar 15000
	scalar drop _all

	****************************************************************************
	** DATASET
	pwd
	cd "/Users/juancamiloperdomo/Library/CloudStorage/OneDrive-Inter-AmericanDevelopmentBankGroup/Calculos Indicadores/Indicadores generales/01 Raw"
	use "ECU_2022a_BID.dta", replace

	gen uno=1
	replace factor_ci=round(factor_ci) // Applies when the expansion factor is a non-integer number
	rename p41 codocupa
	rename p40 codindustria
	
	****************************************************************************
	** LOCALS
		local 1_label = "migr"
		local 0_label = "nat"
		
		local 1_sexo = "masc_"
		local 2_sexo = "fem_"
		
	****************************************************************************
	** ISCED
	gen ISCED = 0 if (p10a == 1 | p10a == 3)
	replace ISCED = 1 if inlist(p10a, 2, 4, 5)
	replace ISCED = 3 if (p10a == 6 | p10a == 7)
	replace ISCED = 4 if p10a == 8
	replace ISCED = 6 if p10a == 9
	replace ISCED = 7 if p10a == 10
	
	****************************************************************************
	** JOB QUALIFICATIONS - ISCO
	gen ISCO = real(substr(string(codocupa, "%4.0g"), 1, 1))
	gen length = strlen(string(codocupa))
	replace ISCO = 0 if length == 3
	gen overqualificated = 1 if inrange(ISCED,5,8) & inrange(ISCO,4,9)
	gen low_skilled = 1 if ISCO==9
	gen high_skilled = 1 if inrange(ISCO,1,3)
	
	****************************************************************************
	** Household size
	by idh_ch, sort: egen nmiembros=sum(relacion_ci>=1 & relacion_ci<5)
	by idh_ch, sort: egen nmenor18=sum((relacion_ci>=1 & relacion_ci<=4) & edad_ci<18)
	by idh_ch, sort: egen nmenor15=sum((relacion_ci>=1 & relacion_ci<=4) & edad_ci<15)
	
	****************************************************************************
	** Informality
	gen informal = .
	replace informal = 0 if emp_ci==1 & inrange(edad_ci,15,64)
	replace informal = 1 if cotizando_ci == 0 & emp_ci==1 & inrange(edad_ci,15,64)
	replace informal = 1 if afiliado_ci == 0 & emp_ci==1 & inrange(edad_ci,15,64)
	replace informal = 0 if tipocontrato_ci==1 & emp_ci==1 & inrange(edad_ci,15,64)
	
	****************************************************************************
	** Working hours
	gen more_40 = 1 if horastot_ci >= 40
	replace more_40 = . if horastot_ci == .
	gen more_50 = 1 if horastot_ci >= 50
	replace more_50 = . if horastot_ci == .
	gen more_55 = 1 if horastot_ci >= 55
	replace more_55 = . if horastot_ci == .
	gen less_30 = 1 if horastot_ci <= 30
	replace less_30 = . if horastot_ci == .
	gen by_hours = 1 if emp_ci == 1
	replace by_hours = . if horastot_ci == .
	
	****************************************************************************
	** Months of unemployment
	gen more_12 = 1 if durades_ci>=12
	replace more_12 = . if durades_ci == .
	gen more_6 = 1 if durades_ci>=6
	replace more_6 = . if durades_ci == .
	
	****************************************************************************
	** Nominal monthly wage (USD)
	by idh_ch, sort: egen nmwage=mean(ylm_ci + ylnm_ch)
	replace nmwage = (nmwage)/0.51
	
********************************************************************* STATISTICS
********************************************************************************
********************************************************************************

	** CALCULATION OF INDICATORS
	
	** POPULATION
	
	* Total population calculated according to expansion factor
	sum uno if migrante_ci!=. & sexo_ci == 1 [fw=factor_ci]
	scalar tot_masc_pop = `=r(N)'
	
	* Migrant population calculated according to expansion factor
	sum uno if migrante_ci==1 & sexo_ci == 1 [fw=factor_ci]
	scalar migr_masc_pop = `=r(N)'
	
	* Native population calculated according to expansion factor
	sum uno if migrante_ci==0 & sexo_ci == 1 [fw=factor_ci]
	scalar nat_masc_pop = `=r(N)'
	
	* Total population calculated according to expansion factor
	sum uno if migrante_ci!=. & sexo_ci == 2 [fw=factor_ci]
	scalar tot_fem_pop = `=r(N)'
	
	* Migrant population calculated according to expansion factor
	sum uno if migrante_ci==1 & sexo_ci == 2 [fw=factor_ci]
	scalar migr_fem_pop = `=r(N)'
	
	* Native population calculated according to expansion factor
	sum uno if migrante_ci==0 & sexo_ci == 2 [fw=factor_ci]
	scalar nat_fem_pop = `=r(N)'
	
	* Share of working age population (15-64) Male
	sum uno if inrange(edad_ci,15,64) & migrante_ci==1 & sexo_ci == 1 [fw=factor_ci]
	scalar workAge_migr_masc_pop = `=r(N)'
	sum uno if inrange(edad_ci,15,64) & migrante_ci==0 & sexo_ci == 1 [fw=factor_ci]
	scalar workAge_nat_masc_pop = `=r(N)'
	sum uno if inrange(edad_ci,15,64) & sexo_ci == 1 [fw=factor_ci]
	scalar workAge_masc_pop = `=r(N)'
		
	* Share of labour force population (15-64) Male
	sum uno if inrange(edad_ci,15,64) & pea_ci == 1 & migrante_ci==1 & sexo_ci == 1 [fw=factor_ci]
	scalar econoAct_migr_masc_pop = `=r(N)'
	sum uno if inrange(edad_ci,15,64) & pea_ci == 1 & migrante_ci==0 & sexo_ci == 1 [fw=factor_ci]
	scalar econoAct_nat_masc_pop = `=r(N)'
	sum uno if inrange(edad_ci,15,64) & pea_ci == 1 & sexo_ci == 1 [fw=factor_ci]
	scalar econoAct_masc_pop = `=r(N)'
	
	* Share of Employment rate  (15-64) Male
	sum uno if inrange(edad_ci,15,64) & emp_ci == 1 & migrante_ci==1 & sexo_ci == 1 [fw=factor_ci]
	scalar emp_migr_masc_pop = `=r(N)'
	sum uno if inrange(edad_ci,15,64) & emp_ci == 1 & migrante_ci==0 & sexo_ci == 1 [fw=factor_ci]
	scalar emp_nat_masc_pop = `=r(N)'
	sum uno if inrange(edad_ci,15,64) & emp_ci == 1 & sexo_ci == 1 [fw=factor_ci]
	scalar emp_masc_pop = `=r(N)'
	
	* Share of working age population (15-64) Female
	sum uno if inrange(edad_ci,15,64) & migrante_ci==1 & sexo_ci == 2 [fw=factor_ci]
	scalar workAge_migr_fem_pop = `=r(N)'
	sum uno if inrange(edad_ci,15,64) & migrante_ci==0 & sexo_ci == 2 [fw=factor_ci]
	scalar workAge_nat_fem_pop = `=r(N)'
	sum uno if inrange(edad_ci,15,64) & sexo_ci == 2 [fw=factor_ci]
	scalar workAge_fem_pop = `=r(N)'
		
	* Share of labour force population (15-64) Female
	sum uno if inrange(edad_ci,15,64) & pea_ci == 1 & migrante_ci==1 & sexo_ci == 2 [fw=factor_ci]
	scalar econoAct_migr_fem_pop = `=r(N)'
	sum uno if inrange(edad_ci,15,64) & pea_ci == 1 & migrante_ci==0 & sexo_ci == 2 [fw=factor_ci]
	scalar econoAct_nat_fem_pop = `=r(N)'
	sum uno if inrange(edad_ci,15,64) & pea_ci == 1 & sexo_ci == 2 [fw=factor_ci]
	scalar econoAct_fem_pop = `=r(N)'
	
	* Share of Employment rate  (15-64) Female
	sum uno if inrange(edad_ci,15,64) & emp_ci == 1 & migrante_ci==1 & sexo_ci == 2 [fw=factor_ci]
	scalar emp_migr_fem_pop = `=r(N)'
	sum uno if inrange(edad_ci,15,64) & emp_ci == 1 & migrante_ci==0 & sexo_ci == 2 [fw=factor_ci]
	scalar emp_nat_fem_pop = `=r(N)'
	sum uno if inrange(edad_ci,15,64) & emp_ci == 1 & sexo_ci == 2 [fw=factor_ci]
	scalar emp_fem_pop = `=r(N)'
	

	** CALCULATION OF INDICATORS BY MIGRANTS AND NATIVES
	
	foreach var in 1 0 {
		
		foreach sexo in 1 2 {
		
			** DEMOGRAPHIC
			
			* Age groups
			sum uno if inrange(edad_ci,0,14) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
			scalar pop_``var'_label'_``sexo'_sexo'014 = `=r(N)' // 0 - 14 years
			
			sum uno if inrange(edad_ci,15,24) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
			scalar pop_``var'_label'_``sexo'_sexo'1524 = `=r(N)' // 15 - 24 years

			sum uno if inrange(edad_ci,25,39) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
			scalar pop_``var'_label'_``sexo'_sexo'2539 = `=r(N)' // 25 - 39 years
			
			sum uno if inrange(edad_ci,40,54) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
			scalar pop_``var'_label'_``sexo'_sexo'4054 = `=r(N)' // 40 - 54 years

			sum uno if inrange(edad_ci,55,64) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
			scalar pop_``var'_label'_``sexo'_sexo'5564 = `=r(N)'	//55 - 64 years
			
			sum uno if inrange(edad_ci,65,.) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
			scalar pop_``var'_label'_``sexo'_sexo'65older = `=r(N)'  // 65 older years
			
			* Sex male population
			sum uno if sexo_ci==1 & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
			scalar male_``var'_label'_``sexo'_sexo'pop =`=r(N)'
			
			* Marital status: married/cohabiting
			sum uno if civil_ci==2 & migrante_ci==`var' & inrange(edad_ci,15,64) & sexo_ci==`sexo' [fw=factor_ci]
			scalar married_``var'_label'_``sexo'_sexo'pop = `=r(N)'
			
			sum uno if civil_ci!=. & migrante_ci==`var' & inrange(edad_ci,15,64) & sexo_ci==`sexo' [fw=factor_ci]
			scalar status_``var'_label'_``sexo'_sexo'pop = `=r(N)'
			
			* Marital status: separated/divorced/widowed
			sum uno if (civil_ci==3 | civil_ci==4) & inrange(edad_ci,15,64) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
			scalar separated_``var'_label'_``sexo'_sexo'pop = `=r(N)'	
			
			* Marital status: single
			sum uno if civil_ci==1 & inrange(edad_ci,15,64) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
			scalar single_``var'_label'_``sexo'_sexo'pop = `=r(N)'	
			
			* Urban
			sum uno if zona_c==1 & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
			scalar urban_``var'_label'_``sexo'_sexo'pop = `=r(N)'
			
			* Capital city located
			sum uno if region_c==17 & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
			scalar capital_``var'_label'_``sexo'_sexo'pop = `=r(N)'
			
			* Border cities or region
			sum uno if inlist(region_c, 4, 7, 8, 11) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
			scalar borCity_``var'_label'_``sexo'_sexo'pop = `=r(N)'
			
			* Household size
			sum nmiembros if migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
			scalar size_``var'_label'_``sexo'_sexo'house = `=r(mean)'			
			
			* Number of children <= 18 in household
			sum nmenor18 if migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
			scalar less18_``var'_label'_``sexo'_sexo'house = `=r(mean)'			
			
			* Number of children <= 15 in household
			sum nmenor15 if migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
			scalar less15_``var'_label'_``sexo'_sexo'house = `=r(mean)'
			
			* Number of natural-born children (women only)
			
			
			** LABOUR MARKET INDICATORS
			
			* Share of population with a job
			sum uno if inrange(edad_ci,15,64) & emp_ci==1 & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
			scalar job_``var'_label'_``sexo'_sexo'pop = `=r(N)'
			
			* Activity: Share participating in the labour force
			sum uno if inrange(edad_ci,15,64) & pea_ci==1 & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
			scalar econoAct_``var'_label'_``sexo'_sexo'pop = `=r(N)'
			
			* Economically inactive people
			sum uno if inrange(edad_ci,15,64) & (condocup_ci == 3) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci] 
			scalar inactive_``var'_label'_``sexo'_sexo'pop = `=r(N)'
			
			* Unemployment: Share of population who were unemployed
			sum uno if inrange(edad_ci,15,64) & desemp_ci==1 & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci] 
			scalar unemp_``var'_label'_``sexo'_sexo'pop = `=r(N)'
			
			sum uno if (pea_ci==1 | asiste_ci==1) & inrange(edad_ci,15,64) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
			scalar econoActWorkAge_``var'_label'_``sexo'_sexo'pop = `=r(N)'
			
			* Risk of labour market exclusion: long-term unemployment (12 months)
			sum uno if inrange(edad_ci,15,64) & (more_12==1 & desemp_ci==1) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
			scalar long12_unemp_``var'_label'_``sexo'_sexo'pop = `=r(N)'
			
			sum uno if inrange(edad_ci,15,64) & (desemp_ci==1 | condocup_ci==3) & durades_ci!=. & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci] 
			scalar inac_unemp_``var'_label'_``sexo'_sexo'pop = `=r(N)'
			
			* Risk of labour market exclusion: long-term unemployment (6 months)
			sum uno if inrange(edad_ci,15,64) & (more_6==1 & desemp_ci==1) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
			scalar long6_unemp_``var'_label'_``sexo'_sexo'pop = `=r(N)'
			
			* Risk of labour market exclusion: long-term uemployment >=12 months or inactive involuntary
			sum uno if inrange(edad_ci,15,64) & (desalent_ci==1 | (more_12==1 & desemp_ci==1)) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
			scalar long_invo_``var'_label'_``sexo'_sexo'pop = `=r(N)'
			
			* Risk of labour market exclusion: Inactive involuntary (available past week, not looking for job)
			sum uno if inrange(edad_ci,15,64) & desalent_ci==1 & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
			scalar involuntary_``var'_label'_``sexo'_sexo'pop = `=r(N)'
			
			* Share of population with written contract
			sum uno if inrange(edad_ci,15,64) & inlist(tipocontrato_ci,0,1) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
			scalar written_``var'_label'_``sexo'_sexo'pop = `=r(N)'		
			
			* Share of population with an informal job
			sum uno if inrange(edad_ci,15,64) & formal_ci==0 & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
			scalar informal_``var'_label'_``sexo'_sexo'pop = `=r(N)'
			
			* Types of contracts:  Share of population in temporary contracts
			sum uno if inrange(edad_ci,15,64) & tipocontrato_ci==2 & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci] 
			scalar tempJob_``var'_label'_``sexo'_sexo'pop = `=r(N)'
			
			sum uno if inrange(edad_ci,15,64) & categopri_ci!=2 & asiste_ci!=1 & emp_ci==1 & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
			scalar noself_edu_``var'_label'_``sexo'_sexo'pop = `=r(N)'
			
			* Working hours: long hours >= 40
			sum uno if inrange(edad_ci,15,64) & more_40==1 & emp_ci == 1 & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
			scalar more40h_``var'_label'_``sexo'_sexo'pop = `=r(N)'
			
			sum uno if inrange(edad_ci,15,64) & by_hours==1 & emp_ci == 1 & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
			scalar hours_``var'_label'_``sexo'_sexo'pop = `=r(N)'

			* Working hours: long hours >= 50
			sum uno if inrange(edad_ci,15,64) & more_50==1 & emp_ci == 1 & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
			scalar more50h_``var'_label'_``sexo'_sexo'pop = `=r(N)'
			
			* Working hours: long hours >= 55
			sum uno if inrange(edad_ci,15,64) & more_55==1 & emp_ci == 1 & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
			scalar more55h_``var'_label'_``sexo'_sexo'pop = `=r(N)'		
		
			* Working hours: long hours < 30
			sum uno if inrange(edad_ci,15,64) & less_30==1 & emp_ci == 1 & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
			scalar less30h_``var'_label'_``sexo'_sexo'pop = `=r(N)'

			* Job skills: share of working population in highly skilled jobs
			sum uno if high_skilled==1 & inrange(edad_ci,15,64) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
			scalar highSkill_``var'_label'_``sexo'_sexo'pop = `=r(N)'		
			
			* Job skills: share of working population in low-skilled jobs
			sum uno if low_skilled==1 & inrange(edad_ci,15,64) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
			scalar lowSkill_``var'_label'_``sexo'_sexo'pop = `=r(N)'
			
			sum uno if emp_ci==1 & inrange(edad_ci,15,64) & ISCO!=0 & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
			scalar NotMili_``var'_label'_``sexo'_sexo'pop = `=r(N)'
			
			* Overqualification: share of highly educated individuals who work in low- or medium-skilled jobs
			sum uno if overqualificated==1 & inrange(edad_ci,15,64) & migrante_ci==`var' & sexo_ci==`sexo' & inrange(ISCED,4,9) [fw=factor_ci]
			scalar overquali_``var'_label'_``sexo'_sexo'pop = `=r(N)'
			
			sum uno if emp_ci==1 & inrange(edad_ci,15,64) & asiste_ci!=1 & ISCO!=0 & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
			scalar NotEduNotMili_``var'_label'_``sexo'_sexo'pop = `=r(N)'
			
			* Self-employment: share of population who works in their own firms or businesses
			sum uno if (categopri_ci==1 | categopri_ci==2) & inrange(edad_ci,15,64) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
			scalar selfEmp_``var'_label'_``sexo'_sexo'pop = `=r(N)'
			
			sum uno if inrange(edad_ci,15,64) & rama_ci!=1 & emp_ci==1 & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
			scalar Notagri_emp1564_``var'_label'_``sexo'_sexo'pop = `=r(N)'
			
			* Employment in the public sector
			sum uno if spublico_ci==1 & inrange(edad_ci,15,64) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
			scalar pubSec_``var'_label'_``sexo'_sexo'pop = `=r(N)'
			
			sum uno if inrange(edad_ci,15,64) & emp_ci==1 & categopri_ci!=2 & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
			scalar NoSelf15to64_``var'_label'_``sexo'_sexo'pop = `=r(N)'
			
			* Nominal monthly wage (USD)
			sum nmwage if migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
			scalar nmwage_``var'_label'_``sexo'_sexo' = `=r(mean)'
			
			* Child labour
			

			** EDUCATION AND SKILLS
			
			* Level of educational attainment: high (ISCED groups 5-8)
			sum uno if inrange(ISCED,5,8) & inrange(edad_ci,15,64) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
			scalar ISCED58_``var'_label'_``sexo'_sexo'pop = `=r(N)'
			
			sum uno if inrange(edad_ci,15,64) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
			scalar ISCEDEdu_``var'_label'_``sexo'_sexo'pop = `=r(N)'
			
			* Level of educational attainment: low (ISCED groups 0-2)
			sum uno if inrange(ISCED,0,2) & inrange(edad_ci,15,64) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
			scalar ISCED02_``var'_label'_``sexo'_sexo'pop = `=r(N)'
			
			* Level of educational attainment: very low (ISCED groups 0-1)
			sum uno if inrange(ISCED,0,1) & inrange(edad_ci,15,64) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
			scalar ISCED01_``var'_label'_``sexo'_sexo'pop = `=r(N)'
			
			* Literacy: knows how to read and write 
			sum uno if (p11 == 1 | p10a >=6) & inrange(edad_ci,16,64) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
			scalar literacy_``var'_label'_``sexo'_sexo'pop = `=r(N)'		
			
			sum uno if inrange(edad_ci,16,64) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci] 
			scalar pop_``var'_label'_``sexo'_sexo'1664 = `=r(N)'
			
			* Neither in employment, education or training for youth
			sum uno if (edad_ci>=15 & edad_ci <=34) & emp_ci!=1 & asiste_ci==0 & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
			scalar NoEmpNoedu_``var'_label'_``sexo'_sexo'pop = `=r(N)'
			
			sum uno if inrange(edad_ci,15,34) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
			scalar age1534_``var'_label'_``sexo'_sexo'pop = `=r(N)'
			
			* Early school leaving
			sum uno if asiste_ci == 0 & (edad_ci>=15 & edad_ci <=24) & inlist(ISCED,0,1,2) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
			scalar earlyLeft_``var'_label'_``sexo'_sexo'pop = `=r(N)'
			
			sum uno if inrange(edad_ci,15,24) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
			scalar earlyAge_``var'_label'_``sexo'_sexo'pop = `=r(N)'
			
			* Share of children attending schooling, 5 - 16 years group
			sum uno if asiste_ci==1 & inrange(edad_ci,5,16) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
			scalar attending_5to16_``var'_label'_``sexo'_sexo'pop = `=r(N)'
			
			sum uno if inrange(edad_ci,5,16) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci] 
			scalar pop_``var'_label'_``sexo'_sexo'516 = `=r(N)'
			
			** CHILDREN EDUCATION AND EMPLOYMENT
			
			* Share of children attending school (15-18 year-olds)
			sum uno if asiste_ci==1 & inrange(edad_ci,15,18) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
			scalar attending_15to18_``var'_label'_``sexo'_sexo'pop = `=r(N)'
			
			sum uno if inrange(edad_ci,15,18) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci] 
			scalar pop_``var'_label'_``sexo'_sexo'1518 = `=r(N)'
			
			* Share of children in employment (15-18 year-olds)
			sum uno if emp_ci==1 & inrange(edad_ci,15,18) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
			scalar employment_15to18_``var'_label'_``sexo'_sexo'pop = `=r(N)'
			
			* Share of children attending school only (15-18 year-olds)
			sum uno if (asiste_ci==1 & emp_ci!=1) & inrange(edad_ci,15,18) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
			scalar AttOnly_15to18_``var'_label'_``sexo'_sexo'pop = `=r(N)'
			
			* Share of children in employment only (15-18 year-olds)
			sum uno if (emp_ci==1 & asiste_ci!=1) & inrange(edad_ci,15,18) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
			scalar EmpOnly_15to18_``var'_label'_``sexo'_sexo'pop = `=r(N)'
			
			* Share of children attending school & in employment (15-18 year-olds)
			sum uno if (asiste_ci==1 & emp_ci==1) & inrange(edad_ci,15,18) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
			scalar Att_Emp_1518_``var'_label'_``sexo'_sexo'pop = `=r(N)'
			
			* Neither in employment, education or training for youth (15-18 year-olds)
			sum uno if (edad_ci>=15 & edad_ci <=18) & emp_ci==0 & asiste_ci==0 & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
			scalar NiNi_15to18_``var'_label'_``sexo'_sexo'pop = `=r(N)'
			
			** HEALTH
			
			* Access to health services AMONG working pop
			sum uno if inrange(edad_ci,15,64) & (afiliado_ci==1 | cotizando_ci==1) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci] 
			scalar healthSys_``var'_label'_``sexo'_sexo'pop = `=r(N)'	
			
			sum uno if inrange(edad_ci,15,64) & emp_ci==1 & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
			scalar job15to64_``var'_label'_``sexo'_sexo'pop = `=r(N)'	
			
			** SAMPLE CHARACTERISTICS
			
			* Total sample size: persons 
			sum uno if migrante_ci==`var' & sexo_ci==`sexo'
			scalar survey_``var'_label'_``sexo'_sexo'pop = `=r(N)'
			
			* Total sample size: persons 15-64
			sum uno if inrange(edad_ci,15,64) & migrante_ci==`var' & sexo_ci==`sexo'
			scalar survey_``var'_label'_``sexo'_sexo'15to64 = `=r(N)'

			* Total persons 15-64 (with sample loadings)
			sum uno if inrange(edad_ci,15,64) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
			scalar total_``var'_label'_``sexo'_sexo'15to64 = `=r(N)'
			
		}
	}
	
******************************************************** EXCEL OUTPUTS

	putexcel set "/Users/juancamiloperdomo/Library/CloudStorage/OneDrive-Inter-AmericanDevelopmentBankGroup/Calculos Indicadores/Indicadores generales/Resultados/Resultados por sexo.xlsx", sheet("Ecuador") modify
	putexcel describe
	
	
	** POPULATION
	
	putexcel C6 = (`=nat_masc_pop'/`=tot_masc_pop') E6 = (`=migr_masc_pop'/`=tot_masc_pop')	// Share of population
	
	putexcel C7 = (`=workAge_nat_masc_pop'/`=workAge_masc_pop') E7 = (`=workAge_migr_masc_pop'/`=workAge_masc_pop') // Share of working age population (15-64)
	
	putexcel C8 = (`=econoAct_nat_masc_pop'/`=econoAct_masc_pop') E8 = (`=econoAct_migr_masc_pop'/`=econoAct_masc_pop') // Share of labour force population (15-64)
	
	putexcel C9 = (`=emp_nat_masc_pop'/`=emp_masc_pop') E9 = (`=emp_migr_masc_pop'/`=emp_masc_pop') // Share of Employment rate  (15-64)
	
	
	** DEMOGRAPHIC
	
	putexcel C17 = (`=pop_nat_masc_014'/`=nat_masc_pop') E17 = (`=pop_migr_masc_014'/`=migr_masc_pop') // 0 - 14
	
	putexcel C18 = (`=pop_nat_masc_1524'/`=nat_masc_pop') E18 = (`=pop_migr_masc_1524'/`=migr_masc_pop') // 15 - 24
	
	putexcel C19 = (`=pop_nat_masc_2539'/`=nat_masc_pop') E19 = (`=pop_migr_masc_2539'/`=migr_masc_pop') // 25 - 39
	
	putexcel C20 = (`=pop_nat_masc_4054'/`=nat_masc_pop') E20 = (`=pop_migr_masc_4054'/`=migr_masc_pop') // 40 - 54
	
	putexcel C21 = (`=pop_nat_masc_5564'/`=nat_masc_pop') E21 = (`=pop_migr_masc_5564'/`=migr_masc_pop') // 55 - 64
	
	putexcel C22 = (`=pop_nat_masc_65older'/`=nat_masc_pop') E22 = (`=pop_migr_masc_65older'/`=migr_masc_pop') // 65 Older
	
	putexcel C23 = (`=workAge_nat_masc_pop'/`=nat_masc_pop') E23 = (`=workAge_migr_masc_pop'/`=migr_masc_pop') // 15-64 
	
	*putexcel C25 = (`=male_nat_pop'/`=nat_pop') E25 = (`=male_migr_pop'/`=migr_pop') 	// Sex male
	
	putexcel C26 = (`=married_nat_masc_pop'/`=status_nat_masc_pop') E26 = (`=married_migr_masc_pop'/`=status_migr_masc_pop') // Marital status: married/cohabiting
	
	putexcel C27 = (`=separated_nat_masc_pop'/`=status_nat_masc_pop') E27 = (`=separated_migr_masc_pop'/`=status_migr_masc_pop') // Marital status: separated/divorced/widowed

	putexcel C28 = (`=single_nat_masc_pop'/`=status_nat_masc_pop') E28 = (`=single_migr_masc_pop'/`=status_migr_masc_pop') // Marital status: single
	
	putexcel C29 = (`=urban_nat_masc_pop'/`=nat_masc_pop') E29 = (`=urban_migr_masc_pop'/`=migr_masc_pop') // Urban
	
	putexcel C30 = (`=capital_nat_masc_pop'/`=nat_masc_pop')  E30 = (`=capital_migr_masc_pop'/`=migr_masc_pop') // Capital city located
	
	putexcel C31 = (`=borCity_nat_masc_pop'/`=nat_masc_pop')  E31 = (`=borCity_migr_masc_pop'/`=migr_masc_pop') // Border cities or region
	
	putexcel C34 = (`=size_nat_masc_house')  E34 = (`=size_migr_masc_house') // Household size
		
	putexcel C35 = (`=less18_nat_masc_house')  E35 = (`=less18_migr_masc_house') // Number of children <= 18 in household
		
	putexcel C36 = (`=less15_nat_masc_house')  E36 = (`=less15_migr_masc_house') // Number of children <= 15 in household
		
	// Number of natural-born children (women only)
	
	
	** LABOUR MARKET INDICATORS
	
	putexcel C41 = (`=job_nat_masc_pop'/`=workAge_nat_masc_pop') E41 = (`=job_migr_masc_pop'/`=workAge_migr_masc_pop') // Share of population with a job
	
	putexcel C42 = (`=econoAct_nat_masc_pop'/`=workAge_nat_masc_pop') E42 = (`=econoAct_migr_masc_pop'/`=workAge_migr_masc_pop') // Activity: Share participating in the labour force
	
	putexcel C43 = (`=inactive_nat_masc_pop'/`=workAge_nat_masc_pop') E43 = (`=inactive_migr_masc_pop'/`=workAge_migr_masc_pop')  // Economically inactive people
	
	putexcel C44 = (`=unemp_nat_masc_pop'/`=econoActWorkAge_nat_masc_pop') E44 = (`=unemp_migr_masc_pop'/`=econoActWorkAge_migr_masc_pop') // Unemployment: Share of population who were unemployed
	
	putexcel C45 = (`=long12_unemp_nat_masc_pop'/`=inac_unemp_nat_masc_pop') E45 = (`=long12_unemp_migr_masc_pop'/`=inac_unemp_migr_masc_pop') // Risk of labour market exclusion: long-term unemployment (12 month)
	
	putexcel C46 = (`=long6_unemp_nat_masc_pop'/`=inac_unemp_nat_masc_pop') E46 = (`=long6_unemp_migr_masc_pop'/`=inac_unemp_migr_masc_pop') // Risk of labour market exclusion: long-term unemployment (6 month)
	
	putexcel C47 = (`=involuntary_nat_masc_pop'/`=inac_unemp_nat_masc_pop') E47 = (`=involuntary_migr_masc_pop'/`=inac_unemp_migr_masc_pop') // Inactive involuntary (available past week, not looking for job)
	
	putexcel C48 = (`=long_invo_nat_masc_pop'/`=inac_unemp_nat_masc_pop') E48 = (`=long_invo_migr_masc_pop'/`=inac_unemp_migr_masc_pop') // Long-term uemployment >=12 months or inactive involuntary	
	
	putexcel C49 = (`=written_nat_masc_pop'/`=noself_edu_nat_masc_pop') E49 = (`=written_migr_masc_pop'/`=noself_edu_migr_masc_pop') // Share of population with written contract
	
	putexcel C50 = (`=informal_nat_masc_pop'/`=workAge_nat_masc_pop') E50 = (`=informal_migr_masc_pop'/`=workAge_migr_masc_pop') // Share of population with an informal job	
	
    // Share of population with an informal job (OECD def)
	
	putexcel C52 = (`=tempJob_nat_masc_pop'/`=noself_edu_nat_masc_pop') E52 = (`=tempJob_migr_masc_pop'/`=noself_edu_migr_masc_pop') // Types of contracts: Share of population in temporary contracts	
	
	putexcel C53 = (`=more40h_nat_masc_pop'/`=hours_nat_masc_pop') E53 = (`=more40h_migr_masc_pop'/`=hours_migr_masc_pop')  // Working hours: long (more than 40) hours	

	putexcel C54 = (`=more50h_nat_masc_pop'/`=hours_nat_masc_pop') E54 = (`=more50h_migr_masc_pop'/`=hours_migr_masc_pop')  // Working hours: long (more than 50) hours
	
	putexcel C55 = (`=more55h_nat_masc_pop'/`=hours_nat_masc_pop') E55 = (`=more55h_migr_masc_pop'/`=hours_migr_masc_pop')  // Working hours: long (more than 55) hours
	
	putexcel C56 = (`=less30h_nat_masc_pop'/`=hours_nat_masc_pop') E56 = (`=less30h_migr_masc_pop'/`=hours_migr_masc_pop')  // Working hours: long (less than 30) hours	
	
	putexcel C57 = (`=highSkill_nat_masc_pop'/`=NotMili_nat_masc_pop') E57 = (`=highSkill_migr_masc_pop'/`=NotMili_migr_masc_pop') // Job skills: share of working population in highly skilled jobs
	
	putexcel C58 = (`=lowSkill_nat_masc_pop'/`=NotMili_nat_masc_pop') E58 = (`=lowSkill_migr_masc_pop'/`=NotMili_migr_masc_pop') // Job skills: share of working population in low-skilled jobs 
		
	putexcel C59 = (`=overquali_nat_masc_pop'/`=NotEduNotMili_nat_masc_pop') E59 = (`=overquali_migr_masc_pop'/`=NotEduNotMili_migr_masc_pop') // Overqualification: share of highly educated individuals who work in low- or medium-skilled jobs

	putexcel C60 = (`=selfEmp_nat_masc_pop'/`=Notagri_emp1564_nat_masc_pop') E60 = (`=selfEmp_migr_masc_pop'/`=Notagri_emp1564_migr_masc_pop')   // Self-employment: share of population who work in their own firms or businesses
	
	putexcel C61 = (`=pubSec_nat_masc_pop'/`=NoSelf15to64_nat_masc_pop') E61 = (`=pubSec_migr_masc_pop'/`=NoSelf15to64_migr_masc_pop')   // Employment in the public sector
	
	putexcel C62 = (`=nmwage_nat_masc_')  E62 = (`=nmwage_migr_masc_') // Nominal monthly wage (USD)
	
	* Child labour
	
	
	** EDUCATION AND SKILLS
		
	putexcel C69 = (`=ISCED58_nat_masc_pop'/`=ISCEDEdu_nat_masc_pop') E69 = (`=ISCED58_migr_masc_pop'/`=ISCEDEdu_migr_masc_pop') // Level of educational attainment: high (ISCED groups 5-8)
		
	putexcel C70 = (`=ISCED02_nat_masc_pop'/`=ISCEDEdu_nat_masc_pop') E70 = (`=ISCED02_migr_masc_pop'/`=ISCEDEdu_migr_masc_pop') // Level of educational attainment: low (ISCED groups 0-2)
		
	putexcel C71 = (`=ISCED01_nat_masc_pop'/`=ISCEDEdu_nat_masc_pop') E71 = (`=ISCED01_migr_masc_pop'/`=ISCEDEdu_migr_masc_pop') // Level of educational attainment: very low (ISCED groups 0-1)
		
	putexcel C72 = (`=literacy_nat_masc_pop'/`=pop_nat_masc_1664') E72 = (`=literacy_migr_masc_pop'/`=pop_migr_masc_1664') // Literacy: knows how to read and write
	
	putexcel C73 = (`=NoEmpNoedu_nat_masc_pop'/`=age1534_nat_masc_pop') E73 = (`=NoEmpNoedu_migr_masc_pop'/`=age1534_migr_masc_pop')   // Neither in employment, education or training for youth
	
	putexcel C74 = (`=earlyLeft_nat_masc_pop'/`=earlyAge_nat_masc_pop') E74 = (`=earlyLeft_migr_masc_pop'/`=earlyAge_migr_masc_pop')  // Early school leaving
	
	putexcel C75 = (`=attending_5to16_nat_masc_pop'/`=pop_nat_masc_516') E75 = (`=attending_5to16_migr_masc_pop'/`=pop_migr_masc_516')  // Share of children attending schooling, 5 - 16 years group
	
	** CHILDREN EDUCATION AND EMPLOYMENT	
	
	putexcel C79 = (`=attending_15to18_nat_masc_pop'/`=pop_nat_masc_1518') E79 = (`=attending_15to18_migr_masc_pop'/`=pop_migr_masc_1518')  // Share of children attending school (15-18 year-olds)
	
	putexcel C80 = (`=employment_15to18_nat_masc_pop'/`=pop_nat_masc_1518') E80 = (`=employment_15to18_migr_masc_pop'/`=pop_migr_masc_1518')  // Share of children in employment (15-18 year-olds)
	
	putexcel C81 = (`=AttOnly_15to18_nat_masc_pop'/`=pop_nat_masc_1518') E81 = (`=AttOnly_15to18_migr_masc_pop'/`=pop_migr_masc_1518')  // Share of children attending school only (15-18 year-olds)
	
	putexcel C82 = (`=EmpOnly_15to18_nat_masc_pop'/`=pop_nat_masc_1518') E82 = (`=EmpOnly_15to18_migr_masc_pop'/`=pop_migr_masc_1518')  // Share of children in employment only (15-18 year-olds)
	
	putexcel C83 = (`=Att_Emp_1518_nat_masc_pop'/`=pop_nat_masc_1518') E83 = (`=Att_Emp_1518_migr_masc_pop'/`=pop_migr_masc_1518')  // Share of children attending school & in employment (15-18 year-olds)
	
	putexcel C84 = (`=NiNi_15to18_nat_masc_pop'/`=pop_nat_masc_1518') E84 = (`=NiNi_15to18_migr_masc_pop'/`=pop_migr_masc_1518')  // Neither in employment, education or training for youth (15-18 year-olds)
	
	**HEALTH
	
	* Health problems
	
	putexcel C91 = (`=healthSys_nat_masc_pop'/`=job15to64_nat_masc_pop') E91 = (`=healthSys_migr_masc_pop'/`=job15to64_migr_masc_pop') // Access to health services AMONG working pop
	
	** SIMPLE CHARACTERISTICS
	
	putexcel C96 = (`=survey_nat_masc_pop') E96 = (`=survey_migr_masc_pop') // Total sample size: persons
	
	putexcel C97 = (`=survey_nat_masc_15to64') E97 = (`=survey_migr_masc_15to64') // Total sample size: persons 15-64
	
	putexcel C99 = (`=nat_masc_pop') E99 = (`=migr_masc_pop') // Total population (with sample loadings)
	
	putexcel C100 = (`=total_nat_masc_15to64') E100 = (`=total_migr_masc_15to64') // Total persons 15-64 (with sample loadings)
	
** POPULATION
	
	putexcel D6 = (`=nat_fem_pop'/`=tot_fem_pop') F6 = (`=migr_fem_pop'/`=tot_fem_pop')	// Share of population
	
	putexcel D7 = (`=workAge_nat_fem_pop'/`=workAge_fem_pop') F7 = (`=workAge_migr_fem_pop'/`=workAge_fem_pop') // Share of working age population (15-64)
	
	putexcel D8 = (`=econoAct_nat_fem_pop'/`=econoAct_fem_pop') F8 = (`=econoAct_migr_fem_pop'/`=econoAct_fem_pop') // Share of labour force population (15-64)
	
	putexcel D9 = (`=emp_nat_fem_pop'/`=emp_fem_pop') F9 = (`=emp_migr_fem_pop'/`=emp_fem_pop') // Share of Employment rate  (15-64)
	
	
	** DEMOGRAPHIC
	
	putexcel D17 = (`=pop_nat_fem_014'/`=nat_fem_pop') F17 = (`=pop_migr_fem_014'/`=migr_fem_pop') // 0 - 14
	
	putexcel D18 = (`=pop_nat_fem_1524'/`=nat_fem_pop') F18 = (`=pop_migr_fem_1524'/`=migr_fem_pop') // 15 - 24
	
	putexcel D19 = (`=pop_nat_fem_2539'/`=nat_fem_pop') F19 = (`=pop_migr_fem_2539'/`=migr_fem_pop') // 25 - 39
	
	putexcel D20 = (`=pop_nat_fem_4054'/`=nat_fem_pop') F20 = (`=pop_migr_fem_4054'/`=migr_fem_pop') // 40 - 54
	
	putexcel D21 = (`=pop_nat_fem_5564'/`=nat_fem_pop') F21 = (`=pop_migr_fem_5564'/`=migr_fem_pop') // 55 - 64
	
	putexcel D22 = (`=pop_nat_fem_65older'/`=nat_fem_pop') F22 = (`=pop_migr_fem_65older'/`=migr_fem_pop') // 65 Older
	
	putexcel D23 = (`=workAge_nat_fem_pop'/`=nat_fem_pop') F23 = (`=workAge_migr_fem_pop'/`=migr_fem_pop') // 15-64 
	
	*putexcel D25 = (`=male_nat_pop'/`=nat_pop') F25 = (`=male_migr_pop'/`=migr_pop') 	// Sex male
	
	putexcel D26 = (`=married_nat_fem_pop'/`=status_nat_fem_pop') F26 = (`=married_migr_fem_pop'/`=status_migr_fem_pop') // Marital status: married/cohabiting
	
	putexcel D27 = (`=separated_nat_fem_pop'/`=status_nat_fem_pop') F27 = (`=separated_migr_fem_pop'/`=status_migr_fem_pop') // Marital status: separated/divorced/widowed

	putexcel D28 = (`=single_nat_fem_pop'/`=status_nat_fem_pop') F28 = (`=single_migr_fem_pop'/`=status_migr_fem_pop') // Marital status: single
	
	putexcel D29 = (`=urban_nat_fem_pop'/`=nat_fem_pop') F29 = (`=urban_migr_fem_pop'/`=migr_fem_pop') // Urban
	
	putexcel D30 = (`=capital_nat_fem_pop'/`=nat_fem_pop')  F30 = (`=capital_migr_fem_pop'/`=migr_fem_pop') // Capital city located
	
	putexcel D31 = (`=borCity_nat_fem_pop'/`=nat_fem_pop')  F31 = (`=borCity_migr_fem_pop'/`=migr_fem_pop') // Border cities or region
	
	putexcel D34 = (`=size_nat_fem_house')  F34 = (`=size_migr_fem_house') // Household size
		
	putexcel D35 = (`=less18_nat_fem_house')  F35 = (`=less18_migr_fem_house') // Number of children <= 18 in household
		
	putexcel D36 = (`=less15_nat_fem_house')  F36 = (`=less15_migr_fem_house') // Number of children <= 15 in household
		
	// Number of natural-born children (women only)
	
	
	** LABOUR MARKET INDICATORS
	
	putexcel D41 = (`=job_nat_fem_pop'/`=workAge_nat_fem_pop') F41 = (`=job_migr_fem_pop'/`=workAge_migr_fem_pop') // Share of population with a job
	
	putexcel D42 = (`=econoAct_nat_fem_pop'/`=workAge_nat_fem_pop') F42 = (`=econoAct_migr_fem_pop'/`=workAge_migr_fem_pop') // Activity: Share participating in the labour force
	
	putexcel D43 = (`=inactive_nat_fem_pop'/`=workAge_nat_fem_pop') F43 = (`=inactive_migr_fem_pop'/`=workAge_migr_fem_pop')  // Economically inactive people
	
	putexcel D44 = (`=unemp_nat_fem_pop'/`=econoActWorkAge_nat_fem_pop') F44 = (`=unemp_migr_fem_pop'/`=econoActWorkAge_migr_fem_pop') // Unemployment: Share of population who were unemployed
	
	putexcel D45 = (`=long12_unemp_nat_fem_pop'/`=inac_unemp_nat_fem_pop') F45 = (`=long12_unemp_migr_fem_pop'/`=inac_unemp_migr_fem_pop') // Risk of labour market exclusion: long-term unemployment (12 month)
	
	putexcel D46 = (`=long6_unemp_nat_fem_pop'/`=inac_unemp_nat_fem_pop') F46 = (`=long6_unemp_migr_fem_pop'/`=inac_unemp_migr_fem_pop') // Risk of labour market exclusion: long-term unemployment (6 month)
	
	putexcel D47 = (`=involuntary_nat_fem_pop'/`=inac_unemp_nat_fem_pop') F47 = (`=involuntary_migr_fem_pop'/`=inac_unemp_migr_fem_pop') // Inactive involuntary (available past week, not looking for job)
	
	putexcel D48 = (`=long_invo_nat_fem_pop'/`=inac_unemp_nat_fem_pop') F48 = (`=long_invo_migr_fem_pop'/`=inac_unemp_migr_fem_pop') // Long-term uemployment >=12 months or inactive involuntary	
	
	putexcel D49 = (`=written_nat_fem_pop'/`=noself_edu_nat_fem_pop') F49 = (`=written_migr_fem_pop'/`=noself_edu_migr_fem_pop') // Share of population with written contract
	
	putexcel D50 = (`=informal_nat_fem_pop'/`=workAge_nat_fem_pop') F50 = (`=informal_migr_fem_pop'/`=workAge_migr_fem_pop') // Share of population with an informal job	
	
    // Share of population with an informal job (OECD def)
	
	putexcel D52 = (`=tempJob_nat_fem_pop'/`=noself_edu_nat_fem_pop') F52 = (`=tempJob_migr_fem_pop'/`=noself_edu_migr_fem_pop') // Types of contracts: Share of population in temporary contracts	
	
	putexcel D53 = (`=more40h_nat_fem_pop'/`=hours_nat_fem_pop') F53 = (`=more40h_migr_fem_pop'/`=hours_migr_fem_pop')  // Working hours: long (more than 40) hours	

	putexcel D54 = (`=more50h_nat_fem_pop'/`=hours_nat_fem_pop') F54 = (`=more50h_migr_fem_pop'/`=hours_migr_fem_pop')  // Working hours: long (more than 50) hours
	
	putexcel D55 = (`=more55h_nat_fem_pop'/`=hours_nat_fem_pop') F55 = (`=more55h_migr_fem_pop'/`=hours_migr_fem_pop')  // Working hours: long (more than 55) hours
	
	putexcel D56 = (`=less30h_nat_fem_pop'/`=hours_nat_fem_pop') F56 = (`=less30h_migr_fem_pop'/`=hours_migr_fem_pop')  // Working hours: long (less than 30) hours	
	
	putexcel D57 = (`=highSkill_nat_fem_pop'/`=NotMili_nat_fem_pop') F57 = (`=highSkill_migr_fem_pop'/`=NotMili_migr_fem_pop') // Job skills: share of working population in highly skilled jobs
	
	putexcel D58 = (`=lowSkill_nat_fem_pop'/`=NotMili_nat_fem_pop') F58 = (`=lowSkill_migr_fem_pop'/`=NotMili_migr_fem_pop') // Job skills: share of working population in low-skilled jobs 
		
	putexcel D59 = (`=overquali_nat_fem_pop'/`=NotEduNotMili_nat_fem_pop') F59 = (`=overquali_migr_fem_pop'/`=NotEduNotMili_migr_fem_pop') // Overqualification: share of highly educated individuals who work in low- or medium-skilled jobs

	putexcel D60 = (`=selfEmp_nat_fem_pop'/`=Notagri_emp1564_nat_fem_pop') F60 = (`=selfEmp_migr_fem_pop'/`=Notagri_emp1564_migr_fem_pop')   // Self-employment: share of population who work in their own firms or businesses
	
	putexcel D61 = (`=pubSec_nat_fem_pop'/`=NoSelf15to64_nat_fem_pop') F61 = (`=pubSec_migr_fem_pop'/`=NoSelf15to64_migr_fem_pop')   // Employment in the public sector
	
	putexcel D62 = (`=nmwage_nat_fem_')  F62 = (`=nmwage_migr_fem_') // Nominal monthly wage (USD)
	
	* Child labour
	
	
	** EDUCATION AND SKILLS
		
	putexcel D69 = (`=ISCED58_nat_fem_pop'/`=ISCEDEdu_nat_fem_pop') F69 = (`=ISCED58_migr_fem_pop'/`=ISCEDEdu_migr_fem_pop') // Level of educational attainment: high (ISCED groups 5-8)
		
	putexcel D70 = (`=ISCED02_nat_fem_pop'/`=ISCEDEdu_nat_fem_pop') F70 = (`=ISCED02_migr_fem_pop'/`=ISCEDEdu_migr_fem_pop') // Level of educational attainment: low (ISCED groups 0-2)
		
	putexcel D71 = (`=ISCED01_nat_fem_pop'/`=ISCEDEdu_nat_fem_pop') F71 = (`=ISCED01_migr_fem_pop'/`=ISCEDEdu_migr_fem_pop') // Level of educational attainment: very low (ISCED groups 0-1)
		
	putexcel D72 = (`=literacy_nat_fem_pop'/`=pop_nat_fem_1664') F72 = (`=literacy_migr_fem_pop'/`=pop_migr_fem_1664') // Literacy: knows how to read and write
	
	putexcel D73 = (`=NoEmpNoedu_nat_fem_pop'/`=age1534_nat_fem_pop') F73 = (`=NoEmpNoedu_migr_fem_pop'/`=age1534_migr_fem_pop')   // Neither in employment, education or training for youth
	
	putexcel D74 = (`=earlyLeft_nat_fem_pop'/`=earlyAge_nat_fem_pop') F74 = (`=earlyLeft_migr_fem_pop'/`=earlyAge_migr_fem_pop')  // Early school leaving
	
	putexcel D75 = (`=attending_5to16_nat_fem_pop'/`=pop_nat_fem_516') F75 = (`=attending_5to16_migr_fem_pop'/`=pop_migr_fem_516')  // Share of children attending schooling, 5 - 16 years group
	
	** CHILDREN EDUCATION AND EMPLOYMENT	
	
	putexcel D79 = (`=attending_15to18_nat_fem_pop'/`=pop_nat_fem_1518') F79 = (`=attending_15to18_migr_fem_pop'/`=pop_migr_fem_1518')  // Share of children attending school (15-18 year-olds)
	
	putexcel D80 = (`=employment_15to18_nat_fem_pop'/`=pop_nat_fem_1518') F80 = (`=employment_15to18_migr_fem_pop'/`=pop_migr_fem_1518')  // Share of children in employment (15-18 year-olds)
	
	putexcel D81 = (`=AttOnly_15to18_nat_fem_pop'/`=pop_nat_fem_1518') F81 = (`=AttOnly_15to18_migr_fem_pop'/`=pop_migr_fem_1518')  // Share of children attending school only (15-18 year-olds)
	
	putexcel D82 = (`=EmpOnly_15to18_nat_fem_pop'/`=pop_nat_fem_1518') F82 = (`=EmpOnly_15to18_migr_fem_pop'/`=pop_migr_fem_1518')  // Share of children in employment only (15-18 year-olds)
	
	putexcel D83 = (`=Att_Emp_1518_nat_fem_pop'/`=pop_nat_fem_1518') F83 = (`=Att_Emp_1518_migr_fem_pop'/`=pop_migr_fem_1518')  // Share of children attending school & in employment (15-18 year-olds)
	
	putexcel D84 = (`=NiNi_15to18_nat_fem_pop'/`=pop_nat_fem_1518') F84 = (`=NiNi_15to18_migr_fem_pop'/`=pop_migr_fem_1518')  // Neither in employment, education or training for youth (15-18 year-olds)
	
	**HEALTH
	
	* Health problems
	
	putexcel D91 = (`=healthSys_nat_fem_pop'/`=job15to64_nat_fem_pop') F91 = (`=healthSys_migr_fem_pop'/`=job15to64_migr_fem_pop') // Access to health services AMONG working pop
	
	** SIMPLE CHARACTERISTICS
	
	putexcel D96 = (`=survey_nat_fem_pop') F96 = (`=survey_migr_fem_pop') // Total sample size: persons
	
	putexcel D97 = (`=survey_nat_fem_15to64') F97 = (`=survey_migr_fem_15to64') // Total sample size: persons 15-64
	
	putexcel D99 = (`=nat_fem_pop') F99 = (`=migr_fem_pop') // Total population (with sample loadings)
	
	putexcel D100 = (`=total_nat_fem_15to64') F100 = (`=total_migr_fem_15to64') // Total persons 15-64 (with sample loadings)

	
********************************************************************************
********************************************************************************
********************************************************************************
****** DOMINICAN REPUBLIC - HOUSEHOLD SURVEY ENCFT 2021
	
	clear all
	set more off, perm
	set maxvar 15000
	scalar drop _all

	****************************************************************************
	** DATASET
	cd "C:\Users\jcamilop\OneDrive - Inter-American Development Bank Group\OECD\01 Raw"
	use "DOM_2021s1_BID.dta", replace

	gen uno=1
	replace factor_ci=round(factor_ci/2) // Applies when the expansion factor is a non-integer number or not annual data.
	
	****************************************************************************
	** LOCALS
		local 1_label = "migr"
		local 0_label = "nat"
		
		local 1_sexo = "masc_"
		local 2_sexo = "fem_"
		
	****************************************************************************
	** ISCED
	gen ISCED = 0 if inlist(nivel_ultimo_ano_aprobado, 1, 9)
	replace ISCED = 1 if inlist(mayor_nivel_obtenido, 2, 10)
	replace ISCED = 2 if (inlist(curso_matriculado, 1, 2) & nivel_ultimo_ano_aprobado == 3)
	replace ISCED = 3 if curso_matriculado == 3 & nivel_ultimo_ano_aprobado == 3
	replace ISCED = 4 if curso_matriculado == 4	
	replace ISCED = 6 if nivel_ultimo_ano_aprobado == 5
	replace ISCED = 7 if inlist(nivel_ultimo_ano_aprobado, 6, 7)
	replace ISCED = 8 if nivel_ultimo_ano_aprobado == 8
	
	****************************************************************************
	** JOB QUALIFICATIONS - ISCO
	gen ISCO = real(substr(string(ocupacion_principal_cod, "%5.0g"), 1, 1))
	gen length = strlen(string(ocupacion_principal_cod))
	replace ISCO = 0 if length == 3	
	gen overqualificated = 1 if inrange(ISCED,5,8) & inrange(ISCO,4,9)
	gen low_skilled = 1 if ISCO==9
	gen high_skilled = 1 if inrange(ISCO,1,3)

	****************************************************************************
	** Household size
	by idh_ch, sort: egen nmiembros=sum(relacion_ci>=1 & relacion_ci<5)
	by idh_ch, sort: egen nmenor18=sum((relacion_ci>=1 & relacion_ci<=4) & edad_ci<18)
	by idh_ch, sort: egen nmenor15=sum((relacion_ci>=1 & relacion_ci<=4) & edad_ci<15)
		
	****************************************************************************
	** Informality
	gen informal = 1 if afiliado_ci != 1 & emp_ci==1
	
	****************************************************************************
	** Working hours
	gen more_40 = 1 if horastot_ci >= 40
	replace more_40 = . if horastot_ci == .
	gen more_50 = 1 if horastot_ci >= 50
	replace more_50 = . if horastot_ci == .
	gen more_55 = 1 if horastot_ci >= 55
	replace more_55 = . if horastot_ci == .
	gen less_30 = 1 if horastot_ci <= 30
	replace less_30 = . if horastot_ci == .
	gen by_hours = 1 if emp_ci == 1
	replace by_hours = . if horastot_ci == .
	
	****************************************************************************
	** Nominal monthly wage (USD)
	by idh_ch, sort: egen nmwage=mean(ylm_ci + ylnm_ch)
	replace nmwage = (nmwage)/22.91
	
	****************************************************************************
	** Months of unemployment
	gen more_12 = 1 if durades_ci>=12
	replace more_12 = . if durades_ci == .
	gen more_6 = 1 if durades_ci>=6
	replace more_6 = . if durades_ci == .
	
********************************************************************* STATISTICS
********************************************************************************
********************************************************************************

	** CALCULATION OF INDICATORS
	
	** POPULATION
	
	* Total population calculated according to expansion factor
	sum uno if migrante_ci!=. & sexo_ci == 1 [fw=factor_ci]
	scalar tot_masc_pop = `=r(N)'
	
	* Migrant population calculated according to expansion factor
	sum uno if migrante_ci==1 & sexo_ci == 1 [fw=factor_ci]
	scalar migr_masc_pop = `=r(N)'
	
	* Native population calculated according to expansion factor
	sum uno if migrante_ci==0 & sexo_ci == 1 [fw=factor_ci]
	scalar nat_masc_pop = `=r(N)'
	
	* Total population calculated according to expansion factor
	sum uno if migrante_ci!=. & sexo_ci == 2 [fw=factor_ci]
	scalar tot_fem_pop = `=r(N)'
	
	* Migrant population calculated according to expansion factor
	sum uno if migrante_ci==1 & sexo_ci == 2 [fw=factor_ci]
	scalar migr_fem_pop = `=r(N)'
	
	* Native population calculated according to expansion factor
	sum uno if migrante_ci==0 & sexo_ci == 2 [fw=factor_ci]
	scalar nat_fem_pop = `=r(N)'
	
	* Share of working age population (15-64) Male
	sum uno if inrange(edad_ci,15,64) & migrante_ci==1 & sexo_ci == 1 [fw=factor_ci]
	scalar workAge_migr_masc_pop = `=r(N)'
	sum uno if inrange(edad_ci,15,64) & migrante_ci==0 & sexo_ci == 1 [fw=factor_ci]
	scalar workAge_nat_masc_pop = `=r(N)'
	sum uno if inrange(edad_ci,15,64) & sexo_ci == 1 [fw=factor_ci]
	scalar workAge_masc_pop = `=r(N)'
		
	* Share of labour force population (15-64) Male
	sum uno if inrange(edad_ci,15,64) & pea_ci == 1 & migrante_ci==1 & sexo_ci == 1 [fw=factor_ci]
	scalar econoAct_migr_masc_pop = `=r(N)'
	sum uno if inrange(edad_ci,15,64) & pea_ci == 1 & migrante_ci==0 & sexo_ci == 1 [fw=factor_ci]
	scalar econoAct_nat_masc_pop = `=r(N)'
	sum uno if inrange(edad_ci,15,64) & pea_ci == 1 & sexo_ci == 1 [fw=factor_ci]
	scalar econoAct_masc_pop = `=r(N)'
	
	* Share of Employment rate  (15-64) Male
	sum uno if inrange(edad_ci,15,64) & emp_ci == 1 & migrante_ci==1 & sexo_ci == 1 [fw=factor_ci]
	scalar emp_migr_masc_pop = `=r(N)'
	sum uno if inrange(edad_ci,15,64) & emp_ci == 1 & migrante_ci==0 & sexo_ci == 1 [fw=factor_ci]
	scalar emp_nat_masc_pop = `=r(N)'
	sum uno if inrange(edad_ci,15,64) & emp_ci == 1 & sexo_ci == 1 [fw=factor_ci]
	scalar emp_masc_pop = `=r(N)'
	
	* Share of working age population (15-64) Female
	sum uno if inrange(edad_ci,15,64) & migrante_ci==1 & sexo_ci == 2 [fw=factor_ci]
	scalar workAge_migr_fem_pop = `=r(N)'
	sum uno if inrange(edad_ci,15,64) & migrante_ci==0 & sexo_ci == 2 [fw=factor_ci]
	scalar workAge_nat_fem_pop = `=r(N)'
	sum uno if inrange(edad_ci,15,64) & sexo_ci == 2 [fw=factor_ci]
	scalar workAge_fem_pop = `=r(N)'
		
	* Share of labour force population (15-64) Female
	sum uno if inrange(edad_ci,15,64) & pea_ci == 1 & migrante_ci==1 & sexo_ci == 2 [fw=factor_ci]
	scalar econoAct_migr_fem_pop = `=r(N)'
	sum uno if inrange(edad_ci,15,64) & pea_ci == 1 & migrante_ci==0 & sexo_ci == 2 [fw=factor_ci]
	scalar econoAct_nat_fem_pop = `=r(N)'
	sum uno if inrange(edad_ci,15,64) & pea_ci == 1 & sexo_ci == 2 [fw=factor_ci]
	scalar econoAct_fem_pop = `=r(N)'
	
	* Share of Employment rate  (15-64) Female
	sum uno if inrange(edad_ci,15,64) & emp_ci == 1 & migrante_ci==1 & sexo_ci == 2 [fw=factor_ci]
	scalar emp_migr_fem_pop = `=r(N)'
	sum uno if inrange(edad_ci,15,64) & emp_ci == 1 & migrante_ci==0 & sexo_ci == 2 [fw=factor_ci]
	scalar emp_nat_fem_pop = `=r(N)'
	sum uno if inrange(edad_ci,15,64) & emp_ci == 1 & sexo_ci == 2 [fw=factor_ci]
	scalar emp_fem_pop = `=r(N)'
	

	** CALCULATION OF INDICATORS BY MIGRANTS AND NATIVES
	
	foreach var in 1 0 {
		
		foreach sexo in 1 2 {
		
		** DEMOGRAPHIC
		
		* Age groups
		
		sum uno if inrange(edad_ci,0,14) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar pop_``var'_label'_``sexo'_sexo'014 = `=r(N)' // 0 - 14 years
		
		sum uno if inrange(edad_ci,15,24) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar pop_``var'_label'_``sexo'_sexo'1524 = `=r(N)' // 15 - 24 years

		sum uno if inrange(edad_ci,25,39) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar pop_``var'_label'_``sexo'_sexo'2539 = `=r(N)' // 25 - 39 years
		
		sum uno if inrange(edad_ci,40,54) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar pop_``var'_label'_``sexo'_sexo'4054 = `=r(N)' // 40 - 54 years

		sum uno if inrange(edad_ci,55,64) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar pop_``var'_label'_``sexo'_sexo'5564 = `=r(N)'	//55 - 64 years
		
		sum uno if inrange(edad_ci,65,.) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar pop_``var'_label'_``sexo'_sexo'65older = `=r(N)'  // 65 older years
		
		* Sex male population
		sum uno if sexo_ci==1 & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar male_``var'_label'_``sexo'_sexo'pop =`=r(N)'
		
		* Marital status: married/cohabiting
		sum uno if civil_ci==2 & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar married_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		sum uno if civil_ci!=. & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar status_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		* Marital status: separated/divorced/widowed
		sum uno if (civil_ci==3 | civil_ci==4) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar separated_``var'_label'_``sexo'_sexo'pop = `=r(N)'	
		
		* Marital status: single
		sum uno if civil_ci==1 & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar single_``var'_label'_``sexo'_sexo'pop = `=r(N)'	
		
		* Urban
		sum uno if zona_c==1 & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar urban_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		* Capital city located
		sum uno if (region_c==1 | region_c==32) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar capital_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		* Border cities or region
		sum uno if inlist(region_c, 5, 7, 15, 16) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar borCity_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		* Household size
		sum nmiembros if migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar size_``var'_label'_``sexo'_sexo'house = `=r(mean)'			
		
		* Number of children <= 18 in household
		sum nmenor18 if migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar less18_``var'_label'_``sexo'_sexo'house = `=r(mean)'			
		
		* Number of children <= 15 in household
		sum nmenor15 if migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar less15_``var'_label'_``sexo'_sexo'house = `=r(mean)'
		
		* Number of natural-born children (women only)
		
		
		** LABOUR MARKET INDICATORS
		
		* Share of population with a job
		sum uno if inrange(edad_ci,15,64) & emp_ci==1 & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar job_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		* Activity: Share participating in the labour force
		sum uno if inrange(edad_ci,15,64) & pea_ci==1 & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar econoAct_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		* Economically inactive people
		sum uno if inrange(edad_ci,15,64) & (condocup_ci == 3) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci] 
		scalar inactive_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		* Unemployment: Share of population who were unemployed
		sum uno if inrange(edad_ci,15,64) & desemp_ci==1 & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci] 
		scalar unemp_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		sum uno if (pea_ci==1 | asiste_ci==1) & inrange(edad_ci,15,64) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar econoActWorkAge_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		* Risk of labour market exclusion: long-term unemployment (12 months)
		sum uno if inrange(edad_ci,15,64) & (more_12==1 & desemp_ci==1) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar long12_unemp_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		sum uno if inrange(edad_ci,15,64) & (desemp_ci==1 | condocup_ci==3) & durades_ci!=. & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci] 
		scalar inac_unemp_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		* Risk of labour market exclusion: long-term unemployment (6 months)
		sum uno if inrange(edad_ci,15,64) & (more_6==1 & desemp_ci==1) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar long6_unemp_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		* Risk of labour market exclusion: long-term uemployment >=12 months or inactive involuntary
		sum uno if inrange(edad_ci,15,64) & (desalent_ci==1 | (more_12==1 & desemp_ci==1)) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar long_invo_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		* Risk of labour market exclusion: Inactive involuntary (available past week, not looking for job)
		sum uno if inrange(edad_ci,15,64) & desalent_ci==1 & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar involuntary_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		* Share of population with written contract
		sum uno if inrange(edad_ci,15,64) & inlist(tipocontrato_ci,0,1,2) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar written_``var'_label'_``sexo'_sexo'pop = `=r(N)'		
		
		* Share of population with an informal job
		sum uno if inrange(edad_ci,15,64) & formal_ci==0 & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar informal_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		* Types of contracts:  Share of population in temporary contracts
		sum uno if inrange(edad_ci,15,64) & (tipocontrato_ci==2 | tipocontrato_ci==3) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci] 
		scalar tempJob_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		sum uno if inrange(edad_ci,15,64) & categopri_ci!=2 & asiste_ci!=1 & emp_ci==1 & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar noself_edu_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		* Working hours: long hours >= 40
		sum uno if inrange(edad_ci,15,64) & more_40==1 & emp_ci == 1 & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar more40h_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		sum uno if inrange(edad_ci,15,64) & by_hours==1 & emp_ci == 1 & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar hours_``var'_label'_``sexo'_sexo'pop = `=r(N)'

		* Working hours: long hours >= 50
		sum uno if inrange(edad_ci,15,64) & more_50==1 & emp_ci == 1 & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar more50h_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		* Working hours: long hours >= 55
		sum uno if inrange(edad_ci,15,64) & more_55==1 & emp_ci == 1 & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar more55h_``var'_label'_``sexo'_sexo'pop = `=r(N)'		
	
		* Working hours: long hours < 30
		sum uno if inrange(edad_ci,15,64) & less_30==1 & emp_ci == 1 & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar less30h_``var'_label'_``sexo'_sexo'pop = `=r(N)'

		* Job skills: share of working population in highly skilled jobs
		sum uno if high_skilled==1 & inrange(edad_ci,15,64) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar highSkill_``var'_label'_``sexo'_sexo'pop = `=r(N)'		
		
		* Job skills: share of working population in low-skilled jobs
		sum uno if low_skilled==1 & inrange(edad_ci,15,64) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar lowSkill_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		sum uno if emp_ci==1 & inrange(edad_ci,15,64) & ISCO!=0 & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar NotMili_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		* Overqualification: share of highly educated individuals who work in low- or medium-skilled jobs
		sum uno if overqualificated==1 & inrange(edad_ci,15,64) & migrante_ci==`var' & sexo_ci==`sexo' & inrange(ISCED,4,9) [fw=factor_ci]
		scalar overquali_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		sum uno if emp_ci==1 & inrange(edad_ci,15,64) & asiste_ci!=1 & ISCO!=0 & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar NotEduNotMili_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		* Self-employment: share of population who works in their own firms or businesses
		sum uno if (categopri_ci==1 | categopri_ci==2) & inrange(edad_ci,15,64) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar selfEmp_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		sum uno if inrange(edad_ci,15,64) & rama_ci!=1 & emp_ci==1 & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar Notagri_emp1564_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		* Employment in the public sector
		sum uno if spublico_ci==1 & inrange(edad_ci,15,64) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar pubSec_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		sum uno if inrange(edad_ci,15,64) & emp_ci==1 & categopri_ci!=2 & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar NoSelf15to64_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		* Nominal monthly wage (USD)
		sum nmwage if migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar nmwage_``var'_label'_``sexo'_sexo' = `=r(mean)'
		
		* Child labour
		

		** EDUCATION AND SKILLS
		
		* Level of educational attainment: high (ISCED groups 5-8)
		sum uno if inrange(ISCED,5,8) & inrange(edad_ci,15,64) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar ISCED58_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		sum uno if inrange(edad_ci,15,64) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar ISCEDEdu_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		* Level of educational attainment: low (ISCED groups 0-2)
		sum uno if inrange(ISCED,0,2) & inrange(edad_ci,15,64) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar ISCED02_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		* Level of educational attainment: very low (ISCED groups 0-1)
		sum uno if inrange(ISCED,0,1) & inrange(edad_ci,15,64) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar ISCED01_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		* Literacy: knows how to read and write 
		sum uno if sabe_leer_escribir == 1 & inrange(edad_ci,16,64) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar literacy_``var'_label'_``sexo'_sexo'pop = `=r(N)'		
		
		sum uno if inrange(edad_ci,16,64) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci] 
		scalar pop_``var'_label'_``sexo'_sexo'1664 = `=r(N)'
		
		* Neither in employment, education or training for youth
		sum uno if (edad_ci>=15 & edad_ci <=34) & emp_ci!=1 & asiste_ci==0 & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar NoEmpNoedu_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		sum uno if inrange(edad_ci,15,34) & migrante_ci==`var' [fw=factor_ci]
		scalar age1534_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		* Early school leaving
		sum uno if asiste_ci == 0 & (edad_ci>=15 & edad_ci <=24) & inlist(ISCED,0,1,2) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar earlyLeft_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		sum uno if inrange(edad_ci,15,24) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar earlyAge_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		* Share of children attending schooling, 5 - 16 years group
		sum uno if asiste_ci==1 & inrange(edad_ci,5,16) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar attending_5to16_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		sum uno if inrange(edad_ci,5,16) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci] 
		scalar pop_``var'_label'_``sexo'_sexo'516 = `=r(N)'
		
		** CHILDREN EDUCATION AND EMPLOYMENT
		
		* Share of children attending school (15-18 year-olds)
		sum uno if asiste_ci==1 & inrange(edad_ci,15,18) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar attending_15to18_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		sum uno if inrange(edad_ci,15,18) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci] 
		scalar pop_``var'_label'_``sexo'_sexo'1518 = `=r(N)'
		
		* Share of children in employment (15-18 year-olds)
		sum uno if emp_ci==1 & inrange(edad_ci,15,18) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar employment_15to18_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		* Share of children attending school only (15-18 year-olds)
		sum uno if (asiste_ci==1 & emp_ci!=1) & inrange(edad_ci,15,18) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar AttOnly_15to18_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		* Share of children in employment only (15-18 year-olds)
		sum uno if (emp_ci==1 & asiste_ci!=1) & inrange(edad_ci,15,18) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar EmpOnly_15to18_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		* Share of children attending school & in employment (15-18 year-olds)
		sum uno if (asiste_ci==1 & emp_ci==1) & inrange(edad_ci,15,18) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar Att_Emp_1518_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		* Neither in employment, education or training for youth (15-18 year-olds)
		sum uno if (edad_ci>=15 & edad_ci <=18) & emp_ci==0 & asiste_ci==0 & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar NiNi_15to18_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		** HEALTH
		
		* Access to health services AMONG working pop
		sum uno if inrange(edad_ci,15,64) & (afiliado_ci==1 | cotizando_ci==1) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci] 
		scalar healthSys_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		sum uno if inrange(edad_ci,15,64) & emp_ci==1 & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar job15to64_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		** SAMPLE CHARACTERISTICS
		
		* Total sample size: persons 
		sum uno if migrante_ci==`var' & sexo_ci==`sexo'
		scalar survey_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		* Total sample size: persons 15-64
		sum uno if inrange(edad_ci,15,64) & migrante_ci==`var' & sexo_ci==`sexo'
		scalar survey_``var'_label'_``sexo'_sexo'15to64 = `=r(N)'

		* Total persons 15-64 (with sample loadings)
		sum uno if inrange(edad_ci,15,64) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar total_``var'_label'_``sexo'_sexo'15to64 = `=r(N)'
		
	}
	
		}
	
******************************************************** EXCEL OUTPUTS

	putexcel set "C:\Users\jcamilop\OneDrive - Inter-American Development Bank Group\OECD\03 Outputs\Resultados por sexo.xlsx", sheet("Dominican Rep.") modify
	putexcel describe
	
	
	** POPULATION
	
	putexcel C6 = (`=nat_masc_pop'/`=tot_masc_pop') E6 = (`=migr_masc_pop'/`=tot_masc_pop')	// Share of population
	
	putexcel C7 = (`=workAge_nat_masc_pop'/`=workAge_masc_pop') E7 = (`=workAge_migr_masc_pop'/`=workAge_masc_pop') // Share of working age population (15-64)
	
	putexcel C8 = (`=econoAct_nat_masc_pop'/`=econoAct_masc_pop') E8 = (`=econoAct_migr_masc_pop'/`=econoAct_masc_pop') // Share of labour force population (15-64)
	
	putexcel C9 = (`=emp_nat_masc_pop'/`=emp_masc_pop') E9 = (`=emp_migr_masc_pop'/`=emp_masc_pop') // Share of Employment rate  (15-64)
	
	
	** DEMOGRAPHIC
	
	putexcel C17 = (`=pop_nat_masc_014'/`=nat_masc_pop') E17 = (`=pop_migr_masc_014'/`=migr_masc_pop') // 0 - 14
	
	putexcel C18 = (`=pop_nat_masc_1524'/`=nat_masc_pop') E18 = (`=pop_migr_masc_1524'/`=migr_masc_pop') // 15 - 24
	
	putexcel C19 = (`=pop_nat_masc_2539'/`=nat_masc_pop') E19 = (`=pop_migr_masc_2539'/`=migr_masc_pop') // 25 - 39
	
	putexcel C20 = (`=pop_nat_masc_4054'/`=nat_masc_pop') E20 = (`=pop_migr_masc_4054'/`=migr_masc_pop') // 40 - 54
	
	putexcel C21 = (`=pop_nat_masc_5564'/`=nat_masc_pop') E21 = (`=pop_migr_masc_5564'/`=migr_masc_pop') // 55 - 64
	
	putexcel C22 = (`=pop_nat_masc_65older'/`=nat_masc_pop') E22 = (`=pop_migr_masc_65older'/`=migr_masc_pop') // 65 Older
	
	putexcel C23 = (`=workAge_nat_masc_pop'/`=nat_masc_pop') E23 = (`=workAge_migr_masc_pop'/`=migr_masc_pop') // 15-64 
	
	*putexcel C25 = (`=male_nat_pop'/`=nat_pop') E25 = (`=male_migr_pop'/`=migr_pop') 	// Sex male
	
	putexcel C26 = (`=married_nat_masc_pop'/`=status_nat_masc_pop') E26 = (`=married_migr_masc_pop'/`=status_migr_masc_pop') // Marital status: married/cohabiting
	
	putexcel C27 = (`=separated_nat_masc_pop'/`=status_nat_masc_pop') E27 = (`=separated_migr_masc_pop'/`=status_migr_masc_pop') // Marital status: separated/divorced/widowed

	putexcel C28 = (`=single_nat_masc_pop'/`=status_nat_masc_pop') E28 = (`=single_migr_masc_pop'/`=status_migr_masc_pop') // Marital status: single
	
	putexcel C29 = (`=urban_nat_masc_pop'/`=nat_masc_pop') E29 = (`=urban_migr_masc_pop'/`=migr_masc_pop') // Urban
	
	putexcel C30 = (`=capital_nat_masc_pop'/`=nat_masc_pop')  E30 = (`=capital_migr_masc_pop'/`=migr_masc_pop') // Capital city located
	
	putexcel C31 = (`=borCity_nat_masc_pop'/`=nat_masc_pop')  E31 = (`=borCity_migr_masc_pop'/`=migr_masc_pop') // Border cities or region
	
	putexcel C34 = (`=size_nat_masc_house')  E34 = (`=size_migr_masc_house') // Household size
		
	putexcel C35 = (`=less18_nat_masc_house')  E35 = (`=less18_migr_masc_house') // Number of children <= 18 in household
		
	putexcel C36 = (`=less15_nat_masc_house')  E36 = (`=less15_migr_masc_house') // Number of children <= 15 in household
		
	// Number of natural-born children (women only)
	
	
	** LABOUR MARKET INDICATORS
	
	putexcel C41 = (`=job_nat_masc_pop'/`=workAge_nat_masc_pop') E41 = (`=job_migr_masc_pop'/`=workAge_migr_masc_pop') // Share of population with a job
	
	putexcel C42 = (`=econoAct_nat_masc_pop'/`=workAge_nat_masc_pop') E42 = (`=econoAct_migr_masc_pop'/`=workAge_migr_masc_pop') // Activity: Share participating in the labour force
	
	putexcel C43 = (`=inactive_nat_masc_pop'/`=workAge_nat_masc_pop') E43 = (`=inactive_migr_masc_pop'/`=workAge_migr_masc_pop')  // Economically inactive people
	
	putexcel C44 = (`=unemp_nat_masc_pop'/`=econoActWorkAge_nat_masc_pop') E44 = (`=unemp_migr_masc_pop'/`=econoActWorkAge_migr_masc_pop') // Unemployment: Share of population who were unemployed
	
	putexcel C45 = (`=long12_unemp_nat_masc_pop'/`=inac_unemp_nat_masc_pop') E45 = (`=long12_unemp_migr_masc_pop'/`=inac_unemp_migr_masc_pop') // Risk of labour market exclusion: long-term unemployment (12 month)
	
	putexcel C46 = (`=long6_unemp_nat_masc_pop'/`=inac_unemp_nat_masc_pop') E46 = (`=long6_unemp_migr_masc_pop'/`=inac_unemp_migr_masc_pop') // Risk of labour market exclusion: long-term unemployment (6 month)
	
	putexcel C47 = (`=involuntary_nat_masc_pop'/`=inac_unemp_nat_masc_pop') E47 = (`=involuntary_migr_masc_pop'/`=inac_unemp_migr_masc_pop') // Inactive involuntary (available past week, not looking for job)
	
	putexcel C48 = (`=long_invo_nat_masc_pop'/`=inac_unemp_nat_masc_pop') E48 = (`=long_invo_migr_masc_pop'/`=inac_unemp_migr_masc_pop') // Long-term uemployment >=12 months or inactive involuntary	
	
	putexcel C49 = (`=written_nat_masc_pop'/`=noself_edu_nat_masc_pop') E49 = (`=written_migr_masc_pop'/`=noself_edu_migr_masc_pop') // Share of population with written contract
	
	putexcel C50 = (`=informal_nat_masc_pop'/`=job_nat_masc_pop') E50 = (`=informal_migr_masc_pop'/`=job_migr_masc_pop') // Share of population with an informal job	
	
    // Share of population with an informal job (OECD def)
	
	putexcel C52 = (`=tempJob_nat_masc_pop'/`=noself_edu_nat_masc_pop') E52 = (`=tempJob_migr_masc_pop'/`=noself_edu_migr_masc_pop') // Types of contracts: Share of population in temporary contracts	
	
	putexcel C53 = (`=more40h_nat_masc_pop'/`=hours_nat_masc_pop') E53 = (`=more40h_migr_masc_pop'/`=hours_migr_masc_pop')  // Working hours: long (more than 40) hours	

	putexcel C54 = (`=more50h_nat_masc_pop'/`=hours_nat_masc_pop') E54 = (`=more50h_migr_masc_pop'/`=hours_migr_masc_pop')  // Working hours: long (more than 50) hours
	
	putexcel C55 = (`=more55h_nat_masc_pop'/`=hours_nat_masc_pop') E55 = (`=more55h_migr_masc_pop'/`=hours_migr_masc_pop')  // Working hours: long (more than 55) hours
	
	putexcel C56 = (`=less30h_nat_masc_pop'/`=hours_nat_masc_pop') E56 = (`=less30h_migr_masc_pop'/`=hours_migr_masc_pop')  // Working hours: long (less than 30) hours	
	
	putexcel C57 = (`=highSkill_nat_masc_pop'/`=NotMili_nat_masc_pop') E57 = (`=highSkill_migr_masc_pop'/`=NotMili_migr_masc_pop') // Job skills: share of working population in highly skilled jobs
	
	putexcel C58 = (`=lowSkill_nat_masc_pop'/`=NotMili_nat_masc_pop') E58 = (`=lowSkill_migr_masc_pop'/`=NotMili_migr_masc_pop') // Job skills: share of working population in low-skilled jobs 
		
	putexcel C59 = (`=overquali_nat_masc_pop'/`=NotEduNotMili_nat_masc_pop') E59 = (`=overquali_migr_masc_pop'/`=NotEduNotMili_migr_masc_pop') // Overqualification: share of highly educated individuals who work in low- or medium-skilled jobs

	putexcel C60 = (`=selfEmp_nat_masc_pop'/`=Notagri_emp1564_nat_masc_pop') E60 = (`=selfEmp_migr_masc_pop'/`=Notagri_emp1564_migr_masc_pop')   // Self-employment: share of population who work in their own firms or businesses
	
	putexcel C61 = (`=pubSec_nat_masc_pop'/`=NoSelf15to64_nat_masc_pop') E61 = (`=pubSec_migr_masc_pop'/`=NoSelf15to64_migr_masc_pop')   // Employment in the public sector
	
	putexcel C62 = (`=nmwage_nat_masc_')  E62 = (`=nmwage_migr_masc_') // Nominal monthly wage (USD)
	
	* Child labour
	
	
	** EDUCATION AND SKILLS
		
	putexcel C69 = (`=ISCED58_nat_masc_pop'/`=ISCEDEdu_nat_masc_pop') E69 = (`=ISCED58_migr_masc_pop'/`=ISCEDEdu_migr_masc_pop') // Level of educational attainment: high (ISCED groups 5-8)
		
	putexcel C70 = (`=ISCED02_nat_masc_pop'/`=ISCEDEdu_nat_masc_pop') E70 = (`=ISCED02_migr_masc_pop'/`=ISCEDEdu_migr_masc_pop') // Level of educational attainment: low (ISCED groups 0-2)
		
	putexcel C71 = (`=ISCED01_nat_masc_pop'/`=ISCEDEdu_nat_masc_pop') E71 = (`=ISCED01_migr_masc_pop'/`=ISCEDEdu_migr_masc_pop') // Level of educational attainment: very low (ISCED groups 0-1)
		
	putexcel C72 = (`=literacy_nat_masc_pop'/`=pop_nat_masc_1664') E72 = (`=literacy_migr_masc_pop'/`=pop_migr_masc_1664') // Literacy: knows how to read and write
	
	putexcel C73 = (`=NoEmpNoedu_nat_masc_pop'/`=age1534_nat_masc_pop') E73 = (`=NoEmpNoedu_migr_masc_pop'/`=age1534_migr_masc_pop')   // Neither in employment, education or training for youth
	
	putexcel C74 = (`=earlyLeft_nat_masc_pop'/`=earlyAge_nat_masc_pop') E74 = (`=earlyLeft_migr_masc_pop'/`=earlyAge_migr_masc_pop')  // Early school leaving
	
	putexcel C75 = (`=attending_5to16_nat_masc_pop'/`=pop_nat_masc_516') E75 = (`=attending_5to16_migr_masc_pop'/`=pop_migr_masc_516')  // Share of children attending schooling, 5 - 16 years group
	
	** CHILDREN EDUCATION AND EMPLOYMENT	
	
	putexcel C79 = (`=attending_15to18_nat_masc_pop'/`=pop_nat_masc_1518') E79 = (`=attending_15to18_migr_masc_pop'/`=pop_migr_masc_1518')  // Share of children attending school (15-18 year-olds)
	
	putexcel C80 = (`=employment_15to18_nat_masc_pop'/`=pop_nat_masc_1518') E80 = (`=employment_15to18_migr_masc_pop'/`=pop_migr_masc_1518')  // Share of children in employment (15-18 year-olds)
	
	putexcel C81 = (`=AttOnly_15to18_nat_masc_pop'/`=pop_nat_masc_1518') E81 = (`=AttOnly_15to18_migr_masc_pop'/`=pop_migr_masc_1518')  // Share of children attending school only (15-18 year-olds)
	
	putexcel C82 = (`=EmpOnly_15to18_nat_masc_pop'/`=pop_nat_masc_1518') E82 = (`=EmpOnly_15to18_migr_masc_pop'/`=pop_migr_masc_1518')  // Share of children in employment only (15-18 year-olds)
	
	putexcel C83 = (`=Att_Emp_1518_nat_masc_pop'/`=pop_nat_masc_1518') E83 = (`=Att_Emp_1518_migr_masc_pop'/`=pop_migr_masc_1518')  // Share of children attending school & in employment (15-18 year-olds)
	
	putexcel C84 = (`=NiNi_15to18_nat_masc_pop'/`=pop_nat_masc_1518') E84 = (`=NiNi_15to18_migr_masc_pop'/`=pop_migr_masc_1518')  // Neither in employment, education or training for youth (15-18 year-olds)
	
	**HEALTH
	
	* Health problems
	
	putexcel C91 = (`=healthSys_nat_masc_pop'/`=job15to64_nat_masc_pop') E91 = (`=healthSys_migr_masc_pop'/`=job15to64_migr_masc_pop') // Access to health services AMONG working pop
	
	** SIMPLE CHARACTERISTICS
	
	putexcel C96 = (`=survey_nat_masc_pop') E96 = (`=survey_migr_masc_pop') // Total sample size: persons
	
	putexcel C97 = (`=survey_nat_masc_15to64') E97 = (`=survey_migr_masc_15to64') // Total sample size: persons 15-64
	
	putexcel C99 = (`=nat_masc_pop') E99 = (`=migr_masc_pop') // Total population (with sample loadings)
	
	putexcel C100 = (`=total_nat_masc_15to64') E100 = (`=total_migr_masc_15to64') // Total persons 15-64 (with sample loadings)
	
** POPULATION
	
	putexcel D6 = (`=nat_fem_pop'/`=tot_fem_pop') F6 = (`=migr_fem_pop'/`=tot_fem_pop')	// Share of population
	
	putexcel D7 = (`=workAge_nat_fem_pop'/`=workAge_fem_pop') F7 = (`=workAge_migr_fem_pop'/`=workAge_fem_pop') // Share of working age population (15-64)
	
	putexcel D8 = (`=econoAct_nat_fem_pop'/`=econoAct_fem_pop') F8 = (`=econoAct_migr_fem_pop'/`=econoAct_fem_pop') // Share of labour force population (15-64)
	
	putexcel D9 = (`=emp_nat_fem_pop'/`=emp_fem_pop') F9 = (`=emp_migr_fem_pop'/`=emp_fem_pop') // Share of Employment rate  (15-64)
	
	
	** DEMOGRAPHIC
	
	putexcel D17 = (`=pop_nat_fem_014'/`=nat_fem_pop') F17 = (`=pop_migr_fem_014'/`=migr_fem_pop') // 0 - 14
	
	putexcel D18 = (`=pop_nat_fem_1524'/`=nat_fem_pop') F18 = (`=pop_migr_fem_1524'/`=migr_fem_pop') // 15 - 24
	
	putexcel D19 = (`=pop_nat_fem_2539'/`=nat_fem_pop') F19 = (`=pop_migr_fem_2539'/`=migr_fem_pop') // 25 - 39
	
	putexcel D20 = (`=pop_nat_fem_4054'/`=nat_fem_pop') F20 = (`=pop_migr_fem_4054'/`=migr_fem_pop') // 40 - 54
	
	putexcel D21 = (`=pop_nat_fem_5564'/`=nat_fem_pop') F21 = (`=pop_migr_fem_5564'/`=migr_fem_pop') // 55 - 64
	
	putexcel D22 = (`=pop_nat_fem_65older'/`=nat_fem_pop') F22 = (`=pop_migr_fem_65older'/`=migr_fem_pop') // 65 Older
	
	putexcel D23 = (`=workAge_nat_fem_pop'/`=nat_fem_pop') F23 = (`=workAge_migr_fem_pop'/`=migr_fem_pop') // 15-64 
	
	*putexcel D25 = (`=male_nat_pop'/`=nat_pop') F25 = (`=male_migr_pop'/`=migr_pop') 	// Sex male
	
	putexcel D26 = (`=married_nat_fem_pop'/`=status_nat_fem_pop') F26 = (`=married_migr_fem_pop'/`=status_migr_fem_pop') // Marital status: married/cohabiting
	
	putexcel D27 = (`=separated_nat_fem_pop'/`=status_nat_fem_pop') F27 = (`=separated_migr_fem_pop'/`=status_migr_fem_pop') // Marital status: separated/divorced/widowed

	putexcel D28 = (`=single_nat_fem_pop'/`=status_nat_fem_pop') F28 = (`=single_migr_fem_pop'/`=status_migr_fem_pop') // Marital status: single
	
	putexcel D29 = (`=urban_nat_fem_pop'/`=nat_fem_pop') F29 = (`=urban_migr_fem_pop'/`=migr_fem_pop') // Urban
	
	putexcel D30 = (`=capital_nat_fem_pop'/`=nat_fem_pop')  F30 = (`=capital_migr_fem_pop'/`=migr_fem_pop') // Capital city located
	
	putexcel D31 = (`=borCity_nat_fem_pop'/`=nat_fem_pop')  F31 = (`=borCity_migr_fem_pop'/`=migr_fem_pop') // Border cities or region
	
	putexcel D34 = (`=size_nat_fem_house')  F34 = (`=size_migr_fem_house') // Household size
		
	putexcel D35 = (`=less18_nat_fem_house')  F35 = (`=less18_migr_fem_house') // Number of children <= 18 in household
		
	putexcel D36 = (`=less15_nat_fem_house')  F36 = (`=less15_migr_fem_house') // Number of children <= 15 in household
		
	// Number of natural-born children (women only)
	
	
	** LABOUR MARKET INDICATORS
	
	putexcel D41 = (`=job_nat_fem_pop'/`=workAge_nat_fem_pop') F41 = (`=job_migr_fem_pop'/`=workAge_migr_fem_pop') // Share of population with a job
	
	putexcel D42 = (`=econoAct_nat_fem_pop'/`=workAge_nat_fem_pop') F42 = (`=econoAct_migr_fem_pop'/`=workAge_migr_fem_pop') // Activity: Share participating in the labour force
	
	putexcel D43 = (`=inactive_nat_fem_pop'/`=workAge_nat_fem_pop') F43 = (`=inactive_migr_fem_pop'/`=workAge_migr_fem_pop')  // Economically inactive people
	
	putexcel D44 = (`=unemp_nat_fem_pop'/`=econoActWorkAge_nat_fem_pop') F44 = (`=unemp_migr_fem_pop'/`=econoActWorkAge_migr_fem_pop') // Unemployment: Share of population who were unemployed
	
	putexcel D45 = (`=long12_unemp_nat_fem_pop'/`=inac_unemp_nat_fem_pop') F45 = (`=long12_unemp_migr_fem_pop'/`=inac_unemp_migr_fem_pop') // Risk of labour market exclusion: long-term unemployment (12 month)
	
	putexcel D46 = (`=long6_unemp_nat_fem_pop'/`=inac_unemp_nat_fem_pop') F46 = (`=long6_unemp_migr_fem_pop'/`=inac_unemp_migr_fem_pop') // Risk of labour market exclusion: long-term unemployment (6 month)
	
	putexcel D47 = (`=involuntary_nat_fem_pop'/`=inac_unemp_nat_fem_pop') F47 = (`=involuntary_migr_fem_pop'/`=inac_unemp_migr_fem_pop') // Inactive involuntary (available past week, not looking for job)
	
	putexcel D48 = (`=long_invo_nat_fem_pop'/`=inac_unemp_nat_fem_pop') F48 = (`=long_invo_migr_fem_pop'/`=inac_unemp_migr_fem_pop') // Long-term uemployment >=12 months or inactive involuntary	
	
	putexcel D49 = (`=written_nat_fem_pop'/`=noself_edu_nat_fem_pop') F49 = (`=written_migr_fem_pop'/`=noself_edu_migr_fem_pop') // Share of population with written contract
	
	putexcel D50 = (`=informal_nat_fem_pop'/`=job_nat_fem_pop') F50 = (`=informal_migr_fem_pop'/`=job_migr_fem_pop') // Share of population with an informal job	
	
    // Share of population with an informal job (OECD def)
	
	putexcel D52 = (`=tempJob_nat_fem_pop'/`=noself_edu_nat_fem_pop') F52 = (`=tempJob_migr_fem_pop'/`=noself_edu_migr_fem_pop') // Types of contracts: Share of population in temporary contracts	
	
	putexcel D53 = (`=more40h_nat_fem_pop'/`=hours_nat_fem_pop') F53 = (`=more40h_migr_fem_pop'/`=hours_migr_fem_pop')  // Working hours: long (more than 40) hours	

	putexcel D54 = (`=more50h_nat_fem_pop'/`=hours_nat_fem_pop') F54 = (`=more50h_migr_fem_pop'/`=hours_migr_fem_pop')  // Working hours: long (more than 50) hours
	
	putexcel D55 = (`=more55h_nat_fem_pop'/`=hours_nat_fem_pop') F55 = (`=more55h_migr_fem_pop'/`=hours_migr_fem_pop')  // Working hours: long (more than 55) hours
	
	putexcel D56 = (`=less30h_nat_fem_pop'/`=hours_nat_fem_pop') F56 = (`=less30h_migr_fem_pop'/`=hours_migr_fem_pop')  // Working hours: long (less than 30) hours	
	
	putexcel D57 = (`=highSkill_nat_fem_pop'/`=NotMili_nat_fem_pop') F57 = (`=highSkill_migr_fem_pop'/`=NotMili_migr_fem_pop') // Job skills: share of working population in highly skilled jobs
	
	putexcel D58 = (`=lowSkill_nat_fem_pop'/`=NotMili_nat_fem_pop') F58 = (`=lowSkill_migr_fem_pop'/`=NotMili_migr_fem_pop') // Job skills: share of working population in low-skilled jobs 
		
	putexcel D59 = (`=overquali_nat_fem_pop'/`=NotEduNotMili_nat_fem_pop') F59 = (`=overquali_migr_fem_pop'/`=NotEduNotMili_migr_fem_pop') // Overqualification: share of highly educated individuals who work in low- or medium-skilled jobs

	putexcel D60 = (`=selfEmp_nat_fem_pop'/`=Notagri_emp1564_nat_fem_pop') F60 = (`=selfEmp_migr_fem_pop'/`=Notagri_emp1564_migr_fem_pop')   // Self-employment: share of population who work in their own firms or businesses
	
	putexcel D61 = (`=pubSec_nat_fem_pop'/`=NoSelf15to64_nat_fem_pop') F61 = (`=pubSec_migr_fem_pop'/`=NoSelf15to64_migr_fem_pop')   // Employment in the public sector
	
	putexcel D62 = (`=nmwage_nat_fem_')  F62 = (`=nmwage_migr_fem_') // Nominal monthly wage (USD)
	
	* Child labour
	
	
	** EDUCATION AND SKILLS
		
	putexcel D69 = (`=ISCED58_nat_fem_pop'/`=ISCEDEdu_nat_fem_pop') F69 = (`=ISCED58_migr_fem_pop'/`=ISCEDEdu_migr_fem_pop') // Level of educational attainment: high (ISCED groups 5-8)
		
	putexcel D70 = (`=ISCED02_nat_fem_pop'/`=ISCEDEdu_nat_fem_pop') F70 = (`=ISCED02_migr_fem_pop'/`=ISCEDEdu_migr_fem_pop') // Level of educational attainment: low (ISCED groups 0-2)
		
	putexcel D71 = (`=ISCED01_nat_fem_pop'/`=ISCEDEdu_nat_fem_pop') F71 = (`=ISCED01_migr_fem_pop'/`=ISCEDEdu_migr_fem_pop') // Level of educational attainment: very low (ISCED groups 0-1)
		
	putexcel D72 = (`=literacy_nat_fem_pop'/`=pop_nat_fem_1664') F72 = (`=literacy_migr_fem_pop'/`=pop_migr_fem_1664') // Literacy: knows how to read and write
	
	putexcel D73 = (`=NoEmpNoedu_nat_fem_pop'/`=age1534_nat_fem_pop') F73 = (`=NoEmpNoedu_migr_fem_pop'/`=age1534_migr_fem_pop')   // Neither in employment, education or training for youth
	
	putexcel D74 = (`=earlyLeft_nat_fem_pop'/`=earlyAge_nat_fem_pop') F74 = (`=earlyLeft_migr_fem_pop'/`=earlyAge_migr_fem_pop')  // Early school leaving
	
	putexcel D75 = (`=attending_5to16_nat_fem_pop'/`=pop_nat_fem_516') F75 = (`=attending_5to16_migr_fem_pop'/`=pop_migr_fem_516')  // Share of children attending schooling, 5 - 16 years group
	
	** CHILDREN EDUCATION AND EMPLOYMENT	
	
	putexcel D79 = (`=attending_15to18_nat_fem_pop'/`=pop_nat_fem_1518') F79 = (`=attending_15to18_migr_fem_pop'/`=pop_migr_fem_1518')  // Share of children attending school (15-18 year-olds)
	
	putexcel D80 = (`=employment_15to18_nat_fem_pop'/`=pop_nat_fem_1518') F80 = (`=employment_15to18_migr_fem_pop'/`=pop_migr_fem_1518')  // Share of children in employment (15-18 year-olds)
	
	putexcel D81 = (`=AttOnly_15to18_nat_fem_pop'/`=pop_nat_fem_1518') F81 = (`=AttOnly_15to18_migr_fem_pop'/`=pop_migr_fem_1518')  // Share of children attending school only (15-18 year-olds)
	
	putexcel D82 = (`=EmpOnly_15to18_nat_fem_pop'/`=pop_nat_fem_1518') F82 = (`=EmpOnly_15to18_migr_fem_pop'/`=pop_migr_fem_1518')  // Share of children in employment only (15-18 year-olds)
	
	putexcel D83 = (`=Att_Emp_1518_nat_fem_pop'/`=pop_nat_fem_1518') F83 = (`=Att_Emp_1518_migr_fem_pop'/`=pop_migr_fem_1518')  // Share of children attending school & in employment (15-18 year-olds)
	
	putexcel D84 = (`=NiNi_15to18_nat_fem_pop'/`=pop_nat_fem_1518') F84 = (`=NiNi_15to18_migr_fem_pop'/`=pop_migr_fem_1518')  // Neither in employment, education or training for youth (15-18 year-olds)
	
	**HEALTH
	
	* Health problems
	
	putexcel D91 = (`=healthSys_nat_fem_pop'/`=job15to64_nat_fem_pop') F91 = (`=healthSys_migr_fem_pop'/`=job15to64_migr_fem_pop') // Access to health services AMONG working pop
	
	** SIMPLE CHARACTERISTICS
	
	putexcel D96 = (`=survey_nat_fem_pop') F96 = (`=survey_migr_fem_pop') // Total sample size: persons
	
	putexcel D97 = (`=survey_nat_fem_15to64') F97 = (`=survey_migr_fem_15to64') // Total sample size: persons 15-64
	
	putexcel D99 = (`=nat_fem_pop') F99 = (`=migr_fem_pop') // Total population (with sample loadings)
	
	putexcel D100 = (`=total_nat_fem_15to64') F100 = (`=total_migr_fem_15to64') // Total persons 15-64 (with sample loadings)
	
	
********************************************************************************
********************************************************************************
********************************************************************************
****** PANAMA - HOUSEHOLD SURVEY EHPM 2019
	
	clear all
	set more off, perm
	set maxvar 15000
	scalar drop _all

	****************************************************************************
	** DATASET
	cd "C:\Users\jcamilop\OneDrive - Inter-American Development Bank Group\OECD\01 Raw"
	use "PAN_2019m3_BID.dta", replace

	gen uno=1
	*replace factor_ci=round(factor_ci) // Applies when the expansion factor is a non-integer numbers
	
	****************************************************************************
	** LOCALS
		local 1_label = "migr"
		local 0_label = "nat"
		
		local 1_sexo = "masc_"
		local 2_sexo = "fem_"
		
	****************************************************************************
	** ISCED
	gen ISCED = 0 if inlist(p6, 1, 2, 3)
	replace ISCED = 1 if p6 == 4 | inrange(p6, 11, 16)
	replace ISCED = 2 if inrange(p6, 21, 23)
	replace ISCED = 3 if inrange(p6, 31, 36)
	replace ISCED = 4 if inlist(p6, 41, 42)
	replace ISCED = 6 if inrange(p6, 51, 56)
	replace ISCED = 7 if inlist(p6, 61, 71, 72)
	replace ISCED = 8 if inlist(p6, 82, 83, 84)
	
	****************************************************************************
	** JOB QUALIFICATIONS - ISCO
	gen ISCO = 	p26reco
	gen overqualificated = 1 if inrange(ISCED,5,8) & inrange(ISCO,4,9)
	gen low_skilled = 1 if ISCO==9
	gen high_skilled = 1 if inrange(ISCO,1,3)
	
	****************************************************************************
	** Household size
	by idh_ch, sort: egen nmiembros=sum(relacion_ci>=1 & relacion_ci<5)
	by idh_ch, sort: egen nmenor18=sum((relacion_ci>=1 & relacion_ci<=4) & edad_ci<18)
	by idh_ch, sort: egen nmenor15=sum((relacion_ci>=1 & relacion_ci<=4) & edad_ci<15)
		
	****************************************************************************
	** Informality
	gen informal = 1 if afiliado_ci != 1 & emp_ci==1
	
	****************************************************************************
	** Working hours
	gen more_40 = 1 if horastot_ci >= 40
	replace more_40 = . if horastot_ci == .
	gen more_50 = 1 if horastot_ci >= 50
	replace more_50 = . if horastot_ci == .
	gen more_55 = 1 if horastot_ci >= 55
	replace more_55 = . if horastot_ci == .
	gen less_30 = 1 if horastot_ci <= 30
	replace less_30 = . if horastot_ci == .
	gen by_hours = 1 if emp_ci == 1
	replace by_hours = . if horastot_ci == .
	
	****************************************************************************
	** Nominal monthly wage (USD)
	by idh_ch, sort: egen nmwage=mean(ylm_ci + ylnm_ch)
	replace nmwage = (nmwage)/0.47
	
	****************************************************************************
	** Months of unemployment
	gen more_12 = 1 if durades_ci>=12
	replace more_12 = . if durades_ci == .
	gen more_6 = 1 if durades_ci>=6
	replace more_6 = . if durades_ci == .
		
********************************************************************* STATISTICS
********************************************************************************
********************************************************************************

	** CALCULATION OF INDICATORS
	
	** POPULATION
	
	* Total population calculated according to expansion factor
	sum uno if migrante_ci!=. & sexo_ci == 1 [fw=factor_ci]
	scalar tot_masc_pop = `=r(N)'
	
	* Migrant population calculated according to expansion factor
	sum uno if migrante_ci==1 & sexo_ci == 1 [fw=factor_ci]
	scalar migr_masc_pop = `=r(N)'
	
	* Native population calculated according to expansion factor
	sum uno if migrante_ci==0 & sexo_ci == 1 [fw=factor_ci]
	scalar nat_masc_pop = `=r(N)'
	
	* Total population calculated according to expansion factor
	sum uno if migrante_ci!=. & sexo_ci == 2 [fw=factor_ci]
	scalar tot_fem_pop = `=r(N)'
	
	* Migrant population calculated according to expansion factor
	sum uno if migrante_ci==1 & sexo_ci == 2 [fw=factor_ci]
	scalar migr_fem_pop = `=r(N)'
	
	* Native population calculated according to expansion factor
	sum uno if migrante_ci==0 & sexo_ci == 2 [fw=factor_ci]
	scalar nat_fem_pop = `=r(N)'
	
	* Share of working age population (15-64) Male
	sum uno if inrange(edad_ci,15,64) & migrante_ci==1 & sexo_ci == 1 [fw=factor_ci]
	scalar workAge_migr_masc_pop = `=r(N)'
	sum uno if inrange(edad_ci,15,64) & migrante_ci==0 & sexo_ci == 1 [fw=factor_ci]
	scalar workAge_nat_masc_pop = `=r(N)'
	sum uno if inrange(edad_ci,15,64) & sexo_ci == 1 [fw=factor_ci]
	scalar workAge_masc_pop = `=r(N)'
		
	* Share of labour force population (15-64) Male
	sum uno if inrange(edad_ci,15,64) & pea_ci == 1 & migrante_ci==1 & sexo_ci == 1 [fw=factor_ci]
	scalar econoAct_migr_masc_pop = `=r(N)'
	sum uno if inrange(edad_ci,15,64) & pea_ci == 1 & migrante_ci==0 & sexo_ci == 1 [fw=factor_ci]
	scalar econoAct_nat_masc_pop = `=r(N)'
	sum uno if inrange(edad_ci,15,64) & pea_ci == 1 & sexo_ci == 1 [fw=factor_ci]
	scalar econoAct_masc_pop = `=r(N)'
	
	* Share of Employment rate  (15-64) Male
	sum uno if inrange(edad_ci,15,64) & emp_ci == 1 & migrante_ci==1 & sexo_ci == 1 [fw=factor_ci]
	scalar emp_migr_masc_pop = `=r(N)'
	sum uno if inrange(edad_ci,15,64) & emp_ci == 1 & migrante_ci==0 & sexo_ci == 1 [fw=factor_ci]
	scalar emp_nat_masc_pop = `=r(N)'
	sum uno if inrange(edad_ci,15,64) & emp_ci == 1 & sexo_ci == 1 [fw=factor_ci]
	scalar emp_masc_pop = `=r(N)'
	
	* Share of working age population (15-64) Female
	sum uno if inrange(edad_ci,15,64) & migrante_ci==1 & sexo_ci == 2 [fw=factor_ci]
	scalar workAge_migr_fem_pop = `=r(N)'
	sum uno if inrange(edad_ci,15,64) & migrante_ci==0 & sexo_ci == 2 [fw=factor_ci]
	scalar workAge_nat_fem_pop = `=r(N)'
	sum uno if inrange(edad_ci,15,64) & sexo_ci == 2 [fw=factor_ci]
	scalar workAge_fem_pop = `=r(N)'
		
	* Share of labour force population (15-64) Female
	sum uno if inrange(edad_ci,15,64) & pea_ci == 1 & migrante_ci==1 & sexo_ci == 2 [fw=factor_ci]
	scalar econoAct_migr_fem_pop = `=r(N)'
	sum uno if inrange(edad_ci,15,64) & pea_ci == 1 & migrante_ci==0 & sexo_ci == 2 [fw=factor_ci]
	scalar econoAct_nat_fem_pop = `=r(N)'
	sum uno if inrange(edad_ci,15,64) & pea_ci == 1 & sexo_ci == 2 [fw=factor_ci]
	scalar econoAct_fem_pop = `=r(N)'
	
	* Share of Employment rate  (15-64) Female
	sum uno if inrange(edad_ci,15,64) & emp_ci == 1 & migrante_ci==1 & sexo_ci == 2 [fw=factor_ci]
	scalar emp_migr_fem_pop = `=r(N)'
	sum uno if inrange(edad_ci,15,64) & emp_ci == 1 & migrante_ci==0 & sexo_ci == 2 [fw=factor_ci]
	scalar emp_nat_fem_pop = `=r(N)'
	sum uno if inrange(edad_ci,15,64) & emp_ci == 1 & sexo_ci == 2 [fw=factor_ci]
	scalar emp_fem_pop = `=r(N)'
	

	** CALCULATION OF INDICATORS BY MIGRANTS AND NATIVES
	
	foreach var in 1 0 {
		
		foreach sexo in 1 2 {
		
		** DEMOGRAPHIC
		
		* Age groups
		
		sum uno if inrange(edad_ci,0,14) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar pop_``var'_label'_``sexo'_sexo'014 = `=r(N)' // 0 - 14 years
		
		sum uno if inrange(edad_ci,15,24) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar pop_``var'_label'_``sexo'_sexo'1524 = `=r(N)' // 15 - 24 years

		sum uno if inrange(edad_ci,25,39) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar pop_``var'_label'_``sexo'_sexo'2539 = `=r(N)' // 25 - 39 years
		
		sum uno if inrange(edad_ci,40,54) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar pop_``var'_label'_``sexo'_sexo'4054 = `=r(N)' // 40 - 54 years

		sum uno if inrange(edad_ci,55,64) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar pop_``var'_label'_``sexo'_sexo'5564 = `=r(N)'	//55 - 64 years
		
		sum uno if inrange(edad_ci,65,.) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar pop_``var'_label'_``sexo'_sexo'65older = `=r(N)'  // 65 older years
		
		* Sex male population
		sum uno if sexo_ci==1 & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar male_``var'_label'_``sexo'_sexo'pop =`=r(N)'
		
		* Marital status: married/cohabiting
		*sum uno if civil_ci==2 & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		*scalar married_``var'_label'_pop = `=r(N)'
		
		*sum uno if civil_ci!=. & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		*scalar status_``var'_label'_pop = `=r(N)'
		
		* Marital status: separated/divorced/widowed
		*sum uno if (civil_ci==3 | civil_ci==4) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		*scalar separated_``var'_label'_pop = `=r(N)'	
		
		* Marital status: single
		*sum uno if civil_ci==1 & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		*scalar single_``var'_label'_pop = `=r(N)'	
		
		* Urban
		sum uno if zona_c==1 & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar urban_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		* Capital city located
		sum uno if region_c==8 & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar capital_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		* Border cities or region
		sum uno if inlist(region_c, 5, 11) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar borCity_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		* Household size
		sum nmiembros_ch if migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar size_``var'_label'_``sexo'_sexo'house = `=r(mean)'			
		
		* Number of children <= 18 in household
		sum nmenor18 if migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar less18_``var'_label'_``sexo'_sexo'house = `=r(mean)'			
		
		* Number of children <= 15 in household
		sum nmenor15 if migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar less15_``var'_label'_``sexo'_sexo'house = `=r(mean)'
		
		* Number of natural-born children (women only)
		
		
		** LABOUR MARKET INDICATORS
		
		* Share of population with a job
		sum uno if inrange(edad_ci,15,64) & emp_ci==1 & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar job_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		* Activity: Share participating in the labour force
		sum uno if inrange(edad_ci,15,64) & pea_ci==1 & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar econoAct_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		* Economically inactive people
		sum uno if inrange(edad_ci,15,64) & (condocup_ci == 3) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci] 
		scalar inactive_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		* Unemployment: Share of population who were unemployed
		sum uno if inrange(edad_ci,15,64) & desemp_ci==1 & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci] 
		scalar unemp_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		sum uno if (pea_ci==1 | asiste_ci==1) & inrange(edad_ci,15,64) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar econoActWorkAge_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		* Risk of labour market exclusion: long-term unemployment (12 months)
		sum uno if inrange(edad_ci,15,64) & (more_12==1 & desemp_ci==1) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar long12_unemp_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		sum uno if inrange(edad_ci,15,64) & (desemp_ci==1 | condocup_ci==3) & durades_ci!=. & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci] 
		scalar inac_unemp_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		* Risk of labour market exclusion: long-term unemployment (6 months)
		sum uno if inrange(edad_ci,15,64) & (more_6==1 & desemp_ci==1) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar long6_unemp_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		* Risk of labour market exclusion: long-term uemployment >=12 months or inactive involuntary
		sum uno if inrange(edad_ci,15,64) & (desalent_ci==1 | (more_12==1 & desemp_ci==1)) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar long_invo_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		* Risk of labour market exclusion: Inactive involuntary (available past week, not looking for job)
		sum uno if inrange(edad_ci,15,64) & desalent_ci==1 & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar involuntary_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		* Share of population with written contract
		sum uno if inrange(edad_ci,15,64) & inlist(tipocontrato_ci,0,1,2) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar written_``var'_label'_``sexo'_sexo'pop = `=r(N)'		
		
		* Share of population with an informal job
		sum uno if inrange(edad_ci,15,64) & informal==1 & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar informal_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		* Types of contracts:  Share of population in temporary contracts
		sum uno if inrange(edad_ci,15,64) & tipocontrato_ci==2 & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci] 
		scalar tempJob_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		sum uno if inrange(edad_ci,15,64) & categopri_ci!=2 & asiste_ci!=1 & emp_ci==1 & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar noself_edu_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		* Working hours: long hours >= 40
		sum uno if inrange(edad_ci,15,64) & more_40==1 & emp_ci == 1 & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar more40h_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		sum uno if inrange(edad_ci,15,64) & by_hours==1 & emp_ci == 1 & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar hours_``var'_label'_``sexo'_sexo'pop = `=r(N)'

		* Working hours: long hours >= 50
		sum uno if inrange(edad_ci,15,64) & more_50==1 & emp_ci == 1 & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar more50h_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		* Working hours: long hours >= 55
		sum uno if inrange(edad_ci,15,64) & more_55==1 & emp_ci == 1 & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar more55h_``var'_label'_``sexo'_sexo'pop = `=r(N)'		
	
		* Working hours: long hours < 30
		sum uno if inrange(edad_ci,15,64) & less_30==1 & emp_ci == 1 & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar less30h_``var'_label'_``sexo'_sexo'pop = `=r(N)'

		* Job skills: share of working population in highly skilled jobs
		sum uno if high_skilled==1 & inrange(edad_ci,15,64) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar highSkill_``var'_label'_``sexo'_sexo'pop = `=r(N)'		
		
		* Job skills: share of working population in low-skilled jobs
		sum uno if low_skilled==1 & inrange(edad_ci,15,64) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar lowSkill_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		sum uno if emp_ci==1 & inrange(edad_ci,15,64) & ISCO!=0 & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar NotMili_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		* Overqualification: share of highly educated individuals who work in low- or medium-skilled jobs
		sum uno if overqualificated==1 & inrange(edad_ci,15,64) & migrante_ci==`var' & sexo_ci==`sexo' & inrange(ISCED,4,9) [fw=factor_ci]
		scalar overquali_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		sum uno if emp_ci==1 & inrange(edad_ci,15,64) & asiste_ci!=1 & ISCO!=0 & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar NotEduNotMili_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		* Self-employment: share of population who works in their own firms or businesses
		sum uno if (categopri_ci==1 | categopri_ci==2) & inrange(edad_ci,15,64) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar selfEmp_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		sum uno if inrange(edad_ci,15,64) & rama_ci!=1 & emp_ci==1 & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar Notagri_emp1564_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		* Employment in the public sector
		sum uno if spublico_ci==1 & inrange(edad_ci,15,64) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar pubSec_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		sum uno if inrange(edad_ci,15,64) & emp_ci==1 & categopri_ci!=2 & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar NoSelf15to64_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		* Nominal monthly wage (USD)
		sum ylm_ci if migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar nmwage_``var'_label'_``sexo'_sexo' = `=r(mean)'
		
		* Child labour
		

		** EDUCATION AND SKILLS
		
		* Level of educational attainment: high (ISCED groups 5-8)
		sum uno if inrange(ISCED,5,8) & inrange(edad_ci,15,64) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar ISCED58_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		sum uno if inrange(edad_ci,15,64) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar ISCEDEdu_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		* Level of educational attainment: low (ISCED groups 0-2)
		sum uno if inrange(ISCED,0,2) & inrange(edad_ci,15,64) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar ISCED02_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		* Level of educational attainment: very low (ISCED groups 0-1)
		sum uno if inrange(ISCED,0,1) & inrange(edad_ci,15,64) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar ISCED01_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		* Literacy: knows how to read and write 
		sum uno if p7 == 1 & inrange(edad_ci,16,64) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar literacy_``var'_label'_``sexo'_sexo'pop = `=r(N)'		
		
		sum uno if inrange(edad_ci,16,64) & migrante_ci==`var' [fw=factor_ci] 
		scalar pop_``var'_label'_``sexo'_sexo'1664 = `=r(N)'
		
		* Neither in employment, education or training for youth
		sum uno if (edad_ci>=15 & edad_ci <=34) & emp_ci!=1 & asiste_ci==0 & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar NoEmpNoedu_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		sum uno if inrange(edad_ci,15,34) & migrante_ci==`var' [fw=factor_ci]
		scalar age1534_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		* Early school leaving
		sum uno if asiste_ci == 0 & (edad_ci>=15 & edad_ci <=24) & inlist(ISCED,0,1,2) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar earlyLeft_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		sum uno if inrange(edad_ci,15,24) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar earlyAge_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		* Share of children attending schooling, 5 - 16 years group
		sum uno if asiste_ci==1 & inrange(edad_ci,5,16) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar attending_5to16_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		sum uno if inrange(edad_ci,5,16) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci] 
		scalar pop_``var'_label'_``sexo'_sexo'516 = `=r(N)'
		
		** CHILDREN EDUCATION AND EMPLOYMENT
		
		* Share of children attending school (15-18 year-olds)
		sum uno if asiste_ci==1 & inrange(edad_ci,15,18) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar attending_15to18_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		sum uno if inrange(edad_ci,15,18) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci] 
		scalar pop_``var'_label'_``sexo'_sexo'1518 = `=r(N)'
		
		* Share of children in employment (15-18 year-olds)
		sum uno if emp_ci==1 & inrange(edad_ci,15,18) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar employment_15to18_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		* Share of children attending school only (15-18 year-olds)
		sum uno if (asiste_ci==1 & emp_ci!=1) & inrange(edad_ci,15,18) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar AttOnly_15to18_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		* Share of children in employment only (15-18 year-olds)
		sum uno if (emp_ci==1 & asiste_ci!=1) & inrange(edad_ci,15,18) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar EmpOnly_15to18_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		* Share of children attending school & in employment (15-18 year-olds)
		sum uno if (asiste_ci==1 & emp_ci==1) & inrange(edad_ci,15,18) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar Att_Emp_1518_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		* Neither in employment, education or training for youth (15-18 year-olds)
		sum uno if (edad_ci>=15 & edad_ci <=18) & emp_ci==0 & asiste_ci==0 & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar NiNi_15to18_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		** HEALTH
		
		* Access to health services AMONG working pop
		sum uno if inrange(edad_ci,15,64) & (afiliado_ci==1 | cotizando_ci==1) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci] 
		scalar healthSys_``var'_label'_``sexo'_sexo'pop = `=r(N)'	
		
		sum uno if inrange(edad_ci,15,64) & emp_ci==1 & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar job15to64_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		** SAMPLE CHARACTERISTICS
		
		* Total sample size: persons 
		sum uno if migrante_ci==`var' & sexo_ci==`sexo'  & sexo_ci==`sexo'
		scalar survey_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		* Total sample size: persons 15-64
		sum uno if inrange(edad_ci,15,64) & migrante_ci==`var' & sexo_ci==`sexo'
		scalar survey_``var'_label'_``sexo'_sexo'15to64 = `=r(N)'

		* Total persons 15-64 (with sample loadings)
		sum uno if inrange(edad_ci,15,64) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar total_``var'_label'_``sexo'_sexo'15to64 = `=r(N)'
		
	}
	
		}
	
******************************************************** EXCEL OUTPUTS

	putexcel set "C:\Users\jcamilop\OneDrive - Inter-American Development Bank Group\OECD\03 Outputs\Resultados por sexo.xlsx", sheet("Panama") modify
	putexcel describe
	
	
	** POPULATION
	
	putexcel C6 = (`=nat_masc_pop'/`=tot_masc_pop') E6 = (`=migr_masc_pop'/`=tot_masc_pop')	// Share of population
	
	putexcel C7 = (`=workAge_nat_masc_pop'/`=workAge_masc_pop') E7 = (`=workAge_migr_masc_pop'/`=workAge_masc_pop') // Share of working age population (15-64)
	
	putexcel C8 = (`=econoAct_nat_masc_pop'/`=econoAct_masc_pop') E8 = (`=econoAct_migr_masc_pop'/`=econoAct_masc_pop') // Share of labour force population (15-64)
	
	putexcel C9 = (`=emp_nat_masc_pop'/`=emp_masc_pop') E9 = (`=emp_migr_masc_pop'/`=emp_masc_pop') // Share of Employment rate  (15-64)
	
	
	** DEMOGRAPHIC
	
	putexcel C17 = (`=pop_nat_masc_014'/`=nat_masc_pop') E17 = (`=pop_migr_masc_014'/`=migr_masc_pop') // 0 - 14
	
	putexcel C18 = (`=pop_nat_masc_1524'/`=nat_masc_pop') E18 = (`=pop_migr_masc_1524'/`=migr_masc_pop') // 15 - 24
	
	putexcel C19 = (`=pop_nat_masc_2539'/`=nat_masc_pop') E19 = (`=pop_migr_masc_2539'/`=migr_masc_pop') // 25 - 39
	
	putexcel C20 = (`=pop_nat_masc_4054'/`=nat_masc_pop') E20 = (`=pop_migr_masc_4054'/`=migr_masc_pop') // 40 - 54
	
	putexcel C21 = (`=pop_nat_masc_5564'/`=nat_masc_pop') E21 = (`=pop_migr_masc_5564'/`=migr_masc_pop') // 55 - 64
	
	putexcel C22 = (`=pop_nat_masc_65older'/`=nat_masc_pop') E22 = (`=pop_migr_masc_65older'/`=migr_masc_pop') // 65 Older
	
	putexcel C23 = (`=workAge_nat_masc_pop'/`=nat_masc_pop') E23 = (`=workAge_migr_masc_pop'/`=migr_masc_pop') // 15-64 
	
	*putexcel C25 = (`=male_nat_pop'/`=nat_pop') E25 = (`=male_migr_pop'/`=migr_pop') 	// Sex male
	
	*putexcel C26 = (`=married_nat_masc_pop'/`=status_nat_masc_pop') E26 = (`=married_migr_masc_pop'/`=status_migr_masc_pop') // Marital status: married/cohabiting
	
	*putexcel C27 = (`=separated_nat_masc_pop'/`=status_nat_masc_pop') E27 = (`=separated_migr_masc_pop'/`=status_migr_masc_pop') // Marital status: separated/divorced/widowed

	*putexcel C28 = (`=single_nat_masc_pop'/`=status_nat_masc_pop') E28 = (`=single_migr_masc_pop'/`=status_migr_masc_pop') // Marital status: single
	
	putexcel C29 = (`=urban_nat_masc_pop'/`=nat_masc_pop') E29 = (`=urban_migr_masc_pop'/`=migr_masc_pop') // Urban
	
	putexcel C30 = (`=capital_nat_masc_pop'/`=nat_masc_pop')  E30 = (`=capital_migr_masc_pop'/`=migr_masc_pop') // Capital city located
	
	putexcel C31 = (`=borCity_nat_masc_pop'/`=nat_masc_pop')  E31 = (`=borCity_migr_masc_pop'/`=migr_masc_pop') // Border cities or region
	
	putexcel C34 = (`=size_nat_masc_house')  E34 = (`=size_migr_masc_house') // Household size
		
	putexcel C35 = (`=less18_nat_masc_house')  E35 = (`=less18_migr_masc_house') // Number of children <= 18 in household
		
	putexcel C36 = (`=less15_nat_masc_house')  E36 = (`=less15_migr_masc_house') // Number of children <= 15 in household
		
	// Number of natural-born children (women only)
	
	
	** LABOUR MARKET INDICATORS
	
	putexcel C41 = (`=job_nat_masc_pop'/`=workAge_nat_masc_pop') E41 = (`=job_migr_masc_pop'/`=workAge_migr_masc_pop') // Share of population with a job
	
	putexcel C42 = (`=econoAct_nat_masc_pop'/`=workAge_nat_masc_pop') E42 = (`=econoAct_migr_masc_pop'/`=workAge_migr_masc_pop') // Activity: Share participating in the labour force
	
	putexcel C43 = (`=inactive_nat_masc_pop'/`=workAge_nat_masc_pop') E43 = (`=inactive_migr_masc_pop'/`=workAge_migr_masc_pop')  // Economically inactive people
	
	putexcel C44 = (`=unemp_nat_masc_pop'/`=econoActWorkAge_nat_masc_pop') E44 = (`=unemp_migr_masc_pop'/`=econoActWorkAge_migr_masc_pop') // Unemployment: Share of population who were unemployed
	
	putexcel C45 = (`=long12_unemp_nat_masc_pop'/`=inac_unemp_nat_masc_pop') E45 = (`=long12_unemp_migr_masc_pop'/`=inac_unemp_migr_masc_pop') // Risk of labour market exclusion: long-term unemployment (12 month)
	
	putexcel C46 = (`=long6_unemp_nat_masc_pop'/`=inac_unemp_nat_masc_pop') E46 = (`=long6_unemp_migr_masc_pop'/`=inac_unemp_migr_masc_pop') // Risk of labour market exclusion: long-term unemployment (6 month)
	
	putexcel C47 = (`=involuntary_nat_masc_pop'/`=inac_unemp_nat_masc_pop') E47 = (`=involuntary_migr_masc_pop'/`=inac_unemp_migr_masc_pop') // Inactive involuntary (available past week, not looking for job)
	
	putexcel C48 = (`=long_invo_nat_masc_pop'/`=inac_unemp_nat_masc_pop') E48 = (`=long_invo_migr_masc_pop'/`=inac_unemp_migr_masc_pop') // Long-term uemployment >=12 months or inactive involuntary	
	
	putexcel C49 = (`=written_nat_masc_pop'/`=noself_edu_nat_masc_pop') E49 = (`=written_migr_masc_pop'/`=noself_edu_migr_masc_pop') // Share of population with written contract
	
	putexcel C50 = (`=informal_nat_masc_pop'/`=job_nat_masc_pop') E50 = (`=informal_migr_masc_pop'/`=job_migr_masc_pop') // Share of population with an informal job	
	
    // Share of population with an informal job (OECD def)
	
	putexcel C52 = (`=tempJob_nat_masc_pop'/`=noself_edu_nat_masc_pop') E52 = (`=tempJob_migr_masc_pop'/`=noself_edu_migr_masc_pop') // Types of contracts: Share of population in temporary contracts	
	
	putexcel C53 = (`=more40h_nat_masc_pop'/`=hours_nat_masc_pop') E53 = (`=more40h_migr_masc_pop'/`=hours_migr_masc_pop')  // Working hours: long (more than 40) hours	

	putexcel C54 = (`=more50h_nat_masc_pop'/`=hours_nat_masc_pop') E54 = (`=more50h_migr_masc_pop'/`=hours_migr_masc_pop')  // Working hours: long (more than 50) hours
	
	putexcel C55 = (`=more55h_nat_masc_pop'/`=hours_nat_masc_pop') E55 = (`=more55h_migr_masc_pop'/`=hours_migr_masc_pop')  // Working hours: long (more than 55) hours
	
	putexcel C56 = (`=less30h_nat_masc_pop'/`=hours_nat_masc_pop') E56 = (`=less30h_migr_masc_pop'/`=hours_migr_masc_pop')  // Working hours: long (less than 30) hours	
	
	putexcel C57 = (`=highSkill_nat_masc_pop'/`=NotMili_nat_masc_pop') E57 = (`=highSkill_migr_masc_pop'/`=NotMili_migr_masc_pop') // Job skills: share of working population in highly skilled jobs
	
	putexcel C58 = (`=lowSkill_nat_masc_pop'/`=NotMili_nat_masc_pop') E58 = (`=lowSkill_migr_masc_pop'/`=NotMili_migr_masc_pop') // Job skills: share of working population in low-skilled jobs 
		
	putexcel C59 = (`=overquali_nat_masc_pop'/`=NotEduNotMili_nat_masc_pop') E59 = (`=overquali_migr_masc_pop'/`=NotEduNotMili_migr_masc_pop') // Overqualification: share of highly educated individuals who work in low- or medium-skilled jobs

	putexcel C60 = (`=selfEmp_nat_masc_pop'/`=Notagri_emp1564_nat_masc_pop') E60 = (`=selfEmp_migr_masc_pop'/`=Notagri_emp1564_migr_masc_pop')   // Self-employment: share of population who work in their own firms or businesses
	
	putexcel C61 = (`=pubSec_nat_masc_pop'/`=NoSelf15to64_nat_masc_pop') E61 = (`=pubSec_migr_masc_pop'/`=NoSelf15to64_migr_masc_pop')   // Employment in the public sector
	
	putexcel C62 = (`=nmwage_nat_masc_')  E62 = (`=nmwage_migr_masc_') // Nominal monthly wage (USD)
	
	* Child labour
	
	
	** EDUCATION AND SKILLS
		
	putexcel C69 = (`=ISCED58_nat_masc_pop'/`=ISCEDEdu_nat_masc_pop') E69 = (`=ISCED58_migr_masc_pop'/`=ISCEDEdu_migr_masc_pop') // Level of educational attainment: high (ISCED groups 5-8)
		
	putexcel C70 = (`=ISCED02_nat_masc_pop'/`=ISCEDEdu_nat_masc_pop') E70 = (`=ISCED02_migr_masc_pop'/`=ISCEDEdu_migr_masc_pop') // Level of educational attainment: low (ISCED groups 0-2)
		
	putexcel C71 = (`=ISCED01_nat_masc_pop'/`=ISCEDEdu_nat_masc_pop') E71 = (`=ISCED01_migr_masc_pop'/`=ISCEDEdu_migr_masc_pop') // Level of educational attainment: very low (ISCED groups 0-1)
		
	putexcel C72 = (`=literacy_nat_masc_pop'/`=pop_nat_masc_1664') E72 = (`=literacy_migr_masc_pop'/`=pop_migr_masc_1664') // Literacy: knows how to read and write
	
	putexcel C73 = (`=NoEmpNoedu_nat_masc_pop'/`=age1534_nat_masc_pop') E73 = (`=NoEmpNoedu_migr_masc_pop'/`=age1534_migr_masc_pop')   // Neither in employment, education or training for youth
	
	putexcel C74 = (`=earlyLeft_nat_masc_pop'/`=earlyAge_nat_masc_pop') E74 = (`=earlyLeft_migr_masc_pop'/`=earlyAge_migr_masc_pop')  // Early school leaving
	
	putexcel C75 = (`=attending_5to16_nat_masc_pop'/`=pop_nat_masc_516') E75 = (`=attending_5to16_migr_masc_pop'/`=pop_migr_masc_516')  // Share of children attending schooling, 5 - 16 years group
	
	** CHILDREN EDUCATION AND EMPLOYMENT	
	
	putexcel C79 = (`=attending_15to18_nat_masc_pop'/`=pop_nat_masc_1518') E79 = (`=attending_15to18_migr_masc_pop'/`=pop_migr_masc_1518')  // Share of children attending school (15-18 year-olds)
	
	putexcel C80 = (`=employment_15to18_nat_masc_pop'/`=pop_nat_masc_1518') E80 = (`=employment_15to18_migr_masc_pop'/`=pop_migr_masc_1518')  // Share of children in employment (15-18 year-olds)
	
	putexcel C81 = (`=AttOnly_15to18_nat_masc_pop'/`=pop_nat_masc_1518') E81 = (`=AttOnly_15to18_migr_masc_pop'/`=pop_migr_masc_1518')  // Share of children attending school only (15-18 year-olds)
	
	putexcel C82 = (`=EmpOnly_15to18_nat_masc_pop'/`=pop_nat_masc_1518') E82 = (`=EmpOnly_15to18_migr_masc_pop'/`=pop_migr_masc_1518')  // Share of children in employment only (15-18 year-olds)
	
	putexcel C83 = (`=Att_Emp_1518_nat_masc_pop'/`=pop_nat_masc_1518') E83 = (`=Att_Emp_1518_migr_masc_pop'/`=pop_migr_masc_1518')  // Share of children attending school & in employment (15-18 year-olds)
	
	putexcel C84 = (`=NiNi_15to18_nat_masc_pop'/`=pop_nat_masc_1518') E84 = (`=NiNi_15to18_migr_masc_pop'/`=pop_migr_masc_1518')  // Neither in employment, education or training for youth (15-18 year-olds)
	
	**HEALTH
	
	* Health problems
	
	putexcel C91 = (`=healthSys_nat_masc_pop'/`=job15to64_nat_masc_pop') E91 = (`=healthSys_migr_masc_pop'/`=job15to64_migr_masc_pop') // Access to health services AMONG working pop
	
	** SIMPLE CHARACTERISTICS
	
	putexcel C96 = (`=survey_nat_masc_pop') E96 = (`=survey_migr_masc_pop') // Total sample size: persons
	
	putexcel C97 = (`=survey_nat_masc_15to64') E97 = (`=survey_migr_masc_15to64') // Total sample size: persons 15-64
	
	putexcel C99 = (`=nat_masc_pop') E99 = (`=migr_masc_pop') // Total population (with sample loadings)
	
	putexcel C100 = (`=total_nat_masc_15to64') E100 = (`=total_migr_masc_15to64') // Total persons 15-64 (with sample loadings)
	
** POPULATION
	
	putexcel D6 = (`=nat_fem_pop'/`=tot_fem_pop') F6 = (`=migr_fem_pop'/`=tot_fem_pop')	// Share of population
	
	putexcel D7 = (`=workAge_nat_fem_pop'/`=workAge_fem_pop') F7 = (`=workAge_migr_fem_pop'/`=workAge_fem_pop') // Share of working age population (15-64)
	
	putexcel D8 = (`=econoAct_nat_fem_pop'/`=econoAct_fem_pop') F8 = (`=econoAct_migr_fem_pop'/`=econoAct_fem_pop') // Share of labour force population (15-64)
	
	putexcel D9 = (`=emp_nat_fem_pop'/`=emp_fem_pop') F9 = (`=emp_migr_fem_pop'/`=emp_fem_pop') // Share of Employment rate  (15-64)
	
	
	** DEMOGRAPHIC
	
	putexcel D17 = (`=pop_nat_fem_014'/`=nat_fem_pop') F17 = (`=pop_migr_fem_014'/`=migr_fem_pop') // 0 - 14
	
	putexcel D18 = (`=pop_nat_fem_1524'/`=nat_fem_pop') F18 = (`=pop_migr_fem_1524'/`=migr_fem_pop') // 15 - 24
	
	putexcel D19 = (`=pop_nat_fem_2539'/`=nat_fem_pop') F19 = (`=pop_migr_fem_2539'/`=migr_fem_pop') // 25 - 39
	
	putexcel D20 = (`=pop_nat_fem_4054'/`=nat_fem_pop') F20 = (`=pop_migr_fem_4054'/`=migr_fem_pop') // 40 - 54
	
	putexcel D21 = (`=pop_nat_fem_5564'/`=nat_fem_pop') F21 = (`=pop_migr_fem_5564'/`=migr_fem_pop') // 55 - 64
	
	putexcel D22 = (`=pop_nat_fem_65older'/`=nat_fem_pop') F22 = (`=pop_migr_fem_65older'/`=migr_fem_pop') // 65 Older
	
	putexcel D23 = (`=workAge_nat_fem_pop'/`=nat_fem_pop') F23 = (`=workAge_migr_fem_pop'/`=migr_fem_pop') // 15-64 
	
	*putexcel D25 = (`=male_nat_pop'/`=nat_pop') F25 = (`=male_migr_pop'/`=migr_pop') 	// Sex male
	
	*putexcel D26 = (`=married_nat_fem_pop'/`=status_nat_fem_pop') F26 = (`=married_migr_fem_pop'/`=status_migr_fem_pop') // Marital status: married/cohabiting
	
	*putexcel D27 = (`=separated_nat_fem_pop'/`=status_nat_fem_pop') F27 = (`=separated_migr_fem_pop'/`=status_migr_fem_pop') // Marital status: separated/divorced/widowed

	*putexcel D28 = (`=single_nat_fem_pop'/`=status_nat_fem_pop') F28 = (`=single_migr_fem_pop'/`=status_migr_fem_pop') // Marital status: single
	
	putexcel D29 = (`=urban_nat_fem_pop'/`=nat_fem_pop') F29 = (`=urban_migr_fem_pop'/`=migr_fem_pop') // Urban
	
	putexcel D30 = (`=capital_nat_fem_pop'/`=nat_fem_pop')  F30 = (`=capital_migr_fem_pop'/`=migr_fem_pop') // Capital city located
	
	putexcel D31 = (`=borCity_nat_fem_pop'/`=nat_fem_pop')  F31 = (`=borCity_migr_fem_pop'/`=migr_fem_pop') // Border cities or region
	
	putexcel D34 = (`=size_nat_fem_house')  F34 = (`=size_migr_fem_house') // Household size
		
	putexcel D35 = (`=less18_nat_fem_house')  F35 = (`=less18_migr_fem_house') // Number of children <= 18 in household
		
	putexcel D36 = (`=less15_nat_fem_house')  F36 = (`=less15_migr_fem_house') // Number of children <= 15 in household
		
	// Number of natural-born children (women only)
	
	
	** LABOUR MARKET INDICATORS
	
	putexcel D41 = (`=job_nat_fem_pop'/`=workAge_nat_fem_pop') F41 = (`=job_migr_fem_pop'/`=workAge_migr_fem_pop') // Share of population with a job
	
	putexcel D42 = (`=econoAct_nat_fem_pop'/`=workAge_nat_fem_pop') F42 = (`=econoAct_migr_fem_pop'/`=workAge_migr_fem_pop') // Activity: Share participating in the labour force
	
	putexcel D43 = (`=inactive_nat_fem_pop'/`=workAge_nat_fem_pop') F43 = (`=inactive_migr_fem_pop'/`=workAge_migr_fem_pop')  // Economically inactive people
	
	putexcel D44 = (`=unemp_nat_fem_pop'/`=econoActWorkAge_nat_fem_pop') F44 = (`=unemp_migr_fem_pop'/`=econoActWorkAge_migr_fem_pop') // Unemployment: Share of population who were unemployed
	
	putexcel D45 = (`=long12_unemp_nat_fem_pop'/`=inac_unemp_nat_fem_pop') F45 = (`=long12_unemp_migr_fem_pop'/`=inac_unemp_migr_fem_pop') // Risk of labour market exclusion: long-term unemployment (12 month)
	
	putexcel D46 = (`=long6_unemp_nat_fem_pop'/`=inac_unemp_nat_fem_pop') F46 = (`=long6_unemp_migr_fem_pop'/`=inac_unemp_migr_fem_pop') // Risk of labour market exclusion: long-term unemployment (6 month)
	
	putexcel D47 = (`=involuntary_nat_fem_pop'/`=inac_unemp_nat_fem_pop') F47 = (`=involuntary_migr_fem_pop'/`=inac_unemp_migr_fem_pop') // Inactive involuntary (available past week, not looking for job)
	
	putexcel D48 = (`=long_invo_nat_fem_pop'/`=inac_unemp_nat_fem_pop') F48 = (`=long_invo_migr_fem_pop'/`=inac_unemp_migr_fem_pop') // Long-term uemployment >=12 months or inactive involuntary	
	
	putexcel D49 = (`=written_nat_fem_pop'/`=noself_edu_nat_fem_pop') F49 = (`=written_migr_fem_pop'/`=noself_edu_migr_fem_pop') // Share of population with written contract
	
	putexcel D50 = (`=informal_nat_fem_pop'/`=job_nat_fem_pop') F50 = (`=informal_migr_fem_pop'/`=job_migr_fem_pop') // Share of population with an informal job	
	
    // Share of population with an informal job (OECD def)
	
	putexcel D52 = (`=tempJob_nat_fem_pop'/`=noself_edu_nat_fem_pop') F52 = (`=tempJob_migr_fem_pop'/`=noself_edu_migr_fem_pop') // Types of contracts: Share of population in temporary contracts	
	
	putexcel D53 = (`=more40h_nat_fem_pop'/`=hours_nat_fem_pop') F53 = (`=more40h_migr_fem_pop'/`=hours_migr_fem_pop')  // Working hours: long (more than 40) hours	

	putexcel D54 = (`=more50h_nat_fem_pop'/`=hours_nat_fem_pop') F54 = (`=more50h_migr_fem_pop'/`=hours_migr_fem_pop')  // Working hours: long (more than 50) hours
	
	putexcel D55 = (`=more55h_nat_fem_pop'/`=hours_nat_fem_pop') F55 = (`=more55h_migr_fem_pop'/`=hours_migr_fem_pop')  // Working hours: long (more than 55) hours
	
	putexcel D56 = (`=less30h_nat_fem_pop'/`=hours_nat_fem_pop') F56 = (`=less30h_migr_fem_pop'/`=hours_migr_fem_pop')  // Working hours: long (less than 30) hours	
	
	putexcel D57 = (`=highSkill_nat_fem_pop'/`=NotMili_nat_fem_pop') F57 = (`=highSkill_migr_fem_pop'/`=NotMili_migr_fem_pop') // Job skills: share of working population in highly skilled jobs
	
	putexcel D58 = (`=lowSkill_nat_fem_pop'/`=NotMili_nat_fem_pop') F58 = (`=lowSkill_migr_fem_pop'/`=NotMili_migr_fem_pop') // Job skills: share of working population in low-skilled jobs 
		
	putexcel D59 = (`=overquali_nat_fem_pop'/`=NotEduNotMili_nat_fem_pop') F59 = (`=overquali_migr_fem_pop'/`=NotEduNotMili_migr_fem_pop') // Overqualification: share of highly educated individuals who work in low- or medium-skilled jobs

	putexcel D60 = (`=selfEmp_nat_fem_pop'/`=Notagri_emp1564_nat_fem_pop') F60 = (`=selfEmp_migr_fem_pop'/`=Notagri_emp1564_migr_fem_pop')   // Self-employment: share of population who work in their own firms or businesses
	
	putexcel D61 = (`=pubSec_nat_fem_pop'/`=NoSelf15to64_nat_fem_pop') F61 = (`=pubSec_migr_fem_pop'/`=NoSelf15to64_migr_fem_pop')   // Employment in the public sector
	
	putexcel D62 = (`=nmwage_nat_fem_')  F62 = (`=nmwage_migr_fem_') // Nominal monthly wage (USD)
	
	* Child labour
	
	
	** EDUCATION AND SKILLS
		
	putexcel D69 = (`=ISCED58_nat_fem_pop'/`=ISCEDEdu_nat_fem_pop') F69 = (`=ISCED58_migr_fem_pop'/`=ISCEDEdu_migr_fem_pop') // Level of educational attainment: high (ISCED groups 5-8)
		
	putexcel D70 = (`=ISCED02_nat_fem_pop'/`=ISCEDEdu_nat_fem_pop') F70 = (`=ISCED02_migr_fem_pop'/`=ISCEDEdu_migr_fem_pop') // Level of educational attainment: low (ISCED groups 0-2)
		
	putexcel D71 = (`=ISCED01_nat_fem_pop'/`=ISCEDEdu_nat_fem_pop') F71 = (`=ISCED01_migr_fem_pop'/`=ISCEDEdu_migr_fem_pop') // Level of educational attainment: very low (ISCED groups 0-1)
		
	putexcel D72 = (`=literacy_nat_fem_pop'/`=pop_nat_fem_1664') F72 = (`=literacy_migr_fem_pop'/`=pop_migr_fem_1664') // Literacy: knows how to read and write
	
	putexcel D73 = (`=NoEmpNoedu_nat_fem_pop'/`=age1534_nat_fem_pop') F73 = (`=NoEmpNoedu_migr_fem_pop'/`=age1534_migr_fem_pop')   // Neither in employment, education or training for youth
	
	putexcel D74 = (`=earlyLeft_nat_fem_pop'/`=earlyAge_nat_fem_pop') F74 = (`=earlyLeft_migr_fem_pop'/`=earlyAge_migr_fem_pop')  // Early school leaving
	
	putexcel D75 = (`=attending_5to16_nat_fem_pop'/`=pop_nat_fem_516') F75 = (`=attending_5to16_migr_fem_pop'/`=pop_migr_fem_516')  // Share of children attending schooling, 5 - 16 years group
	
	** CHILDREN EDUCATION AND EMPLOYMENT	
	
	putexcel D79 = (`=attending_15to18_nat_fem_pop'/`=pop_nat_fem_1518') F79 = (`=attending_15to18_migr_fem_pop'/`=pop_migr_fem_1518')  // Share of children attending school (15-18 year-olds)
	
	putexcel D80 = (`=employment_15to18_nat_fem_pop'/`=pop_nat_fem_1518') F80 = (`=employment_15to18_migr_fem_pop'/`=pop_migr_fem_1518')  // Share of children in employment (15-18 year-olds)
	
	putexcel D81 = (`=AttOnly_15to18_nat_fem_pop'/`=pop_nat_fem_1518') F81 = (`=AttOnly_15to18_migr_fem_pop'/`=pop_migr_fem_1518')  // Share of children attending school only (15-18 year-olds)
	
	putexcel D82 = (`=EmpOnly_15to18_nat_fem_pop'/`=pop_nat_fem_1518') F82 = (`=EmpOnly_15to18_migr_fem_pop'/`=pop_migr_fem_1518')  // Share of children in employment only (15-18 year-olds)
	
	putexcel D83 = (`=Att_Emp_1518_nat_fem_pop'/`=pop_nat_fem_1518') F83 = (`=Att_Emp_1518_migr_fem_pop'/`=pop_migr_fem_1518')  // Share of children attending school & in employment (15-18 year-olds)
	
	putexcel D84 = (`=NiNi_15to18_nat_fem_pop'/`=pop_nat_fem_1518') F84 = (`=NiNi_15to18_migr_fem_pop'/`=pop_migr_fem_1518')  // Neither in employment, education or training for youth (15-18 year-olds)
	
	**HEALTH
	
	* Health problems
	
	putexcel D91 = (`=healthSys_nat_fem_pop'/`=job15to64_nat_fem_pop') F91 = (`=healthSys_migr_fem_pop'/`=job15to64_migr_fem_pop') // Access to health services AMONG working pop
	
	** SIMPLE CHARACTERISTICS
	
	putexcel D96 = (`=survey_nat_fem_pop') F96 = (`=survey_migr_fem_pop') // Total sample size: persons
	
	putexcel D97 = (`=survey_nat_fem_15to64') F97 = (`=survey_migr_fem_15to64') // Total sample size: persons 15-64
	
	putexcel D99 = (`=nat_fem_pop') F99 = (`=migr_fem_pop') // Total population (with sample loadings)
	
	putexcel D100 = (`=total_nat_fem_15to64') F100 = (`=total_migr_fem_15to64') // Total persons 15-64 (with sample loadings)
	
	
********************************************************************************
********************************************************************************
********************************************************************************
****** PARAGUAY - HOUSEHOLD SURVEY EPHC 2020
	
	clear all
	set more off, perm
	set maxvar 15000
	scalar drop _all

	****************************************************************************
	** DATASET
	cd "C:\Users\jcamilop\OneDrive - Inter-American Development Bank Group\OECD\01 Raw"
	use "PRY_2020t4_BID.dta", replace

	gen uno=1
	*replace factor_ci=round(factor_ci) // Applies when the expansion factor is a non-integer numbers
	
	****************************************************************************
	** LOCALS
		local 1_label = "migr"
		local 0_label = "nat"
		
		local 1_sexo = "masc_"
		local 2_sexo = "fem_"
	
	****************************************************************************
	** ISCED
	gen ISCED = 0 if ed0504 == 0 | ed06c == 14
	replace ISCED = 0 if inlist(ed0504, 210 211, 212)
	replace ISCED = 1 if (ed0504 > 100 & ed0504 < 500) | (ed0504 > 1800 & ed0504 < 1901)
	replace ISCED = 2 if (ed0504 > 500 & ed0504 < 600) | (ed0504 > 1700 & ed0504 < 1800)
	replace ISCED = 3 if (ed0504 > 600 & ed0504 < 1700)
	replace ISCED = 4 if (ed0504 > 1700 & ed0504 < 2300) | inlist(ed06c, 7,11, 12)
	replace ISCED = 5 if inrange(ed06c, 2, 7)
	replace ISCED = 6 if (ed0504 > 2400 & ed0504 < 2500) | ed06c == 1
	replace ISCED = 7 if ed06c == 9 | ed06c == 10
	replace ISCED = 8 if ed06c == 8
	
	****************************************************************************
	** JOB QUALIFICATIONS - ISCO
	gen ISCO = real(substr(string(codocupa, "%5.0g"), 1, 1))
	gen length = strlen(string(codocupa))
	replace ISCO = 0 if length == 3		
	replace ISCO = 2 if inlist(codocupa, 1229, 3213, 3221, 3222, 3223, 3226, 3229, 3241, 3310, 3320, 3330, 3340, 3411, 3415, 3471, 3472, 3473, 3474)
	replace ISCO = 3 if inlist(codocupa, 1223, 2230, 2419, 4111, 4112, 4114, 4115, 4121, 4122, 4131, 4132, 4133, 4141, 4142, 4143, 4144, 4190, 4211, 4212, 4215, 4221, 4222, 4223, 5122, 5132, 7111, 7129, 7311, 8111, 8121, 8122, 8123, 8124, 8142, 8143, 8152, 8153, 8154, 8155, 8159, 8161, 8163, 8170, 8211, 8221, 8222, 8223, 8224, 8229, 8231, 8232, 8240, 8251, 8252, 8253, 8261, 8262, 8263, 8264, 8265, 8266, 8269, 8271, 8272, 8273, 8274, 8275, 8276, 8277, 8278, 8279, 8281, 8282, 8283, 8284, 8285, 8286, 8290)
	replace ISCO = 4 if codocupa == 3414
	replace ISCO = 5 if inlist(codocupa, 1213, 3242, 3340, 4211, 6129, 9111, 9113, 9141, 9152, 9170)
	replace ISCO = 7 if inlist(codocupa, 3152, 8211, 8240, 8251, 8252, 9335)
	replace ISCO = 8 if inlist(codocupa, 7111, 7344)
	replace ISCO = 9 if inlist(codocupa, 5122, 6113)
	gen overqualificated = 1 if inrange(ISCED,5,8) & inrange(ISCO,4,9)
	gen low_skilled = 1 if ISCO==9
	gen high_skilled = 1 if inrange(ISCO,1,3)
	
	****************************************************************************
	** Household size
	by idh_ch, sort: egen nmiembros=sum(relacion_ci>=1 & relacion_ci<5)
	by idh_ch, sort: egen nmenor18=sum((relacion_ci>=1 & relacion_ci<=4) & edad_ci<18)
	by idh_ch, sort: egen nmenor15=sum((relacion_ci>=1 & relacion_ci<=4) & edad_ci<15)
	
	****************************************************************************
	** Informalidad
	gen informal = 1 if cotizando_ci != 1 & emp_ci==1
	
	****************************************************************************
	** Working hours
	gen more_40 = 1 if horastot_ci >= 40
	replace more_40 = . if horastot_ci == .
	gen more_50 = 1 if horastot_ci >= 50
	replace more_50 = . if horastot_ci == .
	gen more_55 = 1 if horastot_ci >= 55
	replace more_55 = . if horastot_ci == .
	gen less_30 = 1 if horastot_ci <= 30
	replace less_30 = . if horastot_ci == .
	gen by_hours = 1 if emp_ci == 1
	replace by_hours = . if horastot_ci == .
	
	****************************************************************************
	** Nominal monthly wage (USD)
	by idh_ch, sort: egen nmwage=mean(ylm_ci)
	replace nmwage = (nmwage)/2591.04
	
	****************************************************************************
	** Months of unemployment
	gen more_12 = 1 if durades_ci>=12
	replace more_12 = . if durades_ci == .
	gen more_6 = 1 if durades_ci>=6
	replace more_6 = . if durades_ci == .
	
********************************************************************* STATISTICS
********************************************************************************
********************************************************************************

	** CALCULATION OF INDICATORS
	
	** POPULATION
	
	* Total population calculated according to expansion factor
	sum uno if migrante_ci!=. & sexo_ci == 1 [fw=factor_ci]
	scalar tot_masc_pop = `=r(N)'
	
	* Migrant population calculated according to expansion factor
	sum uno if migrante_ci==1 & sexo_ci == 1 [fw=factor_ci]
	scalar migr_masc_pop = `=r(N)'
	
	* Native population calculated according to expansion factor
	sum uno if migrante_ci==0 & sexo_ci == 1 [fw=factor_ci]
	scalar nat_masc_pop = `=r(N)'
	
	* Total population calculated according to expansion factor
	sum uno if migrante_ci!=. & sexo_ci == 2 [fw=factor_ci]
	scalar tot_fem_pop = `=r(N)'
	
	* Migrant population calculated according to expansion factor
	sum uno if migrante_ci==1 & sexo_ci == 2 [fw=factor_ci]
	scalar migr_fem_pop = `=r(N)'
	
	* Native population calculated according to expansion factor
	sum uno if migrante_ci==0 & sexo_ci == 2 [fw=factor_ci]
	scalar nat_fem_pop = `=r(N)'
	
	* Share of working age population (15-64) Male
	sum uno if inrange(edad_ci,15,64) & migrante_ci==1 & sexo_ci == 1 [fw=factor_ci]
	scalar workAge_migr_masc_pop = `=r(N)'
	sum uno if inrange(edad_ci,15,64) & migrante_ci==0 & sexo_ci == 1 [fw=factor_ci]
	scalar workAge_nat_masc_pop = `=r(N)'
	sum uno if inrange(edad_ci,15,64) & sexo_ci == 1 [fw=factor_ci]
	scalar workAge_masc_pop = `=r(N)'
		
	* Share of labour force population (15-64) Male
	sum uno if inrange(edad_ci,15,64) & pea_ci == 1 & migrante_ci==1 & sexo_ci == 1 [fw=factor_ci]
	scalar econoAct_migr_masc_pop = `=r(N)'
	sum uno if inrange(edad_ci,15,64) & pea_ci == 1 & migrante_ci==0 & sexo_ci == 1 [fw=factor_ci]
	scalar econoAct_nat_masc_pop = `=r(N)'
	sum uno if inrange(edad_ci,15,64) & pea_ci == 1 & sexo_ci == 1 [fw=factor_ci]
	scalar econoAct_masc_pop = `=r(N)'
	
	* Share of Employment rate  (15-64) Male
	sum uno if inrange(edad_ci,15,64) & emp_ci == 1 & migrante_ci==1 & sexo_ci == 1 [fw=factor_ci]
	scalar emp_migr_masc_pop = `=r(N)'
	sum uno if inrange(edad_ci,15,64) & emp_ci == 1 & migrante_ci==0 & sexo_ci == 1 [fw=factor_ci]
	scalar emp_nat_masc_pop = `=r(N)'
	sum uno if inrange(edad_ci,15,64) & emp_ci == 1 & sexo_ci == 1 [fw=factor_ci]
	scalar emp_masc_pop = `=r(N)'
	
	* Share of working age population (15-64) Female
	sum uno if inrange(edad_ci,15,64) & migrante_ci==1 & sexo_ci == 2 [fw=factor_ci]
	scalar workAge_migr_fem_pop = `=r(N)'
	sum uno if inrange(edad_ci,15,64) & migrante_ci==0 & sexo_ci == 2 [fw=factor_ci]
	scalar workAge_nat_fem_pop = `=r(N)'
	sum uno if inrange(edad_ci,15,64) & sexo_ci == 2 [fw=factor_ci]
	scalar workAge_fem_pop = `=r(N)'
		
	* Share of labour force population (15-64) Female
	sum uno if inrange(edad_ci,15,64) & pea_ci == 1 & migrante_ci==1 & sexo_ci == 2 [fw=factor_ci]
	scalar econoAct_migr_fem_pop = `=r(N)'
	sum uno if inrange(edad_ci,15,64) & pea_ci == 1 & migrante_ci==0 & sexo_ci == 2 [fw=factor_ci]
	scalar econoAct_nat_fem_pop = `=r(N)'
	sum uno if inrange(edad_ci,15,64) & pea_ci == 1 & sexo_ci == 2 [fw=factor_ci]
	scalar econoAct_fem_pop = `=r(N)'
	
	* Share of Employment rate  (15-64) Female
	sum uno if inrange(edad_ci,15,64) & emp_ci == 1 & migrante_ci==1 & sexo_ci == 2 [fw=factor_ci]
	scalar emp_migr_fem_pop = `=r(N)'
	sum uno if inrange(edad_ci,15,64) & emp_ci == 1 & migrante_ci==0 & sexo_ci == 2 [fw=factor_ci]
	scalar emp_nat_fem_pop = `=r(N)'
	sum uno if inrange(edad_ci,15,64) & emp_ci == 1 & sexo_ci == 2 [fw=factor_ci]
	scalar emp_fem_pop = `=r(N)'
	

	** CALCULATION OF INDICATORS BY MIGRANTS AND NATIVES
	
	foreach var in 1 0 {
		
		foreach sexo in 1 2 {
		
		** DEMOGRAPHIC
		
		* Age groups
		
		sum uno if inrange(edad_ci,0,14) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar pop_``var'_label'_``sexo'_sexo'014 = `=r(N)' // 0 - 14 years
		
		sum uno if inrange(edad_ci,15,24) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar pop_``var'_label'_``sexo'_sexo'1524 = `=r(N)' // 15 - 24 years

		sum uno if inrange(edad_ci,25,39) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar pop_``var'_label'_``sexo'_sexo'2539 = `=r(N)' // 25 - 39 years
		
		sum uno if inrange(edad_ci,40,54) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar pop_``var'_label'_``sexo'_sexo'4054 = `=r(N)' // 40 - 54 years

		sum uno if inrange(edad_ci,55,64) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar pop_``var'_label'_``sexo'_sexo'5564 = `=r(N)'	//55 - 64 years
		
		sum uno if inrange(edad_ci,65,.) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar pop_``var'_label'_``sexo'_sexo'65older = `=r(N)'  // 65 older years
		
		* Sex male population
		sum uno if sexo_ci==1 & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar male_``var'_label'_``sexo'_sexo'pop =`=r(N)'
		
		* Marital status: married/cohabiting
		sum uno if civil_ci==2 & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar married_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		sum uno if civil_ci!=. & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar status_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		* Marital status: separated/divorced/widowed
		sum uno if (civil_ci==3 | civil_ci==4) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar separated_``var'_label'_``sexo'_sexo'pop = `=r(N)'		
		
		* Marital status: single
		sum uno if civil_ci==1 & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar single_``var'_label'_``sexo'_sexo'pop = `=r(N)'		
		
		* Urban
		sum uno if zona_c==1 & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar urban_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		* Capital city located
		sum uno if (region_c==1 | region_c==6) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar capital_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		* Border cities or region
		sum uno if (region_c==3) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar borCity_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		* Household size
		sum nmiembros_ch if migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar size_``var'_label'_``sexo'_sexo'house = `=r(mean)'			
		
		* Number of children <= 18 in household
		sum nmenor18 if migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar less18_``var'_label'_``sexo'_sexo'house = `=r(mean)'			
		
		* Number of children <= 15 in household
		sum nmenor15 if migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar less15_``var'_label'_``sexo'_sexo'house = `=r(mean)'
		
		* Number of natural-born children (women only)
		
		
		** LABOUR MARKET INDICATORS
		
		* Share of population with a job
		sum uno if inrange(edad_ci,15,64) & emp_ci==1 & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar job_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		* Activity: Share participating in the labour force
		sum uno if inrange(edad_ci,15,64) & pea_ci==1 & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar econoAct_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		* Economically inactive people
		sum uno if inrange(edad_ci,15,64) & (condocup_ci == 3) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci] 
		scalar inactive_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		* Unemployment: Share of population who were unemployed
		sum uno if inrange(edad_ci,15,64) & desemp_ci==1 & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci] 
		scalar unemp_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		sum uno if pea_ci==1 & inrange(edad_ci,15,64) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar econoActWorkAge_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		* Risk of labour market exclusion: long-term unemployment (12 months)
		sum uno if inrange(edad_ci,15,64) & (more_12==1 & desemp_ci==1) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar long12_unemp_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		sum uno if inrange(edad_ci,15,64) & (desemp_ci==1 | condocup_ci==3) & durades_ci!=. & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci] 
		scalar inac_unemp_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		* Risk of labour market exclusion: long-term unemployment (6 months)
		sum uno if inrange(edad_ci,15,64) & (more_6==1 & desemp_ci==1) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar long6_unemp_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		* Risk of labour market exclusion: long-term uemployment >=12 months or inactive involuntary
		sum uno if inrange(edad_ci,15,64) & (desalent_ci==1 | (more_12==1 & desemp_ci==1)) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar long_invo_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		* Risk of labour market exclusion: Inactive involuntary (available past week, not looking for job)
		sum uno if inrange(edad_ci,15,64) & desalent_ci==1 & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar involuntary_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		* Share of population with written contract
		sum uno if inrange(edad_ci,15,64) & inlist(tipocontrato_ci,0,1,2) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar written_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		sum uno if inrange(edad_ci,15,64) & inlist(tipocontrato_ci,0,1,2) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar written_``var'_label'_``sexo'_sexo'pop = `=r(N)'		
		
		* Share of population with an informal job
		sum uno if inrange(edad_ci,15,64) & formal_ci==0 & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar informal_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		* Types of contracts:  Share of population in temporary contracts
		sum uno if inrange(edad_ci,15,64) & tipocontrato_ci==2 & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci] 
		scalar tempJob_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		sum uno if inrange(edad_ci,15,64) & categopri_ci!=2 & asiste_ci!=1 & emp_ci==1 & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar noself_edu_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		* Working hours: long hours >= 40
		sum uno if inrange(edad_ci,15,64) & more_40==1 & emp_ci == 1 & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar more40h_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		sum uno if inrange(edad_ci,15,64) & by_hours==1 & emp_ci == 1 & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar hours_``var'_label'_``sexo'_sexo'pop = `=r(N)'

		* Working hours: long hours >= 50
		sum uno if inrange(edad_ci,15,64) & more_50==1 & emp_ci == 1 & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar more50h_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		* Working hours: long hours >= 55
		sum uno if inrange(edad_ci,15,64) & more_55==1 & emp_ci == 1 & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar more55h_``var'_label'_``sexo'_sexo'pop = `=r(N)'		
	
		* Working hours: long hours < 30
		sum uno if inrange(edad_ci,15,64) & less_30==1 & emp_ci == 1 & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar less30h_``var'_label'_``sexo'_sexo'pop = `=r(N)'

		* Job skills: share of working population in highly skilled jobs
		sum uno if high_skilled==1 & inrange(edad_ci,15,64) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar highSkill_``var'_label'_``sexo'_sexo'pop = `=r(N)'		
		
		* Job skills: share of working population in low-skilled jobs
		sum uno if low_skilled==1 & inrange(edad_ci,15,64) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar lowSkill_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		sum uno if emp_ci==1 & inrange(edad_ci,15,64) & ISCO!=0 & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar NotMili_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		* Overqualification: share of highly educated individuals who work in low- or medium-skilled jobs
		sum uno if overqualificated==1 & inrange(edad_ci,15,64) & migrante_ci==`var' & sexo_ci==`sexo' & inrange(ISCED,4,9) [fw=factor_ci]
		scalar overquali_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		sum uno if emp_ci==1 & inrange(edad_ci,15,64) & asiste_ci!=1 & ISCO!=0 & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar NotEduNotMili_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		* Self-employment: share of population who works in their own firms or businesses
		sum uno if (categopri_ci==1 | categopri_ci==2) & inrange(edad_ci,15,64) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar selfEmp_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		sum uno if inrange(edad_ci,15,64) & rama_ci!=1 & emp_ci==1 & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar Notagri_emp1564_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		* Employment in the public sector
		sum uno if spublico_ci==1 & inrange(edad_ci,15,64) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar pubSec_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		sum uno if inrange(edad_ci,15,64) & emp_ci==1 & categopri_ci!=2 & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar NoSelf15to64_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		* Nominal monthly wage (USD)
		sum nmwage if migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar nmwage_``var'_label'_``sexo'_sexo' = `=r(mean)'
		
		* Child labour
		

		** EDUCATION AND SKILLS
		
		* Level of educational attainment: high (ISCED groups 5-8)
		sum uno if inrange(ISCED,5,8) & inrange(edad_ci,15,64) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar ISCED58_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		sum uno if inrange(edad_ci,15,64) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar ISCEDEdu_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		* Level of educational attainment: low (ISCED groups 0-2)
		sum uno if inrange(ISCED,0,2) & inrange(edad_ci,15,64) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar ISCED02_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		* Level of educational attainment: very low (ISCED groups 0-1)
		sum uno if inrange(ISCED,0,1) & inrange(edad_ci,15,64) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar ISCED01_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		* Literacy: knows how to read and write 
		sum uno if ed02 == 1 & inrange(edad_ci,16,64) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar literacy_``var'_label'_``sexo'_sexo'pop = `=r(N)'		
		
		sum uno if inrange(edad_ci,16,64) & migrante_ci==`var' [fw=factor_ci] 
		scalar pop_``var'_label'_``sexo'_sexo'1664 = `=r(N)'
		
		* Neither in employment, education or training for youth
		sum uno if (edad_ci>=15 & edad_ci <=34) & emp_ci!=1 & asiste_ci==0 & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar NoEmpNoedu_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		sum uno if inrange(edad_ci,15,34) & migrante_ci==`var' [fw=factor_ci]
		scalar age1534_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		* Early school leaving
		sum uno if asiste_ci == 0 & (edad_ci>=15 & edad_ci <=24) & inlist(ISCED,0,1,2) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar earlyLeft_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		sum uno if inrange(edad_ci,15,24) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar earlyAge_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		* Share of children attending schooling, 5 - 16 years group
		sum uno if asiste_ci==1 & inrange(edad_ci,5,16) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar attending_5to16_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		sum uno if inrange(edad_ci,5,16) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci] 
		scalar pop_``var'_label'_``sexo'_sexo'516 = `=r(N)'
		
		** CHILDREN EDUCATION AND EMPLOYMENT
		
		* Share of children attending school (15-18 year-olds)
		sum uno if asiste_ci==1 & inrange(edad_ci,15,18) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar attending_15to18_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		sum uno if inrange(edad_ci,15,18) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci] 
		scalar pop_``var'_label'_``sexo'_sexo'1518 = `=r(N)'
		
		* Share of children in employment (15-18 year-olds)
		sum uno if emp_ci==1 & inrange(edad_ci,15,18) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar employment_15to18_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		* Share of children attending school only (15-18 year-olds)
		sum uno if (asiste_ci==1 & emp_ci!=1) & inrange(edad_ci,15,18) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar AttOnly_15to18_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		* Share of children in employment only (15-18 year-olds)
		sum uno if (emp_ci==1 & asiste_ci!=1) & inrange(edad_ci,15,18) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar EmpOnly_15to18_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		* Share of children attending school & in employment (15-18 year-olds)
		sum uno if (asiste_ci==1 & emp_ci==1) & inrange(edad_ci,15,18) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar Att_Emp_1518_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		* Neither in employment, education or training for youth (15-18 year-olds)
		sum uno if (edad_ci>=15 & edad_ci <=18) & emp_ci==0 & asiste_ci==0 & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar NiNi_15to18_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		** HEALTH
		
		* Access to health services AMONG working pop
		sum uno if inrange(edad_ci,15,64) & (afiliado_ci==1 | cotizando_ci==1) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci] 
		scalar healthSys_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		sum uno if inrange(edad_ci,15,64) & emp_ci==1 & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar job15to64_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		** SAMPLE CHARACTERISTICS
		
		* Total sample size: persons 
		sum uno if migrante_ci==`var' & sexo_ci==`sexo'
		scalar survey_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		* Total sample size: persons 15-64
		sum uno if inrange(edad_ci,15,64) & migrante_ci==`var' & sexo_ci==`sexo'
		scalar survey_``var'_label'_``sexo'_sexo'15to64 = `=r(N)'

		* Total persons 15-64 (with sample loadings)
		sum uno if inrange(edad_ci,15,64) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar total_``var'_label'_``sexo'_sexo'15to64 = `=r(N)'
		
	}
	
		}
	
******************************************************** EXCEL OUTPUTS

	putexcel set "C:\Users\jcamilop\OneDrive - Inter-American Development Bank Group\OECD\03 Outputs\Resultados por sexo.xlsx", sheet("Paraguay") modify
	putexcel describe
	
	** POPULATION
	
	putexcel C6 = (`=nat_masc_pop'/`=tot_masc_pop') E6 = (`=migr_masc_pop'/`=tot_masc_pop')	// Share of population
	
	putexcel C7 = (`=workAge_nat_masc_pop'/`=workAge_masc_pop') E7 = (`=workAge_migr_masc_pop'/`=workAge_masc_pop') // Share of working age population (15-64)
	
	putexcel C8 = (`=econoAct_nat_masc_pop'/`=econoAct_masc_pop') E8 = (`=econoAct_migr_masc_pop'/`=econoAct_masc_pop') // Share of labour force population (15-64)
	
	putexcel C9 = (`=emp_nat_masc_pop'/`=emp_masc_pop') E9 = (`=emp_migr_masc_pop'/`=emp_masc_pop') // Share of Employment rate  (15-64)
	
	
	** DEMOGRAPHIC
	
	putexcel C17 = (`=pop_nat_masc_014'/`=nat_masc_pop') E17 = (`=pop_migr_masc_014'/`=migr_masc_pop') // 0 - 14
	
	putexcel C18 = (`=pop_nat_masc_1524'/`=nat_masc_pop') E18 = (`=pop_migr_masc_1524'/`=migr_masc_pop') // 15 - 24
	
	putexcel C19 = (`=pop_nat_masc_2539'/`=nat_masc_pop') E19 = (`=pop_migr_masc_2539'/`=migr_masc_pop') // 25 - 39
	
	putexcel C20 = (`=pop_nat_masc_4054'/`=nat_masc_pop') E20 = (`=pop_migr_masc_4054'/`=migr_masc_pop') // 40 - 54
	
	putexcel C21 = (`=pop_nat_masc_5564'/`=nat_masc_pop') E21 = (`=pop_migr_masc_5564'/`=migr_masc_pop') // 55 - 64
	
	putexcel C22 = (`=pop_nat_masc_65older'/`=nat_masc_pop') E22 = (`=pop_migr_masc_65older'/`=migr_masc_pop') // 65 Older
	
	putexcel C23 = (`=workAge_nat_masc_pop'/`=nat_masc_pop') E23 = (`=workAge_migr_masc_pop'/`=migr_masc_pop') // 15-64 
	
	*putexcel C25 = (`=male_nat_pop'/`=nat_pop') E25 = (`=male_migr_pop'/`=migr_pop') 	// Sex male
	
	putexcel C26 = (`=married_nat_masc_pop'/`=status_nat_masc_pop') E26 = (`=married_migr_masc_pop'/`=status_migr_masc_pop') // Marital status: married/cohabiting
	
	putexcel C27 = (`=separated_nat_masc_pop'/`=status_nat_masc_pop') E27 = (`=separated_migr_masc_pop'/`=status_migr_masc_pop') // Marital status: separated/divorced/widowed

	putexcel C28 = (`=single_nat_masc_pop'/`=status_nat_masc_pop') E28 = (`=single_migr_masc_pop'/`=status_migr_masc_pop') // Marital status: single
	
	putexcel C29 = (`=urban_nat_masc_pop'/`=nat_masc_pop') E29 = (`=urban_migr_masc_pop'/`=migr_masc_pop') // Urban
	
	putexcel C30 = (`=capital_nat_masc_pop'/`=nat_masc_pop')  E30 = (`=capital_migr_masc_pop'/`=migr_masc_pop') // Capital city located
	
	putexcel C31 = (`=borCity_nat_masc_pop'/`=nat_masc_pop')  E31 = (`=borCity_migr_masc_pop'/`=migr_masc_pop') // Border cities or region
	
	putexcel C34 = (`=size_nat_masc_house')  E34 = (`=size_migr_masc_house') // Household size
		
	putexcel C35 = (`=less18_nat_masc_house')  E35 = (`=less18_migr_masc_house') // Number of children <= 18 in household
		
	putexcel C36 = (`=less15_nat_masc_house')  E36 = (`=less15_migr_masc_house') // Number of children <= 15 in household
		
	// Number of natural-born children (women only)
	
	
	** LABOUR MARKET INDICATORS
	
	putexcel C41 = (`=job_nat_masc_pop'/`=workAge_nat_masc_pop') E41 = (`=job_migr_masc_pop'/`=workAge_migr_masc_pop') // Share of population with a job
	
	putexcel C42 = (`=econoAct_nat_masc_pop'/`=workAge_nat_masc_pop') E42 = (`=econoAct_migr_masc_pop'/`=workAge_migr_masc_pop') // Activity: Share participating in the labour force
	
	putexcel C43 = (`=inactive_nat_masc_pop'/`=workAge_nat_masc_pop') E43 = (`=inactive_migr_masc_pop'/`=workAge_migr_masc_pop')  // Economically inactive people
	
	putexcel C44 = (`=unemp_nat_masc_pop'/`=econoActWorkAge_nat_masc_pop') E44 = (`=unemp_migr_masc_pop'/`=econoActWorkAge_migr_masc_pop') // Unemployment: Share of population who were unemployed
	
	putexcel C45 = (`=long12_unemp_nat_masc_pop'/`=inac_unemp_nat_masc_pop') E45 = (`=long12_unemp_migr_masc_pop'/`=inac_unemp_migr_masc_pop') // Risk of labour market exclusion: long-term unemployment (12 month)
	
	putexcel C46 = (`=long6_unemp_nat_masc_pop'/`=inac_unemp_nat_masc_pop') E46 = (`=long6_unemp_migr_masc_pop'/`=inac_unemp_migr_masc_pop') // Risk of labour market exclusion: long-term unemployment (6 month)
	
	putexcel C47 = (`=involuntary_nat_masc_pop'/`=inac_unemp_nat_masc_pop') E47 = (`=involuntary_migr_masc_pop'/`=inac_unemp_migr_masc_pop') // Inactive involuntary (available past week, not looking for job)
	
	putexcel C48 = (`=long_invo_nat_masc_pop'/`=inac_unemp_nat_masc_pop') E48 = (`=long_invo_migr_masc_pop'/`=inac_unemp_migr_masc_pop') // Long-term uemployment >=12 months or inactive involuntary	
	
	putexcel C49 = (`=written_nat_masc_pop'/`=noself_edu_nat_masc_pop') E49 = (`=written_migr_masc_pop'/`=noself_edu_migr_masc_pop') // Share of population with written contract
	
	putexcel C50 = (`=informal_nat_masc_pop'/`=workAge_nat_masc_pop') E50 = (`=informal_migr_masc_pop'/`=workAge_migr_masc_pop') // Share of population with an informal job	
	
    // Share of population with an informal job (OECD def)
	
	putexcel C52 = (`=tempJob_nat_masc_pop'/`=noself_edu_nat_masc_pop') E52 = (`=tempJob_migr_masc_pop'/`=noself_edu_migr_masc_pop') // Types of contracts: Share of population in temporary contracts	
	
	putexcel C53 = (`=more40h_nat_masc_pop'/`=hours_nat_masc_pop') E53 = (`=more40h_migr_masc_pop'/`=hours_migr_masc_pop')  // Working hours: long (more than 40) hours	

	putexcel C54 = (`=more50h_nat_masc_pop'/`=hours_nat_masc_pop') E54 = (`=more50h_migr_masc_pop'/`=hours_migr_masc_pop')  // Working hours: long (more than 50) hours
	
	putexcel C55 = (`=more55h_nat_masc_pop'/`=hours_nat_masc_pop') E55 = (`=more55h_migr_masc_pop'/`=hours_migr_masc_pop')  // Working hours: long (more than 55) hours
	
	putexcel C56 = (`=less30h_nat_masc_pop'/`=hours_nat_masc_pop') E56 = (`=less30h_migr_masc_pop'/`=hours_migr_masc_pop')  // Working hours: long (less than 30) hours	
	
	putexcel C57 = (`=highSkill_nat_masc_pop'/`=NotMili_nat_masc_pop') E57 = (`=highSkill_migr_masc_pop'/`=NotMili_migr_masc_pop') // Job skills: share of working population in highly skilled jobs
	
	putexcel C58 = (`=lowSkill_nat_masc_pop'/`=NotMili_nat_masc_pop') E58 = (`=lowSkill_migr_masc_pop'/`=NotMili_migr_masc_pop') // Job skills: share of working population in low-skilled jobs 
		
	putexcel C59 = (`=overquali_nat_masc_pop'/`=NotEduNotMili_nat_masc_pop') E59 = (`=overquali_migr_masc_pop'/`=NotEduNotMili_migr_masc_pop') // Overqualification: share of highly educated individuals who work in low- or medium-skilled jobs

	putexcel C60 = (`=selfEmp_nat_masc_pop'/`=Notagri_emp1564_nat_masc_pop') E60 = (`=selfEmp_migr_masc_pop'/`=Notagri_emp1564_migr_masc_pop')   // Self-employment: share of population who work in their own firms or businesses
	
	putexcel C61 = (`=pubSec_nat_masc_pop'/`=NoSelf15to64_nat_masc_pop') E61 = (`=pubSec_migr_masc_pop'/`=NoSelf15to64_migr_masc_pop')   // Employment in the public sector
	
	putexcel C62 = (`=nmwage_nat_masc_')  E62 = (`=nmwage_migr_masc_') // Nominal monthly wage (USD)
	
	* Child labour
	
	
	** EDUCATION AND SKILLS
		
	putexcel C69 = (`=ISCED58_nat_masc_pop'/`=ISCEDEdu_nat_masc_pop') E69 = (`=ISCED58_migr_masc_pop'/`=ISCEDEdu_migr_masc_pop') // Level of educational attainment: high (ISCED groups 5-8)
		
	putexcel C70 = (`=ISCED02_nat_masc_pop'/`=ISCEDEdu_nat_masc_pop') E70 = (`=ISCED02_migr_masc_pop'/`=ISCEDEdu_migr_masc_pop') // Level of educational attainment: low (ISCED groups 0-2)
		
	putexcel C71 = (`=ISCED01_nat_masc_pop'/`=ISCEDEdu_nat_masc_pop') E71 = (`=ISCED01_migr_masc_pop'/`=ISCEDEdu_migr_masc_pop') // Level of educational attainment: very low (ISCED groups 0-1)
		
	putexcel C72 = (`=literacy_nat_masc_pop'/`=pop_nat_masc_1664') E72 = (`=literacy_migr_masc_pop'/`=pop_migr_masc_1664') // Literacy: knows how to read and write
	
	putexcel C73 = (`=NoEmpNoedu_nat_masc_pop'/`=age1534_nat_masc_pop') E73 = (`=NoEmpNoedu_migr_masc_pop'/`=age1534_migr_masc_pop')   // Neither in employment, education or training for youth
	
	putexcel C74 = (`=earlyLeft_nat_masc_pop'/`=earlyAge_nat_masc_pop') E74 = (`=earlyLeft_migr_masc_pop'/`=earlyAge_migr_masc_pop')  // Early school leaving
	
	putexcel C75 = (`=attending_5to16_nat_masc_pop'/`=pop_nat_masc_516') E75 = (`=attending_5to16_migr_masc_pop'/`=pop_migr_masc_516')  // Share of children attending schooling, 5 - 16 years group
	
	** CHILDREN EDUCATION AND EMPLOYMENT	
	
	putexcel C79 = (`=attending_15to18_nat_masc_pop'/`=pop_nat_masc_1518') E79 = (`=attending_15to18_migr_masc_pop'/`=pop_migr_masc_1518')  // Share of children attending school (15-18 year-olds)
	
	putexcel C80 = (`=employment_15to18_nat_masc_pop'/`=pop_nat_masc_1518') E80 = (`=employment_15to18_migr_masc_pop'/`=pop_migr_masc_1518')  // Share of children in employment (15-18 year-olds)
	
	putexcel C81 = (`=AttOnly_15to18_nat_masc_pop'/`=pop_nat_masc_1518') E81 = (`=AttOnly_15to18_migr_masc_pop'/`=pop_migr_masc_1518')  // Share of children attending school only (15-18 year-olds)
	
	putexcel C82 = (`=EmpOnly_15to18_nat_masc_pop'/`=pop_nat_masc_1518') E82 = (`=EmpOnly_15to18_migr_masc_pop'/`=pop_migr_masc_1518')  // Share of children in employment only (15-18 year-olds)
	
	putexcel C83 = (`=Att_Emp_1518_nat_masc_pop'/`=pop_nat_masc_1518') E83 = (`=Att_Emp_1518_migr_masc_pop'/`=pop_migr_masc_1518')  // Share of children attending school & in employment (15-18 year-olds)
	
	putexcel C84 = (`=NiNi_15to18_nat_masc_pop'/`=pop_nat_masc_1518') E84 = (`=NiNi_15to18_migr_masc_pop'/`=pop_migr_masc_1518')  // Neither in employment, education or training for youth (15-18 year-olds)
	
	**HEALTH
	
	* Health problems
	
	putexcel C91 = (`=healthSys_nat_masc_pop'/`=job15to64_nat_masc_pop') E91 = (`=healthSys_migr_masc_pop'/`=job15to64_migr_masc_pop') // Access to health services AMONG working pop
	
	** SIMPLE CHARACTERISTICS
	
	putexcel C96 = (`=survey_nat_masc_pop') E96 = (`=survey_migr_masc_pop') // Total sample size: persons
	
	putexcel C97 = (`=survey_nat_masc_15to64') E97 = (`=survey_migr_masc_15to64') // Total sample size: persons 15-64
	
	putexcel C99 = (`=nat_masc_pop') E99 = (`=migr_masc_pop') // Total population (with sample loadings)
	
	putexcel C100 = (`=total_nat_masc_15to64') E100 = (`=total_migr_masc_15to64') // Total persons 15-64 (with sample loadings)
	
** POPULATION
	
	putexcel D6 = (`=nat_fem_pop'/`=tot_fem_pop') F6 = (`=migr_fem_pop'/`=tot_fem_pop')	// Share of population
	
	putexcel D7 = (`=workAge_nat_fem_pop'/`=workAge_fem_pop') F7 = (`=workAge_migr_fem_pop'/`=workAge_fem_pop') // Share of working age population (15-64)
	
	putexcel D8 = (`=econoAct_nat_fem_pop'/`=econoAct_fem_pop') F8 = (`=econoAct_migr_fem_pop'/`=econoAct_fem_pop') // Share of labour force population (15-64)
	
	putexcel D9 = (`=emp_nat_fem_pop'/`=emp_fem_pop') F9 = (`=emp_migr_fem_pop'/`=emp_fem_pop') // Share of Employment rate  (15-64)
	
	
	** DEMOGRAPHIC
	
	putexcel D17 = (`=pop_nat_fem_014'/`=nat_fem_pop') F17 = (`=pop_migr_fem_014'/`=migr_fem_pop') // 0 - 14
	
	putexcel D18 = (`=pop_nat_fem_1524'/`=nat_fem_pop') F18 = (`=pop_migr_fem_1524'/`=migr_fem_pop') // 15 - 24
	
	putexcel D19 = (`=pop_nat_fem_2539'/`=nat_fem_pop') F19 = (`=pop_migr_fem_2539'/`=migr_fem_pop') // 25 - 39
	
	putexcel D20 = (`=pop_nat_fem_4054'/`=nat_fem_pop') F20 = (`=pop_migr_fem_4054'/`=migr_fem_pop') // 40 - 54
	
	putexcel D21 = (`=pop_nat_fem_5564'/`=nat_fem_pop') F21 = (`=pop_migr_fem_5564'/`=migr_fem_pop') // 55 - 64
	
	putexcel D22 = (`=pop_nat_fem_65older'/`=nat_fem_pop') F22 = (`=pop_migr_fem_65older'/`=migr_fem_pop') // 65 Older
	
	putexcel D23 = (`=workAge_nat_fem_pop'/`=nat_fem_pop') F23 = (`=workAge_migr_fem_pop'/`=migr_fem_pop') // 15-64 
	
	*putexcel D25 = (`=male_nat_pop'/`=nat_pop') F25 = (`=male_migr_pop'/`=migr_pop') 	// Sex male
	
	putexcel D26 = (`=married_nat_fem_pop'/`=status_nat_fem_pop') F26 = (`=married_migr_fem_pop'/`=status_migr_fem_pop') // Marital status: married/cohabiting
	
	putexcel D27 = (`=separated_nat_fem_pop'/`=status_nat_fem_pop') F27 = (`=separated_migr_fem_pop'/`=status_migr_fem_pop') // Marital status: separated/divorced/widowed

	putexcel D28 = (`=single_nat_fem_pop'/`=status_nat_fem_pop') F28 = (`=single_migr_fem_pop'/`=status_migr_fem_pop') // Marital status: single
	
	putexcel D29 = (`=urban_nat_fem_pop'/`=nat_fem_pop') F29 = (`=urban_migr_fem_pop'/`=migr_fem_pop') // Urban
	
	putexcel D30 = (`=capital_nat_fem_pop'/`=nat_fem_pop')  F30 = (`=capital_migr_fem_pop'/`=migr_fem_pop') // Capital city located
	
	putexcel D31 = (`=borCity_nat_fem_pop'/`=nat_fem_pop')  F31 = (`=borCity_migr_fem_pop'/`=migr_fem_pop') // Border cities or region
	
	putexcel D34 = (`=size_nat_fem_house')  F34 = (`=size_migr_fem_house') // Household size
		
	putexcel D35 = (`=less18_nat_fem_house')  F35 = (`=less18_migr_fem_house') // Number of children <= 18 in household
		
	putexcel D36 = (`=less15_nat_fem_house')  F36 = (`=less15_migr_fem_house') // Number of children <= 15 in household
		
	// Number of natural-born children (women only)
	
	
	** LABOUR MARKET INDICATORS
	
	putexcel D41 = (`=job_nat_fem_pop'/`=workAge_nat_fem_pop') F41 = (`=job_migr_fem_pop'/`=workAge_migr_fem_pop') // Share of population with a job
	
	putexcel D42 = (`=econoAct_nat_fem_pop'/`=workAge_nat_fem_pop') F42 = (`=econoAct_migr_fem_pop'/`=workAge_migr_fem_pop') // Activity: Share participating in the labour force
	
	putexcel D43 = (`=inactive_nat_fem_pop'/`=workAge_nat_fem_pop') F43 = (`=inactive_migr_fem_pop'/`=workAge_migr_fem_pop')  // Economically inactive people
	
	putexcel D44 = (`=unemp_nat_fem_pop'/`=econoActWorkAge_nat_fem_pop') F44 = (`=unemp_migr_fem_pop'/`=econoActWorkAge_migr_fem_pop') // Unemployment: Share of population who were unemployed
	
	putexcel D45 = (`=long12_unemp_nat_fem_pop'/`=inac_unemp_nat_fem_pop') F45 = (`=long12_unemp_migr_fem_pop'/`=inac_unemp_migr_fem_pop') // Risk of labour market exclusion: long-term unemployment (12 month)
	
	putexcel D46 = (`=long6_unemp_nat_fem_pop'/`=inac_unemp_nat_fem_pop') F46 = (`=long6_unemp_migr_fem_pop'/`=inac_unemp_migr_fem_pop') // Risk of labour market exclusion: long-term unemployment (6 month)
	
	putexcel D47 = (`=involuntary_nat_fem_pop'/`=inac_unemp_nat_fem_pop') F47 = (`=involuntary_migr_fem_pop'/`=inac_unemp_migr_fem_pop') // Inactive involuntary (available past week, not looking for job)
	
	putexcel D48 = (`=long_invo_nat_fem_pop'/`=inac_unemp_nat_fem_pop') F48 = (`=long_invo_migr_fem_pop'/`=inac_unemp_migr_fem_pop') // Long-term uemployment >=12 months or inactive involuntary	
	
	putexcel D49 = (`=written_nat_fem_pop'/`=noself_edu_nat_fem_pop') F49 = (`=written_migr_fem_pop'/`=noself_edu_migr_fem_pop') // Share of population with written contract
	
	putexcel D50 = (`=informal_nat_fem_pop'/`=workAge_nat_fem_pop') F50 = (`=informal_migr_fem_pop'/`=workAge_migr_fem_pop') // Share of population with an informal job	
	
    // Share of population with an informal job (OECD def)
	
	putexcel D52 = (`=tempJob_nat_fem_pop'/`=noself_edu_nat_fem_pop') F52 = (`=tempJob_migr_fem_pop'/`=noself_edu_migr_fem_pop') // Types of contracts: Share of population in temporary contracts	
	
	putexcel D53 = (`=more40h_nat_fem_pop'/`=hours_nat_fem_pop') F53 = (`=more40h_migr_fem_pop'/`=hours_migr_fem_pop')  // Working hours: long (more than 40) hours	

	putexcel D54 = (`=more50h_nat_fem_pop'/`=hours_nat_fem_pop') F54 = (`=more50h_migr_fem_pop'/`=hours_migr_fem_pop')  // Working hours: long (more than 50) hours
	
	putexcel D55 = (`=more55h_nat_fem_pop'/`=hours_nat_fem_pop') F55 = (`=more55h_migr_fem_pop'/`=hours_migr_fem_pop')  // Working hours: long (more than 55) hours
	
	putexcel D56 = (`=less30h_nat_fem_pop'/`=hours_nat_fem_pop') F56 = (`=less30h_migr_fem_pop'/`=hours_migr_fem_pop')  // Working hours: long (less than 30) hours	
	
	putexcel D57 = (`=highSkill_nat_fem_pop'/`=NotMili_nat_fem_pop') F57 = (`=highSkill_migr_fem_pop'/`=NotMili_migr_fem_pop') // Job skills: share of working population in highly skilled jobs
	
	putexcel D58 = (`=lowSkill_nat_fem_pop'/`=NotMili_nat_fem_pop') F58 = (`=lowSkill_migr_fem_pop'/`=NotMili_migr_fem_pop') // Job skills: share of working population in low-skilled jobs 
		
	putexcel D59 = (`=overquali_nat_fem_pop'/`=NotEduNotMili_nat_fem_pop') F59 = (`=overquali_migr_fem_pop'/`=NotEduNotMili_migr_fem_pop') // Overqualification: share of highly educated individuals who work in low- or medium-skilled jobs

	putexcel D60 = (`=selfEmp_nat_fem_pop'/`=Notagri_emp1564_nat_fem_pop') F60 = (`=selfEmp_migr_fem_pop'/`=Notagri_emp1564_migr_fem_pop')   // Self-employment: share of population who work in their own firms or businesses
	
	putexcel D61 = (`=pubSec_nat_fem_pop'/`=NoSelf15to64_nat_fem_pop') F61 = (`=pubSec_migr_fem_pop'/`=NoSelf15to64_migr_fem_pop')   // Employment in the public sector
	
	putexcel D62 = (`=nmwage_nat_fem_')  F62 = (`=nmwage_migr_fem_') // Nominal monthly wage (USD)
	
	* Child labour
	
	
	** EDUCATION AND SKILLS
		
	putexcel D69 = (`=ISCED58_nat_fem_pop'/`=ISCEDEdu_nat_fem_pop') F69 = (`=ISCED58_migr_fem_pop'/`=ISCEDEdu_migr_fem_pop') // Level of educational attainment: high (ISCED groups 5-8)
		
	putexcel D70 = (`=ISCED02_nat_fem_pop'/`=ISCEDEdu_nat_fem_pop') F70 = (`=ISCED02_migr_fem_pop'/`=ISCEDEdu_migr_fem_pop') // Level of educational attainment: low (ISCED groups 0-2)
		
	putexcel D71 = (`=ISCED01_nat_fem_pop'/`=ISCEDEdu_nat_fem_pop') F71 = (`=ISCED01_migr_fem_pop'/`=ISCEDEdu_migr_fem_pop') // Level of educational attainment: very low (ISCED groups 0-1)
		
	putexcel D72 = (`=literacy_nat_fem_pop'/`=pop_nat_fem_1664') F72 = (`=literacy_migr_fem_pop'/`=pop_migr_fem_1664') // Literacy: knows how to read and write
	
	putexcel D73 = (`=NoEmpNoedu_nat_fem_pop'/`=age1534_nat_fem_pop') F73 = (`=NoEmpNoedu_migr_fem_pop'/`=age1534_migr_fem_pop')   // Neither in employment, education or training for youth
	
	putexcel D74 = (`=earlyLeft_nat_fem_pop'/`=earlyAge_nat_fem_pop') F74 = (`=earlyLeft_migr_fem_pop'/`=earlyAge_migr_fem_pop')  // Early school leaving
	
	putexcel D75 = (`=attending_5to16_nat_fem_pop'/`=pop_nat_fem_516') F75 = (`=attending_5to16_migr_fem_pop'/`=pop_migr_fem_516')  // Share of children attending schooling, 5 - 16 years group
	
	** CHILDREN EDUCATION AND EMPLOYMENT	
	
	putexcel D79 = (`=attending_15to18_nat_fem_pop'/`=pop_nat_fem_1518') F79 = (`=attending_15to18_migr_fem_pop'/`=pop_migr_fem_1518')  // Share of children attending school (15-18 year-olds)
	
	putexcel D80 = (`=employment_15to18_nat_fem_pop'/`=pop_nat_fem_1518') F80 = (`=employment_15to18_migr_fem_pop'/`=pop_migr_fem_1518')  // Share of children in employment (15-18 year-olds)
	
	putexcel D81 = (`=AttOnly_15to18_nat_fem_pop'/`=pop_nat_fem_1518') F81 = (`=AttOnly_15to18_migr_fem_pop'/`=pop_migr_fem_1518')  // Share of children attending school only (15-18 year-olds)
	
	putexcel D82 = (`=EmpOnly_15to18_nat_fem_pop'/`=pop_nat_fem_1518') F82 = (`=EmpOnly_15to18_migr_fem_pop'/`=pop_migr_fem_1518')  // Share of children in employment only (15-18 year-olds)
	
	putexcel D83 = (`=Att_Emp_1518_nat_fem_pop'/`=pop_nat_fem_1518') F83 = (`=Att_Emp_1518_migr_fem_pop'/`=pop_migr_fem_1518')  // Share of children attending school & in employment (15-18 year-olds)
	
	putexcel D84 = (`=NiNi_15to18_nat_fem_pop'/`=pop_nat_fem_1518') F84 = (`=NiNi_15to18_migr_fem_pop'/`=pop_migr_fem_1518')  // Neither in employment, education or training for youth (15-18 year-olds)
	
	**HEALTH
	
	* Health problems
	
	putexcel D91 = (`=healthSys_nat_fem_pop'/`=job15to64_nat_fem_pop') F91 = (`=healthSys_migr_fem_pop'/`=job15to64_migr_fem_pop') // Access to health services AMONG working pop
	
	** SIMPLE CHARACTERISTICS
	
	putexcel D96 = (`=survey_nat_fem_pop') F96 = (`=survey_migr_fem_pop') // Total sample size: persons
	
	putexcel D97 = (`=survey_nat_fem_15to64') F97 = (`=survey_migr_fem_15to64') // Total sample size: persons 15-64
	
	putexcel D99 = (`=nat_fem_pop') F99 = (`=migr_fem_pop') // Total population (with sample loadings)
	
	putexcel D100 = (`=total_nat_fem_15to64') F100 = (`=total_migr_fem_15to64') // Total persons 15-64 (with sample loadings)
	
	
********************************************************************************
********************************************************************************
********************************************************************************
****** PERU - ENCUESTA 2021
	
	clear all
	set more off, perm
	set maxvar 15000
	scalar drop _all

	** DATASET
	cd "C:\Users\jcamilop\OneDrive - Inter-American Development Bank Group\OECD\01 Raw"
	use "PER_2021a_BID.dta", replace

	gen uno=1
	replace factor_ci=round(factor_ci) // Applies when the expansion factor is a non-integer numbers
	replace migrante_ci = 0 if migrante_ci == .
	gen mig_rec = 1 if migantiguo5_ci==0 & migrante_ci==1
	
	****************************************************************************
	** LOCALS
		local 1_label = "migr"
		local 0_label = "nat"
		
		local 1_sexo = "masc_"
		local 2_sexo = "fem_"
		
	****************************************************************************
	** ISCED
	gen ISCED = 0 if (p301a == 1 | p301a == 2)
	replace ISCED = 1 if (p301a == 3 | p301a == 4 | p301a == 12)
	replace ISCED = 2 if p301a == 5
	replace ISCED = 3 if p301a == 6
	replace ISCED = 4 if p301a == 7
	replace ISCED = 4 if p301a == 8	
	replace ISCED = 6 if (p301a == 9 | p301a == 10)
	replace ISCED = 7 if p301a == 11
	
	****************************************************************************
	** JOB QUALIFICATIONS - ISCO
	gen ISCO = real(substr(string(codocupa, "%5.0g"), 1, 1))
	gen length = strlen(string(codocupa))
	replace ISCO = 0 if length == 3			
	replace ISCO = 2 if inlist(codocupa, 1113, 3258, 3322, 3523, 3439)
	replace ISCO = 3 if inlist(codocupa, 2433, 4110, 4120, 5419, 8133, 8134)
	replace ISCO = 4 if inlist(codocupa, 3124, 3125)
	replace ISCO = 5 if inlist(codocupa, 0120, 0320, 0220, 9622, 9512, 9511, 9411, 9622, 9111, 3132, 3131, 9334)
	replace ISCO = 7 if codocupa == 9129
	replace ISCO = 8 if codocupa == 7334
	replace ISCO = 9 if codocupa == 5241	
	gen overqualificated = 1 if inrange(ISCED,5,8) & inrange(ISCO,4,9)
	gen low_skilled = 1 if ISCO==9
	gen high_skilled = 1 if inrange(ISCO,1,3)
	
	****************************************************************************
	** Household size
	by idh_ch, sort: egen nmiembros=sum(relacion_ci>=1 & relacion_ci<5)
	by idh_ch, sort: egen nmenor18=sum((relacion_ci>=1 & relacion_ci<=4) & edad_ci<18)
	by idh_ch, sort: egen nmenor15=sum((relacion_ci>=1 & relacion_ci<=4) & edad_ci<15)
		
	****************************************************************************
	** Informality
	gen informal = 1 if cotizando_ci != 1 & emp_ci==1
	replace informal =1 if informal!=1 & afiliado_ci != 1 & emp_ci==1
	
	****************************************************************************
	** Working hours
	gen more_40 = 1 if horastot_ci >= 40
	replace more_40 = . if horastot_ci == .
	gen more_50 = 1 if horastot_ci >= 50
	replace more_50 = . if horastot_ci == .
	gen more_55 = 1 if horastot_ci >= 55
	replace more_55 = . if horastot_ci == .
	gen less_30 = 1 if horastot_ci <= 30
	replace less_30 = . if horastot_ci == .
	gen by_hours = 1 if emp_ci == 1
	replace by_hours = . if horastot_ci == .
	
	****************************************************************************
	** Nominal monthly wage (USD)
	by idh_ch, sort: egen nmwage=mean(ylm_ci + ylnm_ch)
	replace nmwage = (nmwage)/1.80
	
	****************************************************************************
	** Months of unemployment
	gen more_12 = 1 if p551>=12
	replace more_12 = . if durades_ci == .
	gen more_6 = 1 if p551>=6
	replace more_6 = . if durades_ci == .
		
********************************************************************* STATISTICS
********************************************************************************
********************************************************************************

	** CALCULATION OF INDICATORS
	
	** POPULATION
	
	* Total population calculated according to expansion factor
	sum uno if migrante_ci!=. & sexo_ci == 1 [fw=factor_ci]
	scalar tot_masc_pop = `=r(N)'
	
	* Migrant population calculated according to expansion factor
	sum uno if migrante_ci==1 & sexo_ci == 1 [fw=factor_ci]
	scalar migr_masc_pop = `=r(N)'
	
	* Native population calculated according to expansion factor
	sum uno if migrante_ci==0 & sexo_ci == 1 [fw=factor_ci]
	scalar nat_masc_pop = `=r(N)'
	
	* Total population calculated according to expansion factor
	sum uno if migrante_ci!=. & sexo_ci == 2 [fw=factor_ci]
	scalar tot_fem_pop = `=r(N)'
	
	* Migrant population calculated according to expansion factor
	sum uno if migrante_ci==1 & sexo_ci == 2 [fw=factor_ci]
	scalar migr_fem_pop = `=r(N)'
	
	* Native population calculated according to expansion factor
	sum uno if migrante_ci==0 & sexo_ci == 2 [fw=factor_ci]
	scalar nat_fem_pop = `=r(N)'
	
	* Share of working age population (15-64) Male
	sum uno if inrange(edad_ci,15,64) & migrante_ci==1 & sexo_ci == 1 [fw=factor_ci]
	scalar workAge_migr_masc_pop = `=r(N)'
	sum uno if inrange(edad_ci,15,64) & migrante_ci==0 & sexo_ci == 1 [fw=factor_ci]
	scalar workAge_nat_masc_pop = `=r(N)'
	sum uno if inrange(edad_ci,15,64) & sexo_ci == 1 [fw=factor_ci]
	scalar workAge_masc_pop = `=r(N)'
		
	* Share of labour force population (15-64) Male
	sum uno if inrange(edad_ci,15,64) & pea_ci == 1 & migrante_ci==1 & sexo_ci == 1 [fw=factor_ci]
	scalar econoAct_migr_masc_pop = `=r(N)'
	sum uno if inrange(edad_ci,15,64) & pea_ci == 1 & migrante_ci==0 & sexo_ci == 1 [fw=factor_ci]
	scalar econoAct_nat_masc_pop = `=r(N)'
	sum uno if inrange(edad_ci,15,64) & pea_ci == 1 & sexo_ci == 1 [fw=factor_ci]
	scalar econoAct_masc_pop = `=r(N)'
	
	* Share of Employment rate  (15-64) Male
	sum uno if inrange(edad_ci,15,64) & emp_ci == 1 & migrante_ci==1 & sexo_ci == 1 [fw=factor_ci]
	scalar emp_migr_masc_pop = `=r(N)'
	sum uno if inrange(edad_ci,15,64) & emp_ci == 1 & migrante_ci==0 & sexo_ci == 1 [fw=factor_ci]
	scalar emp_nat_masc_pop = `=r(N)'
	sum uno if inrange(edad_ci,15,64) & emp_ci == 1 & sexo_ci == 1 [fw=factor_ci]
	scalar emp_masc_pop = `=r(N)'
	
	* Share of working age population (15-64) Female
	sum uno if inrange(edad_ci,15,64) & migrante_ci==1 & sexo_ci == 2 [fw=factor_ci]
	scalar workAge_migr_fem_pop = `=r(N)'
	sum uno if inrange(edad_ci,15,64) & migrante_ci==0 & sexo_ci == 2 [fw=factor_ci]
	scalar workAge_nat_fem_pop = `=r(N)'
	sum uno if inrange(edad_ci,15,64) & sexo_ci == 2 [fw=factor_ci]
	scalar workAge_fem_pop = `=r(N)'
		
	* Share of labour force population (15-64) Female
	sum uno if inrange(edad_ci,15,64) & pea_ci == 1 & migrante_ci==1 & sexo_ci == 2 [fw=factor_ci]
	scalar econoAct_migr_fem_pop = `=r(N)'
	sum uno if inrange(edad_ci,15,64) & pea_ci == 1 & migrante_ci==0 & sexo_ci == 2 [fw=factor_ci]
	scalar econoAct_nat_fem_pop = `=r(N)'
	sum uno if inrange(edad_ci,15,64) & pea_ci == 1 & sexo_ci == 2 [fw=factor_ci]
	scalar econoAct_fem_pop = `=r(N)'
	
	* Share of Employment rate  (15-64) Female
	sum uno if inrange(edad_ci,15,64) & emp_ci == 1 & migrante_ci==1 & sexo_ci == 2 [fw=factor_ci]
	scalar emp_migr_fem_pop = `=r(N)'
	sum uno if inrange(edad_ci,15,64) & emp_ci == 1 & migrante_ci==0 & sexo_ci == 2 [fw=factor_ci]
	scalar emp_nat_fem_pop = `=r(N)'
	sum uno if inrange(edad_ci,15,64) & emp_ci == 1 & sexo_ci == 2 [fw=factor_ci]
	scalar emp_fem_pop = `=r(N)'
	

	** CALCULATION OF INDICATORS BY MIGRANTS AND NATIVES
	
	foreach var in 1 0 {
		
		foreach sexo in 1 2 {
		
		** DEMOGRAPHIC
		
		* Age groups
		
		sum uno if inrange(edad_ci,0,14) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar pop_``var'_label'_``sexo'_sexo'014 = `=r(N)' // 0 - 14 years
		
		sum uno if inrange(edad_ci,15,24) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar pop_``var'_label'_``sexo'_sexo'1524 = `=r(N)' // 15 - 24 years

		sum uno if inrange(edad_ci,25,39) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar pop_``var'_label'_``sexo'_sexo'2539 = `=r(N)' // 25 - 39 years
		
		sum uno if inrange(edad_ci,40,54) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar pop_``var'_label'_``sexo'_sexo'4054 = `=r(N)' // 40 - 54 years

		sum uno if inrange(edad_ci,55,64) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar pop_``var'_label'_``sexo'_sexo'5564 = `=r(N)'	//55 - 64 years
		
		sum uno if inrange(edad_ci,65,.) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar pop_``var'_label'_``sexo'_sexo'65older = `=r(N)'  // 65 older years
		
		* Sex male population
		sum uno if sexo_ci==1 & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar male_``var'_label'_``sexo'_sexo'pop =`=r(N)'
		
		* Marital status: married/cohabiting
		sum uno if civil_ci==2 & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar married_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		sum uno if civil_ci!=. & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar status_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		* Marital status: separated/divorced/widowed
		sum uno if (civil_ci==3 | civil_ci==4) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar separated_``var'_label'_``sexo'_sexo'pop = `=r(N)'	
		
		* Marital status: single
		sum uno if civil_ci==1 & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar single_``var'_label'_``sexo'_sexo'pop = `=r(N)'	
		
		* Urban
		sum uno if zona_c==1 & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar urban_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		* Capital city located
		sum uno if region_c==15 & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar capital_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		* Border cities or region
		sum uno if inlist(region_c, 1, 6, 16, 17, 20, 21, 23, 24, 25) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar borCity_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		* Household size
		sum nmiembros_ch if migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar size_``var'_label'_``sexo'_sexo'house = `=r(mean)'			
		
		* Number of children <= 18 in household
		sum nmenor18 if migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar less18_``var'_label'_``sexo'_sexo'house = `=r(mean)'			
		
		* Number of children <= 15 in household
		sum nmenor15 if migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar less15_``var'_label'_``sexo'_sexo'house = `=r(mean)'
		
		* Number of natural-born children (women only)
		
		
		** LABOUR MARKET INDICATORS
		
		* Share of population with a job
		sum uno if inrange(edad_ci,15,64) & emp_ci==1 & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar job_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		* Activity: Share participating in the labour force
		sum uno if inrange(edad_ci,15,64) & pea_ci==1 & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar econoAct_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		* Economically inactive people
		sum uno if inrange(edad_ci,15,64) & (condocup_ci == 3) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci] 
		scalar inactive_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		* Unemployment: Share of population who were unemployed
		sum uno if inrange(edad_ci,15,64) & desemp_ci==1 & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci] 
		scalar unemp_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		sum uno if (pea_ci==1 | asiste_ci==1) & inrange(edad_ci,15,64) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar econoActWorkAge_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		* Risk of labour market exclusion: long-term unemployment (12 months)
		sum uno if inrange(edad_ci,15,64) & (more_12==1 & desemp_ci==1) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar long12_unemp_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		sum uno if inrange(edad_ci,15,64) & (desemp_ci==1 | condocup_ci==3) & durades_ci!=. & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci] 
		scalar inac_unemp_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		* Risk of labour market exclusion: long-term unemployment (6 months)
		sum uno if inrange(edad_ci,15,64) & (more_6==1 & desemp_ci==1) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar long6_unemp_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		* Risk of labour market exclusion: long-term uemployment >=12 months or inactive involuntary
		sum uno if inrange(edad_ci,15,64) & (desalent_ci==1 | (more_12==1 & desemp_ci==1)) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar long_invo_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		* Risk of labour market exclusion: Inactive involuntary (available past week, not looking for job)
		sum uno if inrange(edad_ci,15,64) & desalent_ci==1 & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar involuntary_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		* Share of population with written contract
		sum uno if inrange(edad_ci,15,64) & inlist(tipocontrato_ci,0,1,2) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar written_``var'_label'_``sexo'_sexo'pop = `=r(N)'		
		
		* Share of population with an informal job
		sum uno if inrange(edad_ci,15,64) & informal==1 & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar informal_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		* Types of contracts:  Share of population in temporary contracts
		sum uno if inrange(edad_ci,15,64) & tipocontrato_ci==2 & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci] 
		scalar tempJob_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		sum uno if inrange(edad_ci,15,64) & categopri_ci!=2 & asiste_ci!=1 & emp_ci==1 & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar noself_edu_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		* Working hours: long hours >= 40
		sum uno if inrange(edad_ci,15,64) & more_40==1 & emp_ci == 1 & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar more40h_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		sum uno if inrange(edad_ci,15,64) & by_hours==1 & emp_ci == 1 & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar hours_``var'_label'_``sexo'_sexo'pop = `=r(N)'

		* Working hours: long hours >= 50
		sum uno if inrange(edad_ci,15,64) & more_50==1 & emp_ci == 1 & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar more50h_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		* Working hours: long hours >= 55
		sum uno if inrange(edad_ci,15,64) & more_55==1 & emp_ci == 1 & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar more55h_``var'_label'_``sexo'_sexo'pop = `=r(N)'		
	
		* Working hours: long hours < 30
		sum uno if inrange(edad_ci,15,64) & less_30==1 & emp_ci == 1 & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar less30h_``var'_label'_``sexo'_sexo'pop = `=r(N)'

		* Job skills: share of working population in highly skilled jobs
		sum uno if high_skilled==1 & inrange(edad_ci,15,64) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar highSkill_``var'_label'_``sexo'_sexo'pop = `=r(N)'		
		
		* Job skills: share of working population in low-skilled jobs
		sum uno if low_skilled==1 & inrange(edad_ci,15,64) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar lowSkill_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		sum uno if emp_ci==1 & inrange(edad_ci,15,64) & ISCO!=0 & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar NotMili_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		* Overqualification: share of highly educated individuals who work in low- or medium-skilled jobs
		sum uno if overqualificated==1 & inrange(edad_ci,15,64) & migrante_ci==`var' & sexo_ci==`sexo' & inrange(ISCED,4,9) [fw=factor_ci]
		scalar overquali_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		sum uno if emp_ci==1 & inrange(edad_ci,15,64) & asiste_ci!=1 & ISCO!=0 & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar NotEduNotMili_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		* Self-employment: share of population who works in their own firms or businesses
		sum uno if (categopri_ci==1 | categopri_ci==2) & inrange(edad_ci,15,64) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar selfEmp_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		sum uno if inrange(edad_ci,15,64) & rama_ci!=1 & emp_ci==1 & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar Notagri_emp1564_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		* Employment in the public sector
		sum uno if spublico_ci==1 & inrange(edad_ci,15,64) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar pubSec_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		sum uno if inrange(edad_ci,15,64) & emp_ci==1 & categopri_ci!=2 & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar NoSelf15to64_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		* Nominal monthly wage (USD)
		sum nmwage if migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar nmwage_``var'_label'_``sexo'_sexo' = `=r(mean)'
		
		* Child labour
		

		** EDUCATION AND SKILLS
		
		* Level of educational attainment: high (ISCED groups 5-8)
		sum uno if inrange(ISCED,5,8) & inrange(edad_ci,15,64) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar ISCED58_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		sum uno if inrange(edad_ci,15,64) & migrante_ci==`var' [fw=factor_ci]
		scalar ISCEDEdu_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		* Level of educational attainment: low (ISCED groups 0-2)
		sum uno if inrange(ISCED,0,2) & inrange(edad_ci,15,64) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar ISCED02_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		* Level of educational attainment: very low (ISCED groups 0-1)
		sum uno if inrange(ISCED,0,1) & inrange(edad_ci,15,64) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar ISCED01_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		* Literacy: knows how to read and write 
		sum uno if (p302 == 1 | p301a >= 4) & inrange(edad_ci,16,64) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar literacy_``var'_label'_``sexo'_sexo'pop = `=r(N)'		
		
		sum uno if inrange(edad_ci,16,64) & migrante_ci==`var' [fw=factor_ci] 
		scalar pop_``var'_label'_``sexo'_sexo'1664 = `=r(N)'
		
		* Neither in employment, education or training for youth
		sum uno if (edad_ci>=15 & edad_ci <=34) & emp_ci!=1 & asiste_ci==0 & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar NoEmpNoedu_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		sum uno if inrange(edad_ci,15,34) & migrante_ci==`var' [fw=factor_ci]
		scalar age1534_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		* Early school leaving
		sum uno if asiste_ci == 0 & (edad_ci>=15 & edad_ci <=24) & inlist(ISCED,0,1,2) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar earlyLeft_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		sum uno if inrange(edad_ci,15,24) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar earlyAge_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		* Share of children attending schooling, 5 - 16 years group
		sum uno if asiste_ci==1 & inrange(edad_ci,5,16) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar attending_5to16_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		sum uno if inrange(edad_ci,5,16) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci] 
		scalar pop_``var'_label'_``sexo'_sexo'516 = `=r(N)'
		
		** CHILDREN EDUCATION AND EMPLOYMENT
		
		* Share of children attending school (15-18 year-olds)
		sum uno if asiste_ci==1 & inrange(edad_ci,15,18) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar attending_15to18_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		sum uno if inrange(edad_ci,15,18) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci] 
		scalar pop_``var'_label'_``sexo'_sexo'1518 = `=r(N)'
		
		* Share of children in employment (15-18 year-olds)
		sum uno if emp_ci==1 & inrange(edad_ci,15,18) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar employment_15to18_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		* Share of children attending school only (15-18 year-olds)
		sum uno if (asiste_ci==1 & emp_ci!=1) & inrange(edad_ci,15,18) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar AttOnly_15to18_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		* Share of children in employment only (15-18 year-olds)
		sum uno if (emp_ci==1 & asiste_ci!=1) & inrange(edad_ci,15,18) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar EmpOnly_15to18_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		* Share of children attending school & in employment (15-18 year-olds)
		sum uno if (asiste_ci==1 & emp_ci==1) & inrange(edad_ci,15,18) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar Att_Emp_1518_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		* Neither in employment, education or training for youth (15-18 year-olds)
		sum uno if (edad_ci>=15 & edad_ci <=18) & emp_ci==0 & asiste_ci==0 & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar NiNi_15to18_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		** HEALTH
		
		* Access to health services AMONG working pop
		sum uno if inrange(edad_ci,15,64) & (afiliado_ci==1 | cotizando_ci==1) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci] 
		scalar healthSys_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		sum uno if inrange(edad_ci,15,64) & emp_ci==1 & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar job15to64_``var'_label'_``sexo'_sexo'pop = `=r(N)'	
		
		** SAMPLE CHARACTERISTICS
		
		* Total sample size: persons 
		sum uno if migrante_ci==`var' & sexo_ci==`sexo'
		scalar survey_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		* Total sample size: persons 15-64
		sum uno if inrange(edad_ci,15,64) & migrante_ci==`var' & sexo_ci==`sexo'
		scalar survey_``var'_label'_``sexo'_sexo'15to64 = `=r(N)'

		* Total persons 15-64 (with sample loadings)
		sum uno if inrange(edad_ci,15,64) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar total_``var'_label'_``sexo'_sexo'15to64 = `=r(N)'
		
	}
	
		}
	
******************************************************** EXCEL OUTPUTS

	putexcel set "C:\Users\jcamilop\OneDrive - Inter-American Development Bank Group\OECD\03 Outputs\Resultados por sexo.xlsx", sheet("Peru") modify
	putexcel describe
	
	
	** POPULATION
	
	putexcel C6 = (`=nat_masc_pop'/`=tot_masc_pop') E6 = (`=migr_masc_pop'/`=tot_masc_pop')	// Share of population
	
	putexcel C7 = (`=workAge_nat_masc_pop'/`=workAge_masc_pop') E7 = (`=workAge_migr_masc_pop'/`=workAge_masc_pop') // Share of working age population (15-64)
	
	putexcel C8 = (`=econoAct_nat_masc_pop'/`=econoAct_masc_pop') E8 = (`=econoAct_migr_masc_pop'/`=econoAct_masc_pop') // Share of labour force population (15-64)
	
	putexcel C9 = (`=emp_nat_masc_pop'/`=emp_masc_pop') E9 = (`=emp_migr_masc_pop'/`=emp_masc_pop') // Share of Employment rate  (15-64)
	
	
	** DEMOGRAPHIC
	
	putexcel C17 = (`=pop_nat_masc_014'/`=nat_masc_pop') E17 = (`=pop_migr_masc_014'/`=migr_masc_pop') // 0 - 14
	
	putexcel C18 = (`=pop_nat_masc_1524'/`=nat_masc_pop') E18 = (`=pop_migr_masc_1524'/`=migr_masc_pop') // 15 - 24
	
	putexcel C19 = (`=pop_nat_masc_2539'/`=nat_masc_pop') E19 = (`=pop_migr_masc_2539'/`=migr_masc_pop') // 25 - 39
	
	putexcel C20 = (`=pop_nat_masc_4054'/`=nat_masc_pop') E20 = (`=pop_migr_masc_4054'/`=migr_masc_pop') // 40 - 54
	
	putexcel C21 = (`=pop_nat_masc_5564'/`=nat_masc_pop') E21 = (`=pop_migr_masc_5564'/`=migr_masc_pop') // 55 - 64
	
	putexcel C22 = (`=pop_nat_masc_65older'/`=nat_masc_pop') E22 = (`=pop_migr_masc_65older'/`=migr_masc_pop') // 65 Older
	
	putexcel C23 = (`=workAge_nat_masc_pop'/`=nat_masc_pop') E23 = (`=workAge_migr_masc_pop'/`=migr_masc_pop') // 15-64 
	
	*putexcel C25 = (`=male_nat_pop'/`=nat_pop') E25 = (`=male_migr_pop'/`=migr_pop') 	// Sex male
	
	putexcel C26 = (`=married_nat_masc_pop'/`=status_nat_masc_pop') E26 = (`=married_migr_masc_pop'/`=status_migr_masc_pop') // Marital status: married/cohabiting
	
	putexcel C27 = (`=separated_nat_masc_pop'/`=status_nat_masc_pop') E27 = (`=separated_migr_masc_pop'/`=status_migr_masc_pop') // Marital status: separated/divorced/widowed

	putexcel C28 = (`=single_nat_masc_pop'/`=status_nat_masc_pop') E28 = (`=single_migr_masc_pop'/`=status_migr_masc_pop') // Marital status: single
	
	putexcel C29 = (`=urban_nat_masc_pop'/`=nat_masc_pop') E29 = (`=urban_migr_masc_pop'/`=migr_masc_pop') // Urban
	
	putexcel C30 = (`=capital_nat_masc_pop'/`=nat_masc_pop')  E30 = (`=capital_migr_masc_pop'/`=migr_masc_pop') // Capital city located
	
	putexcel C31 = (`=borCity_nat_masc_pop'/`=nat_masc_pop')  E31 = (`=borCity_migr_masc_pop'/`=migr_masc_pop') // Border cities or region
	
	putexcel C34 = (`=size_nat_masc_house')  E34 = (`=size_migr_masc_house') // Household size
		
	putexcel C35 = (`=less18_nat_masc_house')  E35 = (`=less18_migr_masc_house') // Number of children <= 18 in household
		
	putexcel C36 = (`=less15_nat_masc_house')  E36 = (`=less15_migr_masc_house') // Number of children <= 15 in household
		
	// Number of natural-born children (women only)
	
	
	** LABOUR MARKET INDICATORS
	
	putexcel C41 = (`=job_nat_masc_pop'/`=workAge_nat_masc_pop') E41 = (`=job_migr_masc_pop'/`=workAge_migr_masc_pop') // Share of population with a job
	
	putexcel C42 = (`=econoAct_nat_masc_pop'/`=workAge_nat_masc_pop') E42 = (`=econoAct_migr_masc_pop'/`=workAge_migr_masc_pop') // Activity: Share participating in the labour force
	
	putexcel C43 = (`=inactive_nat_masc_pop'/`=workAge_nat_masc_pop') E43 = (`=inactive_migr_masc_pop'/`=workAge_migr_masc_pop')  // Economically inactive people
	
	putexcel C44 = (`=unemp_nat_masc_pop'/`=econoActWorkAge_nat_masc_pop') E44 = (`=unemp_migr_masc_pop'/`=econoActWorkAge_migr_masc_pop') // Unemployment: Share of population who were unemployed
	
	putexcel C45 = (`=long12_unemp_nat_masc_pop'/`=inac_unemp_nat_masc_pop') E45 = (`=long12_unemp_migr_masc_pop'/`=inac_unemp_migr_masc_pop') // Risk of labour market exclusion: long-term unemployment (12 month)
	
	putexcel C46 = (`=long6_unemp_nat_masc_pop'/`=inac_unemp_nat_masc_pop') E46 = (`=long6_unemp_migr_masc_pop'/`=inac_unemp_migr_masc_pop') // Risk of labour market exclusion: long-term unemployment (6 month)
	
	putexcel C47 = (`=involuntary_nat_masc_pop'/`=inac_unemp_nat_masc_pop') E47 = (`=involuntary_migr_masc_pop'/`=inac_unemp_migr_masc_pop') // Inactive involuntary (available past week, not looking for job)
	
	putexcel C48 = (`=long_invo_nat_masc_pop'/`=inac_unemp_nat_masc_pop') E48 = (`=long_invo_migr_masc_pop'/`=inac_unemp_migr_masc_pop') // Long-term uemployment >=12 months or inactive involuntary	
	
	putexcel C49 = (`=written_nat_masc_pop'/`=noself_edu_nat_masc_pop') E49 = (`=written_migr_masc_pop'/`=noself_edu_migr_masc_pop') // Share of population with written contract
	
	putexcel C50 = (`=informal_nat_masc_pop'/`=econoAct_nat_masc_pop') E50= (`=informal_migr_masc_pop'/`=econoAct_migr_masc_pop') // Share of population with an informal job	
	
    // Share of population with an informal job (OECD def)
	
	putexcel C52 = (`=tempJob_nat_masc_pop'/`=noself_edu_nat_masc_pop') E52 = (`=tempJob_migr_masc_pop'/`=noself_edu_migr_masc_pop') // Types of contracts: Share of population in temporary contracts	
	
	putexcel C53 = (`=more40h_nat_masc_pop'/`=hours_nat_masc_pop') E53 = (`=more40h_migr_masc_pop'/`=hours_migr_masc_pop')  // Working hours: long (more than 40) hours	

	putexcel C54 = (`=more50h_nat_masc_pop'/`=hours_nat_masc_pop') E54 = (`=more50h_migr_masc_pop'/`=hours_migr_masc_pop')  // Working hours: long (more than 50) hours
	
	putexcel C55 = (`=more55h_nat_masc_pop'/`=hours_nat_masc_pop') E55 = (`=more55h_migr_masc_pop'/`=hours_migr_masc_pop')  // Working hours: long (more than 55) hours
	
	putexcel C56 = (`=less30h_nat_masc_pop'/`=hours_nat_masc_pop') E56 = (`=less30h_migr_masc_pop'/`=hours_migr_masc_pop')  // Working hours: long (less than 30) hours	
	
	putexcel C57 = (`=highSkill_nat_masc_pop'/`=NotMili_nat_masc_pop') E57 = (`=highSkill_migr_masc_pop'/`=NotMili_migr_masc_pop') // Job skills: share of working population in highly skilled jobs
	
	putexcel C58 = (`=lowSkill_nat_masc_pop'/`=NotMili_nat_masc_pop') E58 = (`=lowSkill_migr_masc_pop'/`=NotMili_migr_masc_pop') // Job skills: share of working population in low-skilled jobs 
		
	putexcel C59 = (`=overquali_nat_masc_pop'/`=NotEduNotMili_nat_masc_pop') E59 = (`=overquali_migr_masc_pop'/`=NotEduNotMili_migr_masc_pop') // Overqualification: share of highly educated individuals who work in low- or medium-skilled jobs

	putexcel C60 = (`=selfEmp_nat_masc_pop'/`=Notagri_emp1564_nat_masc_pop') E60 = (`=selfEmp_migr_masc_pop'/`=Notagri_emp1564_migr_masc_pop')   // Self-employment: share of population who work in their own firms or businesses
	
	putexcel C61 = (`=pubSec_nat_masc_pop'/`=NoSelf15to64_nat_masc_pop') E61 = (`=pubSec_migr_masc_pop'/`=NoSelf15to64_migr_masc_pop')   // Employment in the public sector
	
	putexcel C62 = (`=nmwage_nat_masc_')  E62 = (`=nmwage_migr_masc_') // Nominal monthly wage (USD)
	
	* Child labour
	
	
	** EDUCATION AND SKILLS
		
	putexcel C69 = (`=ISCED58_nat_masc_pop'/`=ISCEDEdu_nat_masc_pop') E69 = (`=ISCED58_migr_masc_pop'/`=ISCEDEdu_migr_masc_pop') // Level of educational attainment: high (ISCED groups 5-8)
		
	putexcel C70 = (`=ISCED02_nat_masc_pop'/`=ISCEDEdu_nat_masc_pop') E70 = (`=ISCED02_migr_masc_pop'/`=ISCEDEdu_migr_masc_pop') // Level of educational attainment: low (ISCED groups 0-2)
		
	putexcel C71 = (`=ISCED01_nat_masc_pop'/`=ISCEDEdu_nat_masc_pop') E71 = (`=ISCED01_migr_masc_pop'/`=ISCEDEdu_migr_masc_pop') // Level of educational attainment: very low (ISCED groups 0-1)
		
	putexcel C72 = (`=literacy_nat_masc_pop'/`=pop_nat_masc_1664') E72 = (`=literacy_migr_masc_pop'/`=pop_migr_masc_1664') // Literacy: knows how to read and write
	
	putexcel C73 = (`=NoEmpNoedu_nat_masc_pop'/`=age1534_nat_masc_pop') E73 = (`=NoEmpNoedu_migr_masc_pop'/`=age1534_migr_masc_pop')   // Neither in employment, education or training for youth
	
	putexcel C74 = (`=earlyLeft_nat_masc_pop'/`=earlyAge_nat_masc_pop') E74 = (`=earlyLeft_migr_masc_pop'/`=earlyAge_migr_masc_pop')  // Early school leaving
	
	putexcel C75 = (`=attending_5to16_nat_masc_pop'/`=pop_nat_masc_516') E75 = (`=attending_5to16_migr_masc_pop'/`=pop_migr_masc_516')  // Share of children attending schooling, 5 - 16 years group
	
	** CHILDREN EDUCATION AND EMPLOYMENT	
	
	putexcel C79 = (`=attending_15to18_nat_masc_pop'/`=pop_nat_masc_1518') E79 = (`=attending_15to18_migr_masc_pop'/`=pop_migr_masc_1518')  // Share of children attending school (15-18 year-olds)
	
	putexcel C80 = (`=employment_15to18_nat_masc_pop'/`=pop_nat_masc_1518') E80 = (`=employment_15to18_migr_masc_pop'/`=pop_migr_masc_1518')  // Share of children in employment (15-18 year-olds)
	
	putexcel C81 = (`=AttOnly_15to18_nat_masc_pop'/`=pop_nat_masc_1518') E81 = (`=AttOnly_15to18_migr_masc_pop'/`=pop_migr_masc_1518')  // Share of children attending school only (15-18 year-olds)
	
	putexcel C82 = (`=EmpOnly_15to18_nat_masc_pop'/`=pop_nat_masc_1518') E82 = (`=EmpOnly_15to18_migr_masc_pop'/`=pop_migr_masc_1518')  // Share of children in employment only (15-18 year-olds)
	
	putexcel C83 = (`=Att_Emp_1518_nat_masc_pop'/`=pop_nat_masc_1518') E83 = (`=Att_Emp_1518_migr_masc_pop'/`=pop_migr_masc_1518')  // Share of children attending school & in employment (15-18 year-olds)
	
	putexcel C84 = (`=NiNi_15to18_nat_masc_pop'/`=pop_nat_masc_1518') E84 = (`=NiNi_15to18_migr_masc_pop'/`=pop_migr_masc_1518')  // Neither in employment, education or training for youth (15-18 year-olds)
	
	**HEALTH
	
	* Health problems
	
	putexcel C91 = (`=healthSys_nat_masc_pop'/`=job15to64_nat_masc_pop') E91 = (`=healthSys_migr_masc_pop'/`=job15to64_migr_masc_pop') // Access to health services AMONG working pop
	
	** SIMPLE CHARACTERISTICS
	
	putexcel C96 = (`=survey_nat_masc_pop') E96 = (`=survey_migr_masc_pop') // Total sample size: persons
	
	putexcel C97 = (`=survey_nat_masc_15to64') E97 = (`=survey_migr_masc_15to64') // Total sample size: persons 15-64
	
	putexcel C99 = (`=nat_masc_pop') E99 = (`=migr_masc_pop') // Total population (with sample loadings)
	
	putexcel C100 = (`=total_nat_masc_15to64') E100 = (`=total_migr_masc_15to64') // Total persons 15-64 (with sample loadings)
	
** POPULATION
	
	putexcel D6 = (`=nat_fem_pop'/`=tot_fem_pop') F6 = (`=migr_fem_pop'/`=tot_fem_pop')	// Share of population
	
	putexcel D7 = (`=workAge_nat_fem_pop'/`=workAge_fem_pop') F7 = (`=workAge_migr_fem_pop'/`=workAge_fem_pop') // Share of working age population (15-64)
	
	putexcel D8 = (`=econoAct_nat_fem_pop'/`=econoAct_fem_pop') F8 = (`=econoAct_migr_fem_pop'/`=econoAct_fem_pop') // Share of labour force population (15-64)
	
	putexcel D9 = (`=emp_nat_fem_pop'/`=emp_fem_pop') F9 = (`=emp_migr_fem_pop'/`=emp_fem_pop') // Share of Employment rate  (15-64)
	
	
	** DEMOGRAPHIC
	
	putexcel D17 = (`=pop_nat_fem_014'/`=nat_fem_pop') F17 = (`=pop_migr_fem_014'/`=migr_fem_pop') // 0 - 14
	
	putexcel D18 = (`=pop_nat_fem_1524'/`=nat_fem_pop') F18 = (`=pop_migr_fem_1524'/`=migr_fem_pop') // 15 - 24
	
	putexcel D19 = (`=pop_nat_fem_2539'/`=nat_fem_pop') F19 = (`=pop_migr_fem_2539'/`=migr_fem_pop') // 25 - 39
	
	putexcel D20 = (`=pop_nat_fem_4054'/`=nat_fem_pop') F20 = (`=pop_migr_fem_4054'/`=migr_fem_pop') // 40 - 54
	
	putexcel D21 = (`=pop_nat_fem_5564'/`=nat_fem_pop') F21 = (`=pop_migr_fem_5564'/`=migr_fem_pop') // 55 - 64
	
	putexcel D22 = (`=pop_nat_fem_65older'/`=nat_fem_pop') F22 = (`=pop_migr_fem_65older'/`=migr_fem_pop') // 65 Older
	
	putexcel D23 = (`=workAge_nat_fem_pop'/`=nat_fem_pop') F23 = (`=workAge_migr_fem_pop'/`=migr_fem_pop') // 15-64 
	
	*putexcel D25 = (`=male_nat_pop'/`=nat_pop') F25 = (`=male_migr_pop'/`=migr_pop') 	// Sex male
	
	putexcel D26 = (`=married_nat_fem_pop'/`=status_nat_fem_pop') F26 = (`=married_migr_fem_pop'/`=status_migr_fem_pop') // Marital status: married/cohabiting
	
	putexcel D27 = (`=separated_nat_fem_pop'/`=status_nat_fem_pop') F27 = (`=separated_migr_fem_pop'/`=status_migr_fem_pop') // Marital status: separated/divorced/widowed

	putexcel D28 = (`=single_nat_fem_pop'/`=status_nat_fem_pop') F28 = (`=single_migr_fem_pop'/`=status_migr_fem_pop') // Marital status: single
	
	putexcel D29 = (`=urban_nat_fem_pop'/`=nat_fem_pop') F29 = (`=urban_migr_fem_pop'/`=migr_fem_pop') // Urban
	
	putexcel D30 = (`=capital_nat_fem_pop'/`=nat_fem_pop')  F30 = (`=capital_migr_fem_pop'/`=migr_fem_pop') // Capital city located
	
	putexcel D31 = (`=borCity_nat_fem_pop'/`=nat_fem_pop')  F31 = (`=borCity_migr_fem_pop'/`=migr_fem_pop') // Border cities or region
	
	putexcel D34 = (`=size_nat_fem_house')  F34 = (`=size_migr_fem_house') // Household size
		
	putexcel D35 = (`=less18_nat_fem_house')  F35 = (`=less18_migr_fem_house') // Number of children <= 18 in household
		
	putexcel D36 = (`=less15_nat_fem_house')  F36 = (`=less15_migr_fem_house') // Number of children <= 15 in household
		
	// Number of natural-born children (women only)
	
	
	** LABOUR MARKET INDICATORS
	
	putexcel D41 = (`=job_nat_fem_pop'/`=workAge_nat_fem_pop') F41 = (`=job_migr_fem_pop'/`=workAge_migr_fem_pop') // Share of population with a job
	
	putexcel D42 = (`=econoAct_nat_fem_pop'/`=workAge_nat_fem_pop') F42 = (`=econoAct_migr_fem_pop'/`=workAge_migr_fem_pop') // Activity: Share participating in the labour force
	
	putexcel D43 = (`=inactive_nat_fem_pop'/`=workAge_nat_fem_pop') F43 = (`=inactive_migr_fem_pop'/`=workAge_migr_fem_pop')  // Economically inactive people
	
	putexcel D44 = (`=unemp_nat_fem_pop'/`=econoActWorkAge_nat_fem_pop') F44 = (`=unemp_migr_fem_pop'/`=econoActWorkAge_migr_fem_pop') // Unemployment: Share of population who were unemployed
	
	putexcel D45 = (`=long12_unemp_nat_fem_pop'/`=inac_unemp_nat_fem_pop') F45 = (`=long12_unemp_migr_fem_pop'/`=inac_unemp_migr_fem_pop') // Risk of labour market exclusion: long-term unemployment (12 month)
	
	putexcel D46 = (`=long6_unemp_nat_fem_pop'/`=inac_unemp_nat_fem_pop') F46 = (`=long6_unemp_migr_fem_pop'/`=inac_unemp_migr_fem_pop') // Risk of labour market exclusion: long-term unemployment (6 month)
	
	putexcel D47 = (`=involuntary_nat_fem_pop'/`=inac_unemp_nat_fem_pop') F47 = (`=involuntary_migr_fem_pop'/`=inac_unemp_migr_fem_pop') // Inactive involuntary (available past week, not looking for job)
	
	putexcel D48 = (`=long_invo_nat_fem_pop'/`=inac_unemp_nat_fem_pop') F48 = (`=long_invo_migr_fem_pop'/`=inac_unemp_migr_fem_pop') // Long-term uemployment >=12 months or inactive involuntary	
	
	putexcel D49 = (`=written_nat_fem_pop'/`=noself_edu_nat_fem_pop') F49 = (`=written_migr_fem_pop'/`=noself_edu_migr_fem_pop') // Share of population with written contract
	
	putexcel D50 = (`=informal_nat_fem_pop'/`=econoAct_nat_fem_pop') F50= (`=informal_migr_fem_pop'/`=econoAct_migr_fem_pop') // Share of population with an informal job	
	
    // Share of population with an informal job (OECD def)
	
	putexcel D52 = (`=tempJob_nat_fem_pop'/`=noself_edu_nat_fem_pop') F52 = (`=tempJob_migr_fem_pop'/`=noself_edu_migr_fem_pop') // Types of contracts: Share of population in temporary contracts	
	
	putexcel D53 = (`=more40h_nat_fem_pop'/`=hours_nat_fem_pop') F53 = (`=more40h_migr_fem_pop'/`=hours_migr_fem_pop')  // Working hours: long (more than 40) hours	

	putexcel D54 = (`=more50h_nat_fem_pop'/`=hours_nat_fem_pop') F54 = (`=more50h_migr_fem_pop'/`=hours_migr_fem_pop')  // Working hours: long (more than 50) hours
	
	putexcel D55 = (`=more55h_nat_fem_pop'/`=hours_nat_fem_pop') F55 = (`=more55h_migr_fem_pop'/`=hours_migr_fem_pop')  // Working hours: long (more than 55) hours
	
	putexcel D56 = (`=less30h_nat_fem_pop'/`=hours_nat_fem_pop') F56 = (`=less30h_migr_fem_pop'/`=hours_migr_fem_pop')  // Working hours: long (less than 30) hours	
	
	putexcel D57 = (`=highSkill_nat_fem_pop'/`=NotMili_nat_fem_pop') F57 = (`=highSkill_migr_fem_pop'/`=NotMili_migr_fem_pop') // Job skills: share of working population in highly skilled jobs
	
	putexcel D58 = (`=lowSkill_nat_fem_pop'/`=NotMili_nat_fem_pop') F58 = (`=lowSkill_migr_fem_pop'/`=NotMili_migr_fem_pop') // Job skills: share of working population in low-skilled jobs 
		
	putexcel D59 = (`=overquali_nat_fem_pop'/`=NotEduNotMili_nat_fem_pop') F59 = (`=overquali_migr_fem_pop'/`=NotEduNotMili_migr_fem_pop') // Overqualification: share of highly educated individuals who work in low- or medium-skilled jobs

	putexcel D60 = (`=selfEmp_nat_fem_pop'/`=Notagri_emp1564_nat_fem_pop') F60 = (`=selfEmp_migr_fem_pop'/`=Notagri_emp1564_migr_fem_pop')   // Self-employment: share of population who work in their own firms or businesses
	
	putexcel D61 = (`=pubSec_nat_fem_pop'/`=NoSelf15to64_nat_fem_pop') F61 = (`=pubSec_migr_fem_pop'/`=NoSelf15to64_migr_fem_pop')   // Employment in the public sector
	
	putexcel D62 = (`=nmwage_nat_fem_')  F62 = (`=nmwage_migr_fem_') // Nominal monthly wage (USD)
	
	* Child labour
	
	
	** EDUCATION AND SKILLS
		
	putexcel D69 = (`=ISCED58_nat_fem_pop'/`=ISCEDEdu_nat_fem_pop') F69 = (`=ISCED58_migr_fem_pop'/`=ISCEDEdu_migr_fem_pop') // Level of educational attainment: high (ISCED groups 5-8)
		
	putexcel D70 = (`=ISCED02_nat_fem_pop'/`=ISCEDEdu_nat_fem_pop') F70 = (`=ISCED02_migr_fem_pop'/`=ISCEDEdu_migr_fem_pop') // Level of educational attainment: low (ISCED groups 0-2)
		
	putexcel D71 = (`=ISCED01_nat_fem_pop'/`=ISCEDEdu_nat_fem_pop') F71 = (`=ISCED01_migr_fem_pop'/`=ISCEDEdu_migr_fem_pop') // Level of educational attainment: very low (ISCED groups 0-1)
		
	putexcel D72 = (`=literacy_nat_fem_pop'/`=pop_nat_fem_1664') F72 = (`=literacy_migr_fem_pop'/`=pop_migr_fem_1664') // Literacy: knows how to read and write
	
	putexcel D73 = (`=NoEmpNoedu_nat_fem_pop'/`=age1534_nat_fem_pop') F73 = (`=NoEmpNoedu_migr_fem_pop'/`=age1534_migr_fem_pop')   // Neither in employment, education or training for youth
	
	putexcel D74 = (`=earlyLeft_nat_fem_pop'/`=earlyAge_nat_fem_pop') F74 = (`=earlyLeft_migr_fem_pop'/`=earlyAge_migr_fem_pop')  // Early school leaving
	
	putexcel D75 = (`=attending_5to16_nat_fem_pop'/`=pop_nat_fem_516') F75 = (`=attending_5to16_migr_fem_pop'/`=pop_migr_fem_516')  // Share of children attending schooling, 5 - 16 years group
	
	** CHILDREN EDUCATION AND EMPLOYMENT	
	
	putexcel D79 = (`=attending_15to18_nat_fem_pop'/`=pop_nat_fem_1518') F79 = (`=attending_15to18_migr_fem_pop'/`=pop_migr_fem_1518')  // Share of children attending school (15-18 year-olds)
	
	putexcel D80 = (`=employment_15to18_nat_fem_pop'/`=pop_nat_fem_1518') F80 = (`=employment_15to18_migr_fem_pop'/`=pop_migr_fem_1518')  // Share of children in employment (15-18 year-olds)
	
	putexcel D81 = (`=AttOnly_15to18_nat_fem_pop'/`=pop_nat_fem_1518') F81 = (`=AttOnly_15to18_migr_fem_pop'/`=pop_migr_fem_1518')  // Share of children attending school only (15-18 year-olds)
	
	putexcel D82 = (`=EmpOnly_15to18_nat_fem_pop'/`=pop_nat_fem_1518') F82 = (`=EmpOnly_15to18_migr_fem_pop'/`=pop_migr_fem_1518')  // Share of children in employment only (15-18 year-olds)
	
	putexcel D83 = (`=Att_Emp_1518_nat_fem_pop'/`=pop_nat_fem_1518') F83 = (`=Att_Emp_1518_migr_fem_pop'/`=pop_migr_fem_1518')  // Share of children attending school & in employment (15-18 year-olds)
	
	putexcel D84 = (`=NiNi_15to18_nat_fem_pop'/`=pop_nat_fem_1518') F84 = (`=NiNi_15to18_migr_fem_pop'/`=pop_migr_fem_1518')  // Neither in employment, education or training for youth (15-18 year-olds)
	
	**HEALTH
	
	* Health problems
	
	putexcel D91 = (`=healthSys_nat_fem_pop'/`=job15to64_nat_fem_pop') F91 = (`=healthSys_migr_fem_pop'/`=job15to64_migr_fem_pop') // Access to health services AMONG working pop
	
	** SIMPLE CHARACTERISTICS
	
	putexcel D96 = (`=survey_nat_fem_pop') F96 = (`=survey_migr_fem_pop') // Total sample size: persons
	
	putexcel D97 = (`=survey_nat_fem_15to64') F97 = (`=survey_migr_fem_15to64') // Total sample size: persons 15-64
	
	putexcel D99 = (`=nat_fem_pop') F99 = (`=migr_fem_pop') // Total population (with sample loadings)
	
	putexcel D100 = (`=total_nat_fem_15to64') F100 = (`=total_migr_fem_15to64') // Total persons 15-64 (with sample loadings)
	
	
********************************************************************************
********************************************************************************
********************************************************************************
****** TRINIDAD Y TOBAGO - HOUSEHOLD SURVEY 2015
	
	clear all
	set more off, perm
	set maxvar 15000
	scalar drop _all

	****************************************************************************
	** DATASET
	cd "C:\Users\jcamilop\OneDrive - Inter-American Development Bank Group\OECD\01 Raw"
	use "TTO_2015a_BID.dta", replace

	gen uno=1
	replace factor_ci=round(factor_ci) // Applies when the expansion factor is a non-integer numbers
	gen mig_rec = 1 if migantiguo5_ci==0 & migrante_ci==1
	
	****************************************************************************
	** LOCALS
		local 1_label = "migr"
		local 0_label = "nat"
		
		local 1_sexo = "masc_"
		local 2_sexo = "fem_"
		
	****************************************************************************
	** ISCED
	gen ISCED = 0 if reduc == 1
	replace ISCED = 1 if inrange(reduc, 2, 4)
	replace ISCED = 2 if inrange(reduc, 5, 10)
	replace ISCED = 4 if reduc == 11
	replace ISCED = 6 if inlist(reduc, 12, 13)
	
	****************************************************************************
	** Household size
	by idh_ch, sort: egen nmiembros=sum(relacion_ci>=1 & relacion_ci<5)
	by idh_ch, sort: egen nmenor18=sum((relacion_ci>=1 & relacion_ci<=4) & edad_ci<18)
	by idh_ch, sort: egen nmenor15=sum((relacion_ci>=1 & relacion_ci<=4) & edad_ci<15)
	
	****************************************************************************
	** Working hours
	gen more_40 = 1 if horastot_ci >= 40
	replace more_40 = . if horastot_ci == .
	gen more_50 = 1 if horastot_ci >= 50
	replace more_50 = . if horastot_ci == .
	gen more_55 = 1 if horastot_ci >= 55
	replace more_55 = . if horastot_ci == .
	gen less_30 = 1 if horastot_ci <= 30
	replace less_30 = . if horastot_ci == .
	gen by_hours = 1 if horastot_ci > 1
	replace by_hours = . if horastot_ci == .
	
	****************************************************************************
	** Nominal monthly wage (USD)
	by idh_ch, sort: egen nmwage=mean(ylm_ci + ylnm_ch)
	replace nmwage = (nmwage)/4.16
	
	****************************************************************************
	** Months of unemployment
	gen more_12 = 1 if durades_ci>=12
	replace more_12 = . if durades_ci == .
	gen more_6 = 1 if durades_ci>=6
	replace more_6 = . if durades_ci == .
		
********************************************************************* STATISTICS
********************************************************************************
********************************************************************************

	** CALCULATION OF INDICATORS
	
	** POPULATION
	
	* Total population calculated according to expansion factor
	sum uno if migrante_ci!=. & sexo_ci == 1 [fw=factor_ci]
	scalar tot_masc_pop = `=r(N)'
	
	* Migrant population calculated according to expansion factor
	sum uno if migrante_ci==1 & sexo_ci == 1 [fw=factor_ci]
	scalar migr_masc_pop = `=r(N)'
	
	* Native population calculated according to expansion factor
	sum uno if migrante_ci==0 & sexo_ci == 1 [fw=factor_ci]
	scalar nat_masc_pop = `=r(N)'
	
	* Total population calculated according to expansion factor
	sum uno if migrante_ci!=. & sexo_ci == 2 [fw=factor_ci]
	scalar tot_fem_pop = `=r(N)'
	
	* Migrant population calculated according to expansion factor
	sum uno if migrante_ci==1 & sexo_ci == 2 [fw=factor_ci]
	scalar migr_fem_pop = `=r(N)'
	
	* Native population calculated according to expansion factor
	sum uno if migrante_ci==0 & sexo_ci == 2 [fw=factor_ci]
	scalar nat_fem_pop = `=r(N)'
	
	* Share of working age population (15-64) Male
	sum uno if inrange(edad_ci,15,64) & migrante_ci==1 & sexo_ci == 1 [fw=factor_ci]
	scalar workAge_migr_masc_pop = `=r(N)'
	sum uno if inrange(edad_ci,15,64) & migrante_ci==0 & sexo_ci == 1 [fw=factor_ci]
	scalar workAge_nat_masc_pop = `=r(N)'
	sum uno if inrange(edad_ci,15,64) & sexo_ci == 1 [fw=factor_ci]
	scalar workAge_masc_pop = `=r(N)'
		
	* Share of labour force population (15-64) Male
	sum uno if inrange(edad_ci,15,64) & pea_ci == 1 & migrante_ci==1 & sexo_ci == 1 [fw=factor_ci]
	scalar econoAct_migr_masc_pop = `=r(N)'
	sum uno if inrange(edad_ci,15,64) & pea_ci == 1 & migrante_ci==0 & sexo_ci == 1 [fw=factor_ci]
	scalar econoAct_nat_masc_pop = `=r(N)'
	sum uno if inrange(edad_ci,15,64) & pea_ci == 1 & sexo_ci == 1 [fw=factor_ci]
	scalar econoAct_masc_pop = `=r(N)'
	
	* Share of Employment rate  (15-64) Male
	sum uno if inrange(edad_ci,15,64) & emp_ci == 1 & migrante_ci==1 & sexo_ci == 1 [fw=factor_ci]
	scalar emp_migr_masc_pop = `=r(N)'
	sum uno if inrange(edad_ci,15,64) & emp_ci == 1 & migrante_ci==0 & sexo_ci == 1 [fw=factor_ci]
	scalar emp_nat_masc_pop = `=r(N)'
	sum uno if inrange(edad_ci,15,64) & emp_ci == 1 & sexo_ci == 1 [fw=factor_ci]
	scalar emp_masc_pop = `=r(N)'
	
	* Share of working age population (15-64) Female
	sum uno if inrange(edad_ci,15,64) & migrante_ci==1 & sexo_ci == 2 [fw=factor_ci]
	scalar workAge_migr_fem_pop = `=r(N)'
	sum uno if inrange(edad_ci,15,64) & migrante_ci==0 & sexo_ci == 2 [fw=factor_ci]
	scalar workAge_nat_fem_pop = `=r(N)'
	sum uno if inrange(edad_ci,15,64) & sexo_ci == 2 [fw=factor_ci]
	scalar workAge_fem_pop = `=r(N)'
		
	* Share of labour force population (15-64) Female
	sum uno if inrange(edad_ci,15,64) & pea_ci == 1 & migrante_ci==1 & sexo_ci == 2 [fw=factor_ci]
	scalar econoAct_migr_fem_pop = `=r(N)'
	sum uno if inrange(edad_ci,15,64) & pea_ci == 1 & migrante_ci==0 & sexo_ci == 2 [fw=factor_ci]
	scalar econoAct_nat_fem_pop = `=r(N)'
	sum uno if inrange(edad_ci,15,64) & pea_ci == 1 & sexo_ci == 2 [fw=factor_ci]
	scalar econoAct_fem_pop = `=r(N)'
	
	* Share of Employment rate  (15-64) Female
	sum uno if inrange(edad_ci,15,64) & emp_ci == 1 & migrante_ci==1 & sexo_ci == 2 [fw=factor_ci]
	scalar emp_migr_fem_pop = `=r(N)'
	sum uno if inrange(edad_ci,15,64) & emp_ci == 1 & migrante_ci==0 & sexo_ci == 2 [fw=factor_ci]
	scalar emp_nat_fem_pop = `=r(N)'
	sum uno if inrange(edad_ci,15,64) & emp_ci == 1 & sexo_ci == 2 [fw=factor_ci]
	scalar emp_fem_pop = `=r(N)'
	

	** CALCULATION OF INDICATORS BY MIGRANTS AND NATIVES
	
	foreach var in 1 0 {
		
		foreach sexo in 1 2 {
		
		** DEMOGRAPHIC
		
		* Age groups
		
		sum uno if inrange(edad_ci,0,14) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar pop_``var'_label'_``sexo'_sexo'014 = `=r(N)' // 0 - 14 years
		
		sum uno if inrange(edad_ci,15,24) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar pop_``var'_label'_``sexo'_sexo'1524 = `=r(N)' // 15 - 24 years

		sum uno if inrange(edad_ci,25,39) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar pop_``var'_label'_``sexo'_sexo'2539 = `=r(N)' // 25 - 39 years
		
		sum uno if inrange(edad_ci,40,54) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar pop_``var'_label'_``sexo'_sexo'4054 = `=r(N)' // 40 - 54 years

		sum uno if inrange(edad_ci,55,64) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar pop_``var'_label'_``sexo'_sexo'5564 = `=r(N)'	//55 - 64 years
		
		sum uno if inrange(edad_ci,65,.) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar pop_``var'_label'_``sexo'_sexo'65older = `=r(N)'  // 65 older years
		
		* Sex male population
		sum uno if sexo_ci==1 & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar male_``var'_label'_``sexo'_sexo'pop =`=r(N)'
		
		* Marital status: married/cohabiting
		sum uno if civil_ci==2 & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar married_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		sum uno if civil_ci!=. & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar status_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		* Marital status: separated/divorced/widowed
		sum uno if (civil_ci==3 | civil_ci==4) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar separated_``var'_label'_``sexo'_sexo'pop = `=r(N)'	
		
		* Marital status: single
		sum uno if civil_ci==1 & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar single_``var'_label'_``sexo'_sexo'pop = `=r(N)'	
		
		* Urban
		sum uno if zona_c==1 & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar urban_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		* Capital city located
		sum uno if (region_c==10 | region_c==31) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar capital_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		* Border cities or region
		*sum uno if inlist(region_c, ) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		*scalar borCity_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		* Household size
		sum nmiembros_ch if migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar size_``var'_label'_``sexo'_sexo'house = `=r(mean)'			
		
		* Number of children <= 18 in household
		sum nmenor18 if migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar less18_``var'_label'_``sexo'_sexo'house = `=r(mean)'			
		
		* Number of children <= 15 in household
		sum nmenor15 if migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar less15_``var'_label'_``sexo'_sexo'house = `=r(mean)'
		
		* Number of natural-born children (women only)
		
		
		** LABOUR MARKET INDICATORS
		
		* Share of population with a job
		sum uno if inrange(edad_ci,15,64) & emp_ci==1 & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar job_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		* Activity: Share participating in the labour force
		sum uno if inrange(edad_ci,15,64) & pea_ci==1 & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar econoAct_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		* Economically inactive people
		sum uno if inrange(edad_ci,15,64) & (condocup_ci == 3) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci] 
		scalar inactive_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		* Unemployment: Share of population who were unemployed
		sum uno if inrange(edad_ci,15,64) & desemp_ci==1 & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci] 
		scalar unemp_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		sum uno if (pea_ci==1 | asiste_ci==1) & inrange(edad_ci,15,64) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar econoActWorkAge_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		* Risk of labour market exclusion: long-term unemployment (12 months)
		sum uno if inrange(edad_ci,15,64) & (more_12==1 & desemp_ci==1) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar long12_unemp_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		sum uno if inrange(edad_ci,15,64) & (desemp_ci==1 | condocup_ci==3) & durades_ci!=. & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci] 
		scalar inac_unemp_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		* Risk of labour market exclusion: long-term unemployment (6 months)
		sum uno if inrange(edad_ci,15,64) & (more_6==1 & desemp_ci==1) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar long6_unemp_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		* Risk of labour market exclusion: long-term uemployment >=12 months or inactive involuntary
		sum uno if inrange(edad_ci,15,64) & (desalent_ci==1 | (more_12==1 & desemp_ci==1)) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar long_invo_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		* Risk of labour market exclusion: Inactive involuntary (available past week, not looking for job)
		sum uno if inrange(edad_ci,15,64) & desalent_ci==1 & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar involuntary_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		* Share of population with written contract
		sum uno if inrange(edad_ci,15,64) & inlist(tipocontrato_ci,0,1,2) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar written_``var'_label'_``sexo'_sexo'pop = `=r(N)'		
		
		* Share of population with an informal job
		*sum uno if inrange(edad_ci,15,64) & informal==1 & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		*scalar informal_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		* Types of contracts:  Share of population in temporary contracts
		sum uno if inrange(edad_ci,15,64) & tipocontrato_ci==2 & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci] 
		scalar tempJob_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		sum uno if inrange(edad_ci,15,64) & categopri_ci!=2 & asiste_ci!=1 & emp_ci==1 & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar noself_edu_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		* Working hours: long hours >= 40
		sum uno if inrange(edad_ci,15,64) & more_40==1 & emp_ci == 1 & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar more40h_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		sum uno if inrange(edad_ci,15,64) & by_hours==1 & emp_ci == 1 & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar hours_``var'_label'_``sexo'_sexo'pop = `=r(N)'

		* Working hours: long hours >= 50
		sum uno if inrange(edad_ci,15,64) & more_50==1 & emp_ci == 1 & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar more50h_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		* Working hours: long hours >= 55
		sum uno if inrange(edad_ci,15,64) & more_55==1 & emp_ci == 1 & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar more55h_``var'_label'_``sexo'_sexo'pop = `=r(N)'		
	
		* Working hours: long hours < 30
		sum uno if inrange(edad_ci,15,64) & less_30==1 & emp_ci == 1 & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar less30h_``var'_label'_``sexo'_sexo'pop = `=r(N)'

		* Job skills: share of working population in highly skilled jobs
		*sum uno if high_skilled==1 & inrange(edad_ci,15,64) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		*scalar highSkill_``var'_label'_``sexo'_sexo'pop = `=r(N)'	
		
		* Job skills: share of working population in low-skilled jobs 
		*sum uno if low_skilled==1 & inrange(edad_ci,15,64) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		*scalar lowSkill_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		* Overqualification: share of highly educated individuals who work in low- or medium-skilled jobs
		*sum uno if overqualificated==1 & inrange(edad_ci,15,64) & migrante_ci==`var' & sexo_ci==`sexo' & inrange(ISCED,4,9) [fw=factor_ci]
		*scalar overquali_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		*sum uno if emp_ci==1 & inrange(edad_ci,15,64) & asiste_ci!=1 & ISCO!=0 & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		*scalar NotEduNotMili_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		* Self-employment: share of population who works in their own firms or businesses
		sum uno if (categopri_ci==1 | categopri_ci==2) & inrange(edad_ci,15,64) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar selfEmp_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		sum uno if inrange(edad_ci,15,64) & rama_ci!=1 & emp_ci==1 & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar Notagri_emp1564_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		* Employment in the public sector
		sum uno if spublico_ci==1 & inrange(edad_ci,15,64) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar pubSec_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		sum uno if inrange(edad_ci,15,64) & emp_ci==1 & categopri_ci!=2 & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar NoSelf15to64_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		* Nominal monthly wage (USD)
		sum nmwage if migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar nmwage_``var'_label'_``sexo'_sexo' = `=r(mean)'
		
		* Child labour
		

		** EDUCATION AND SKILLS
		
		* Level of educational attainment: high (ISCED groups 5-8)
		sum uno if inrange(ISCED,5,8) & inrange(edad_ci,15,64) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar ISCED58_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		sum uno if inrange(edad_ci,15,64) & migrante_ci==`var' [fw=factor_ci]
		scalar ISCEDEdu_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		* Level of educational attainment: low (ISCED groups 0-2)
		sum uno if inrange(ISCED,0,2) & inrange(edad_ci,15,64) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar ISCED02_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		* Level of educational attainment: very low (ISCED groups 0-1)
		sum uno if inrange(ISCED,0,1) & inrange(edad_ci,15,64) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar ISCED01_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		* Literacy: knows how to read and write NOT AVAILABLE	
		
		sum uno if inrange(edad_ci,16,64) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci] 
		scalar pop_``var'_label'_``sexo'_sexo'1664 = `=r(N)'
		
		* Neither in employment, education or training for youth
		sum uno if (edad_ci>=15 & edad_ci <=34) & emp_ci!=1 & asiste_ci==0 & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar NoEmpNoedu_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		sum uno if inrange(edad_ci,15,34) & migrante_ci==`var' [fw=factor_ci]
		scalar age1534_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		* Early school leaving
		sum uno if asiste_ci == 0 & (edad_ci>=15 & edad_ci <=24) & inlist(ISCED,0,1,2) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar earlyLeft_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		sum uno if inrange(edad_ci,15,24) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar earlyAge_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		* Share of children attending schooling, 5 - 16 years group
		sum uno if asiste_ci==1 & inrange(edad_ci,5,16) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar attending_5to16_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		sum uno if inrange(edad_ci,5,16) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci] 
		scalar pop_``var'_label'_``sexo'_sexo'516 = `=r(N)'
		
		** CHILDREN EDUCATION AND EMPLOYMENT
		
		* Share of children attending school (15-18 year-olds)
		sum uno if asiste_ci==1 & inrange(edad_ci,15,18) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar attending_15to18_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		sum uno if inrange(edad_ci,15,18) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci] 
		scalar pop_``var'_label'_``sexo'_sexo'1518 = `=r(N)'
		
		* Share of children in employment (15-18 year-olds)
		sum uno if emp_ci==1 & inrange(edad_ci,15,18) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar employment_15to18_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		* Share of children attending school only (15-18 year-olds)
		sum uno if (asiste_ci==1 & emp_ci!=1) & inrange(edad_ci,15,18) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar AttOnly_15to18_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		* Share of children in employment only (15-18 year-olds)
		sum uno if (emp_ci==1 & asiste_ci!=1) & inrange(edad_ci,15,18) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar EmpOnly_15to18_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		* Share of children attending school & in employment (15-18 year-olds)
		sum uno if (asiste_ci==1 & emp_ci==1) & inrange(edad_ci,15,18) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar Att_Emp_1518_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		* Neither in employment, education or training for youth (15-18 year-olds)
		sum uno if (edad_ci>=15 & edad_ci <=18) & emp_ci==0 & asiste_ci==0 & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar NiNi_15to18_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		** HEALTH
		
		* Access to health services AMONG working pop
		sum uno if inrange(edad_ci,15,64) & (afiliado_ci==1 | cotizando_ci==1) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci] 
		scalar healthSys_``var'_label'_``sexo'_sexo'pop = `=r(N)'	
		
		sum uno if inrange(edad_ci,15,64) & emp_ci==1 & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar job15to64_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		** SAMPLE CHARACTERISTICS
		
		* Total sample size: persons 
		sum uno if migrante_ci==`var' & sexo_ci==`sexo'
		scalar survey_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		* Total sample size: persons 15-64
		sum uno if inrange(edad_ci,15,64) & migrante_ci==`var' & sexo_ci==`sexo'
		scalar survey_``var'_label'_``sexo'_sexo'15to64 = `=r(N)'

		* Total persons 15-64 (with sample loadings)
		sum uno if inrange(edad_ci,15,64) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar total_``var'_label'_``sexo'_sexo'15to64 = `=r(N)'
		
	}
	
		}
	
******************************************************** EXCEL OUTPUTS

	putexcel set "C:\Users\jcamilop\OneDrive - Inter-American Development Bank Group\OECD\03 Outputs\Resultados por sexo.xlsx", sheet("T&T") modify
	putexcel describe
	
	
	** POPULATION
	
	putexcel C6 = (`=nat_masc_pop'/`=tot_masc_pop') E6 = (`=migr_masc_pop'/`=tot_masc_pop')	// Share of population
	
	putexcel C7 = (`=workAge_nat_masc_pop'/`=workAge_masc_pop') E7 = (`=workAge_migr_masc_pop'/`=workAge_masc_pop') // Share of working age population (15-64)
	
	putexcel C8 = (`=econoAct_nat_masc_pop'/`=econoAct_masc_pop') E8 = (`=econoAct_migr_masc_pop'/`=econoAct_masc_pop') // Share of labour force population (15-64)
	
	putexcel C9 = (`=emp_nat_masc_pop'/`=emp_masc_pop') E9 = (`=emp_migr_masc_pop'/`=emp_masc_pop') // Share of Employment rate  (15-64)
	
	
	** DEMOGRAPHIC
	
	putexcel C17 = (`=pop_nat_masc_014'/`=nat_masc_pop') E17 = (`=pop_migr_masc_014'/`=migr_masc_pop') // 0 - 14
	
	putexcel C18 = (`=pop_nat_masc_1524'/`=nat_masc_pop') E18 = (`=pop_migr_masc_1524'/`=migr_masc_pop') // 15 - 24
	
	putexcel C19 = (`=pop_nat_masc_2539'/`=nat_masc_pop') E19 = (`=pop_migr_masc_2539'/`=migr_masc_pop') // 25 - 39
	
	putexcel C20 = (`=pop_nat_masc_4054'/`=nat_masc_pop') E20 = (`=pop_migr_masc_4054'/`=migr_masc_pop') // 40 - 54
	
	putexcel C21 = (`=pop_nat_masc_5564'/`=nat_masc_pop') E21 = (`=pop_migr_masc_5564'/`=migr_masc_pop') // 55 - 64
	
	putexcel C22 = (`=pop_nat_masc_65older'/`=nat_masc_pop') E22 = (`=pop_migr_masc_65older'/`=migr_masc_pop') // 65 Older
	
	putexcel C23 = (`=workAge_nat_masc_pop'/`=nat_masc_pop') E23 = (`=workAge_migr_masc_pop'/`=migr_masc_pop') // 15-64 
	
	*putexcel C25 = (`=male_nat_pop'/`=nat_pop') E25 = (`=male_migr_pop'/`=migr_pop') 	// Sex male
	
	putexcel C26 = (`=married_nat_masc_pop'/`=status_nat_masc_pop') E26 = (`=married_migr_masc_pop'/`=status_migr_masc_pop') // Marital status: married/cohabiting
	
	putexcel C27 = (`=separated_nat_masc_pop'/`=status_nat_masc_pop') E27 = (`=separated_migr_masc_pop'/`=status_migr_masc_pop') // Marital status: separated/divorced/widowed

	putexcel C28 = (`=single_nat_masc_pop'/`=status_nat_masc_pop') E28 = (`=single_migr_masc_pop'/`=status_migr_masc_pop') // Marital status: single
	
	putexcel C29 = (`=urban_nat_masc_pop'/`=nat_masc_pop') E29 = (`=urban_migr_masc_pop'/`=migr_masc_pop') // Urban
	
	putexcel C30 = (`=capital_nat_masc_pop'/`=nat_masc_pop')  E30 = (`=capital_migr_masc_pop'/`=migr_masc_pop') // Capital city located
	
	*putexcel C31 = (`=borCity_nat_masc_pop'/`=nat_masc_pop')  E31 = (`=borCity_migr_masc_pop'/`=migr_masc_pop') // Border cities or region
	
	putexcel C34 = (`=size_nat_masc_house')  E34 = (`=size_migr_masc_house') // Household size
		
	putexcel C35 = (`=less18_nat_masc_house')  E35 = (`=less18_migr_masc_house') // Number of children <= 18 in household
		
	putexcel C36 = (`=less15_nat_masc_house')  E36 = (`=less15_migr_masc_house') // Number of children <= 15 in household
		
	// Number of natural-born children (women only)
	
	
	** LABOUR MARKET INDICATORS
	
	putexcel C41 = (`=job_nat_masc_pop'/`=workAge_nat_masc_pop') E41 = (`=job_migr_masc_pop'/`=workAge_migr_masc_pop') // Share of population with a job
	
	putexcel C42 = (`=econoAct_nat_masc_pop'/`=workAge_nat_masc_pop') E42 = (`=econoAct_migr_masc_pop'/`=workAge_migr_masc_pop') // Activity: Share participating in the labour force
	
	putexcel C43 = (`=inactive_nat_masc_pop'/`=workAge_nat_masc_pop') E43 = (`=inactive_migr_masc_pop'/`=workAge_migr_masc_pop')  // Economically inactive people
	
	putexcel C44 = (`=unemp_nat_masc_pop'/`=econoActWorkAge_nat_masc_pop') E44 = (`=unemp_migr_masc_pop'/`=econoActWorkAge_migr_masc_pop') // Unemployment: Share of population who were unemployed
	
	*putexcel C45 = (`=long12_unemp_nat_masc_pop'/`=inac_unemp_nat_masc_pop') E45 = (`=long12_unemp_migr_masc_pop'/`=inac_unemp_migr_masc_pop') // Risk of labour market exclusion: long-term unemployment (12 month)
	
	*putexcel C46 = (`=long6_unemp_nat_masc_pop'/`=inac_unemp_nat_masc_pop') E46 = (`=long6_unemp_migr_masc_pop'/`=inac_unemp_migr_masc_pop') // Risk of labour market exclusion: long-term unemployment (6 month)
	
	*putexcel C47 = (`=involuntary_nat_masc_pop'/`=inac_unemp_nat_masc_pop') E47 = (`=involuntary_migr_masc_pop'/`=inac_unemp_migr_masc_pop') // Inactive involuntary (available past week, not looking for job)
	
	*putexcel C48 = (`=long_invo_nat_masc_pop'/`=inac_unemp_nat_masc_pop') E48 = (`=long_invo_migr_masc_pop'/`=inac_unemp_migr_masc_pop') // Long-term uemployment >=12 months or inactive involuntary	
	
	*putexcel C49 = (`=written_nat_masc_pop'/`=noself_edu_nat_masc_pop') E49 = (`=written_migr_masc_pop'/`=noself_edu_migr_masc_pop') // Share of population with written contract
	
	*putexcel C50 = (`=informal_nat_masc_pop'/`=job_nat_masc_pop') E50 = (`=informal_migr_masc_pop'/`=job_migr_masc_pop') // Share of population with an informal job	
	
    // Share of population with an informal job (OECD def)
	
	*putexcel C52 = (`=tempJob_nat_masc_pop'/`=noself_edu_nat_masc_pop') E52 = (`=tempJob_migr_masc_pop'/`=noself_edu_migr_masc_pop') // Types of contracts: Share of population in temporary contracts	
	
	putexcel C53 = (`=more40h_nat_masc_pop'/`=hours_nat_masc_pop') E53 = (`=more40h_migr_masc_pop'/`=hours_migr_masc_pop')  // Working hours: long (more than 40) hours	

	putexcel C54 = (`=more50h_nat_masc_pop'/`=hours_nat_masc_pop') E54 = (`=more50h_migr_masc_pop'/`=hours_migr_masc_pop')  // Working hours: long (more than 50) hours
	
	putexcel C55 = (`=more55h_nat_masc_pop'/`=hours_nat_masc_pop') E55 = (`=more55h_migr_masc_pop'/`=hours_migr_masc_pop')  // Working hours: long (more than 55) hours
	
	putexcel C56 = (`=less30h_nat_masc_pop'/`=hours_nat_masc_pop') E56 = (`=less30h_migr_masc_pop'/`=hours_migr_masc_pop')  // Working hours: long (less than 30) hours	
	
	*putexcel C57 = (`=highSkill_nat_masc_pop'/`=NotMili_nat_masc_pop') E57 = (`=highSkill_migr_masc_pop'/`=NotMili_migr_masc_pop') // Job skills: share of working population in highly skilled jobs
	
	*putexcel C58 = (`=lowSkill_nat_masc_pop'/`=NotMili_nat_masc_pop') E58 = (`=lowSkill_migr_masc_pop'/`=NotMili_migr_masc_pop') // Job skills: share of working population in low-skilled jobs 
		
	*putexcel C59 = (`=overquali_nat_masc_pop'/`=NotEduNotMili_nat_masc_pop') E59 = (`=overquali_migr_masc_pop'/`=NotEduNotMili_migr_masc_pop') // Overqualification: share of highly educated individuals who work in low- or medium-skilled jobs

	putexcel C60 = (`=selfEmp_nat_masc_pop'/`=Notagri_emp1564_nat_masc_pop') E60 = (`=selfEmp_migr_masc_pop'/`=Notagri_emp1564_migr_masc_pop')   // Self-employment: share of population who work in their own firms or businesses
	
	putexcel C61 = (`=pubSec_nat_masc_pop'/`=NoSelf15to64_nat_masc_pop') E61 = (`=pubSec_migr_masc_pop'/`=NoSelf15to64_migr_masc_pop')   // Employment in the public sector
	
	putexcel C62 = (`=nmwage_nat_masc_')  E62 = (`=nmwage_migr_masc_') // Nominal monthly wage (USD)
	
	* Child labour
	
	
	** EDUCATION AND SKILLS
		
	putexcel C69 = (`=ISCED58_nat_masc_pop'/`=ISCEDEdu_nat_masc_pop') E69 = (`=ISCED58_migr_masc_pop'/`=ISCEDEdu_migr_masc_pop') // Level of educational attainment: high (ISCED groups 5-8)
		
	putexcel C70 = (`=ISCED02_nat_masc_pop'/`=ISCEDEdu_nat_masc_pop') E70 = (`=ISCED02_migr_masc_pop'/`=ISCEDEdu_migr_masc_pop') // Level of educational attainment: low (ISCED groups 0-2)
		
	putexcel C71 = (`=ISCED01_nat_masc_pop'/`=ISCEDEdu_nat_masc_pop') E71 = (`=ISCED01_migr_masc_pop'/`=ISCEDEdu_migr_masc_pop') // Level of educational attainment: very low (ISCED groups 0-1)
		
	*putexcel C72 = (`=literacy_nat_masc_pop'/`=pop_nat_masc_1664') E72 = (`=literacy_migr_masc_pop'/`=pop_migr_masc_1664') // Literacy: knows how to read and write
	
	putexcel C73 = (`=NoEmpNoedu_nat_masc_pop'/`=age1534_nat_masc_pop') E73 = (`=NoEmpNoedu_migr_masc_pop'/`=age1534_migr_masc_pop')   // Neither in employment, education or training for youth
	
	putexcel C74 = (`=earlyLeft_nat_masc_pop'/`=earlyAge_nat_masc_pop') E74 = (`=earlyLeft_migr_masc_pop'/`=earlyAge_migr_masc_pop')  // Early school leaving
	
	putexcel C75 = (`=attending_5to16_nat_masc_pop'/`=pop_nat_masc_516') E75 = (`=attending_5to16_migr_masc_pop'/`=pop_migr_masc_516')  // Share of children attending schooling, 5 - 16 years group
	
	** CHILDREN EDUCATION AND EMPLOYMENT	
	
	putexcel C79 = (`=attending_15to18_nat_masc_pop'/`=pop_nat_masc_1518') E79 = (`=attending_15to18_migr_masc_pop'/`=pop_migr_masc_1518')  // Share of children attending school (15-18 year-olds)
	
	putexcel C80 = (`=employment_15to18_nat_masc_pop'/`=pop_nat_masc_1518') E80 = (`=employment_15to18_migr_masc_pop'/`=pop_migr_masc_1518')  // Share of children in employment (15-18 year-olds)
	
	putexcel C81 = (`=AttOnly_15to18_nat_masc_pop'/`=pop_nat_masc_1518') E81 = (`=AttOnly_15to18_migr_masc_pop'/`=pop_migr_masc_1518')  // Share of children attending school only (15-18 year-olds)
	
	putexcel C82 = (`=EmpOnly_15to18_nat_masc_pop'/`=pop_nat_masc_1518') E82 = (`=EmpOnly_15to18_migr_masc_pop'/`=pop_migr_masc_1518')  // Share of children in employment only (15-18 year-olds)
	
	putexcel C83 = (`=Att_Emp_1518_nat_masc_pop'/`=pop_nat_masc_1518') E83 = (`=Att_Emp_1518_migr_masc_pop'/`=pop_migr_masc_1518')  // Share of children attending school & in employment (15-18 year-olds)
	
	putexcel C84 = (`=NiNi_15to18_nat_masc_pop'/`=pop_nat_masc_1518') E84 = (`=NiNi_15to18_migr_masc_pop'/`=pop_migr_masc_1518')  // Neither in employment, education or training for youth (15-18 year-olds)
	
	**HEALTH
	
	* Health problems
	
	putexcel C91 = (`=healthSys_nat_masc_pop'/`=job15to64_nat_masc_pop') E91 = (`=healthSys_migr_masc_pop'/`=job15to64_migr_masc_pop') // Access to health services AMONG working pop
	
	** SIMPLE CHARACTERISTICS
	
	putexcel C96 = (`=survey_nat_masc_pop') E96 = (`=survey_migr_masc_pop') // Total sample size: persons
	
	putexcel C97 = (`=survey_nat_masc_15to64') E97 = (`=survey_migr_masc_15to64') // Total sample size: persons 15-64
	
	putexcel C99 = (`=nat_masc_pop') E99 = (`=migr_masc_pop') // Total population (with sample loadings)
	
	putexcel C100 = (`=total_nat_masc_15to64') E100 = (`=total_migr_masc_15to64') // Total persons 15-64 (with sample loadings)
	
** POPULATION
	
	putexcel D6 = (`=nat_fem_pop'/`=tot_fem_pop') F6 = (`=migr_fem_pop'/`=tot_fem_pop')	// Share of population
	
	putexcel D7 = (`=workAge_nat_fem_pop'/`=workAge_fem_pop') F7 = (`=workAge_migr_fem_pop'/`=workAge_fem_pop') // Share of working age population (15-64)
	
	putexcel D8 = (`=econoAct_nat_fem_pop'/`=econoAct_fem_pop') F8 = (`=econoAct_migr_fem_pop'/`=econoAct_fem_pop') // Share of labour force population (15-64)
	
	putexcel D9 = (`=emp_nat_fem_pop'/`=emp_fem_pop') F9 = (`=emp_migr_fem_pop'/`=emp_fem_pop') // Share of Employment rate  (15-64)
	
	
	** DEMOGRAPHIC
	
	putexcel D17 = (`=pop_nat_fem_014'/`=nat_fem_pop') F17 = (`=pop_migr_fem_014'/`=migr_fem_pop') // 0 - 14
	
	putexcel D18 = (`=pop_nat_fem_1524'/`=nat_fem_pop') F18 = (`=pop_migr_fem_1524'/`=migr_fem_pop') // 15 - 24
	
	putexcel D19 = (`=pop_nat_fem_2539'/`=nat_fem_pop') F19 = (`=pop_migr_fem_2539'/`=migr_fem_pop') // 25 - 39
	
	putexcel D20 = (`=pop_nat_fem_4054'/`=nat_fem_pop') F20 = (`=pop_migr_fem_4054'/`=migr_fem_pop') // 40 - 54
	
	putexcel D21 = (`=pop_nat_fem_5564'/`=nat_fem_pop') F21 = (`=pop_migr_fem_5564'/`=migr_fem_pop') // 55 - 64
	
	putexcel D22 = (`=pop_nat_fem_65older'/`=nat_fem_pop') F22 = (`=pop_migr_fem_65older'/`=migr_fem_pop') // 65 Older
	
	putexcel D23 = (`=workAge_nat_fem_pop'/`=nat_fem_pop') F23 = (`=workAge_migr_fem_pop'/`=migr_fem_pop') // 15-64 
	
	*putexcel D25 = (`=male_nat_pop'/`=nat_pop') F25 = (`=male_migr_pop'/`=migr_pop') 	// Sex male
	
	putexcel D26 = (`=married_nat_fem_pop'/`=status_nat_fem_pop') F26 = (`=married_migr_fem_pop'/`=status_migr_fem_pop') // Marital status: married/cohabiting
	
	putexcel D27 = (`=separated_nat_fem_pop'/`=status_nat_fem_pop') F27 = (`=separated_migr_fem_pop'/`=status_migr_fem_pop') // Marital status: separated/divorced/widowed

	putexcel D28 = (`=single_nat_fem_pop'/`=status_nat_fem_pop') F28 = (`=single_migr_fem_pop'/`=status_migr_fem_pop') // Marital status: single
	
	putexcel D29 = (`=urban_nat_fem_pop'/`=nat_fem_pop') F29 = (`=urban_migr_fem_pop'/`=migr_fem_pop') // Urban
	
	putexcel D30 = (`=capital_nat_fem_pop'/`=nat_fem_pop')  F30 = (`=capital_migr_fem_pop'/`=migr_fem_pop') // Capital city located
	
	*putexcel D31 = (`=borCity_nat_fem_pop'/`=nat_fem_pop')  F31 = (`=borCity_migr_fem_pop'/`=migr_fem_pop') // Border cities or region
	
	putexcel D34 = (`=size_nat_fem_house')  F34 = (`=size_migr_fem_house') // Household size
		
	putexcel D35 = (`=less18_nat_fem_house')  F35 = (`=less18_migr_fem_house') // Number of children <= 18 in household
		
	putexcel D36 = (`=less15_nat_fem_house')  F36 = (`=less15_migr_fem_house') // Number of children <= 15 in household
		
	// Number of natural-born children (women only)
	
	
	** LABOUR MARKET INDICATORS
	
	putexcel D41 = (`=job_nat_fem_pop'/`=workAge_nat_fem_pop') F41 = (`=job_migr_fem_pop'/`=workAge_migr_fem_pop') // Share of population with a job
	
	putexcel D42 = (`=econoAct_nat_fem_pop'/`=workAge_nat_fem_pop') F42 = (`=econoAct_migr_fem_pop'/`=workAge_migr_fem_pop') // Activity: Share participating in the labour force
	
	putexcel D43 = (`=inactive_nat_fem_pop'/`=workAge_nat_fem_pop') F43 = (`=inactive_migr_fem_pop'/`=workAge_migr_fem_pop')  // Economically inactive people
	
	putexcel D44 = (`=unemp_nat_fem_pop'/`=econoActWorkAge_nat_fem_pop') F44 = (`=unemp_migr_fem_pop'/`=econoActWorkAge_migr_fem_pop') // Unemployment: Share of population who were unemployed
	
	*putexcel D45 = (`=long12_unemp_nat_fem_pop'/`=inac_unemp_nat_fem_pop') F45 = (`=long12_unemp_migr_fem_pop'/`=inac_unemp_migr_fem_pop') // Risk of labour market exclusion: long-term unemployment (12 month)
	
	*putexcel D46 = (`=long6_unemp_nat_fem_pop'/`=inac_unemp_nat_fem_pop') F46 = (`=long6_unemp_migr_fem_pop'/`=inac_unemp_migr_fem_pop') // Risk of labour market exclusion: long-term unemployment (6 month)
	
	*putexcel D47 = (`=involuntary_nat_fem_pop'/`=inac_unemp_nat_fem_pop') F47 = (`=involuntary_migr_fem_pop'/`=inac_unemp_migr_fem_pop') // Inactive involuntary (available past week, not looking for job)
	
	*putexcel D48 = (`=long_invo_nat_fem_pop'/`=inac_unemp_nat_fem_pop') F48 = (`=long_invo_migr_fem_pop'/`=inac_unemp_migr_fem_pop') // Long-term uemployment >=12 months or inactive involuntary	
	
	*putexcel D49 = (`=written_nat_fem_pop'/`=noself_edu_nat_fem_pop') F49 = (`=written_migr_fem_pop'/`=noself_edu_migr_fem_pop') // Share of population with written contract
	
	*putexcel D50 = (`=informal_nat_fem_pop'/`=job_nat_fem_pop') F50 = (`=informal_migr_fem_pop'/`=job_migr_fem_pop') // Share of population with an informal job	
	
    // Share of population with an informal job (OECD def)
	
	putexcel D52 = (`=tempJob_nat_fem_pop'/`=noself_edu_nat_fem_pop') F52 = (`=tempJob_migr_fem_pop'/`=noself_edu_migr_fem_pop') // Types of contracts: Share of population in temporary contracts	
	
	putexcel D53 = (`=more40h_nat_fem_pop'/`=hours_nat_fem_pop') F53 = (`=more40h_migr_fem_pop'/`=hours_migr_fem_pop')  // Working hours: long (more than 40) hours	

	putexcel D54 = (`=more50h_nat_fem_pop'/`=hours_nat_fem_pop') F54 = (`=more50h_migr_fem_pop'/`=hours_migr_fem_pop')  // Working hours: long (more than 50) hours
	
	putexcel D55 = (`=more55h_nat_fem_pop'/`=hours_nat_fem_pop') F55 = (`=more55h_migr_fem_pop'/`=hours_migr_fem_pop')  // Working hours: long (more than 55) hours
	
	putexcel D56 = (`=less30h_nat_fem_pop'/`=hours_nat_fem_pop') F56 = (`=less30h_migr_fem_pop'/`=hours_migr_fem_pop')  // Working hours: long (less than 30) hours	
	
	*putexcel D57 = (`=highSkill_nat_fem_pop'/`=NotMili_nat_fem_pop') F57 = (`=highSkill_migr_fem_pop'/`=NotMili_migr_fem_pop') // Job skills: share of working population in highly skilled jobs
	
	*putexcel D58 = (`=lowSkill_nat_fem_pop'/`=NotMili_nat_fem_pop') F58 = (`=lowSkill_migr_fem_pop'/`=NotMili_migr_fem_pop') // Job skills: share of working population in low-skilled jobs 
		
	*putexcel D59 = (`=overquali_nat_fem_pop'/`=NotEduNotMili_nat_fem_pop') F59 = (`=overquali_migr_fem_pop'/`=NotEduNotMili_migr_fem_pop') // Overqualification: share of highly educated individuals who work in low- or medium-skilled jobs

	putexcel D60 = (`=selfEmp_nat_fem_pop'/`=Notagri_emp1564_nat_fem_pop') F60 = (`=selfEmp_migr_fem_pop'/`=Notagri_emp1564_migr_fem_pop')   // Self-employment: share of population who work in their own firms or businesses
	
	putexcel D61 = (`=pubSec_nat_fem_pop'/`=NoSelf15to64_nat_fem_pop') F61 = (`=pubSec_migr_fem_pop'/`=NoSelf15to64_migr_fem_pop')   // Employment in the public sector
	
	putexcel D62 = (`=nmwage_nat_fem_')  F62 = (`=nmwage_migr_fem_') // Nominal monthly wage (USD)
	
	* Child labour
	
	
	** EDUCATION AND SKILLS
		
	putexcel D69 = (`=ISCED58_nat_fem_pop'/`=ISCEDEdu_nat_fem_pop') F69 = (`=ISCED58_migr_fem_pop'/`=ISCEDEdu_migr_fem_pop') // Level of educational attainment: high (ISCED groups 5-8)
		
	putexcel D70 = (`=ISCED02_nat_fem_pop'/`=ISCEDEdu_nat_fem_pop') F70 = (`=ISCED02_migr_fem_pop'/`=ISCEDEdu_migr_fem_pop') // Level of educational attainment: low (ISCED groups 0-2)
		
	putexcel D71 = (`=ISCED01_nat_fem_pop'/`=ISCEDEdu_nat_fem_pop') F71 = (`=ISCED01_migr_fem_pop'/`=ISCEDEdu_migr_fem_pop') // Level of educational attainment: very low (ISCED groups 0-1)
		
	*putexcel D72 = (`=literacy_nat_fem_pop'/`=pop_nat_fem_1664') F72 = (`=literacy_migr_fem_pop'/`=pop_migr_fem_1664') // Literacy: knows how to read and write
	
	putexcel D73 = (`=NoEmpNoedu_nat_fem_pop'/`=age1534_nat_fem_pop') F73 = (`=NoEmpNoedu_migr_fem_pop'/`=age1534_migr_fem_pop')   // Neither in employment, education or training for youth
	
	putexcel D74 = (`=earlyLeft_nat_fem_pop'/`=earlyAge_nat_fem_pop') F74 = (`=earlyLeft_migr_fem_pop'/`=earlyAge_migr_fem_pop')  // Early school leaving
	
	putexcel D75 = (`=attending_5to16_nat_fem_pop'/`=pop_nat_fem_516') F75 = (`=attending_5to16_migr_fem_pop'/`=pop_migr_fem_516')  // Share of children attending schooling, 5 - 16 years group
	
	** CHILDREN EDUCATION AND EMPLOYMENT	
	
	putexcel D79 = (`=attending_15to18_nat_fem_pop'/`=pop_nat_fem_1518') F79 = (`=attending_15to18_migr_fem_pop'/`=pop_migr_fem_1518')  // Share of children attending school (15-18 year-olds)
	
	putexcel D80 = (`=employment_15to18_nat_fem_pop'/`=pop_nat_fem_1518') F80 = (`=employment_15to18_migr_fem_pop'/`=pop_migr_fem_1518')  // Share of children in employment (15-18 year-olds)
	
	putexcel D81 = (`=AttOnly_15to18_nat_fem_pop'/`=pop_nat_fem_1518') F81 = (`=AttOnly_15to18_migr_fem_pop'/`=pop_migr_fem_1518')  // Share of children attending school only (15-18 year-olds)
	
	putexcel D82 = (`=EmpOnly_15to18_nat_fem_pop'/`=pop_nat_fem_1518') F82 = (`=EmpOnly_15to18_migr_fem_pop'/`=pop_migr_fem_1518')  // Share of children in employment only (15-18 year-olds)
	
	putexcel D83 = (`=Att_Emp_1518_nat_fem_pop'/`=pop_nat_fem_1518') F83 = (`=Att_Emp_1518_migr_fem_pop'/`=pop_migr_fem_1518')  // Share of children attending school & in employment (15-18 year-olds)
	
	putexcel D84 = (`=NiNi_15to18_nat_fem_pop'/`=pop_nat_fem_1518') F84 = (`=NiNi_15to18_migr_fem_pop'/`=pop_migr_fem_1518')  // Neither in employment, education or training for youth (15-18 year-olds)
	
	**HEALTH
	
	* Health problems
	
	putexcel D91 = (`=healthSys_nat_fem_pop'/`=job15to64_nat_fem_pop') F91 = (`=healthSys_migr_fem_pop'/`=job15to64_migr_fem_pop') // Access to health services AMONG working pop
	
	** SIMPLE CHARACTERISTICS
	
	putexcel D96 = (`=survey_nat_fem_pop') F96 = (`=survey_migr_fem_pop') // Total sample size: persons
	
	putexcel D97 = (`=survey_nat_fem_15to64') F97 = (`=survey_migr_fem_15to64') // Total sample size: persons 15-64
	
	putexcel D99 = (`=nat_fem_pop') F99 = (`=migr_fem_pop') // Total population (with sample loadings)
	
	putexcel D100 = (`=total_nat_fem_15to64') F100 = (`=total_migr_fem_15to64') // Total persons 15-64 (with sample loadings)
	

********************************************************************************
********************************************************************************
********************************************************************************
****** URUGUAY - HOUSEHOLD SURVEY ECH 2019
	
	clear all
	set more off, perm
	set maxvar 15000
	scalar drop _all

	****************************************************************************
	** DATASET
	cd "C:\Users\jcamilop\OneDrive - Inter-American Development Bank Group\OECD\01 Raw"
	use "URY_2019a_BID.dta", replace

	gen uno=1
	replace factor_ci=round(factor_ci) // Applies when the expansion factor is a non-integer numbers
	
	****************************************************************************
	** LOCALS
		local 1_label = "migr"
		local 0_label = "nat"
		
		local 1_sexo = "masc_"
		local 2_sexo = "fem_"
	
	****************************************************************************
	** ISCED
	gen ISCED = 0 if eduno_ci == 1
	replace ISCED = 1 if edupi_ci == 1 | edupc_ci == 1
	replace ISCED = 2 if edus1i_ci == 1 | edus1c_ci  == 1
	replace ISCED = 3 if edus2i_ci  == 1 | edus2c_ci == 1
	replace ISCED = 6 if (eduui_ci == 1 | eduuc_ci == 1)
	
	****************************************************************************
	** JOB QUALIFICATIONS - ISCO
	gen ISCO = real(substr(string(codocupa, "%5.0g"), 1, 1))
	gen length = strlen(string(codocupa))
	replace ISCO = 0 if length == 3			
	replace ISCO = 1 if inlist(codocupa, 2311, 6130, 6141, 6151, 6152, 6153, 2446, 5121, 2332, 2331, 2321, 2312, 2311, 2359, 4213)
	replace ISCO = 2 if inlist(codocupa, 3213, 3471, 3118, 3121, 3241, 3229, 3226, 3223, 3226, 3224, 3229, 3310, 3320, 3433, 4190, 3415, 7321, 3473, 3472, 3474)
	replace ISCO = 3 if inlist(codocupa, 8112, 8111, 7111, 8171, 8172, 8211, 8213, 8214, 8221, 8223, 8231, 8240, 8251, 8253, 8261, 8262, 8263, 8264, 8265, 8266, 8271, 8272, 8273, 8274, 8275, 8276, 8277, 8278, 8279, 8281, 8282, 8283, 8284, 8285, 8286, 8232, 8171, 7122, 7123, 7124, 7137, 7136, 8161, 8163, 8152, 8153, 8155, 8123, 8112, 8121, 8122, 8171, 8142, 4136, 4135, 7311, 4141, 4143, 5132, 4122, 4216, 4190, 4213, 4215, 4133, 4134, 4135, 4136, 4190, 4121, 4131, 4136, 4133, 4135, 4134, 4133, 4131, 4190, 4113, 2429, 4115, 2419, 2460, 8290, 4141, 5122)
	replace ISCO = 4 if inlist(codocupa, 3431, 3414, 9333, 7345)
	replace ISCO = 5 if inlist(codocupa, 9141, 9152, 9151, 6129, 9151, 3340, 3242, 9171, 9111, 9172, 1310, 4211, 9113, 9152)
	replace ISCO = 7 if inlist(codocupa, 8211, 8212, 3471, 8251, 8252, 3214, 8240, 6152, 3152, 3215, 3214)
	replace ISCO = 8 if inlist(codocupa, 7344, 7431, 7419, 7214)
	replace ISCO = 9 if inlist(codocupa, 6113, 5221, 5122, 4131)
	gen overqualificated = 1 if inrange(ISCED,5,8) & inrange(ISCO,4,9)
	gen low_skilled = 1 if ISCO==9
	gen high_skilled = 1 if inrange(ISCO,1,3)
	
	****************************************************************************
	** Household size
	by idh_ch, sort: egen nmiembros=sum(relacion_ci>=1 & relacion_ci<5)
	by idh_ch, sort: egen nmenor18=sum((relacion_ci>=1 & relacion_ci<=4) & edad_ci<18)
	by idh_ch, sort: egen nmenor15=sum((relacion_ci>=1 & relacion_ci<=4) & edad_ci<15)
		
	****************************************************************************
	** Informality
	gen informal = 1 if cotizando_ci != 1 & emp_ci==1
	replace informal =1 if informal!=1 & afiliado_ci != 1 & emp_ci==1
	
	****************************************************************************
	** Working hours
	gen more_40 = 1 if horastot_ci >= 40
	replace more_40 = . if horastot_ci == .
	gen more_50 = 1 if horastot_ci >= 50
	replace more_50 = . if horastot_ci == .
	gen more_55 = 1 if horastot_ci >= 55
	replace more_55 = . if horastot_ci == .
	gen less_30 = 1 if horastot_ci <= 30
	replace less_30 = . if horastot_ci == .
	gen by_hours = 1 if emp_ci == 1
	replace by_hours = . if horastot_ci == .
	
	****************************************************************************
	** Nominal monthly wage (USD)
	by idh_ch, sort: egen nmwage=mean(ylm_ci + ylnm_ch)
	replace nmwage = (nmwage)/28.46
	
	****************************************************************************
	** Months of unemployment
	gen more_12 = 1 if f113>=12
	replace more_12 = . if durades_ci == .
	gen more_6 = 1 if f113>=6
	replace more_6 = . if durades_ci == .
		
********************************************************************* STATISTICS
********************************************************************************
********************************************************************************

	** CALCULATION OF INDICATORS
	
	** POPULATION
	
	* Total population calculated according to expansion factor
	sum uno if migrante_ci!=. & sexo_ci == 1 [fw=factor_ci]
	scalar tot_masc_pop = `=r(N)'
	
	* Migrant population calculated according to expansion factor
	sum uno if migrante_ci==1 & sexo_ci == 1 [fw=factor_ci]
	scalar migr_masc_pop = `=r(N)'
	
	* Native population calculated according to expansion factor
	sum uno if migrante_ci==0 & sexo_ci == 1 [fw=factor_ci]
	scalar nat_masc_pop = `=r(N)'
	
	* Total population calculated according to expansion factor
	sum uno if migrante_ci!=. & sexo_ci == 2 [fw=factor_ci]
	scalar tot_fem_pop = `=r(N)'
	
	* Migrant population calculated according to expansion factor
	sum uno if migrante_ci==1 & sexo_ci == 2 [fw=factor_ci]
	scalar migr_fem_pop = `=r(N)'
	
	* Native population calculated according to expansion factor
	sum uno if migrante_ci==0 & sexo_ci == 2 [fw=factor_ci]
	scalar nat_fem_pop = `=r(N)'
	
	* Share of working age population (15-64) Male
	sum uno if inrange(edad_ci,15,64) & migrante_ci==1 & sexo_ci == 1 [fw=factor_ci]
	scalar workAge_migr_masc_pop = `=r(N)'
	sum uno if inrange(edad_ci,15,64) & migrante_ci==0 & sexo_ci == 1 [fw=factor_ci]
	scalar workAge_nat_masc_pop = `=r(N)'
	sum uno if inrange(edad_ci,15,64) & sexo_ci == 1 [fw=factor_ci]
	scalar workAge_masc_pop = `=r(N)'
		
	* Share of labour force population (15-64) Male
	sum uno if inrange(edad_ci,15,64) & pea_ci == 1 & migrante_ci==1 & sexo_ci == 1 [fw=factor_ci]
	scalar econoAct_migr_masc_pop = `=r(N)'
	sum uno if inrange(edad_ci,15,64) & pea_ci == 1 & migrante_ci==0 & sexo_ci == 1 [fw=factor_ci]
	scalar econoAct_nat_masc_pop = `=r(N)'
	sum uno if inrange(edad_ci,15,64) & pea_ci == 1 & sexo_ci == 1 [fw=factor_ci]
	scalar econoAct_masc_pop = `=r(N)'
	
	* Share of Employment rate  (15-64) Male
	sum uno if inrange(edad_ci,15,64) & emp_ci == 1 & migrante_ci==1 & sexo_ci == 1 [fw=factor_ci]
	scalar emp_migr_masc_pop = `=r(N)'
	sum uno if inrange(edad_ci,15,64) & emp_ci == 1 & migrante_ci==0 & sexo_ci == 1 [fw=factor_ci]
	scalar emp_nat_masc_pop = `=r(N)'
	sum uno if inrange(edad_ci,15,64) & emp_ci == 1 & sexo_ci == 1 [fw=factor_ci]
	scalar emp_masc_pop = `=r(N)'
	
	* Share of working age population (15-64) Female
	sum uno if inrange(edad_ci,15,64) & migrante_ci==1 & sexo_ci == 2 [fw=factor_ci]
	scalar workAge_migr_fem_pop = `=r(N)'
	sum uno if inrange(edad_ci,15,64) & migrante_ci==0 & sexo_ci == 2 [fw=factor_ci]
	scalar workAge_nat_fem_pop = `=r(N)'
	sum uno if inrange(edad_ci,15,64) & sexo_ci == 2 [fw=factor_ci]
	scalar workAge_fem_pop = `=r(N)'
		
	* Share of labour force population (15-64) Female
	sum uno if inrange(edad_ci,15,64) & pea_ci == 1 & migrante_ci==1 & sexo_ci == 2 [fw=factor_ci]
	scalar econoAct_migr_fem_pop = `=r(N)'
	sum uno if inrange(edad_ci,15,64) & pea_ci == 1 & migrante_ci==0 & sexo_ci == 2 [fw=factor_ci]
	scalar econoAct_nat_fem_pop = `=r(N)'
	sum uno if inrange(edad_ci,15,64) & pea_ci == 1 & sexo_ci == 2 [fw=factor_ci]
	scalar econoAct_fem_pop = `=r(N)'
	
	* Share of Employment rate  (15-64) Female
	sum uno if inrange(edad_ci,15,64) & emp_ci == 1 & migrante_ci==1 & sexo_ci == 2 [fw=factor_ci]
	scalar emp_migr_fem_pop = `=r(N)'
	sum uno if inrange(edad_ci,15,64) & emp_ci == 1 & migrante_ci==0 & sexo_ci == 2 [fw=factor_ci]
	scalar emp_nat_fem_pop = `=r(N)'
	sum uno if inrange(edad_ci,15,64) & emp_ci == 1 & sexo_ci == 2 [fw=factor_ci]
	scalar emp_fem_pop = `=r(N)'
	

	** CALCULATION OF INDICATORS BY MIGRANTS AND NATIVES
	
	foreach var in 1 0 {
		
		foreach sexo in 1 2 {
		
		** DEMOGRAPHIC
		
		* Age groups
		
		sum uno if inrange(edad_ci,0,14) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar pop_``var'_label'_``sexo'_sexo'014 = `=r(N)' // 0 - 14 years
		
		sum uno if inrange(edad_ci,15,24) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar pop_``var'_label'_``sexo'_sexo'1524 = `=r(N)' // 15 - 24 years

		sum uno if inrange(edad_ci,25,39) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar pop_``var'_label'_``sexo'_sexo'2539 = `=r(N)' // 25 - 39 years
		
		sum uno if inrange(edad_ci,40,54) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar pop_``var'_label'_``sexo'_sexo'4054 = `=r(N)' // 40 - 54 years

		sum uno if inrange(edad_ci,55,64) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar pop_``var'_label'_``sexo'_sexo'5564 = `=r(N)'	//55 - 64 years
		
		sum uno if inrange(edad_ci,65,.) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar pop_``var'_label'_``sexo'_sexo'65older = `=r(N)'  // 65 older years
		
		* Sex male population
		sum uno if sexo_ci==1 & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar male_``var'_label'_``sexo'_sexo'pop =`=r(N)'
		
		* Marital status: married/cohabiting
		sum uno if civil_ci==2 & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar married_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		sum uno if civil_ci!=. & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar status_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		* Marital status: separated/divorced/widowed
		sum uno if (civil_ci==3 | civil_ci==4) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar separated_``var'_label'_``sexo'_sexo'pop = `=r(N)'	
		
		* Marital status: single
		sum uno if civil_ci==1 & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar single_``var'_label'_``sexo'_sexo'pop = `=r(N)'	
		
		* Urban
		sum uno if zona_c==1 & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar urban_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		* Capital city located
		sum uno if region_c==1 & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar capital_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		* Border cities or region
		sum uno if inlist(region_c, 1, 2, 4, 11, 12, 13, 14, 15, 19) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar borCity_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		* Household size
		sum nmiembros_ch if migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar size_``var'_label'_``sexo'_sexo'house = `=r(mean)'			
		
		* Number of children <= 18 in household
		sum nmenor18 if migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar less18_``var'_label'_``sexo'_sexo'house = `=r(mean)'			
		
		* Number of children <= 15 in household
		sum nmenor15 if migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar less15_``var'_label'_``sexo'_sexo'house = `=r(mean)'
		
		* Number of natural-born children (women only)
		
		
		** LABOUR MARKET INDICATORS
		
		* Share of population with a job
		sum uno if inrange(edad_ci,15,64) & emp_ci==1 & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar job_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		* Activity: Share participating in the labour force
		sum uno if inrange(edad_ci,15,64) & pea_ci==1 & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar econoAct_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		* Economically inactive people
		sum uno if inrange(edad_ci,15,64) & (condocup_ci == 3) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci] 
		scalar inactive_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		* Unemployment: Share of population who were unemployed
		sum uno if inrange(edad_ci,15,64) & desemp_ci==1 & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci] 
		scalar unemp_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		sum uno if (pea_ci==1 | asiste_ci==1) & inrange(edad_ci,15,64) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar econoActWorkAge_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		* Risk of labour market exclusion: long-term unemployment (12 months)
		sum uno if inrange(edad_ci,15,64) & (more_12==1 & desemp_ci==1) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar long12_unemp_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		sum uno if inrange(edad_ci,15,64) & (desemp_ci==1 | condocup_ci==3) & durades_ci!=. & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci] 
		scalar inac_unemp_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		* Risk of labour market exclusion: long-term unemployment (6 months)
		sum uno if inrange(edad_ci,15,64) & (more_6==1 & desemp_ci==1) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar long6_unemp_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		* Risk of labour market exclusion: long-term uemployment >=12 months or inactive involuntary
		sum uno if inrange(edad_ci,15,64) & (desalent_ci==1 | (more_12==1 & desemp_ci==1)) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar long_invo_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		* Risk of labour market exclusion: Inactive involuntary (available past week, not looking for job)
		sum uno if inrange(edad_ci,15,64) & desalent_ci==1 & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar involuntary_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		* Share of population with written contract
		sum uno if inrange(edad_ci,15,64) & (cotizando_ci== 1) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar written_``var'_label'_``sexo'_sexo'pop = `=r(N)'		
		
		* Share of population with an informal job
		sum uno if inrange(edad_ci,15,64) & informal==1 & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar informal_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		* Types of contracts:  Share of population in temporary contracts
		sum uno if inrange(edad_ci,15,64) & tipocontrato_ci==2 & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci] 
		scalar tempJob_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		sum uno if inrange(edad_ci,15,64) & categopri_ci!=2 & asiste_ci!=1 & emp_ci==1 & migrante_ci==`var' [fw=factor_ci]
		scalar noself_edu_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		* Working hours: long hours >= 40
		sum uno if inrange(edad_ci,15,64) & more_40==1 & emp_ci == 1 & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar more40h_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		sum uno if inrange(edad_ci,15,64) & by_hours==1 & emp_ci == 1 & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar hours_``var'_label'_``sexo'_sexo'pop = `=r(N)'

		* Working hours: long hours >= 50
		sum uno if inrange(edad_ci,15,64) & more_50==1 & emp_ci == 1 & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar more50h_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		* Working hours: long hours >= 55
		sum uno if inrange(edad_ci,15,64) & more_55==1 & emp_ci == 1 & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar more55h_``var'_label'_``sexo'_sexo'pop = `=r(N)'		
	
		* Working hours: long hours < 30
		sum uno if inrange(edad_ci,15,64) & less_30==1 & emp_ci == 1 & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar less30h_``var'_label'_``sexo'_sexo'pop = `=r(N)'

		* Job skills: share of working population in highly skilled jobs
		sum uno if high_skilled==1 & inrange(edad_ci,15,64) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar highSkill_``var'_label'_``sexo'_sexo'pop = `=r(N)'		
		
		* Job skills: share of working population in low-skilled jobs
		sum uno if low_skilled==1 & inrange(edad_ci,15,64) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar lowSkill_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		sum uno if emp_ci==1 & inrange(edad_ci,15,64) & ISCO!=0 & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar NotMili_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		* Overqualification: share of highly educated individuals who work in low- or medium-skilled jobs
		sum uno if overqualificated==1 & inrange(edad_ci,15,64) & migrante_ci==`var' & sexo_ci==`sexo' & inrange(ISCED,4,9) [fw=factor_ci]
		scalar overquali_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		sum uno if emp_ci==1 & inrange(edad_ci,15,64) & asiste_ci!=1 & ISCO!=0 & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar NotEduNotMili_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		* Self-employment: share of population who works in their own firms or businesses
		sum uno if (categopri_ci==1 | categopri_ci==2) & inrange(edad_ci,15,64) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar selfEmp_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		sum uno if inrange(edad_ci,15,64) & rama_ci!=1 & emp_ci==1 & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar Notagri_emp1564_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		* Employment in the public sector
		sum uno if spublico_ci==1 & inrange(edad_ci,15,64) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar pubSec_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		sum uno if inrange(edad_ci,15,64) & emp_ci==1 & categopri_ci!=2 & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar NoSelf15to64_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		* Nominal monthly wage (USD)
		sum nmwage if migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar nmwage_``var'_label'_``sexo'_sexo' = `=r(mean)'
		
		* Child labour
		

		** EDUCATION AND SKILLS
		
		* Level of educational attainment: high (ISCED groups 5-8)
		sum uno if inrange(ISCED,5,8) & inrange(edad_ci,15,64) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar ISCED58_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		sum uno if inrange(edad_ci,15,64) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar ISCEDEdu_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		* Level of educational attainment: low (ISCED groups 0-2)
		sum uno if inrange(ISCED,0,2) & inrange(edad_ci,15,64) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar ISCED02_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		* Level of educational attainment: very low (ISCED groups 0-1)
		sum uno if inrange(ISCED,0,1) & inrange(edad_ci,15,64) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar ISCED01_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		* Literacy: knows how to read and write 
		sum uno if (edusi_ci==1 | edusc_ci==1 | eduui_ci==1 | eduuc_ci==1 | aedu_ci>=5) & inrange(edad_ci,16,64) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar literacy_``var'_label'_``sexo'_sexo'pop = `=r(N)'			
		
		sum uno if inrange(edad_ci,16,64) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci] 
		scalar pop_``var'_label'_``sexo'_sexo'1664 = `=r(N)'
		
		* Neither in employment, education or training for youth
		sum uno if (edad_ci>=15 & edad_ci <=34) & emp_ci!=1 & asiste_ci==0 & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar NoEmpNoedu_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		sum uno if inrange(edad_ci,15,34) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar age1534_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		* Early school leaving
		sum uno if asiste_ci == 0 & (edad_ci>=15 & edad_ci <=24) & inlist(ISCED,0,1,2) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar earlyLeft_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		sum uno if inrange(edad_ci,15,24) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar earlyAge_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		* Share of children attending schooling, 5 - 16 years group
		sum uno if asiste_ci==1 & inrange(edad_ci,5,16) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar attending_5to16_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		sum uno if inrange(edad_ci,5,16) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci] 
		scalar pop_``var'_label'_``sexo'_sexo'516 = `=r(N)'
		
		** CHILDREN EDUCATION AND EMPLOYMENT
		
		* Share of children attending school (15-18 year-olds)
		sum uno if asiste_ci==1 & inrange(edad_ci,15,18) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar attending_15to18_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		sum uno if inrange(edad_ci,15,18) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci] 
		scalar pop_``var'_label'_``sexo'_sexo'1518 = `=r(N)'
		
		* Share of children in employment (15-18 year-olds)
		sum uno if emp_ci==1 & inrange(edad_ci,15,18) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar employment_15to18_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		* Share of children attending school only (15-18 year-olds)
		sum uno if (asiste_ci==1 & emp_ci!=1) & inrange(edad_ci,15,18) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar AttOnly_15to18_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		* Share of children in employment only (15-18 year-olds)
		sum uno if (emp_ci==1 & asiste_ci!=1) & inrange(edad_ci,15,18) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar EmpOnly_15to18_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		* Share of children attending school & in employment (15-18 year-olds)
		sum uno if (asiste_ci==1 & emp_ci==1) & inrange(edad_ci,15,18) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar Att_Emp_1518_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		* Neither in employment, education or training for youth (15-18 year-olds)
		sum uno if (edad_ci>=15 & edad_ci <=18) & emp_ci==0 & asiste_ci==0 & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar NiNi_15to18_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		** HEALTH
		
		* Access to health services AMONG working pop
		sum uno if inrange(edad_ci,15,64) & (afiliado_ci==1 | cotizando_ci==1) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci] 
		scalar healthSys_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		sum uno if inrange(edad_ci,15,64) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar job15to64_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		** SAMPLE CHARACTERISTICS
		
		* Total sample size: persons 
		sum uno if migrante_ci==`var' & sexo_ci==`sexo'
		scalar survey_``var'_label'_``sexo'_sexo'pop = `=r(N)'
		
		* Total sample size: persons 15-64
		sum uno if inrange(edad_ci,15,64) & migrante_ci==`var' & sexo_ci==`sexo'
		scalar survey_``var'_label'_``sexo'_sexo'15to64 = `=r(N)'

		* Total persons 15-64 (with sample loadings)
		sum uno if inrange(edad_ci,15,64) & migrante_ci==`var' & sexo_ci==`sexo' [fw=factor_ci]
		scalar total_``var'_label'_``sexo'_sexo'15to64 = `=r(N)'
		
	}
	
		}
	
******************************************************** EXCEL OUTPUTS

	putexcel set "C:\Users\jcamilop\OneDrive - Inter-American Development Bank Group\OECD\03 Outputs\Resultados por sexo.xlsx", sheet("Uruguay") modify
	putexcel describe
	
	
	** POPULATION
	
	putexcel C6 = (`=nat_masc_pop'/`=tot_masc_pop') E6 = (`=migr_masc_pop'/`=tot_masc_pop')	// Share of population
	
	putexcel C7 = (`=workAge_nat_masc_pop'/`=workAge_masc_pop') E7 = (`=workAge_migr_masc_pop'/`=workAge_masc_pop') // Share of working age population (15-64)
	
	putexcel C8 = (`=econoAct_nat_masc_pop'/`=econoAct_masc_pop') E8 = (`=econoAct_migr_masc_pop'/`=econoAct_masc_pop') // Share of labour force population (15-64)
	
	putexcel C9 = (`=emp_nat_masc_pop'/`=emp_masc_pop') E9 = (`=emp_migr_masc_pop'/`=emp_masc_pop') // Share of Employment rate  (15-64)
	
	
	** DEMOGRAPHIC
	
	putexcel C17 = (`=pop_nat_masc_014'/`=nat_masc_pop') E17 = (`=pop_migr_masc_014'/`=migr_masc_pop') // 0 - 14
	
	putexcel C18 = (`=pop_nat_masc_1524'/`=nat_masc_pop') E18 = (`=pop_migr_masc_1524'/`=migr_masc_pop') // 15 - 24
	
	putexcel C19 = (`=pop_nat_masc_2539'/`=nat_masc_pop') E19 = (`=pop_migr_masc_2539'/`=migr_masc_pop') // 25 - 39
	
	putexcel C20 = (`=pop_nat_masc_4054'/`=nat_masc_pop') E20 = (`=pop_migr_masc_4054'/`=migr_masc_pop') // 40 - 54
	
	putexcel C21 = (`=pop_nat_masc_5564'/`=nat_masc_pop') E21 = (`=pop_migr_masc_5564'/`=migr_masc_pop') // 55 - 64
	
	putexcel C22 = (`=pop_nat_masc_65older'/`=nat_masc_pop') E22 = (`=pop_migr_masc_65older'/`=migr_masc_pop') // 65 Older
	
	putexcel C23 = (`=workAge_nat_masc_pop'/`=nat_masc_pop') E23 = (`=workAge_migr_masc_pop'/`=migr_masc_pop') // 15-64 
	
	*putexcel C25 = (`=male_nat_pop'/`=nat_pop') E25 = (`=male_migr_pop'/`=migr_pop') 	// Sex male
	
	putexcel C26 = (`=married_nat_masc_pop'/`=status_nat_masc_pop') E26 = (`=married_migr_masc_pop'/`=status_migr_masc_pop') // Marital status: married/cohabiting
	
	putexcel C27 = (`=separated_nat_masc_pop'/`=status_nat_masc_pop') E27 = (`=separated_migr_masc_pop'/`=status_migr_masc_pop') // Marital status: separated/divorced/widowed

	putexcel C28 = (`=single_nat_masc_pop'/`=status_nat_masc_pop') E28 = (`=single_migr_masc_pop'/`=status_migr_masc_pop') // Marital status: single
	
	putexcel C29 = (`=urban_nat_masc_pop'/`=nat_masc_pop') E29 = (`=urban_migr_masc_pop'/`=migr_masc_pop') // Urban
	
	putexcel C30 = (`=capital_nat_masc_pop'/`=nat_masc_pop')  E30 = (`=capital_migr_masc_pop'/`=migr_masc_pop') // Capital city located
	
	putexcel C31 = (`=borCity_nat_masc_pop'/`=nat_masc_pop')  E31 = (`=borCity_migr_masc_pop'/`=migr_masc_pop') // Border cities or region
	
	putexcel C34 = (`=size_nat_masc_house')  E34 = (`=size_migr_masc_house') // Household size
		
	putexcel C35 = (`=less18_nat_masc_house')  E35 = (`=less18_migr_masc_house') // Number of children <= 18 in household
		
	putexcel C36 = (`=less15_nat_masc_house')  E36 = (`=less15_migr_masc_house') // Number of children <= 15 in household
		
	// Number of natural-born children (women only)
	
	
	** LABOUR MARKET INDICATORS
	
	putexcel C41 = (`=job_nat_masc_pop'/`=workAge_nat_masc_pop') E41 = (`=job_migr_masc_pop'/`=workAge_migr_masc_pop') // Share of population with a job
	
	putexcel C42 = (`=econoAct_nat_masc_pop'/`=workAge_nat_masc_pop') E42 = (`=econoAct_migr_masc_pop'/`=workAge_migr_masc_pop') // Activity: Share participating in the labour force
	
	putexcel C43 = (`=inactive_nat_masc_pop'/`=workAge_nat_masc_pop') E43 = (`=inactive_migr_masc_pop'/`=workAge_migr_masc_pop')  // Economically inactive people
	
	putexcel C44 = (`=unemp_nat_masc_pop'/`=econoActWorkAge_nat_masc_pop') E44 = (`=unemp_migr_masc_pop'/`=econoActWorkAge_migr_masc_pop') // Unemployment: Share of population who were unemployed
	
	putexcel C45 = (`=long12_unemp_nat_masc_pop'/`=inac_unemp_nat_masc_pop') E45 = (`=long12_unemp_migr_masc_pop'/`=inac_unemp_migr_masc_pop') // Risk of labour market exclusion: long-term unemployment (12 month)
	
	putexcel C46 = (`=long6_unemp_nat_masc_pop'/`=inac_unemp_nat_masc_pop') E46 = (`=long6_unemp_migr_masc_pop'/`=inac_unemp_migr_masc_pop') // Risk of labour market exclusion: long-term unemployment (6 month)
	
	putexcel C47 = (`=involuntary_nat_masc_pop'/`=inac_unemp_nat_masc_pop') E47 = (`=involuntary_migr_masc_pop'/`=inac_unemp_migr_masc_pop') // Inactive involuntary (available past week, not looking for job)
	
	putexcel C48 = (`=long_invo_nat_masc_pop'/`=inac_unemp_nat_masc_pop') E48 = (`=long_invo_migr_masc_pop'/`=inac_unemp_migr_masc_pop') // Long-term uemployment >=12 months or inactive involuntary	
	
	putexcel C49 = (`=written_nat_masc_pop'/`=noself_edu_nat_masc_pop') E49 = (`=written_migr_masc_pop'/`=noself_edu_migr_masc_pop') // Share of population with written contract
	
	putexcel C50 = (`=informal_nat_masc_pop'/`=job_nat_masc_pop') E50 = (`=informal_migr_masc_pop'/`=job_migr_masc_pop') // Share of population with an informal job	
	
    // Share of population with an informal job (OECD def)
	
	putexcel C52 = (`=tempJob_nat_masc_pop'/`=noself_edu_nat_masc_pop') E52 = (`=tempJob_migr_masc_pop'/`=noself_edu_migr_masc_pop') // Types of contracts: Share of population in temporary contracts	
	
	putexcel C53 = (`=more40h_nat_masc_pop'/`=hours_nat_masc_pop') E53 = (`=more40h_migr_masc_pop'/`=hours_migr_masc_pop')  // Working hours: long (more than 40) hours	

	putexcel C54 = (`=more50h_nat_masc_pop'/`=hours_nat_masc_pop') E54 = (`=more50h_migr_masc_pop'/`=hours_migr_masc_pop')  // Working hours: long (more than 50) hours
	
	putexcel C55 = (`=more55h_nat_masc_pop'/`=hours_nat_masc_pop') E55 = (`=more55h_migr_masc_pop'/`=hours_migr_masc_pop')  // Working hours: long (more than 55) hours
	
	putexcel C56 = (`=less30h_nat_masc_pop'/`=hours_nat_masc_pop') E56 = (`=less30h_migr_masc_pop'/`=hours_migr_masc_pop')  // Working hours: long (less than 30) hours	
	
	putexcel C57 = (`=highSkill_nat_masc_pop'/`=NotMili_nat_masc_pop') E57 = (`=highSkill_migr_masc_pop'/`=NotMili_migr_masc_pop') // Job skills: share of working population in highly skilled jobs
	
	putexcel C58 = (`=lowSkill_nat_masc_pop'/`=NotMili_nat_masc_pop') E58 = (`=lowSkill_migr_masc_pop'/`=NotMili_migr_masc_pop') // Job skills: share of working population in low-skilled jobs 
		
	putexcel C59 = (`=overquali_nat_masc_pop'/`=NotEduNotMili_nat_masc_pop') E59 = (`=overquali_migr_masc_pop'/`=NotEduNotMili_migr_masc_pop') // Overqualification: share of highly educated individuals who work in low- or medium-skilled jobs

	putexcel C60 = (`=selfEmp_nat_masc_pop'/`=Notagri_emp1564_nat_masc_pop') E60 = (`=selfEmp_migr_masc_pop'/`=Notagri_emp1564_migr_masc_pop')   // Self-employment: share of population who work in their own firms or businesses
	
	putexcel C61 = (`=pubSec_nat_masc_pop'/`=NoSelf15to64_nat_masc_pop') E61 = (`=pubSec_migr_masc_pop'/`=NoSelf15to64_migr_masc_pop')   // Employment in the public sector
	
	putexcel C62 = (`=nmwage_nat_masc_')  E62 = (`=nmwage_migr_masc_') // Nominal monthly wage (USD)
	
	* Child labour
	
	
	** EDUCATION AND SKILLS
		
	putexcel C69 = (`=ISCED58_nat_masc_pop'/`=ISCEDEdu_nat_masc_pop') E69 = (`=ISCED58_migr_masc_pop'/`=ISCEDEdu_migr_masc_pop') // Level of educational attainment: high (ISCED groups 5-8)
		
	putexcel C70 = (`=ISCED02_nat_masc_pop'/`=ISCEDEdu_nat_masc_pop') E70 = (`=ISCED02_migr_masc_pop'/`=ISCEDEdu_migr_masc_pop') // Level of educational attainment: low (ISCED groups 0-2)
		
	putexcel C71 = (`=ISCED01_nat_masc_pop'/`=ISCEDEdu_nat_masc_pop') E71 = (`=ISCED01_migr_masc_pop'/`=ISCEDEdu_migr_masc_pop') // Level of educational attainment: very low (ISCED groups 0-1)
		
	putexcel C72 = (`=literacy_nat_masc_pop'/`=pop_nat_masc_1664') E72 = (`=literacy_migr_masc_pop'/`=pop_migr_masc_1664') // Literacy: knows how to read and write
	
	putexcel C73 = (`=NoEmpNoedu_nat_masc_pop'/`=age1534_nat_masc_pop') E73 = (`=NoEmpNoedu_migr_masc_pop'/`=age1534_migr_masc_pop')   // Neither in employment, education or training for youth
	
	putexcel C74 = (`=earlyLeft_nat_masc_pop'/`=earlyAge_nat_masc_pop') E74 = (`=earlyLeft_migr_masc_pop'/`=earlyAge_migr_masc_pop')  // Early school leaving
	
	putexcel C75 = (`=attending_5to16_nat_masc_pop'/`=pop_nat_masc_516') E75 = (`=attending_5to16_migr_masc_pop'/`=pop_migr_masc_516')  // Share of children attending schooling, 5 - 16 years group
	
	** CHILDREN EDUCATION AND EMPLOYMENT	
	
	putexcel C79 = (`=attending_15to18_nat_masc_pop'/`=pop_nat_masc_1518') E79 = (`=attending_15to18_migr_masc_pop'/`=pop_migr_masc_1518')  // Share of children attending school (15-18 year-olds)
	
	putexcel C80 = (`=employment_15to18_nat_masc_pop'/`=pop_nat_masc_1518') E80 = (`=employment_15to18_migr_masc_pop'/`=pop_migr_masc_1518')  // Share of children in employment (15-18 year-olds)
	
	putexcel C81 = (`=AttOnly_15to18_nat_masc_pop'/`=pop_nat_masc_1518') E81 = (`=AttOnly_15to18_migr_masc_pop'/`=pop_migr_masc_1518')  // Share of children attending school only (15-18 year-olds)
	
	putexcel C82 = (`=EmpOnly_15to18_nat_masc_pop'/`=pop_nat_masc_1518') E82 = (`=EmpOnly_15to18_migr_masc_pop'/`=pop_migr_masc_1518')  // Share of children in employment only (15-18 year-olds)
	
	putexcel C83 = (`=Att_Emp_1518_nat_masc_pop'/`=pop_nat_masc_1518') E83 = (`=Att_Emp_1518_migr_masc_pop'/`=pop_migr_masc_1518')  // Share of children attending school & in employment (15-18 year-olds)
	
	putexcel C84 = (`=NiNi_15to18_nat_masc_pop'/`=pop_nat_masc_1518') E84 = (`=NiNi_15to18_migr_masc_pop'/`=pop_migr_masc_1518')  // Neither in employment, education or training for youth (15-18 year-olds)
	
	**HEALTH
	
	* Health problems
	
	putexcel C91 = (`=healthSys_nat_masc_pop'/`=job15to64_nat_masc_pop') E91 = (`=healthSys_migr_masc_pop'/`=job15to64_migr_masc_pop') // Access to health services AMONG working pop
	
	** SIMPLE CHARACTERISTICS
	
	putexcel C96 = (`=survey_nat_masc_pop') E96 = (`=survey_migr_masc_pop') // Total sample size: persons
	
	putexcel C97 = (`=survey_nat_masc_15to64') E97 = (`=survey_migr_masc_15to64') // Total sample size: persons 15-64
	
	putexcel C99 = (`=nat_masc_pop') E99 = (`=migr_masc_pop') // Total population (with sample loadings)
	
	putexcel C100 = (`=total_nat_masc_15to64') E100 = (`=total_migr_masc_15to64') // Total persons 15-64 (with sample loadings)
	
** POPULATION
	
	putexcel D6 = (`=nat_fem_pop'/`=tot_fem_pop') F6 = (`=migr_fem_pop'/`=tot_fem_pop')	// Share of population
	
	putexcel D7 = (`=workAge_nat_fem_pop'/`=workAge_fem_pop') F7 = (`=workAge_migr_fem_pop'/`=workAge_fem_pop') // Share of working age population (15-64)
	
	putexcel D8 = (`=econoAct_nat_fem_pop'/`=econoAct_fem_pop') F8 = (`=econoAct_migr_fem_pop'/`=econoAct_fem_pop') // Share of labour force population (15-64)
	
	putexcel D9 = (`=emp_nat_fem_pop'/`=emp_fem_pop') F9 = (`=emp_migr_fem_pop'/`=emp_fem_pop') // Share of Employment rate  (15-64)
	
	
	** DEMOGRAPHIC
	
	putexcel D17 = (`=pop_nat_fem_014'/`=nat_fem_pop') F17 = (`=pop_migr_fem_014'/`=migr_fem_pop') // 0 - 14
	
	putexcel D18 = (`=pop_nat_fem_1524'/`=nat_fem_pop') F18 = (`=pop_migr_fem_1524'/`=migr_fem_pop') // 15 - 24
	
	putexcel D19 = (`=pop_nat_fem_2539'/`=nat_fem_pop') F19 = (`=pop_migr_fem_2539'/`=migr_fem_pop') // 25 - 39
	
	putexcel D20 = (`=pop_nat_fem_4054'/`=nat_fem_pop') F20 = (`=pop_migr_fem_4054'/`=migr_fem_pop') // 40 - 54
	
	putexcel D21 = (`=pop_nat_fem_5564'/`=nat_fem_pop') F21 = (`=pop_migr_fem_5564'/`=migr_fem_pop') // 55 - 64
	
	putexcel D22 = (`=pop_nat_fem_65older'/`=nat_fem_pop') F22 = (`=pop_migr_fem_65older'/`=migr_fem_pop') // 65 Older
	
	putexcel D23 = (`=workAge_nat_fem_pop'/`=nat_fem_pop') F23 = (`=workAge_migr_fem_pop'/`=migr_fem_pop') // 15-64 
	
	*putexcel D25 = (`=male_nat_pop'/`=nat_pop') F25 = (`=male_migr_pop'/`=migr_pop') 	// Sex male
	
	putexcel D26 = (`=married_nat_fem_pop'/`=status_nat_fem_pop') F26 = (`=married_migr_fem_pop'/`=status_migr_fem_pop') // Marital status: married/cohabiting
	
	putexcel D27 = (`=separated_nat_fem_pop'/`=status_nat_fem_pop') F27 = (`=separated_migr_fem_pop'/`=status_migr_fem_pop') // Marital status: separated/divorced/widowed

	putexcel D28 = (`=single_nat_fem_pop'/`=status_nat_fem_pop') F28 = (`=single_migr_fem_pop'/`=status_migr_fem_pop') // Marital status: single
	
	putexcel D29 = (`=urban_nat_fem_pop'/`=nat_fem_pop') F29 = (`=urban_migr_fem_pop'/`=migr_fem_pop') // Urban
	
	putexcel D30 = (`=capital_nat_fem_pop'/`=nat_fem_pop')  F30 = (`=capital_migr_fem_pop'/`=migr_fem_pop') // Capital city located
	
	putexcel D31 = (`=borCity_nat_fem_pop'/`=nat_fem_pop')  F31 = (`=borCity_migr_fem_pop'/`=migr_fem_pop') // Border cities or region
	
	putexcel D34 = (`=size_nat_fem_house')  F34 = (`=size_migr_fem_house') // Household size
		
	putexcel D35 = (`=less18_nat_fem_house')  F35 = (`=less18_migr_fem_house') // Number of children <= 18 in household
		
	putexcel D36 = (`=less15_nat_fem_house')  F36 = (`=less15_migr_fem_house') // Number of children <= 15 in household
		
	// Number of natural-born children (women only)
	
	
	** LABOUR MARKET INDICATORS
	
	putexcel D41 = (`=job_nat_fem_pop'/`=workAge_nat_fem_pop') F41 = (`=job_migr_fem_pop'/`=workAge_migr_fem_pop') // Share of population with a job
	
	putexcel D42 = (`=econoAct_nat_fem_pop'/`=workAge_nat_fem_pop') F42 = (`=econoAct_migr_fem_pop'/`=workAge_migr_fem_pop') // Activity: Share participating in the labour force
	
	putexcel D43 = (`=inactive_nat_fem_pop'/`=workAge_nat_fem_pop') F43 = (`=inactive_migr_fem_pop'/`=workAge_migr_fem_pop')  // Economically inactive people
	
	putexcel D44 = (`=unemp_nat_fem_pop'/`=econoActWorkAge_nat_fem_pop') F44 = (`=unemp_migr_fem_pop'/`=econoActWorkAge_migr_fem_pop') // Unemployment: Share of population who were unemployed
	
	putexcel D45 = (`=long12_unemp_nat_fem_pop'/`=inac_unemp_nat_fem_pop') F45 = (`=long12_unemp_migr_fem_pop'/`=inac_unemp_migr_fem_pop') // Risk of labour market exclusion: long-term unemployment (12 month)
	
	putexcel D46 = (`=long6_unemp_nat_fem_pop'/`=inac_unemp_nat_fem_pop') F46 = (`=long6_unemp_migr_fem_pop'/`=inac_unemp_migr_fem_pop') // Risk of labour market exclusion: long-term unemployment (6 month)
	
	putexcel D47 = (`=involuntary_nat_fem_pop'/`=inac_unemp_nat_fem_pop') F47 = (`=involuntary_migr_fem_pop'/`=inac_unemp_migr_fem_pop') // Inactive involuntary (available past week, not looking for job)
	
	putexcel D48 = (`=long_invo_nat_fem_pop'/`=inac_unemp_nat_fem_pop') F48 = (`=long_invo_migr_fem_pop'/`=inac_unemp_migr_fem_pop') // Long-term uemployment >=12 months or inactive involuntary	
	
	putexcel D49 = (`=written_nat_fem_pop'/`=noself_edu_nat_fem_pop') F49 = (`=written_migr_fem_pop'/`=noself_edu_migr_fem_pop') // Share of population with written contract
	
	putexcel D50 = (`=informal_nat_fem_pop'/`=job_nat_fem_pop') F50 = (`=informal_migr_fem_pop'/`=job_migr_fem_pop') // Share of population with an informal job	
	
    // Share of population with an informal job (OECD def)
	
	putexcel D52 = (`=tempJob_nat_fem_pop'/`=noself_edu_nat_fem_pop') F52 = (`=tempJob_migr_fem_pop'/`=noself_edu_migr_fem_pop') // Types of contracts: Share of population in temporary contracts	
	
	putexcel D53 = (`=more40h_nat_fem_pop'/`=hours_nat_fem_pop') F53 = (`=more40h_migr_fem_pop'/`=hours_migr_fem_pop')  // Working hours: long (more than 40) hours	

	putexcel D54 = (`=more50h_nat_fem_pop'/`=hours_nat_fem_pop') F54 = (`=more50h_migr_fem_pop'/`=hours_migr_fem_pop')  // Working hours: long (more than 50) hours
	
	putexcel D55 = (`=more55h_nat_fem_pop'/`=hours_nat_fem_pop') F55 = (`=more55h_migr_fem_pop'/`=hours_migr_fem_pop')  // Working hours: long (more than 55) hours
	
	putexcel D56 = (`=less30h_nat_fem_pop'/`=hours_nat_fem_pop') F56 = (`=less30h_migr_fem_pop'/`=hours_migr_fem_pop')  // Working hours: long (less than 30) hours	
	
	putexcel D57 = (`=highSkill_nat_fem_pop'/`=NotMili_nat_fem_pop') F57 = (`=highSkill_migr_fem_pop'/`=NotMili_migr_fem_pop') // Job skills: share of working population in highly skilled jobs
	
	putexcel D58 = (`=lowSkill_nat_fem_pop'/`=NotMili_nat_fem_pop') F58 = (`=lowSkill_migr_fem_pop'/`=NotMili_migr_fem_pop') // Job skills: share of working population in low-skilled jobs 
		
	putexcel D59 = (`=overquali_nat_fem_pop'/`=NotEduNotMili_nat_fem_pop') F59 = (`=overquali_migr_fem_pop'/`=NotEduNotMili_migr_fem_pop') // Overqualification: share of highly educated individuals who work in low- or medium-skilled jobs

	putexcel D60 = (`=selfEmp_nat_fem_pop'/`=Notagri_emp1564_nat_fem_pop') F60 = (`=selfEmp_migr_fem_pop'/`=Notagri_emp1564_migr_fem_pop')   // Self-employment: share of population who work in their own firms or businesses
	
	putexcel D61 = (`=pubSec_nat_fem_pop'/`=NoSelf15to64_nat_fem_pop') F61 = (`=pubSec_migr_fem_pop'/`=NoSelf15to64_migr_fem_pop')   // Employment in the public sector
	
	putexcel D62 = (`=nmwage_nat_fem_')  F62 = (`=nmwage_migr_fem_') // Nominal monthly wage (USD)
	
	* Child labour
	
	
	** EDUCATION AND SKILLS
		
	putexcel D69 = (`=ISCED58_nat_fem_pop'/`=ISCEDEdu_nat_fem_pop') F69 = (`=ISCED58_migr_fem_pop'/`=ISCEDEdu_migr_fem_pop') // Level of educational attainment: high (ISCED groups 5-8)
		
	putexcel D70 = (`=ISCED02_nat_fem_pop'/`=ISCEDEdu_nat_fem_pop') F70 = (`=ISCED02_migr_fem_pop'/`=ISCEDEdu_migr_fem_pop') // Level of educational attainment: low (ISCED groups 0-2)
		
	putexcel D71 = (`=ISCED01_nat_fem_pop'/`=ISCEDEdu_nat_fem_pop') F71 = (`=ISCED01_migr_fem_pop'/`=ISCEDEdu_migr_fem_pop') // Level of educational attainment: very low (ISCED groups 0-1)
		
	putexcel D72 = (`=literacy_nat_fem_pop'/`=pop_nat_fem_1664') F72 = (`=literacy_migr_fem_pop'/`=pop_migr_fem_1664') // Literacy: knows how to read and write
	
	putexcel D73 = (`=NoEmpNoedu_nat_fem_pop'/`=age1534_nat_fem_pop') F73 = (`=NoEmpNoedu_migr_fem_pop'/`=age1534_migr_fem_pop')   // Neither in employment, education or training for youth
	
	putexcel D74 = (`=earlyLeft_nat_fem_pop'/`=earlyAge_nat_fem_pop') F74 = (`=earlyLeft_migr_fem_pop'/`=earlyAge_migr_fem_pop')  // Early school leaving
	
	putexcel D75 = (`=attending_5to16_nat_fem_pop'/`=pop_nat_fem_516') F75 = (`=attending_5to16_migr_fem_pop'/`=pop_migr_fem_516')  // Share of children attending schooling, 5 - 16 years group
	
	** CHILDREN EDUCATION AND EMPLOYMENT	
	
	putexcel D79 = (`=attending_15to18_nat_fem_pop'/`=pop_nat_fem_1518') F79 = (`=attending_15to18_migr_fem_pop'/`=pop_migr_fem_1518')  // Share of children attending school (15-18 year-olds)
	
	putexcel D80 = (`=employment_15to18_nat_fem_pop'/`=pop_nat_fem_1518') F80 = (`=employment_15to18_migr_fem_pop'/`=pop_migr_fem_1518')  // Share of children in employment (15-18 year-olds)
	
	putexcel D81 = (`=AttOnly_15to18_nat_fem_pop'/`=pop_nat_fem_1518') F81 = (`=AttOnly_15to18_migr_fem_pop'/`=pop_migr_fem_1518')  // Share of children attending school only (15-18 year-olds)
	
	putexcel D82 = (`=EmpOnly_15to18_nat_fem_pop'/`=pop_nat_fem_1518') F82 = (`=EmpOnly_15to18_migr_fem_pop'/`=pop_migr_fem_1518')  // Share of children in employment only (15-18 year-olds)
	
	putexcel D83 = (`=Att_Emp_1518_nat_fem_pop'/`=pop_nat_fem_1518') F83 = (`=Att_Emp_1518_migr_fem_pop'/`=pop_migr_fem_1518')  // Share of children attending school & in employment (15-18 year-olds)
	
	putexcel D84 = (`=NiNi_15to18_nat_fem_pop'/`=pop_nat_fem_1518') F84 = (`=NiNi_15to18_migr_fem_pop'/`=pop_migr_fem_1518')  // Neither in employment, education or training for youth (15-18 year-olds)
	
	**HEALTH
	
	* Health problems
	
	putexcel D91 = (`=healthSys_nat_fem_pop'/`=job15to64_nat_fem_pop') F91 = (`=healthSys_migr_fem_pop'/`=job15to64_migr_fem_pop') // Access to health services AMONG working pop
	
	** SIMPLE CHARACTERISTICS
	
	putexcel D96 = (`=survey_nat_fem_pop') F96 = (`=survey_migr_fem_pop') // Total sample size: persons
	
	putexcel D97 = (`=survey_nat_fem_15to64') F97 = (`=survey_migr_fem_15to64') // Total sample size: persons 15-64
	
	putexcel D99 = (`=nat_fem_pop') F99 = (`=migr_fem_pop') // Total population (with sample loadings)
	
	putexcel D100 = (`=total_nat_fem_15to64') F100 = (`=total_migr_fem_15to64') // Total persons 15-64 (with sample loadings)
