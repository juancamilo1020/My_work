********************************************************************************
********************************************************************************
********************************************************************************
****** ECUADOR - HOUSEHOLD SURVEY ENEMDU 2019
	
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
	sum uno if migrante_ci!=. & inrange(edad_ci,15,34) [fw=factor_ci]
	scalar tot_pop = `=r(N)'
	
	* Migrant population calculated according to expansion factor
	sum uno if migrante_ci==1 [fw=factor_ci]
	scalar migr_pop = `=r(N)'
	
	* Native population calculated according to expansion factor
	sum uno if migrante_ci==0 [fw=factor_ci]
	scalar nat_pop = `=r(N)'
	
	* Share of working age population (15-34)
	sum uno if inrange(edad_ci,15,34) & migrante_ci==1 [fw=factor_ci]
	scalar workAge1534_migr_pop = `=r(N)'
	sum uno if inrange(edad_ci,15,34) & migrante_ci==0 [fw=factor_ci]
	scalar workAge1534_nat_pop = `=r(N)'
	sum uno if inrange(edad_ci,15,34) [fw=factor_ci]
	scalar workAge1534_pop = `=r(N)'
		
	* Share of labour force population (15-34)
	sum uno if inrange(edad_ci,15,34) & pea_ci == 1 & migrante_ci==1 [fw=factor_ci]
	scalar econoAct1534_migr_pop = `=r(N)'
	sum uno if inrange(edad_ci,15,34) & pea_ci == 1 & migrante_ci==0 [fw=factor_ci]
	scalar econoAct1534_nat_pop = `=r(N)'
	sum uno if inrange(edad_ci,15,34) & pea_ci == 1 [fw=factor_ci]
	scalar econoAct1534_pop = `=r(N)'
	
	* Share of Employment rate  (15-34)
	sum uno if inrange(edad_ci,15,34) & emp_ci == 1 & migrante_ci==1 [fw=factor_ci]
	scalar emp1534_migr_pop = `=r(N)'
	sum uno if inrange(edad_ci,15,34) & emp_ci == 1 & migrante_ci==0 [fw=factor_ci]
	scalar emp1534_nat_pop = `=r(N)'
	sum uno if inrange(edad_ci,15,34) & emp_ci == 1 [fw=factor_ci]
	scalar emp1534_pop = `=r(N)'
	
	* Share of working age population (35-64)
	sum uno if inrange(edad_ci,35,64) & migrante_ci==1 [fw=factor_ci]
	scalar workAge3564_migr_pop = `=r(N)'
	sum uno if inrange(edad_ci,35,64) & migrante_ci==0 [fw=factor_ci]
	scalar workAge3564_nat_pop = `=r(N)'
	sum uno if inrange(edad_ci,35,64) [fw=factor_ci]
	scalar workAge3564_pop = `=r(N)'
		
	* Share of labour force population (35-64)
	sum uno if inrange(edad_ci,35,64) & pea_ci == 1 & migrante_ci==1 [fw=factor_ci]
	scalar econoAct3564_migr_pop = `=r(N)'
	sum uno if inrange(edad_ci,35,64) & pea_ci == 1 & migrante_ci==0 [fw=factor_ci]
	scalar econoAct3564_nat_pop = `=r(N)'
	sum uno if inrange(edad_ci,35,64) & pea_ci == 1 [fw=factor_ci]
	scalar econoAct3564_pop = `=r(N)'
	
	* Share of Employment rate  (35-64)
	sum uno if inrange(edad_ci,35,64) & emp_ci == 1 & migrante_ci==1 [fw=factor_ci]
	scalar emp_migr3564_pop = `=r(N)'
	sum uno if inrange(edad_ci,35,64) & emp_ci == 1 & migrante_ci==0 [fw=factor_ci]
	scalar emp_nat3564_pop = `=r(N)'
	sum uno if inrange(edad_ci,35,64) & emp_ci == 1 [fw=factor_ci]
	scalar emp3564_pop = `=r(N)'
	

	** CALCULATION OF INDICATORS BY MIGRANTS AND NATIVES
	
	foreach var in 1 0 {
		
		** LABOUR MARKET INDICATORS (BY AGE)
		
		************************************************************************
		** People of ages from 15 to 34
		
		* Share of population with a job (15-34)
		sum uno if inrange(edad_ci,15,34) & emp_ci==1 & migrante_ci==`var' [fw=factor_ci]
		scalar job1534_``var'_label'_pop = `=r(N)'
		
		* Activity: Share participating in the labour force (15-34)
		sum uno if inrange(edad_ci,15,34) & pea_ci==1 & migrante_ci==`var' [fw=factor_ci]
		scalar econoAct1534_``var'_label'_pop = `=r(N)'
		
		* Economically inactive people (15-34)
		sum uno if inrange(edad_ci,15,34) & (condocup_ci == 3) & migrante_ci==`var' [fw=factor_ci] 
		scalar inactive1534_``var'_label'_pop = `=r(N)'
		
		* Unemployment: Share of population who were unemployed (15-34)
		sum uno if inrange(edad_ci,15,34) & desemp_ci==1 & migrante_ci==`var' [fw=factor_ci] 
		scalar unemp1534_``var'_label'_pop = `=r(N)'
		
		sum uno if (pea_ci==1 | asiste_ci==1) & inrange(edad_ci,15,34) & migrante_ci==`var' [fw=factor_ci]
		scalar econoActWorkAge1534_``var'_label'_pop = `=r(N)'
		
		* Risk of labour market exclusion: long-term unemployment (12 months) (15-34)
		sum uno if inrange(edad_ci,15,34) & (more_12==1 & desemp_ci==1) & migrante_ci==`var' [fw=factor_ci]
		scalar long12_unemp1534_``var'_label'_pop = `=r(N)'
		
		sum uno if inrange(edad_ci,15,34) & (desemp_ci==1 | condocup_ci==3) & durades_ci!=. & migrante_ci==`var' [fw=factor_ci] 
		scalar inac_unemp1534_``var'_label'_pop = `=r(N)'
		
		* Risk of labour market exclusion: long-term unemployment (6 months) (15-34)
		sum uno if inrange(edad_ci,15,34) & (more_6==1 & desemp_ci==1) & migrante_ci==`var' [fw=factor_ci]
		scalar long6_unemp1534_``var'_label'_pop = `=r(N)'
		
		* Risk of labour market exclusion: long-term uemployment >=12 months or inactive involuntary (15-34)
		sum uno if inrange(edad_ci,15,34) & (desalent_ci==1 | (more_12==1 & desemp_ci==1)) & migrante_ci==`var' [fw=factor_ci]
		scalar long_invo1534_``var'_label'_pop = `=r(N)'
		
		* Risk of labour market exclusion: Inactive involuntary (available past week, not looking for job) (15-34)
		sum uno if inrange(edad_ci,15,34) & desalent_ci==1 & migrante_ci==`var' [fw=factor_ci]
		scalar involuntary1534_``var'_label'_pop = `=r(N)'
		
		* Share of population with written contract (15-34)
		sum uno if inrange(edad_ci,15,34) & inlist(tipocontrato_ci,0,1) & migrante_ci==`var' [fw=factor_ci]
		scalar written1534_``var'_label'_pop = `=r(N)'		
		
		* Share of population with an informal job (15-34)
		sum uno if inrange(edad_ci,15,34) & informal==1 & migrante_ci==`var' [fw=factor_ci]
		scalar informal1534_``var'_label'_pop = `=r(N)'
		
		* Types of contracts:  Share of population in temporary contracts (15-34)
		sum uno if inrange(edad_ci,15,34) & tipocontrato_ci==2 & migrante_ci==`var' [fw=factor_ci] 
		scalar tempJob1534_``var'_label'_pop = `=r(N)'
		
		sum uno if inrange(edad_ci,15,34) & categopri_ci!=2 & asiste_ci!=1 & emp_ci==1 & migrante_ci==`var' [fw=factor_ci]
		scalar noself_edu1534_``var'_label'_pop = `=r(N)'
		
		* Working hours: long hours >= 50 (15-34)
		sum uno if inrange(edad_ci,15,34) & more_50==1 & emp_ci == 1 & migrante_ci==`var' [fw=factor_ci]
		scalar more50h1534_``var'_label'_pop = `=r(N)'
		
		sum uno if inrange(edad_ci,15,34) & by_hours==1 & emp_ci == 1 & migrante_ci==`var' [fw=factor_ci]
		scalar hours1534_``var'_label'_pop = `=r(N)'	
	
		* Working hours: long hours < 30 (15-34)
		sum uno if inrange(edad_ci,15,34) & less_30==1 & emp_ci == 1 & migrante_ci==`var' [fw=factor_ci]
		scalar less30h1534_``var'_label'_pop = `=r(N)'

		* Job skills: share of working population in highly skilled jobs (15-34)
		sum uno if high_skilled==1 & inrange(edad_ci,15,34) & migrante_ci==`var' [fw=factor_ci]
		scalar highSkill1534_``var'_label'_pop = `=r(N)'		
		
		* Job skills: share of working population in low-skilled jobs (15-34)
		sum uno if low_skilled==1 & inrange(edad_ci,15,34) & migrante_ci==`var' [fw=factor_ci]
		scalar lowSkill1534_``var'_label'_pop = `=r(N)'
		
		sum uno if emp_ci==1 & inrange(edad_ci,15,34) & ISCO!=0 & migrante_ci==`var' [fw=factor_ci]
		scalar NotMili1534_``var'_label'_pop = `=r(N)'
		
		* Overqualification: share of highly educated individuals who work in low- or medium-skilled jobs (15-34)
		sum uno if overqualificated==1 & inrange(edad_ci,15,34) & migrante_ci==`var' & inrange(ISCED,4,9) [fw=factor_ci]
		scalar overquali1534_``var'_label'_pop = `=r(N)'
		
		sum uno if emp_ci==1 & inrange(edad_ci,15,34) & asiste_ci!=1 & ISCO!=0 & migrante_ci==`var' [fw=factor_ci]
		scalar NotEduNotMili1534_``var'_label'_pop = `=r(N)'
		
		* Self-employment: share of population who works in their own firms or businesses (15-34)
		sum uno if (categopri_ci==1 | categopri_ci==2) & inrange(edad_ci,15,34) & migrante_ci==`var' [fw=factor_ci]
		scalar selfEmp1534_``var'_label'_pop = `=r(N)'
		
		sum uno if inrange(edad_ci,15,34) & rama_ci!=1 & emp_ci==1 & migrante_ci==`var' [fw=factor_ci]
		scalar Notagri_emp1534_``var'_label'_pop = `=r(N)'
		
		* Employment in the public sector (15-34)
		sum uno if spublico_ci==1 & inrange(edad_ci,15,34) & migrante_ci==`var' [fw=factor_ci]
		scalar pubSec1534_``var'_label'_pop = `=r(N)'
		
		sum uno if inrange(edad_ci,15,34) & emp_ci==1 & categopri_ci!=2 & migrante_ci==`var' [fw=factor_ci]
		scalar NoSelf1534_``var'_label'_pop = `=r(N)'
		
		* Nominal monthly wage (USD) (15-34)
		sum nmwage if migrante_ci==`var' & inrange(edad_ci,15,34) [fw=factor_ci]
		scalar nmwage1534_``var'_label' = `=r(mean)'
		
		** SAMPLE CHARACTERISTICS
		
		* Total sample size: persons 
		sum uno if migrante_ci==`var'
		scalar survey_``var'_label'_pop = `=r(N)'
		
		* Total sample size: persons 15-34
		sum uno if inrange(edad_ci,15,34) & migrante_ci==`var'
		scalar survey_``var'_label'_1534 = `=r(N)'

		* Total persons 15-34 (with sample loadings)
		sum uno if inrange(edad_ci,15,34) & migrante_ci==`var' [fw=factor_ci]
		scalar total_``var'_label'_1534 = `=r(N)'
		
		************************************************************************
		** People of ages from 35 to 64
		
		* Share of population with a job (35-64)
		sum uno if inrange(edad_ci,35,64) & emp_ci==1 & migrante_ci==`var' [fw=factor_ci]
		scalar job3564_``var'_label'_pop = `=r(N)'
		
		* Activity: Share participating in the labour force (35-64)
		sum uno if inrange(edad_ci,35,64) & pea_ci==1 & migrante_ci==`var' [fw=factor_ci]
		scalar econoAct3564_``var'_label'_pop = `=r(N)'
		
		* Economically inactive people (35-64)
		sum uno if inrange(edad_ci,35,64) & (condocup_ci == 3) & migrante_ci==`var' [fw=factor_ci] 
		scalar inactive3564_``var'_label'_pop = `=r(N)'
		
		* Unemployment: Share of population who were unemployed (35-64)
		sum uno if inrange(edad_ci,35,64) & desemp_ci==1 & migrante_ci==`var' [fw=factor_ci] 
		scalar unemp3564_``var'_label'_pop = `=r(N)'
		
		sum uno if (pea_ci==1 | asiste_ci==1) & inrange(edad_ci,35,64) & migrante_ci==`var' [fw=factor_ci]
		scalar econoActWorkAge3564_``var'_label'_pop = `=r(N)'
		
		* Risk of labour market exclusion: long-term unemployment (12 months) (35-64)
		sum uno if inrange(edad_ci,35,64) & (more_12==1 & desemp_ci==1) & migrante_ci==`var' [fw=factor_ci]
		scalar long12_unemp3564_``var'_label'_pop = `=r(N)'
		
		sum uno if inrange(edad_ci,35,64) & (desemp_ci==1 | condocup_ci==3) & durades_ci!=. & migrante_ci==`var' [fw=factor_ci] 
		scalar inac_unemp3564_``var'_label'_pop = `=r(N)'
		
		* Risk of labour market exclusion: long-term unemployment (6 months) (35-64)
		sum uno if inrange(edad_ci,35,64) & (more_6==1 & desemp_ci==1) & migrante_ci==`var' [fw=factor_ci]
		scalar long6_unemp3564_``var'_label'_pop = `=r(N)'
		
		* Risk of labour market exclusion: long-term uemployment >=12 months or inactive involuntary (35-64)
		sum uno if inrange(edad_ci,35,64) & (desalent_ci==1 | (more_12==1 & desemp_ci==1)) & migrante_ci==`var' [fw=factor_ci]
		scalar long_invo3564_``var'_label'_pop = `=r(N)'
		
		* Risk of labour market exclusion: Inactive involuntary (available past week, not looking for job) (35-64)
		sum uno if inrange(edad_ci,35,64) & desalent_ci==1 & migrante_ci==`var' [fw=factor_ci]
		scalar involuntary3564_``var'_label'_pop = `=r(N)'
		
		* Share of population with written contract (35-64)
		sum uno if inrange(edad_ci,35,64) & inlist(tipocontrato_ci,0,1,2) & migrante_ci==`var' [fw=factor_ci]
		scalar written3564_``var'_label'_pop = `=r(N)'		
		
		* Share of population with an informal job (35-64)
		sum uno if inrange(edad_ci,35,64) & informal==1 & migrante_ci==`var' [fw=factor_ci]
		scalar informal3564_``var'_label'_pop = `=r(N)'
		
		* Types of contracts:  Share of population in temporary contracts (35-64)
		sum uno if inrange(edad_ci,35,64) & tipocontrato_ci==2 & migrante_ci==`var' [fw=factor_ci] 
		scalar tempJob3564_``var'_label'_pop = `=r(N)'
		
		sum uno if inrange(edad_ci,35,64) & categopri_ci!=2 & asiste_ci!=1 & emp_ci==1 & migrante_ci==`var' [fw=factor_ci]
		scalar noself_edu3564_``var'_label'_pop = `=r(N)'
		
		* Working hours: long hours >= 50 (35-64)
		sum uno if inrange(edad_ci,35,64) & more_50==1 & emp_ci == 1 & migrante_ci==`var' [fw=factor_ci]
		scalar more50h3564_``var'_label'_pop = `=r(N)'
		
		sum uno if inrange(edad_ci,35,64) & by_hours==1 & emp_ci == 1 & migrante_ci==`var' [fw=factor_ci]
		scalar hours3564_``var'_label'_pop = `=r(N)'	
	
		* Working hours: long hours < 30 (35-64)
		sum uno if inrange(edad_ci,35,64) & less_30==1 & emp_ci == 1 & migrante_ci==`var' [fw=factor_ci]
		scalar less30h3564_``var'_label'_pop = `=r(N)'

		* Job skills: share of working population in highly skilled jobs (35-64)
		sum uno if high_skilled==1 & inrange(edad_ci,35,64) & migrante_ci==`var' [fw=factor_ci]
		scalar highSkill3564_``var'_label'_pop = `=r(N)'		
		
		* Job skills: share of working population in low-skilled jobs (35-64)
		sum uno if low_skilled==1 & inrange(edad_ci,35,64) & migrante_ci==`var' [fw=factor_ci]
		scalar lowSkill3564_``var'_label'_pop = `=r(N)'
		
		sum uno if emp_ci==1 & inrange(edad_ci,35,64) & ISCO!=0 & migrante_ci==`var' [fw=factor_ci]
		scalar NotMili3564_``var'_label'_pop = `=r(N)'
		
		* Overqualification: share of highly educated individuals who work in low- or medium-skilled jobs (35-64)
		sum uno if overqualificated==1 & inrange(edad_ci,35,64) & migrante_ci==`var' & inrange(ISCED,4,9) [fw=factor_ci]
		scalar overquali3564_``var'_label'_pop = `=r(N)'
		
		sum uno if emp_ci==1 & inrange(edad_ci,35,64) & asiste_ci!=1 & ISCO!=0 & migrante_ci==`var' [fw=factor_ci]
		scalar NotEduNotMili3564_``var'_label'_pop = `=r(N)'
		
		* Self-employment: share of population who works in their own firms or businesses (35-64)
		sum uno if (categopri_ci==1 | categopri_ci==2) & inrange(edad_ci,35,64) & migrante_ci==`var' [fw=factor_ci]
		scalar selfEmp3564_``var'_label'_pop = `=r(N)'
		
		sum uno if inrange(edad_ci,35,64) & rama_ci!=1 & emp_ci==1 & migrante_ci==`var' [fw=factor_ci]
		scalar Notagri_emp3564_``var'_label'_pop = `=r(N)'
		
		* Employment in the public sector (35-64)
		sum uno if spublico_ci==1 & inrange(edad_ci,35,64) & migrante_ci==`var' [fw=factor_ci]
		scalar pubSec3564_``var'_label'_pop = `=r(N)'
		
		sum uno if inrange(edad_ci,35,64) & emp_ci==1 & categopri_ci!=2 & migrante_ci==`var' [fw=factor_ci]
		scalar NoSelf3564_``var'_label'_pop = `=r(N)'
		
		* Nominal monthly wage (USD) (35-64)
		sum nmwage if migrante_ci==`var' & inrange(edad_ci,35,64) [fw=factor_ci]
		scalar nmwage3564_``var'_label' = `=r(mean)'
		
		** SAMPLE CHARACTERISTICS
		
		* Total sample size: persons 35-64
		sum uno if inrange(edad_ci,35,64) & migrante_ci==`var'
		scalar survey_``var'_label'_3564 = `=r(N)'

		* Total persons 35-64 (with sample loadings)
		sum uno if inrange(edad_ci,35,64) & migrante_ci==`var' [fw=factor_ci]
		scalar total_``var'_label'_3564 = `=r(N)'
		
	}
	
******************************************************** EXCEL OUTPUTS

	putexcel set "/Users/juancamiloperdomo/Library/CloudStorage/OneDrive-Inter-AmericanDevelopmentBankGroup/Calculos Indicadores/Indicadores generales/Resultados/Resultados por edad.xlsx", sheet("Ecuador") modify
	putexcel describe
	
	
	** LABOUR MARKET INDICATORS FOR PEOPLE OF AGES FROM 15 TO 34
	
	putexcel C8 = (`=job1534_nat_pop'/`=workAge1534_nat_pop') E8 = (`=job1534_migr_pop'/`=workAge1534_migr_pop') // Share of population with a job
	
	putexcel C9 = (`=econoAct1534_nat_pop'/`=workAge1534_nat_pop') E9 = (`=econoAct1534_migr_pop'/`=workAge1534_migr_pop') // Activity: Share participating in the labour force
	
	putexcel C10 = (`=inactive1534_nat_pop'/`=workAge1534_nat_pop') E10 = (`=inactive1534_migr_pop'/`=workAge1534_migr_pop')  // Economically inactive people
	
	putexcel C11 = (`=unemp1534_nat_pop'/`=econoActWorkAge1534_nat_pop') E11 = (`=unemp1534_migr_pop'/`=econoActWorkAge1534_migr_pop') // Unemployment: Share of population who were unemployed
	
	putexcel C12 = (`=long12_unemp1534_nat_pop'/`=inac_unemp1534_nat_pop') E12 = (`=long12_unemp1534_migr_pop'/`=inac_unemp1534_migr_pop') // Risk of labour market exclusion: long-term unemployment (12 month)
	
	putexcel C13 = (`=long6_unemp1534_nat_pop'/`=inac_unemp1534_nat_pop') E13 = (`=long6_unemp1534_migr_pop'/`=inac_unemp1534_migr_pop') // Risk of labour market exclusion: long-term unemployment (6 month)
	
	putexcel C14 = (`=long_invo1534_nat_pop'/`=inac_unemp1534_nat_pop') E14 = (`=long_invo1534_migr_pop'/`=inac_unemp1534_migr_pop') // Long-term uemployment >=12 months or inactive involuntary	
	
	putexcel C15 = (`=involuntary1534_nat_pop'/`=inac_unemp1534_nat_pop') E15 = (`=involuntary1534_migr_pop'/`=inac_unemp1534_migr_pop') // Inactive involuntary (available past week, not looking for job)
	
	putexcel C16 = (`=written1534_nat_pop'/`=noself_edu1534_nat_pop') E16 = (`=written1534_migr_pop'/`=noself_edu1534_migr_pop') // Share of population with written contract
	
	putexcel C17 = (`=informal1534_nat_pop'/`=job1534_nat_pop') E17 = (`=informal1534_migr_pop'/`=job1534_migr_pop') // Share of population with an informal job	
	
    // Share of population with an informal job (OECD def)
	
	putexcel C19 = (`=tempJob1534_nat_pop'/`=noself_edu1534_nat_pop') E19 = (`=tempJob1534_migr_pop'/`=noself_edu1534_migr_pop') // Types of contracts: Share of population in temporary contracts	

	putexcel C20 = (`=more50h1534_nat_pop'/`=hours1534_nat_pop') E20 = (`=more50h1534_migr_pop'/`=hours1534_migr_pop')  // Working hours: long (more than 50) hours
	
	putexcel C21 = (`=less30h1534_nat_pop'/`=hours1534_nat_pop') E21 = (`=less30h1534_migr_pop'/`=hours1534_migr_pop')  // Working hours: long (less than 30) hours	
	
	putexcel C22 = (`=highSkill1534_nat_pop'/`=NotMili1534_nat_pop') E22 = (`=highSkill1534_migr_pop'/`=NotMili1534_migr_pop') // Job skills: share of working population in highly skilled jobs
	
	putexcel C23 = (`=lowSkill1534_nat_pop'/`=NotMili1534_nat_pop') E23 = (`=lowSkill1534_migr_pop'/`=NotMili1534_migr_pop') // Job skills: share of working population in low-skilled jobs 
		
	putexcel C24 = (`=overquali1534_nat_pop'/`=NotEduNotMili1534_nat_pop') E24 = (`=overquali1534_migr_pop'/`=NotEduNotMili1534_migr_pop') // Overqualification: share of highly educated individuals who work in low- or medium-skilled jobs

	putexcel C25 = (`=selfEmp1534_nat_pop'/`=Notagri_emp1534_nat_pop') E25 = (`=selfEmp1534_migr_pop'/`=Notagri_emp1534_migr_pop')   // Self-employment: share of population who work in their own firms or businesses
	
	putexcel C26 = (`=pubSec1534_nat_pop'/`=NoSelf1534_nat_pop') E26 = (`=pubSec1534_migr_pop'/`=NoSelf1534_migr_pop')   // Employment in the public sector
	
	putexcel C27 = (`=nmwage1534_nat')  E27 = (`=nmwage1534_migr') // Nominal monthly wage (USD)
	
	
	** SIMPLE CHARACTERISTICS (15 - 34)
	
	putexcel C33 = (`=survey_nat_pop') E33 = (`=survey_migr_pop') // Total sample size: persons
	
	putexcel C34 = (`=survey_nat_1534') E34 = (`=survey_migr_1534') // Total sample size: persons 15-64
	
	putexcel C36 = (`=nat_pop') E36 = (`=migr_pop') // Total population (with sample loadings)
	
	putexcel C37 = (`=total_nat_1534') E37 = (`=total_migr_1534') // Total persons 15-64 (with sample loadings)
	
	
	** LABOUR MARKET INDICATORS FOR PEOPLE OF AGES FROM 35 TO 64
	
	putexcel D8 = (`=job3564_nat_pop'/`=workAge3564_nat_pop') F8 = (`=job3564_migr_pop'/`=workAge3564_migr_pop') // Share of population with a job
	
	putexcel D9 = (`=econoAct3564_nat_pop'/`=workAge3564_nat_pop') F9 = (`=econoAct3564_migr_pop'/`=workAge3564_migr_pop') // Activity: Share participating in the labour force
	
	putexcel D10 = (`=inactive3564_nat_pop'/`=workAge3564_nat_pop') F10 = (`=inactive3564_migr_pop'/`=workAge3564_migr_pop')  // Economically inactive people
	
	putexcel D11 = (`=unemp3564_nat_pop'/`=econoActWorkAge3564_nat_pop') F11 = (`=unemp3564_migr_pop'/`=econoActWorkAge3564_migr_pop') // Unemployment: Share of population who were unemployed
	
	putexcel D12 = (`=long12_unemp3564_nat_pop'/`=inac_unemp3564_nat_pop') F12 = (`=long12_unemp3564_migr_pop'/`=inac_unemp3564_migr_pop') // Risk of labour market exclusion: long-term unemployment (12 month)
	
	putexcel D13 = (`=long6_unemp3564_nat_pop'/`=inac_unemp3564_nat_pop') F13 = (`=long6_unemp3564_migr_pop'/`=inac_unemp3564_migr_pop') // Risk of labour market exclusion: long-term unemployment (6 month)
	
	putexcel D14 = (`=long_invo3564_nat_pop'/`=inac_unemp3564_nat_pop') F14 = (`=long_invo3564_migr_pop'/`=inac_unemp3564_migr_pop') // Long-term uemployment >=12 months or inactive involuntary	
	
	putexcel D15 = (`=involuntary3564_nat_pop'/`=inac_unemp3564_nat_pop') F15 = (`=involuntary3564_migr_pop'/`=inac_unemp3564_migr_pop') // Inactive involuntary (available past week, not looking for job)
	
	putexcel D16 = (`=written3564_nat_pop'/`=noself_edu3564_nat_pop') F16 = (`=written3564_migr_pop'/`=noself_edu3564_migr_pop') // Share of population with written contract
	
	putexcel D17 = (`=informal3564_nat_pop'/`=job3564_nat_pop') F17 = (`=informal3564_migr_pop'/`=job3564_migr_pop') // Share of population with an informal job	
	
    // Share of population with an informal job (OECD def)
	
	putexcel D19 = (`=tempJob3564_nat_pop'/`=noself_edu3564_nat_pop') F19 = (`=tempJob3564_migr_pop'/`=noself_edu3564_migr_pop') // Types of contracts: Share of population in temporary contracts	

	putexcel D20 = (`=more50h3564_nat_pop'/`=hours3564_nat_pop') F20 = (`=more50h3564_migr_pop'/`=hours3564_migr_pop')  // Working hours: long (more than 50) hours
	
	putexcel D21 = (`=less30h3564_nat_pop'/`=hours3564_nat_pop') F21 = (`=less30h3564_migr_pop'/`=hours3564_migr_pop')  // Working hours: long (less than 30) hours	
	
	putexcel D22 = (`=highSkill3564_nat_pop'/`=NotMili3564_nat_pop') F22 = (`=highSkill3564_migr_pop'/`=NotMili3564_migr_pop') // Job skills: share of working population in highly skilled jobs
	
	putexcel D23 = (`=lowSkill3564_nat_pop'/`=NotMili3564_nat_pop') F23 = (`=lowSkill3564_migr_pop'/`=NotMili3564_migr_pop') // Job skills: share of working population in low-skilled jobs 
		
	putexcel D24 = (`=overquali3564_nat_pop'/`=NotEduNotMili3564_nat_pop') F24 = (`=overquali3564_migr_pop'/`=NotEduNotMili3564_migr_pop') // Overqualification: share of highly educated individuals who work in low- or medium-skilled jobs

	putexcel D25 = (`=selfEmp3564_nat_pop'/`=Notagri_emp3564_nat_pop') F25 = (`=selfEmp3564_migr_pop'/`=Notagri_emp3564_migr_pop')   // Self-employment: share of population who work in their own firms or businesses
	
	putexcel D26 = (`=pubSec3564_nat_pop'/`=NoSelf3564_nat_pop') F26 = (`=pubSec3564_migr_pop'/`=NoSelf3564_migr_pop')   // Employment in the public sector
	
	putexcel D27 = (`=nmwage3564_nat')  F27 = (`=nmwage3564_migr') // Nominal monthly wage (USD)
	
	** SIMPLE CHARACTERISTICS (35 - 64)
	
	putexcel D34 = (`=survey_nat_3564') F34 = (`=survey_migr_3564') // Total sample size: persons 15-64
	
	putexcel D37 = (`=total_nat_3564') F37 = (`=total_migr_3564') // Total persons 15-64 (with sample loadings)
	
	
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
	sum uno if migrante_ci!=. & inrange(edad_ci,15,34) [fw=factor_ci]
	scalar tot_pop = `=r(N)'
	
	* Migrant population calculated according to expansion factor
	sum uno if migrante_ci==1 [fw=factor_ci]
	scalar migr_pop = `=r(N)'
	
	* Native population calculated according to expansion factor
	sum uno if migrante_ci==0 [fw=factor_ci]
	scalar nat_pop = `=r(N)'
	
	* Share of working age population (15-34)
	sum uno if inrange(edad_ci,15,34) & migrante_ci==1 [fw=factor_ci]
	scalar workAge1534_migr_pop = `=r(N)'
	sum uno if inrange(edad_ci,15,34) & migrante_ci==0 [fw=factor_ci]
	scalar workAge1534_nat_pop = `=r(N)'
	sum uno if inrange(edad_ci,15,34) [fw=factor_ci]
	scalar workAge1534_pop = `=r(N)'
		
	* Share of labour force population (15-34)
	sum uno if inrange(edad_ci,15,34) & pea_ci == 1 & migrante_ci==1 [fw=factor_ci]
	scalar econoAct1534_migr_pop = `=r(N)'
	sum uno if inrange(edad_ci,15,34) & pea_ci == 1 & migrante_ci==0 [fw=factor_ci]
	scalar econoAct1534_nat_pop = `=r(N)'
	sum uno if inrange(edad_ci,15,34) & pea_ci == 1 [fw=factor_ci]
	scalar econoAct1534_pop = `=r(N)'
	
	* Share of Employment rate  (15-34)
	sum uno if inrange(edad_ci,15,34) & emp_ci == 1 & migrante_ci==1 [fw=factor_ci]
	scalar emp1534_migr_pop = `=r(N)'
	sum uno if inrange(edad_ci,15,34) & emp_ci == 1 & migrante_ci==0 [fw=factor_ci]
	scalar emp1534_nat_pop = `=r(N)'
	sum uno if inrange(edad_ci,15,34) & emp_ci == 1 [fw=factor_ci]
	scalar emp1534_pop = `=r(N)'
	
	* Share of working age population (35-64)
	sum uno if inrange(edad_ci,35,64) & migrante_ci==1 [fw=factor_ci]
	scalar workAge3564_migr_pop = `=r(N)'
	sum uno if inrange(edad_ci,35,64) & migrante_ci==0 [fw=factor_ci]
	scalar workAge3564_nat_pop = `=r(N)'
	sum uno if inrange(edad_ci,35,64) [fw=factor_ci]
	scalar workAge3564_pop = `=r(N)'
		
	* Share of labour force population (35-64)
	sum uno if inrange(edad_ci,35,64) & pea_ci == 1 & migrante_ci==1 [fw=factor_ci]
	scalar econoAct3564_migr_pop = `=r(N)'
	sum uno if inrange(edad_ci,35,64) & pea_ci == 1 & migrante_ci==0 [fw=factor_ci]
	scalar econoAct3564_nat_pop = `=r(N)'
	sum uno if inrange(edad_ci,35,64) & pea_ci == 1 [fw=factor_ci]
	scalar econoAct3564_pop = `=r(N)'
	
	* Share of Employment rate  (35-64)
	sum uno if inrange(edad_ci,35,64) & emp_ci == 1 & migrante_ci==1 [fw=factor_ci]
	scalar emp_migr3564_pop = `=r(N)'
	sum uno if inrange(edad_ci,35,64) & emp_ci == 1 & migrante_ci==0 [fw=factor_ci]
	scalar emp_nat3564_pop = `=r(N)'
	sum uno if inrange(edad_ci,35,64) & emp_ci == 1 [fw=factor_ci]
	scalar emp3564_pop = `=r(N)'
	

	** CALCULATION OF INDICATORS BY MIGRANTS AND NATIVES
	
	foreach var in 1 0 {
		
		** LABOUR MARKET INDICATORS (BY AGE)
		
		************************************************************************
		** People of ages from 15 to 34
		
		* Share of population with a job (15-34)
		sum uno if inrange(edad_ci,15,34) & emp_ci==1 & migrante_ci==`var' [fw=factor_ci]
		scalar job1534_``var'_label'_pop = `=r(N)'
		
		* Activity: Share participating in the labour force (15-34)
		sum uno if inrange(edad_ci,15,34) & pea_ci==1 & migrante_ci==`var' [fw=factor_ci]
		scalar econoAct1534_``var'_label'_pop = `=r(N)'
		
		* Economically inactive people (15-34)
		sum uno if inrange(edad_ci,15,34) & (condocup_ci == 3) & migrante_ci==`var' [fw=factor_ci] 
		scalar inactive1534_``var'_label'_pop = `=r(N)'
		
		* Unemployment: Share of population who were unemployed (15-34)
		sum uno if inrange(edad_ci,15,34) & desemp_ci==1 & migrante_ci==`var' [fw=factor_ci] 
		scalar unemp1534_``var'_label'_pop = `=r(N)'
		
		sum uno if (pea_ci==1 | asiste_ci==1) & inrange(edad_ci,15,34) & migrante_ci==`var' [fw=factor_ci]
		scalar econoActWorkAge1534_``var'_label'_pop = `=r(N)'
		
		* Risk of labour market exclusion: long-term unemployment (12 months) (15-34)
		sum uno if inrange(edad_ci,15,34) & (more_12==1 & desemp_ci==1) & migrante_ci==`var' [fw=factor_ci]
		scalar long12_unemp1534_``var'_label'_pop = `=r(N)'
		
		sum uno if inrange(edad_ci,15,34) & (desemp_ci==1 | condocup_ci==3) & durades_ci!=. & migrante_ci==`var' [fw=factor_ci] 
		scalar inac_unemp1534_``var'_label'_pop = `=r(N)'
		
		* Risk of labour market exclusion: long-term unemployment (6 months) (15-34)
		sum uno if inrange(edad_ci,15,34) & (more_6==1 & desemp_ci==1) & migrante_ci==`var' [fw=factor_ci]
		scalar long6_unemp1534_``var'_label'_pop = `=r(N)'
		
		* Risk of labour market exclusion: long-term uemployment >=12 months or inactive involuntary (15-34)
		sum uno if inrange(edad_ci,15,34) & (desalent_ci==1 | (more_12==1 & desemp_ci==1)) & migrante_ci==`var' [fw=factor_ci]
		scalar long_invo1534_``var'_label'_pop = `=r(N)'
		
		* Risk of labour market exclusion: Inactive involuntary (available past week, not looking for job) (15-34)
		sum uno if inrange(edad_ci,15,34) & desalent_ci==1 & migrante_ci==`var' [fw=factor_ci]
		scalar involuntary1534_``var'_label'_pop = `=r(N)'
		
		* Share of population with written contract (15-34)
		sum uno if inrange(edad_ci,15,34) & inlist(tipocontrato_ci,0,1,2) & migrante_ci==`var' [fw=factor_ci]
		scalar written1534_``var'_label'_pop = `=r(N)'		
		
		* Share of population with an informal job (15-34)
		sum uno if inrange(edad_ci,15,34) & informal==1 & migrante_ci==`var' [fw=factor_ci]
		scalar informal1534_``var'_label'_pop = `=r(N)'
		
		* Types of contracts:  Share of population in temporary contracts (15-34)
		sum uno if inrange(edad_ci,15,34) & tipocontrato_ci==2 & migrante_ci==`var' [fw=factor_ci] 
		scalar tempJob1534_``var'_label'_pop = `=r(N)'
		
		sum uno if inrange(edad_ci,15,34) & categopri_ci!=2 & asiste_ci!=1 & emp_ci==1 & migrante_ci==`var' [fw=factor_ci]
		scalar noself_edu1534_``var'_label'_pop = `=r(N)'
		
		* Working hours: long hours >= 50 (15-34)
		sum uno if inrange(edad_ci,15,34) & more_50==1 & emp_ci == 1 & migrante_ci==`var' [fw=factor_ci]
		scalar more50h1534_``var'_label'_pop = `=r(N)'
		
		sum uno if inrange(edad_ci,15,34) & by_hours==1 & emp_ci == 1 & migrante_ci==`var' [fw=factor_ci]
		scalar hours1534_``var'_label'_pop = `=r(N)'	
	
		* Working hours: long hours < 30 (15-34)
		sum uno if inrange(edad_ci,15,34) & less_30==1 & emp_ci == 1 & migrante_ci==`var' [fw=factor_ci]
		scalar less30h1534_``var'_label'_pop = `=r(N)'

		* Job skills: share of working population in highly skilled jobs (15-34)
		sum uno if high_skilled==1 & inrange(edad_ci,15,34) & migrante_ci==`var' [fw=factor_ci]
		scalar highSkill1534_``var'_label'_pop = `=r(N)'		
		
		* Job skills: share of working population in low-skilled jobs (15-34)
		sum uno if low_skilled==1 & inrange(edad_ci,15,34) & migrante_ci==`var' [fw=factor_ci]
		scalar lowSkill1534_``var'_label'_pop = `=r(N)'
		
		sum uno if emp_ci==1 & inrange(edad_ci,15,34) & ISCO!=0 & migrante_ci==`var' [fw=factor_ci]
		scalar NotMili1534_``var'_label'_pop = `=r(N)'
		
		* Overqualification: share of highly educated individuals who work in low- or medium-skilled jobs (15-34)
		sum uno if overqualificated==1 & inrange(edad_ci,15,34) & migrante_ci==`var' & inrange(ISCED,4,9) [fw=factor_ci]
		scalar overquali1534_``var'_label'_pop = `=r(N)'
		
		sum uno if emp_ci==1 & inrange(edad_ci,15,34) & asiste_ci!=1 & ISCO!=0 & migrante_ci==`var' [fw=factor_ci]
		scalar NotEduNotMili1534_``var'_label'_pop = `=r(N)'
		
		* Self-employment: share of population who works in their own firms or businesses (15-34)
		sum uno if (categopri_ci==1 | categopri_ci==2) & inrange(edad_ci,15,34) & migrante_ci==`var' [fw=factor_ci]
		scalar selfEmp1534_``var'_label'_pop = `=r(N)'
		
		sum uno if inrange(edad_ci,15,34) & rama_ci!=1 & emp_ci==1 & migrante_ci==`var' [fw=factor_ci]
		scalar Notagri_emp1534_``var'_label'_pop = `=r(N)'
		
		* Employment in the public sector (15-34)
		sum uno if spublico_ci==1 & inrange(edad_ci,15,34) & migrante_ci==`var' [fw=factor_ci]
		scalar pubSec1534_``var'_label'_pop = `=r(N)'
		
		sum uno if inrange(edad_ci,15,34) & emp_ci==1 & categopri_ci!=2 & migrante_ci==`var' [fw=factor_ci]
		scalar NoSelf1534_``var'_label'_pop = `=r(N)'
		
		* Nominal monthly wage (USD) (15-34)
		sum nmwage if migrante_ci==`var' & inrange(edad_ci,15,34) [fw=factor_ci]
		scalar nmwage1534_``var'_label' = `=r(mean)'
		
		** SAMPLE CHARACTERISTICS
		
		* Total sample size: persons 
		sum uno if migrante_ci==`var'
		scalar survey_``var'_label'_pop = `=r(N)'
		
		* Total sample size: persons 15-34
		sum uno if inrange(edad_ci,15,34) & migrante_ci==`var'
		scalar survey_``var'_label'_1534 = `=r(N)'

		* Total persons 15-34 (with sample loadings)
		sum uno if inrange(edad_ci,15,34) & migrante_ci==`var' [fw=factor_ci]
		scalar total_``var'_label'_1534 = `=r(N)'
		
		************************************************************************
		** People of ages from 35 to 64
		
		* Share of population with a job (35-64)
		sum uno if inrange(edad_ci,35,64) & emp_ci==1 & migrante_ci==`var' [fw=factor_ci]
		scalar job3564_``var'_label'_pop = `=r(N)'
		
		* Activity: Share participating in the labour force (35-64)
		sum uno if inrange(edad_ci,35,64) & pea_ci==1 & migrante_ci==`var' [fw=factor_ci]
		scalar econoAct3564_``var'_label'_pop = `=r(N)'
		
		* Economically inactive people (35-64)
		sum uno if inrange(edad_ci,35,64) & (condocup_ci == 3) & migrante_ci==`var' [fw=factor_ci] 
		scalar inactive3564_``var'_label'_pop = `=r(N)'
		
		* Unemployment: Share of population who were unemployed (35-64)
		sum uno if inrange(edad_ci,35,64) & desemp_ci==1 & migrante_ci==`var' [fw=factor_ci] 
		scalar unemp3564_``var'_label'_pop = `=r(N)'
		
		sum uno if (pea_ci==1 | asiste_ci==1) & inrange(edad_ci,35,64) & migrante_ci==`var' [fw=factor_ci]
		scalar econoActWorkAge3564_``var'_label'_pop = `=r(N)'
		
		* Risk of labour market exclusion: long-term unemployment (12 months) (35-64)
		sum uno if inrange(edad_ci,35,64) & (more_12==1 & desemp_ci==1) & migrante_ci==`var' [fw=factor_ci]
		scalar long12_unemp3564_``var'_label'_pop = `=r(N)'
		
		sum uno if inrange(edad_ci,35,64) & (desemp_ci==1 | condocup_ci==3) & durades_ci!=. & migrante_ci==`var' [fw=factor_ci] 
		scalar inac_unemp3564_``var'_label'_pop = `=r(N)'
		
		* Risk of labour market exclusion: long-term unemployment (6 months) (35-64)
		sum uno if inrange(edad_ci,35,64) & (more_6==1 & desemp_ci==1) & migrante_ci==`var' [fw=factor_ci]
		scalar long6_unemp3564_``var'_label'_pop = `=r(N)'
		
		* Risk of labour market exclusion: long-term unemployment >=12 months or inactive involuntary (35-64)
		sum uno if inrange(edad_ci,35,64) & (desalent_ci==1 | (more_12==1 & desemp_ci==1)) & migrante_ci==`var' [fw=factor_ci]
		scalar long_invo3564_``var'_label'_pop = `=r(N)'
		
		* Risk of labour market exclusion: Inactive involuntary (available past week, not looking for job) (35-64)
		sum uno if inrange(edad_ci,35,64) & desalent_ci==1 & migrante_ci==`var' [fw=factor_ci]
		scalar involuntary3564_``var'_label'_pop = `=r(N)'
		
		* Share of population with written contract (35-64)
		sum uno if inrange(edad_ci,35,64) & inlist(tipocontrato_ci,0,1,2) & migrante_ci==`var' [fw=factor_ci]
		scalar written3564_``var'_label'_pop = `=r(N)'		
		
		* Share of population with an informal job (35-64)
		sum uno if inrange(edad_ci,35,64) & informal==1 & migrante_ci==`var' [fw=factor_ci]
		scalar informal3564_``var'_label'_pop = `=r(N)'
		
		* Types of contracts:  Share of population in temporary contracts (35-64)
		sum uno if inrange(edad_ci,35,64) & tipocontrato_ci==2 & migrante_ci==`var' [fw=factor_ci] 
		scalar tempJob3564_``var'_label'_pop = `=r(N)'
		
		sum uno if inrange(edad_ci,35,64) & categopri_ci!=2 & asiste_ci!=1 & emp_ci==1 & migrante_ci==`var' [fw=factor_ci]
		scalar noself_edu3564_``var'_label'_pop = `=r(N)'
		
		* Working hours: long hours >= 50 (35-64)
		sum uno if inrange(edad_ci,35,64) & more_50==1 & emp_ci == 1 & migrante_ci==`var' [fw=factor_ci]
		scalar more50h3564_``var'_label'_pop = `=r(N)'
		
		sum uno if inrange(edad_ci,35,64) & by_hours==1 & emp_ci == 1 & migrante_ci==`var' [fw=factor_ci]
		scalar hours3564_``var'_label'_pop = `=r(N)'	
	
		* Working hours: long hours < 30 (35-64)
		sum uno if inrange(edad_ci,35,64) & less_30==1 & emp_ci == 1 & migrante_ci==`var' [fw=factor_ci]
		scalar less30h3564_``var'_label'_pop = `=r(N)'

		* Job skills: share of working population in highly skilled jobs (35-64)
		sum uno if high_skilled==1 & inrange(edad_ci,35,64) & migrante_ci==`var' [fw=factor_ci]
		scalar highSkill3564_``var'_label'_pop = `=r(N)'		
		
		* Job skills: share of working population in low-skilled jobs (35-64)
		sum uno if low_skilled==1 & inrange(edad_ci,35,64) & migrante_ci==`var' [fw=factor_ci]
		scalar lowSkill3564_``var'_label'_pop = `=r(N)'
		
		sum uno if emp_ci==1 & inrange(edad_ci,35,64) & ISCO!=0 & migrante_ci==`var' [fw=factor_ci]
		scalar NotMili3564_``var'_label'_pop = `=r(N)'
		
		* Overqualification: share of highly educated individuals who work in low- or medium-skilled jobs (35-64)
		sum uno if overqualificated==1 & inrange(edad_ci,35,64) & migrante_ci==`var' & inrange(ISCED,4,9) [fw=factor_ci]
		scalar overquali3564_``var'_label'_pop = `=r(N)'
		
		sum uno if emp_ci==1 & inrange(edad_ci,35,64) & asiste_ci!=1 & ISCO!=0 & migrante_ci==`var' [fw=factor_ci]
		scalar NotEduNotMili3564_``var'_label'_pop = `=r(N)'
		
		* Self-employment: share of population who works in their own firms or businesses (35-64)
		sum uno if (categopri_ci==1 | categopri_ci==2) & inrange(edad_ci,35,64) & migrante_ci==`var' [fw=factor_ci]
		scalar selfEmp3564_``var'_label'_pop = `=r(N)'
		
		sum uno if inrange(edad_ci,35,64) & rama_ci!=1 & emp_ci==1 & migrante_ci==`var' [fw=factor_ci]
		scalar Notagri_emp3564_``var'_label'_pop = `=r(N)'
		
		* Employment in the public sector (35-64)
		sum uno if spublico_ci==1 & inrange(edad_ci,35,64) & migrante_ci==`var' [fw=factor_ci]
		scalar pubSec3564_``var'_label'_pop = `=r(N)'
		
		sum uno if inrange(edad_ci,35,64) & emp_ci==1 & categopri_ci!=2 & migrante_ci==`var' [fw=factor_ci]
		scalar NoSelf3564_``var'_label'_pop = `=r(N)'
		
		* Nominal monthly wage (USD) (35-64)
		sum nmwage if migrante_ci==`var' & inrange(edad_ci,35,64) [fw=factor_ci]
		scalar nmwage3564_``var'_label' = `=r(mean)'
		
		** SAMPLE CHARACTERISTICS
		
		* Total sample size: persons 35-64
		sum uno if inrange(edad_ci,35,64) & migrante_ci==`var'
		scalar survey_``var'_label'_3564 = `=r(N)'

		* Total persons 35-64 (with sample loadings)
		sum uno if inrange(edad_ci,35,64) & migrante_ci==`var' [fw=factor_ci]
		scalar total_``var'_label'_3564 = `=r(N)'
		
	}
	
******************************************************** EXCEL OUTPUTS

	putexcel set "C:\Users\jcamilop\OneDrive - Inter-American Development Bank Group\OECD\03 Outputs\Resultados por edad.xlsx", sheet("Dominican Rep.") modify
	putexcel describe
	
	
	** LABOUR MARKET INDICATORS FOR PEOPLE OF AGES FROM 15 TO 34
	
	putexcel C8 = (`=job1534_nat_pop'/`=workAge1534_nat_pop') E8 = (`=job1534_migr_pop'/`=workAge1534_migr_pop') // Share of population with a job
	
	putexcel C9 = (`=econoAct1534_nat_pop'/`=workAge1534_nat_pop') E9 = (`=econoAct1534_migr_pop'/`=workAge1534_migr_pop') // Activity: Share participating in the labour force
	
	putexcel C10 = (`=inactive1534_nat_pop'/`=workAge1534_nat_pop') E10 = (`=inactive1534_migr_pop'/`=workAge1534_migr_pop')  // Economically inactive people
	
	putexcel C11 = (`=unemp1534_nat_pop'/`=econoActWorkAge1534_nat_pop') E11 = (`=unemp1534_migr_pop'/`=econoActWorkAge1534_migr_pop') // Unemployment: Share of population who were unemployed
	
	putexcel C12 = (`=long12_unemp1534_nat_pop'/`=inac_unemp1534_nat_pop') E12 = (`=long12_unemp1534_migr_pop'/`=inac_unemp1534_migr_pop') // Risk of labour market exclusion: long-term unemployment (12 month)
	
	putexcel C13 = (`=long6_unemp1534_nat_pop'/`=inac_unemp1534_nat_pop') E13 = (`=long6_unemp1534_migr_pop'/`=inac_unemp1534_migr_pop') // Risk of labour market exclusion: long-term unemployment (6 month)
	
	putexcel C14 = (`=long_invo1534_nat_pop'/`=inac_unemp1534_nat_pop') E14 = (`=long_invo1534_migr_pop'/`=inac_unemp1534_migr_pop') // Long-term uemployment >=12 months or inactive involuntary	
	
	putexcel C15 = (`=involuntary1534_nat_pop'/`=inac_unemp1534_nat_pop') E15 = (`=involuntary1534_migr_pop'/`=inac_unemp1534_migr_pop') // Inactive involuntary (available past week, not looking for job)
	
	putexcel C16 = (`=written1534_nat_pop'/`=noself_edu1534_nat_pop') E16 = (`=written1534_migr_pop'/`=noself_edu1534_migr_pop') // Share of population with written contract
	
	putexcel C17 = (`=informal1534_nat_pop'/`=job1534_nat_pop') E17 = (`=informal1534_migr_pop'/`=job1534_migr_pop') // Share of population with an informal job	
	
    // Share of population with an informal job (OECD def)
	
	putexcel C19 = (`=tempJob1534_nat_pop'/`=noself_edu1534_nat_pop') E19 = (`=tempJob1534_migr_pop'/`=noself_edu1534_migr_pop') // Types of contracts: Share of population in temporary contracts	

	putexcel C20 = (`=more50h1534_nat_pop'/`=hours1534_nat_pop') E20 = (`=more50h1534_migr_pop'/`=hours1534_migr_pop')  // Working hours: long (more than 50) hours
	
	putexcel C21 = (`=less30h1534_nat_pop'/`=hours1534_nat_pop') E21 = (`=less30h1534_migr_pop'/`=hours1534_migr_pop')  // Working hours: long (less than 30) hours	
	
	putexcel C22 = (`=highSkill1534_nat_pop'/`=NotMili1534_nat_pop') E22 = (`=highSkill1534_migr_pop'/`=NotMili1534_migr_pop') // Job skills: share of working population in highly skilled jobs
	
	putexcel C23 = (`=lowSkill1534_nat_pop'/`=NotMili1534_nat_pop') E23 = (`=lowSkill1534_migr_pop'/`=NotMili1534_migr_pop') // Job skills: share of working population in low-skilled jobs 
		
	putexcel C24 = (`=overquali1534_nat_pop'/`=NotEduNotMili1534_nat_pop') E24 = (`=overquali1534_migr_pop'/`=NotEduNotMili1534_migr_pop') // Overqualification: share of highly educated individuals who work in low- or medium-skilled jobs

	putexcel C25 = (`=selfEmp1534_nat_pop'/`=Notagri_emp1534_nat_pop') E25 = (`=selfEmp1534_migr_pop'/`=Notagri_emp1534_migr_pop')   // Self-employment: share of population who work in their own firms or businesses
	
	putexcel C26 = (`=pubSec1534_nat_pop'/`=NoSelf1534_nat_pop') E26 = (`=pubSec1534_migr_pop'/`=NoSelf1534_migr_pop')   // Employment in the public sector
	
	putexcel C27 = (`=nmwage1534_nat')  E27 = (`=nmwage1534_migr') // Nominal monthly wage (USD)
	
	
	** SIMPLE CHARACTERISTICS (15 - 34)
	
	putexcel C33 = (`=survey_nat_pop') E33 = (`=survey_migr_pop') // Total sample size: persons
	
	putexcel C34 = (`=survey_nat_1534') E34 = (`=survey_migr_1534') // Total sample size: persons 15-64
	
	putexcel C36 = (`=nat_pop') E36 = (`=migr_pop') // Total population (with sample loadings)
	
	putexcel C37 = (`=total_nat_1534') E37 = (`=total_migr_1534') // Total persons 15-64 (with sample loadings)
	
	
	** LABOUR MARKET INDICATORS FOR PEOPLE OF AGES FROM 35 TO 64
	
	putexcel D8 = (`=job3564_nat_pop'/`=workAge3564_nat_pop') F8 = (`=job3564_migr_pop'/`=workAge3564_migr_pop') // Share of population with a job
	
	putexcel D9 = (`=econoAct3564_nat_pop'/`=workAge3564_nat_pop') F9 = (`=econoAct3564_migr_pop'/`=workAge3564_migr_pop') // Activity: Share participating in the labour force
	
	putexcel D10 = (`=inactive3564_nat_pop'/`=workAge3564_nat_pop') F10 = (`=inactive3564_migr_pop'/`=workAge3564_migr_pop')  // Economically inactive people
	
	putexcel D11 = (`=unemp3564_nat_pop'/`=econoActWorkAge3564_nat_pop') F11 = (`=unemp3564_migr_pop'/`=econoActWorkAge3564_migr_pop') // Unemployment: Share of population who were unemployed
	
	putexcel D12 = (`=long12_unemp3564_nat_pop'/`=inac_unemp3564_nat_pop') F12 = (`=long12_unemp3564_migr_pop'/`=inac_unemp3564_migr_pop') // Risk of labour market exclusion: long-term unemployment (12 month)
	
	putexcel D13 = (`=long6_unemp3564_nat_pop'/`=inac_unemp3564_nat_pop') F13 = (`=long6_unemp3564_migr_pop'/`=inac_unemp3564_migr_pop') // Risk of labour market exclusion: long-term unemployment (6 month)
	
	putexcel D14 = (`=long_invo3564_nat_pop'/`=inac_unemp3564_nat_pop') F14 = (`=long_invo3564_migr_pop'/`=inac_unemp3564_migr_pop') // Long-term uemployment >=12 months or inactive involuntary	
	
	putexcel D15 = (`=involuntary3564_nat_pop'/`=inac_unemp3564_nat_pop') F15 = (`=involuntary3564_migr_pop'/`=inac_unemp3564_migr_pop') // Inactive involuntary (available past week, not looking for job)
	
	putexcel D16 = (`=written3564_nat_pop'/`=noself_edu3564_nat_pop') F16 = (`=written3564_migr_pop'/`=noself_edu3564_migr_pop') // Share of population with written contract
	
	putexcel D17 = (`=informal3564_nat_pop'/`=job3564_nat_pop') F17 = (`=informal3564_migr_pop'/`=job3564_migr_pop') // Share of population with an informal job	
	
    // Share of population with an informal job (OECD def)
	
	putexcel D19 = (`=tempJob3564_nat_pop'/`=noself_edu3564_nat_pop') F19 = (`=tempJob3564_migr_pop'/`=noself_edu3564_migr_pop') // Types of contracts: Share of population in temporary contracts	

	putexcel D20 = (`=more50h3564_nat_pop'/`=hours3564_nat_pop') F20 = (`=more50h3564_migr_pop'/`=hours3564_migr_pop')  // Working hours: long (more than 50) hours
	
	putexcel D21 = (`=less30h3564_nat_pop'/`=hours3564_nat_pop') F21 = (`=less30h3564_migr_pop'/`=hours3564_migr_pop')  // Working hours: long (less than 30) hours	
	
	putexcel D22 = (`=highSkill3564_nat_pop'/`=NotMili3564_nat_pop') F22 = (`=highSkill3564_migr_pop'/`=NotMili3564_migr_pop') // Job skills: share of working population in highly skilled jobs
	
	putexcel D23 = (`=lowSkill3564_nat_pop'/`=NotMili3564_nat_pop') F23 = (`=lowSkill3564_migr_pop'/`=NotMili3564_migr_pop') // Job skills: share of working population in low-skilled jobs 
		
	putexcel D24 = (`=overquali3564_nat_pop'/`=NotEduNotMili3564_nat_pop') F24 = (`=overquali3564_migr_pop'/`=NotEduNotMili3564_migr_pop') // Overqualification: share of highly educated individuals who work in low- or medium-skilled jobs

	putexcel D25 = (`=selfEmp3564_nat_pop'/`=Notagri_emp3564_nat_pop') F25 = (`=selfEmp3564_migr_pop'/`=Notagri_emp3564_migr_pop')   // Self-employment: share of population who work in their own firms or businesses
	
	putexcel D26 = (`=pubSec3564_nat_pop'/`=NoSelf3564_nat_pop') F26 = (`=pubSec3564_migr_pop'/`=NoSelf3564_migr_pop')   // Employment in the public sector
	
	putexcel D27 = (`=nmwage3564_nat')  F27 = (`=nmwage3564_migr') // Nominal monthly wage (USD)
	
	** SIMPLE CHARACTERISTICS (35 - 64)
	
	putexcel D34 = (`=survey_nat_3564') F34 = (`=survey_migr_3564') // Total sample size: persons 15-64
	
	putexcel D37 = (`=total_nat_3564') F37 = (`=total_migr_3564') // Total persons 15-64 (with sample loadings)
	
	
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
	sum uno if migrante_ci!=. & inrange(edad_ci,15,34) [fw=factor_ci]
	scalar tot_pop = `=r(N)'
	
	* Migrant population calculated according to expansion factor
	sum uno if migrante_ci==1 [fw=factor_ci]
	scalar migr_pop = `=r(N)'
	
	* Native population calculated according to expansion factor
	sum uno if migrante_ci==0 [fw=factor_ci]
	scalar nat_pop = `=r(N)'
	
	* Share of working age population (15-34)
	sum uno if inrange(edad_ci,15,34) & migrante_ci==1 [fw=factor_ci]
	scalar workAge1534_migr_pop = `=r(N)'
	sum uno if inrange(edad_ci,15,34) & migrante_ci==0 [fw=factor_ci]
	scalar workAge1534_nat_pop = `=r(N)'
	sum uno if inrange(edad_ci,15,34) [fw=factor_ci]
	scalar workAge1534_pop = `=r(N)'
		
	* Share of labour force population (15-34)
	sum uno if inrange(edad_ci,15,34) & pea_ci == 1 & migrante_ci==1 [fw=factor_ci]
	scalar econoAct1534_migr_pop = `=r(N)'
	sum uno if inrange(edad_ci,15,34) & pea_ci == 1 & migrante_ci==0 [fw=factor_ci]
	scalar econoAct1534_nat_pop = `=r(N)'
	sum uno if inrange(edad_ci,15,34) & pea_ci == 1 [fw=factor_ci]
	scalar econoAct1534_pop = `=r(N)'
	
	* Share of Employment rate  (15-34)
	sum uno if inrange(edad_ci,15,34) & emp_ci == 1 & migrante_ci==1 [fw=factor_ci]
	scalar emp1534_migr_pop = `=r(N)'
	sum uno if inrange(edad_ci,15,34) & emp_ci == 1 & migrante_ci==0 [fw=factor_ci]
	scalar emp1534_nat_pop = `=r(N)'
	sum uno if inrange(edad_ci,15,34) & emp_ci == 1 [fw=factor_ci]
	scalar emp1534_pop = `=r(N)'
	
	* Share of working age population (35-64)
	sum uno if inrange(edad_ci,35,64) & migrante_ci==1 [fw=factor_ci]
	scalar workAge3564_migr_pop = `=r(N)'
	sum uno if inrange(edad_ci,35,64) & migrante_ci==0 [fw=factor_ci]
	scalar workAge3564_nat_pop = `=r(N)'
	sum uno if inrange(edad_ci,35,64) [fw=factor_ci]
	scalar workAge3564_pop = `=r(N)'
		
	* Share of labour force population (35-64)
	sum uno if inrange(edad_ci,35,64) & pea_ci == 1 & migrante_ci==1 [fw=factor_ci]
	scalar econoAct3564_migr_pop = `=r(N)'
	sum uno if inrange(edad_ci,35,64) & pea_ci == 1 & migrante_ci==0 [fw=factor_ci]
	scalar econoAct3564_nat_pop = `=r(N)'
	sum uno if inrange(edad_ci,35,64) & pea_ci == 1 [fw=factor_ci]
	scalar econoAct3564_pop = `=r(N)'
	
	* Share of Employment rate  (35-64)
	sum uno if inrange(edad_ci,35,64) & emp_ci == 1 & migrante_ci==1 [fw=factor_ci]
	scalar emp_migr3564_pop = `=r(N)'
	sum uno if inrange(edad_ci,35,64) & emp_ci == 1 & migrante_ci==0 [fw=factor_ci]
	scalar emp_nat3564_pop = `=r(N)'
	sum uno if inrange(edad_ci,35,64) & emp_ci == 1 [fw=factor_ci]
	scalar emp3564_pop = `=r(N)'
	

	** CALCULATION OF INDICATORS BY MIGRANTS AND NATIVES
	
	foreach var in 1 0 {
		
		** LABOUR MARKET INDICATORS (BY AGE)
		
		************************************************************************
		** People of ages from 15 to 34
		
		* Share of population with a job (15-34)
		sum uno if inrange(edad_ci,15,34) & emp_ci==1 & migrante_ci==`var' [fw=factor_ci]
		scalar job1534_``var'_label'_pop = `=r(N)'
		
		* Activity: Share participating in the labour force (15-34)
		sum uno if inrange(edad_ci,15,34) & pea_ci==1 & migrante_ci==`var' [fw=factor_ci]
		scalar econoAct1534_``var'_label'_pop = `=r(N)'
		
		* Economically inactive people (15-34)
		sum uno if inrange(edad_ci,15,34) & (condocup_ci == 3) & migrante_ci==`var' [fw=factor_ci] 
		scalar inactive1534_``var'_label'_pop = `=r(N)'
		
		* Unemployment: Share of population who were unemployed (15-34)
		sum uno if inrange(edad_ci,15,34) & desemp_ci==1 & migrante_ci==`var' [fw=factor_ci] 
		scalar unemp1534_``var'_label'_pop = `=r(N)'
		
		sum uno if (pea_ci==1 | asiste_ci==1) & inrange(edad_ci,15,34) & migrante_ci==`var' [fw=factor_ci]
		scalar econoActWorkAge1534_``var'_label'_pop = `=r(N)'
		
		* Risk of labour market exclusion: long-term unemployment (12 months) (15-34)
		sum uno if inrange(edad_ci,15,34) & (more_12==1 & desemp_ci==1) & migrante_ci==`var' [fw=factor_ci]
		scalar long12_unemp1534_``var'_label'_pop = `=r(N)'
		
		sum uno if inrange(edad_ci,15,34) & (desemp_ci==1 | condocup_ci==3) & durades_ci!=. & migrante_ci==`var' [fw=factor_ci] 
		scalar inac_unemp1534_``var'_label'_pop = `=r(N)'
		
		* Risk of labour market exclusion: long-term unemployment (6 months) (15-34)
		sum uno if inrange(edad_ci,15,34) & (more_6==1 & desemp_ci==1) & migrante_ci==`var' [fw=factor_ci]
		scalar long6_unemp1534_``var'_label'_pop = `=r(N)'
		
		* Risk of labour market exclusion: long-term uemployment >=12 months or inactive involuntary (15-34)
		sum uno if inrange(edad_ci,15,34) & (desalent_ci==1 | (more_12==1 & desemp_ci==1)) & migrante_ci==`var' [fw=factor_ci]
		scalar long_invo1534_``var'_label'_pop = `=r(N)'
		
		* Risk of labour market exclusion: Inactive involuntary (available past week, not looking for job) (15-34)
		sum uno if inrange(edad_ci,15,34) & desalent_ci==1 & migrante_ci==`var' [fw=factor_ci]
		scalar involuntary1534_``var'_label'_pop = `=r(N)'
		
		* Share of population with written contract (15-34)
		sum uno if inrange(edad_ci,15,34) & inlist(tipocontrato_ci,0,1,2) & migrante_ci==`var' [fw=factor_ci]
		scalar written1534_``var'_label'_pop = `=r(N)'		
		
		* Share of population with an informal job (15-34)
		sum uno if inrange(edad_ci,15,34) & informal==1 & migrante_ci==`var' [fw=factor_ci]
		scalar informal1534_``var'_label'_pop = `=r(N)'
		
		* Types of contracts:  Share of population in temporary contracts (15-34)
		sum uno if inrange(edad_ci,15,34) & tipocontrato_ci==2 & migrante_ci==`var' [fw=factor_ci] 
		scalar tempJob1534_``var'_label'_pop = `=r(N)'
		
		sum uno if inrange(edad_ci,15,34) & categopri_ci!=2 & asiste_ci!=1 & emp_ci==1 & migrante_ci==`var' [fw=factor_ci]
		scalar noself_edu1534_``var'_label'_pop = `=r(N)'
		
		* Working hours: long hours >= 50 (15-34)
		sum uno if inrange(edad_ci,15,34) & more_50==1 & emp_ci == 1 & migrante_ci==`var' [fw=factor_ci]
		scalar more50h1534_``var'_label'_pop = `=r(N)'
		
		sum uno if inrange(edad_ci,15,34) & by_hours==1 & emp_ci == 1 & migrante_ci==`var' [fw=factor_ci]
		scalar hours1534_``var'_label'_pop = `=r(N)'	
	
		* Working hours: long hours < 30 (15-34)
		sum uno if inrange(edad_ci,15,34) & less_30==1 & emp_ci == 1 & migrante_ci==`var' [fw=factor_ci]
		scalar less30h1534_``var'_label'_pop = `=r(N)'

		* Job skills: share of working population in highly skilled jobs (15-34)
		sum uno if high_skilled==1 & inrange(edad_ci,15,34) & migrante_ci==`var' [fw=factor_ci]
		scalar highSkill1534_``var'_label'_pop = `=r(N)'		
		
		* Job skills: share of working population in low-skilled jobs (15-34)
		sum uno if low_skilled==1 & inrange(edad_ci,15,34) & migrante_ci==`var' [fw=factor_ci]
		scalar lowSkill1534_``var'_label'_pop = `=r(N)'
		
		sum uno if emp_ci==1 & inrange(edad_ci,15,34) & ISCO!=0 & migrante_ci==`var' [fw=factor_ci]
		scalar NotMili1534_``var'_label'_pop = `=r(N)'
		
		* Overqualification: share of highly educated individuals who work in low- or medium-skilled jobs (15-34)
		sum uno if overqualificated==1 & inrange(edad_ci,15,34) & migrante_ci==`var' & inrange(ISCED,4,9) [fw=factor_ci]
		scalar overquali1534_``var'_label'_pop = `=r(N)'
		
		sum uno if emp_ci==1 & inrange(edad_ci,15,34) & asiste_ci!=1 & ISCO!=0 & migrante_ci==`var' [fw=factor_ci]
		scalar NotEduNotMili1534_``var'_label'_pop = `=r(N)'
		
		* Self-employment: share of population who works in their own firms or businesses (15-34)
		sum uno if (categopri_ci==1 | categopri_ci==2) & inrange(edad_ci,15,34) & migrante_ci==`var' [fw=factor_ci]
		scalar selfEmp1534_``var'_label'_pop = `=r(N)'
		
		sum uno if inrange(edad_ci,15,34) & rama_ci!=1 & emp_ci==1 & migrante_ci==`var' [fw=factor_ci]
		scalar Notagri_emp1534_``var'_label'_pop = `=r(N)'
		
		* Employment in the public sector (15-34)
		sum uno if spublico_ci==1 & inrange(edad_ci,15,34) & migrante_ci==`var' [fw=factor_ci]
		scalar pubSec1534_``var'_label'_pop = `=r(N)'
		
		sum uno if inrange(edad_ci,15,34) & emp_ci==1 & categopri_ci!=2 & migrante_ci==`var' [fw=factor_ci]
		scalar NoSelf1534_``var'_label'_pop = `=r(N)'
		
		* Nominal monthly wage (USD) (15-34)
		sum nmwage if migrante_ci==`var' & inrange(edad_ci,15,34) [fw=factor_ci]
		scalar nmwage1534_``var'_label' = `=r(mean)'
		
		** SAMPLE CHARACTERISTICS
		
		* Total sample size: persons 
		sum uno if migrante_ci==`var'
		scalar survey_``var'_label'_pop = `=r(N)'
		
		* Total sample size: persons 15-34
		sum uno if inrange(edad_ci,15,34) & migrante_ci==`var'
		scalar survey_``var'_label'_1534 = `=r(N)'

		* Total persons 15-34 (with sample loadings)
		sum uno if inrange(edad_ci,15,34) & migrante_ci==`var' [fw=factor_ci]
		scalar total_``var'_label'_1534 = `=r(N)'
		
		************************************************************************
		** People of ages from 35 to 64
		
		* Share of population with a job (35-64)
		sum uno if inrange(edad_ci,35,64) & emp_ci==1 & migrante_ci==`var' [fw=factor_ci]
		scalar job3564_``var'_label'_pop = `=r(N)'
		
		* Activity: Share participating in the labour force (35-64)
		sum uno if inrange(edad_ci,35,64) & pea_ci==1 & migrante_ci==`var' [fw=factor_ci]
		scalar econoAct3564_``var'_label'_pop = `=r(N)'
		
		* Economically inactive people (35-64)
		sum uno if inrange(edad_ci,35,64) & (condocup_ci == 3) & migrante_ci==`var' [fw=factor_ci] 
		scalar inactive3564_``var'_label'_pop = `=r(N)'
		
		* Unemployment: Share of population who were unemployed (35-64)
		sum uno if inrange(edad_ci,35,64) & desemp_ci==1 & migrante_ci==`var' [fw=factor_ci] 
		scalar unemp3564_``var'_label'_pop = `=r(N)'
		
		sum uno if (pea_ci==1 | asiste_ci==1) & inrange(edad_ci,35,64) & migrante_ci==`var' [fw=factor_ci]
		scalar econoActWorkAge3564_``var'_label'_pop = `=r(N)'
		
		* Risk of labour market exclusion: long-term unemployment (12 months) (35-64)
		sum uno if inrange(edad_ci,35,64) & (more_12==1 & desemp_ci==1) & migrante_ci==`var' [fw=factor_ci]
		scalar long12_unemp3564_``var'_label'_pop = `=r(N)'
		
		sum uno if inrange(edad_ci,35,64) & (desemp_ci==1 | condocup_ci==3) & durades_ci!=. & migrante_ci==`var' [fw=factor_ci] 
		scalar inac_unemp3564_``var'_label'_pop = `=r(N)'
		
		* Risk of labour market exclusion: long-term unemployment (6 months) (35-64)
		sum uno if inrange(edad_ci,35,64) & (more_6==1 & desemp_ci==1) & migrante_ci==`var' [fw=factor_ci]
		scalar long6_unemp3564_``var'_label'_pop = `=r(N)'
		
		* Risk of labour market exclusion: long-term unemployment >=12 months or inactive involuntary (35-64)
		sum uno if inrange(edad_ci,35,64) & (desalent_ci==1 | (more_12==1 & desemp_ci==1)) & migrante_ci==`var' [fw=factor_ci]
		scalar long_invo3564_``var'_label'_pop = `=r(N)'
		
		* Risk of labour market exclusion: Inactive involuntary (available past week, not looking for job) (35-64)
		sum uno if inrange(edad_ci,35,64) & desalent_ci==1 & migrante_ci==`var' [fw=factor_ci]
		scalar involuntary3564_``var'_label'_pop = `=r(N)'
		
		* Share of population with written contract (35-64)
		sum uno if inrange(edad_ci,35,64) & inlist(tipocontrato_ci,0,1,2) & migrante_ci==`var' [fw=factor_ci]
		scalar written3564_``var'_label'_pop = `=r(N)'		
		
		* Share of population with an informal job (35-64)
		sum uno if inrange(edad_ci,35,64) & informal==1 & migrante_ci==`var' [fw=factor_ci]
		scalar informal3564_``var'_label'_pop = `=r(N)'
		
		* Types of contracts:  Share of population in temporary contracts (35-64)
		sum uno if inrange(edad_ci,35,64) & tipocontrato_ci==2 & migrante_ci==`var' [fw=factor_ci] 
		scalar tempJob3564_``var'_label'_pop = `=r(N)'
		
		sum uno if inrange(edad_ci,35,64) & categopri_ci!=2 & asiste_ci!=1 & emp_ci==1 & migrante_ci==`var' [fw=factor_ci]
		scalar noself_edu3564_``var'_label'_pop = `=r(N)'
		
		* Working hours: long hours >= 50 (35-64)
		sum uno if inrange(edad_ci,35,64) & more_50==1 & emp_ci == 1 & migrante_ci==`var' [fw=factor_ci]
		scalar more50h3564_``var'_label'_pop = `=r(N)'
		
		sum uno if inrange(edad_ci,35,64) & by_hours==1 & emp_ci == 1 & migrante_ci==`var' [fw=factor_ci]
		scalar hours3564_``var'_label'_pop = `=r(N)'	
	
		* Working hours: long hours < 30 (35-64)
		sum uno if inrange(edad_ci,35,64) & less_30==1 & emp_ci == 1 & migrante_ci==`var' [fw=factor_ci]
		scalar less30h3564_``var'_label'_pop = `=r(N)'

		* Job skills: share of working population in highly skilled jobs (35-64)
		sum uno if high_skilled==1 & inrange(edad_ci,35,64) & migrante_ci==`var' [fw=factor_ci]
		scalar highSkill3564_``var'_label'_pop = `=r(N)'		
		
		* Job skills: share of working population in low-skilled jobs (35-64)
		sum uno if low_skilled==1 & inrange(edad_ci,35,64) & migrante_ci==`var' [fw=factor_ci]
		scalar lowSkill3564_``var'_label'_pop = `=r(N)'
		
		sum uno if emp_ci==1 & inrange(edad_ci,35,64) & ISCO!=0 & migrante_ci==`var' [fw=factor_ci]
		scalar NotMili3564_``var'_label'_pop = `=r(N)'
		
		* Overqualification: share of highly educated individuals who work in low- or medium-skilled jobs (35-64)
		sum uno if overqualificated==1 & inrange(edad_ci,35,64) & migrante_ci==`var' & inrange(ISCED,4,9) [fw=factor_ci]
		scalar overquali3564_``var'_label'_pop = `=r(N)'
		
		sum uno if emp_ci==1 & inrange(edad_ci,35,64) & asiste_ci!=1 & ISCO!=0 & migrante_ci==`var' [fw=factor_ci]
		scalar NotEduNotMili3564_``var'_label'_pop = `=r(N)'
		
		* Self-employment: share of population who works in their own firms or businesses (35-64)
		sum uno if (categopri_ci==1 | categopri_ci==2) & inrange(edad_ci,35,64) & migrante_ci==`var' [fw=factor_ci]
		scalar selfEmp3564_``var'_label'_pop = `=r(N)'
		
		sum uno if inrange(edad_ci,35,64) & rama_ci!=1 & emp_ci==1 & migrante_ci==`var' [fw=factor_ci]
		scalar Notagri_emp3564_``var'_label'_pop = `=r(N)'
		
		* Employment in the public sector (35-64)
		sum uno if spublico_ci==1 & inrange(edad_ci,35,64) & migrante_ci==`var' [fw=factor_ci]
		scalar pubSec3564_``var'_label'_pop = `=r(N)'
		
		sum uno if inrange(edad_ci,35,64) & emp_ci==1 & categopri_ci!=2 & migrante_ci==`var' [fw=factor_ci]
		scalar NoSelf3564_``var'_label'_pop = `=r(N)'
		
		* Nominal monthly wage (USD) (35-64)
		sum nmwage if migrante_ci==`var' & inrange(edad_ci,35,64) [fw=factor_ci]
		scalar nmwage3564_``var'_label' = `=r(mean)'
		
		** SAMPLE CHARACTERISTICS
		
		* Total sample size: persons 35-64
		sum uno if inrange(edad_ci,35,64) & migrante_ci==`var'
		scalar survey_``var'_label'_3564 = `=r(N)'

		* Total persons 35-64 (with sample loadings)
		sum uno if inrange(edad_ci,35,64) & migrante_ci==`var' [fw=factor_ci]
		scalar total_``var'_label'_3564 = `=r(N)'
		
	}
	
******************************************************** EXCEL OUTPUTS

	putexcel set "C:\Users\jcamilop\OneDrive - Inter-American Development Bank Group\OECD\03 Outputs\Resultados por edad.xlsx", sheet("Panama") modify
	putexcel describe
	
	
	** LABOUR MARKET INDICATORS FOR PEOPLE OF AGES FROM 15 TO 34
	
	putexcel C8 = (`=job1534_nat_pop'/`=workAge1534_nat_pop') E8 = (`=job1534_migr_pop'/`=workAge1534_migr_pop') // Share of population with a job
	
	putexcel C9 = (`=econoAct1534_nat_pop'/`=workAge1534_nat_pop') E9 = (`=econoAct1534_migr_pop'/`=workAge1534_migr_pop') // Activity: Share participating in the labour force
	
	putexcel C10 = (`=inactive1534_nat_pop'/`=workAge1534_nat_pop') E10 = (`=inactive1534_migr_pop'/`=workAge1534_migr_pop')  // Economically inactive people
	
	putexcel C11 = (`=unemp1534_nat_pop'/`=econoActWorkAge1534_nat_pop') E11 = (`=unemp1534_migr_pop'/`=econoActWorkAge1534_migr_pop') // Unemployment: Share of population who were unemployed
	
	putexcel C12 = (`=long12_unemp1534_nat_pop'/`=inac_unemp1534_nat_pop') E12 = (`=long12_unemp1534_migr_pop'/`=inac_unemp1534_migr_pop') // Risk of labour market exclusion: long-term unemployment (12 month)
	
	putexcel C13 = (`=long6_unemp1534_nat_pop'/`=inac_unemp1534_nat_pop') E13 = (`=long6_unemp1534_migr_pop'/`=inac_unemp1534_migr_pop') // Risk of labour market exclusion: long-term unemployment (6 month)
	
	putexcel C14 = (`=long_invo1534_nat_pop'/`=inac_unemp1534_nat_pop') E14 = (`=long_invo1534_migr_pop'/`=inac_unemp1534_migr_pop') // Long-term uemployment >=12 months or inactive involuntary	
	
	putexcel C15 = (`=involuntary1534_nat_pop'/`=inac_unemp1534_nat_pop') E15 = (`=involuntary1534_migr_pop'/`=inac_unemp1534_migr_pop') // Inactive involuntary (available past week, not looking for job)
	
	putexcel C16 = (`=written1534_nat_pop'/`=noself_edu1534_nat_pop') E16 = (`=written1534_migr_pop'/`=noself_edu1534_migr_pop') // Share of population with written contract
	
	putexcel C17 = (`=informal1534_nat_pop'/`=job1534_nat_pop') E17 = (`=informal1534_migr_pop'/`=job1534_migr_pop') // Share of population with an informal job	
	
    // Share of population with an informal job (OECD def)
	
	putexcel C19 = (`=tempJob1534_nat_pop'/`=noself_edu1534_nat_pop') E19 = (`=tempJob1534_migr_pop'/`=noself_edu1534_migr_pop') // Types of contracts: Share of population in temporary contracts	

	putexcel C20 = (`=more50h1534_nat_pop'/`=hours1534_nat_pop') E20 = (`=more50h1534_migr_pop'/`=hours1534_migr_pop')  // Working hours: long (more than 50) hours
	
	putexcel C21 = (`=less30h1534_nat_pop'/`=hours1534_nat_pop') E21 = (`=less30h1534_migr_pop'/`=hours1534_migr_pop')  // Working hours: long (less than 30) hours	
	
	putexcel C22 = (`=highSkill1534_nat_pop'/`=NotMili1534_nat_pop') E22 = (`=highSkill1534_migr_pop'/`=NotMili1534_migr_pop') // Job skills: share of working population in highly skilled jobs
	
	putexcel C23 = (`=lowSkill1534_nat_pop'/`=NotMili1534_nat_pop') E23 = (`=lowSkill1534_migr_pop'/`=NotMili1534_migr_pop') // Job skills: share of working population in low-skilled jobs 
		
	putexcel C24 = (`=overquali1534_nat_pop'/`=NotEduNotMili1534_nat_pop') E24 = (`=overquali1534_migr_pop'/`=NotEduNotMili1534_migr_pop') // Overqualification: share of highly educated individuals who work in low- or medium-skilled jobs

	putexcel C25 = (`=selfEmp1534_nat_pop'/`=Notagri_emp1534_nat_pop') E25 = (`=selfEmp1534_migr_pop'/`=Notagri_emp1534_migr_pop')   // Self-employment: share of population who work in their own firms or businesses
	
	putexcel C26 = (`=pubSec1534_nat_pop'/`=NoSelf1534_nat_pop') E26 = (`=pubSec1534_migr_pop'/`=NoSelf1534_migr_pop')   // Employment in the public sector
	
	putexcel C27 = (`=nmwage1534_nat')  E27 = (`=nmwage1534_migr') // Nominal monthly wage (USD)
	
	
	** SIMPLE CHARACTERISTICS (15 - 34)
	
	putexcel C33 = (`=survey_nat_pop') E33 = (`=survey_migr_pop') // Total sample size: persons
	
	putexcel C34 = (`=survey_nat_1534') E34 = (`=survey_migr_1534') // Total sample size: persons 15-64
	
	putexcel C36 = (`=nat_pop') E36 = (`=migr_pop') // Total population (with sample loadings)
	
	putexcel C37 = (`=total_nat_1534') E37 = (`=total_migr_1534') // Total persons 15-64 (with sample loadings)
	
	
	** LABOUR MARKET INDICATORS FOR PEOPLE OF AGES FROM 35 TO 64
	
	putexcel D8 = (`=job3564_nat_pop'/`=workAge3564_nat_pop') F8 = (`=job3564_migr_pop'/`=workAge3564_migr_pop') // Share of population with a job
	
	putexcel D9 = (`=econoAct3564_nat_pop'/`=workAge3564_nat_pop') F9 = (`=econoAct3564_migr_pop'/`=workAge3564_migr_pop') // Activity: Share participating in the labour force
	
	putexcel D10 = (`=inactive3564_nat_pop'/`=workAge3564_nat_pop') F10 = (`=inactive3564_migr_pop'/`=workAge3564_migr_pop')  // Economically inactive people
	
	putexcel D11 = (`=unemp3564_nat_pop'/`=econoActWorkAge3564_nat_pop') F11 = (`=unemp3564_migr_pop'/`=econoActWorkAge3564_migr_pop') // Unemployment: Share of population who were unemployed
	
	putexcel D12 = (`=long12_unemp3564_nat_pop'/`=inac_unemp3564_nat_pop') F12 = (`=long12_unemp3564_migr_pop'/`=inac_unemp3564_migr_pop') // Risk of labour market exclusion: long-term unemployment (12 month)
	
	putexcel D13 = (`=long6_unemp3564_nat_pop'/`=inac_unemp3564_nat_pop') F13 = (`=long6_unemp3564_migr_pop'/`=inac_unemp3564_migr_pop') // Risk of labour market exclusion: long-term unemployment (6 month)
	
	putexcel D14 = (`=long_invo3564_nat_pop'/`=inac_unemp3564_nat_pop') F14 = (`=long_invo3564_migr_pop'/`=inac_unemp3564_migr_pop') // Long-term uemployment >=12 months or inactive involuntary	
	
	putexcel D15 = (`=involuntary3564_nat_pop'/`=inac_unemp3564_nat_pop') F15 = (`=involuntary3564_migr_pop'/`=inac_unemp3564_migr_pop') // Inactive involuntary (available past week, not looking for job)
	
	putexcel D16 = (`=written3564_nat_pop'/`=noself_edu3564_nat_pop') F16 = (`=written3564_migr_pop'/`=noself_edu3564_migr_pop') // Share of population with written contract
	
	putexcel D17 = (`=informal3564_nat_pop'/`=job3564_nat_pop') F17 = (`=informal3564_migr_pop'/`=job3564_migr_pop') // Share of population with an informal job	
	
    // Share of population with an informal job (OECD def)
	
	putexcel D19 = (`=tempJob3564_nat_pop'/`=noself_edu3564_nat_pop') F19 = (`=tempJob3564_migr_pop'/`=noself_edu3564_migr_pop') // Types of contracts: Share of population in temporary contracts	

	putexcel D20 = (`=more50h3564_nat_pop'/`=hours3564_nat_pop') F20 = (`=more50h3564_migr_pop'/`=hours3564_migr_pop')  // Working hours: long (more than 50) hours
	
	putexcel D21 = (`=less30h3564_nat_pop'/`=hours3564_nat_pop') F21 = (`=less30h3564_migr_pop'/`=hours3564_migr_pop')  // Working hours: long (less than 30) hours	
	
	putexcel D22 = (`=highSkill3564_nat_pop'/`=NotMili3564_nat_pop') F22 = (`=highSkill3564_migr_pop'/`=NotMili3564_migr_pop') // Job skills: share of working population in highly skilled jobs
	
	putexcel D23 = (`=lowSkill3564_nat_pop'/`=NotMili3564_nat_pop') F23 = (`=lowSkill3564_migr_pop'/`=NotMili3564_migr_pop') // Job skills: share of working population in low-skilled jobs 
		
	putexcel D24 = (`=overquali3564_nat_pop'/`=NotEduNotMili3564_nat_pop') F24 = (`=overquali3564_migr_pop'/`=NotEduNotMili3564_migr_pop') // Overqualification: share of highly educated individuals who work in low- or medium-skilled jobs

	putexcel D25 = (`=selfEmp3564_nat_pop'/`=Notagri_emp3564_nat_pop') F25 = (`=selfEmp3564_migr_pop'/`=Notagri_emp3564_migr_pop')   // Self-employment: share of population who work in their own firms or businesses
	
	putexcel D26 = (`=pubSec3564_nat_pop'/`=NoSelf3564_nat_pop') F26 = (`=pubSec3564_migr_pop'/`=NoSelf3564_migr_pop')   // Employment in the public sector
	
	putexcel D27 = (`=nmwage3564_nat')  F27 = (`=nmwage3564_migr') // Nominal monthly wage (USD)
	
	** SIMPLE CHARACTERISTICS (35 - 64)
	
	putexcel D34 = (`=survey_nat_3564') F34 = (`=survey_migr_3564') // Total sample size: persons 15-64
	
	putexcel D37 = (`=total_nat_3564') F37 = (`=total_migr_3564') // Total persons 15-64 (with sample loadings)

	
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
	sum uno if migrante_ci!=. & inrange(edad_ci,15,34) [fw=factor_ci]
	scalar tot_pop = `=r(N)'
	
	* Migrant population calculated according to expansion factor
	sum uno if migrante_ci==1 [fw=factor_ci]
	scalar migr_pop = `=r(N)'
	
	* Native population calculated according to expansion factor
	sum uno if migrante_ci==0 [fw=factor_ci]
	scalar nat_pop = `=r(N)'
	
	* Share of working age population (15-34)
	sum uno if inrange(edad_ci,15,34) & migrante_ci==1 [fw=factor_ci]
	scalar workAge1534_migr_pop = `=r(N)'
	sum uno if inrange(edad_ci,15,34) & migrante_ci==0 [fw=factor_ci]
	scalar workAge1534_nat_pop = `=r(N)'
	sum uno if inrange(edad_ci,15,34) [fw=factor_ci]
	scalar workAge1534_pop = `=r(N)'
		
	* Share of labour force population (15-34)
	sum uno if inrange(edad_ci,15,34) & pea_ci == 1 & migrante_ci==1 [fw=factor_ci]
	scalar econoAct1534_migr_pop = `=r(N)'
	sum uno if inrange(edad_ci,15,34) & pea_ci == 1 & migrante_ci==0 [fw=factor_ci]
	scalar econoAct1534_nat_pop = `=r(N)'
	sum uno if inrange(edad_ci,15,34) & pea_ci == 1 [fw=factor_ci]
	scalar econoAct1534_pop = `=r(N)'
	
	* Share of Employment rate  (15-34)
	sum uno if inrange(edad_ci,15,34) & emp_ci == 1 & migrante_ci==1 [fw=factor_ci]
	scalar emp1534_migr_pop = `=r(N)'
	sum uno if inrange(edad_ci,15,34) & emp_ci == 1 & migrante_ci==0 [fw=factor_ci]
	scalar emp1534_nat_pop = `=r(N)'
	sum uno if inrange(edad_ci,15,34) & emp_ci == 1 [fw=factor_ci]
	scalar emp1534_pop = `=r(N)'
	
	* Share of working age population (35-64)
	sum uno if inrange(edad_ci,35,64) & migrante_ci==1 [fw=factor_ci]
	scalar workAge3564_migr_pop = `=r(N)'
	sum uno if inrange(edad_ci,35,64) & migrante_ci==0 [fw=factor_ci]
	scalar workAge3564_nat_pop = `=r(N)'
	sum uno if inrange(edad_ci,35,64) [fw=factor_ci]
	scalar workAge3564_pop = `=r(N)'
		
	* Share of labour force population (35-64)
	sum uno if inrange(edad_ci,35,64) & pea_ci == 1 & migrante_ci==1 [fw=factor_ci]
	scalar econoAct3564_migr_pop = `=r(N)'
	sum uno if inrange(edad_ci,35,64) & pea_ci == 1 & migrante_ci==0 [fw=factor_ci]
	scalar econoAct3564_nat_pop = `=r(N)'
	sum uno if inrange(edad_ci,35,64) & pea_ci == 1 [fw=factor_ci]
	scalar econoAct3564_pop = `=r(N)'
	
	* Share of Employment rate  (35-64)
	sum uno if inrange(edad_ci,35,64) & emp_ci == 1 & migrante_ci==1 [fw=factor_ci]
	scalar emp_migr3564_pop = `=r(N)'
	sum uno if inrange(edad_ci,35,64) & emp_ci == 1 & migrante_ci==0 [fw=factor_ci]
	scalar emp_nat3564_pop = `=r(N)'
	sum uno if inrange(edad_ci,35,64) & emp_ci == 1 [fw=factor_ci]
	scalar emp3564_pop = `=r(N)'
	

	** CALCULATION OF INDICATORS BY MIGRANTS AND NATIVES
	
	foreach var in 1 0 {
		
		** LABOUR MARKET INDICATORS (BY AGE)
		
		************************************************************************
		** People of ages from 15 to 34
		
		* Share of population with a job (15-34)
		sum uno if inrange(edad_ci,15,34) & emp_ci==1 & migrante_ci==`var' [fw=factor_ci]
		scalar job1534_``var'_label'_pop = `=r(N)'
		
		* Activity: Share participating in the labour force (15-34)
		sum uno if inrange(edad_ci,15,34) & pea_ci==1 & migrante_ci==`var' [fw=factor_ci]
		scalar econoAct1534_``var'_label'_pop = `=r(N)'
		
		* Economically inactive people (15-34)
		sum uno if inrange(edad_ci,15,34) & (condocup_ci == 3) & migrante_ci==`var' [fw=factor_ci] 
		scalar inactive1534_``var'_label'_pop = `=r(N)'
		
		* Unemployment: Share of population who were unemployed (15-34)
		sum uno if inrange(edad_ci,15,34) & desemp_ci==1 & migrante_ci==`var' [fw=factor_ci] 
		scalar unemp1534_``var'_label'_pop = `=r(N)'
		
		sum uno if (pea_ci==1 | asiste_ci==1) & inrange(edad_ci,15,34) & migrante_ci==`var' [fw=factor_ci]
		scalar econoActWorkAge1534_``var'_label'_pop = `=r(N)'
		
		* Risk of labour market exclusion: long-term unemployment (12 months) (15-34)
		sum uno if inrange(edad_ci,15,34) & (more_12==1 & desemp_ci==1) & migrante_ci==`var' [fw=factor_ci]
		scalar long12_unemp1534_``var'_label'_pop = `=r(N)'
		
		sum uno if inrange(edad_ci,15,34) & (desemp_ci==1 | condocup_ci==3) & durades_ci!=. & migrante_ci==`var' [fw=factor_ci] 
		scalar inac_unemp1534_``var'_label'_pop = `=r(N)'
		
		* Risk of labour market exclusion: long-term unemployment (6 months) (15-34)
		sum uno if inrange(edad_ci,15,34) & (more_6==1 & desemp_ci==1) & migrante_ci==`var' [fw=factor_ci]
		scalar long6_unemp1534_``var'_label'_pop = `=r(N)'
		
		* Risk of labour market exclusion: long-term uemployment >=12 months or inactive involuntary (15-34)
		sum uno if inrange(edad_ci,15,34) & (desalent_ci==1 | (more_12==1 & desemp_ci==1)) & migrante_ci==`var' [fw=factor_ci]
		scalar long_invo1534_``var'_label'_pop = `=r(N)'
		
		* Risk of labour market exclusion: Inactive involuntary (available past week, not looking for job) (15-34)
		sum uno if inrange(edad_ci,15,34) & desalent_ci==1 & migrante_ci==`var' [fw=factor_ci]
		scalar involuntary1534_``var'_label'_pop = `=r(N)'
		
		* Share of population with written contract (15-34)
		sum uno if inrange(edad_ci,15,34) & inlist(tipocontrato_ci,0,1,2) & migrante_ci==`var' [fw=factor_ci]
		scalar written1534_``var'_label'_pop = `=r(N)'		
		
		* Share of population with an informal job (15-34)
		sum uno if inrange(edad_ci,15,34) & informal==1 & migrante_ci==`var' [fw=factor_ci]
		scalar informal1534_``var'_label'_pop = `=r(N)'
		
		* Types of contracts:  Share of population in temporary contracts (15-34)
		sum uno if inrange(edad_ci,15,34) & tipocontrato_ci==2 & migrante_ci==`var' [fw=factor_ci] 
		scalar tempJob1534_``var'_label'_pop = `=r(N)'
		
		sum uno if inrange(edad_ci,15,34) & categopri_ci!=2 & asiste_ci!=1 & emp_ci==1 & migrante_ci==`var' [fw=factor_ci]
		scalar noself_edu1534_``var'_label'_pop = `=r(N)'
		
		* Working hours: long hours >= 50 (15-34)
		sum uno if inrange(edad_ci,15,34) & more_50==1 & emp_ci == 1 & migrante_ci==`var' [fw=factor_ci]
		scalar more50h1534_``var'_label'_pop = `=r(N)'
		
		sum uno if inrange(edad_ci,15,34) & by_hours==1 & emp_ci == 1 & migrante_ci==`var' [fw=factor_ci]
		scalar hours1534_``var'_label'_pop = `=r(N)'	
	
		* Working hours: long hours < 30 (15-34)
		sum uno if inrange(edad_ci,15,34) & less_30==1 & emp_ci == 1 & migrante_ci==`var' [fw=factor_ci]
		scalar less30h1534_``var'_label'_pop = `=r(N)'

		* Job skills: share of working population in highly skilled jobs (15-34)
		sum uno if high_skilled==1 & inrange(edad_ci,15,34) & migrante_ci==`var' [fw=factor_ci]
		scalar highSkill1534_``var'_label'_pop = `=r(N)'		
		
		* Job skills: share of working population in low-skilled jobs (15-34)
		sum uno if low_skilled==1 & inrange(edad_ci,15,34) & migrante_ci==`var' [fw=factor_ci]
		scalar lowSkill1534_``var'_label'_pop = `=r(N)'
		
		sum uno if emp_ci==1 & inrange(edad_ci,15,34) & ISCO!=0 & migrante_ci==`var' [fw=factor_ci]
		scalar NotMili1534_``var'_label'_pop = `=r(N)'
		
		* Overqualification: share of highly educated individuals who work in low- or medium-skilled jobs (15-34)
		sum uno if overqualificated==1 & inrange(edad_ci,15,34) & migrante_ci==`var' & inrange(ISCED,4,9) [fw=factor_ci]
		scalar overquali1534_``var'_label'_pop = `=r(N)'
		
		sum uno if emp_ci==1 & inrange(edad_ci,15,34) & asiste_ci!=1 & ISCO!=0 & migrante_ci==`var' [fw=factor_ci]
		scalar NotEduNotMili1534_``var'_label'_pop = `=r(N)'
		
		* Self-employment: share of population who works in their own firms or businesses (15-34)
		sum uno if (categopri_ci==1 | categopri_ci==2) & inrange(edad_ci,15,34) & migrante_ci==`var' [fw=factor_ci]
		scalar selfEmp1534_``var'_label'_pop = `=r(N)'
		
		sum uno if inrange(edad_ci,15,34) & rama_ci!=1 & emp_ci==1 & migrante_ci==`var' [fw=factor_ci]
		scalar Notagri_emp1534_``var'_label'_pop = `=r(N)'
		
		* Employment in the public sector (15-34)
		sum uno if spublico_ci==1 & inrange(edad_ci,15,34) & migrante_ci==`var' [fw=factor_ci]
		scalar pubSec1534_``var'_label'_pop = `=r(N)'
		
		sum uno if inrange(edad_ci,15,34) & emp_ci==1 & categopri_ci!=2 & migrante_ci==`var' [fw=factor_ci]
		scalar NoSelf1534_``var'_label'_pop = `=r(N)'
		
		* Nominal monthly wage (USD) (15-34)
		sum nmwage if migrante_ci==`var' & inrange(edad_ci,15,34) [fw=factor_ci]
		scalar nmwage1534_``var'_label' = `=r(mean)'
		
		** SAMPLE CHARACTERISTICS
		
		* Total sample size: persons 
		sum uno if migrante_ci==`var'
		scalar survey_``var'_label'_pop = `=r(N)'
		
		* Total sample size: persons 15-34
		sum uno if inrange(edad_ci,15,34) & migrante_ci==`var'
		scalar survey_``var'_label'_1534 = `=r(N)'

		* Total persons 15-34 (with sample loadings)
		sum uno if inrange(edad_ci,15,34) & migrante_ci==`var' [fw=factor_ci]
		scalar total_``var'_label'_1534 = `=r(N)'
		
		************************************************************************
		** People of ages from 35 to 64
		
		* Share of population with a job (35-64)
		sum uno if inrange(edad_ci,35,64) & emp_ci==1 & migrante_ci==`var' [fw=factor_ci]
		scalar job3564_``var'_label'_pop = `=r(N)'
		
		* Activity: Share participating in the labour force (35-64)
		sum uno if inrange(edad_ci,35,64) & pea_ci==1 & migrante_ci==`var' [fw=factor_ci]
		scalar econoAct3564_``var'_label'_pop = `=r(N)'
		
		* Economically inactive people (35-64)
		sum uno if inrange(edad_ci,35,64) & (condocup_ci == 3) & migrante_ci==`var' [fw=factor_ci] 
		scalar inactive3564_``var'_label'_pop = `=r(N)'
		
		* Unemployment: Share of population who were unemployed (35-64)
		sum uno if inrange(edad_ci,35,64) & desemp_ci==1 & migrante_ci==`var' [fw=factor_ci] 
		scalar unemp3564_``var'_label'_pop = `=r(N)'
		
		sum uno if (pea_ci==1 | asiste_ci==1) & inrange(edad_ci,35,64) & migrante_ci==`var' [fw=factor_ci]
		scalar econoActWorkAge3564_``var'_label'_pop = `=r(N)'
		
		* Risk of labour market exclusion: long-term unemployment (12 months) (35-64)
		sum uno if inrange(edad_ci,35,64) & (more_12==1 & desemp_ci==1) & migrante_ci==`var' [fw=factor_ci]
		scalar long12_unemp3564_``var'_label'_pop = `=r(N)'
		
		sum uno if inrange(edad_ci,35,64) & (desemp_ci==1 | condocup_ci==3) & durades_ci!=. & migrante_ci==`var' [fw=factor_ci] 
		scalar inac_unemp3564_``var'_label'_pop = `=r(N)'
		
		* Risk of labour market exclusion: long-term unemployment (6 months) (35-64)
		sum uno if inrange(edad_ci,35,64) & (more_6==1 & desemp_ci==1) & migrante_ci==`var' [fw=factor_ci]
		scalar long6_unemp3564_``var'_label'_pop = `=r(N)'
		
		* Risk of labour market exclusion: long-term unemployment >=12 months or inactive involuntary (35-64)
		sum uno if inrange(edad_ci,35,64) & (desalent_ci==1 | (more_12==1 & desemp_ci==1)) & migrante_ci==`var' [fw=factor_ci]
		scalar long_invo3564_``var'_label'_pop = `=r(N)'
		
		* Risk of labour market exclusion: Inactive involuntary (available past week, not looking for job) (35-64)
		sum uno if inrange(edad_ci,35,64) & desalent_ci==1 & migrante_ci==`var' [fw=factor_ci]
		scalar involuntary3564_``var'_label'_pop = `=r(N)'
		
		* Share of population with written contract (35-64)
		sum uno if inrange(edad_ci,35,64) & inlist(tipocontrato_ci,0,1,2) & migrante_ci==`var' [fw=factor_ci]
		scalar written3564_``var'_label'_pop = `=r(N)'		
		
		* Share of population with an informal job (35-64)
		sum uno if inrange(edad_ci,35,64) & informal==1 & migrante_ci==`var' [fw=factor_ci]
		scalar informal3564_``var'_label'_pop = `=r(N)'
		
		* Types of contracts:  Share of population in temporary contracts (35-64)
		sum uno if inrange(edad_ci,35,64) & tipocontrato_ci==2 & migrante_ci==`var' [fw=factor_ci] 
		scalar tempJob3564_``var'_label'_pop = `=r(N)'
		
		sum uno if inrange(edad_ci,35,64) & categopri_ci!=2 & asiste_ci!=1 & emp_ci==1 & migrante_ci==`var' [fw=factor_ci]
		scalar noself_edu3564_``var'_label'_pop = `=r(N)'
		
		* Working hours: long hours >= 50 (35-64)
		sum uno if inrange(edad_ci,35,64) & more_50==1 & emp_ci == 1 & migrante_ci==`var' [fw=factor_ci]
		scalar more50h3564_``var'_label'_pop = `=r(N)'
		
		sum uno if inrange(edad_ci,35,64) & by_hours==1 & emp_ci == 1 & migrante_ci==`var' [fw=factor_ci]
		scalar hours3564_``var'_label'_pop = `=r(N)'	
	
		* Working hours: long hours < 30 (35-64)
		sum uno if inrange(edad_ci,35,64) & less_30==1 & emp_ci == 1 & migrante_ci==`var' [fw=factor_ci]
		scalar less30h3564_``var'_label'_pop = `=r(N)'

		* Job skills: share of working population in highly skilled jobs (35-64)
		sum uno if high_skilled==1 & inrange(edad_ci,35,64) & migrante_ci==`var' [fw=factor_ci]
		scalar highSkill3564_``var'_label'_pop = `=r(N)'		
		
		* Job skills: share of working population in low-skilled jobs (35-64)
		sum uno if low_skilled==1 & inrange(edad_ci,35,64) & migrante_ci==`var' [fw=factor_ci]
		scalar lowSkill3564_``var'_label'_pop = `=r(N)'
		
		sum uno if emp_ci==1 & inrange(edad_ci,35,64) & ISCO!=0 & migrante_ci==`var' [fw=factor_ci]
		scalar NotMili3564_``var'_label'_pop = `=r(N)'
		
		* Overqualification: share of highly educated individuals who work in low- or medium-skilled jobs (35-64)
		sum uno if overqualificated==1 & inrange(edad_ci,35,64) & migrante_ci==`var' & inrange(ISCED,4,9) [fw=factor_ci]
		scalar overquali3564_``var'_label'_pop = `=r(N)'
		
		sum uno if emp_ci==1 & inrange(edad_ci,35,64) & asiste_ci!=1 & ISCO!=0 & migrante_ci==`var' [fw=factor_ci]
		scalar NotEduNotMili3564_``var'_label'_pop = `=r(N)'
		
		* Self-employment: share of population who works in their own firms or businesses (35-64)
		sum uno if (categopri_ci==1 | categopri_ci==2) & inrange(edad_ci,35,64) & migrante_ci==`var' [fw=factor_ci]
		scalar selfEmp3564_``var'_label'_pop = `=r(N)'
		
		sum uno if inrange(edad_ci,35,64) & rama_ci!=1 & emp_ci==1 & migrante_ci==`var' [fw=factor_ci]
		scalar Notagri_emp3564_``var'_label'_pop = `=r(N)'
		
		* Employment in the public sector (35-64)
		sum uno if spublico_ci==1 & inrange(edad_ci,35,64) & migrante_ci==`var' [fw=factor_ci]
		scalar pubSec3564_``var'_label'_pop = `=r(N)'
		
		sum uno if inrange(edad_ci,35,64) & emp_ci==1 & categopri_ci!=2 & migrante_ci==`var' [fw=factor_ci]
		scalar NoSelf3564_``var'_label'_pop = `=r(N)'
		
		* Nominal monthly wage (USD) (35-64)
		sum nmwage if migrante_ci==`var' & inrange(edad_ci,35,64) [fw=factor_ci]
		scalar nmwage3564_``var'_label' = `=r(mean)'
		
		** SAMPLE CHARACTERISTICS
		
		* Total sample size: persons 35-64
		sum uno if inrange(edad_ci,35,64) & migrante_ci==`var'
		scalar survey_``var'_label'_3564 = `=r(N)'

		* Total persons 35-64 (with sample loadings)
		sum uno if inrange(edad_ci,35,64) & migrante_ci==`var' [fw=factor_ci]
		scalar total_``var'_label'_3564 = `=r(N)'
		
	}
	
******************************************************** EXCEL OUTPUTS

	putexcel set "C:\Users\jcamilop\OneDrive - Inter-American Development Bank Group\OECD\03 Outputs\Resultados por edad.xlsx", sheet("Paraguay") modify
	putexcel describe
	
	
	** LABOUR MARKET INDICATORS FOR PEOPLE OF AGES FROM 15 TO 34
	
	putexcel C8 = (`=job1534_nat_pop'/`=workAge1534_nat_pop') E8 = (`=job1534_migr_pop'/`=workAge1534_migr_pop') // Share of population with a job
	
	putexcel C9 = (`=econoAct1534_nat_pop'/`=workAge1534_nat_pop') E9 = (`=econoAct1534_migr_pop'/`=workAge1534_migr_pop') // Activity: Share participating in the labour force
	
	putexcel C10 = (`=inactive1534_nat_pop'/`=workAge1534_nat_pop') E10 = (`=inactive1534_migr_pop'/`=workAge1534_migr_pop')  // Economically inactive people
	
	putexcel C11 = (`=unemp1534_nat_pop'/`=econoActWorkAge1534_nat_pop') E11 = (`=unemp1534_migr_pop'/`=econoActWorkAge1534_migr_pop') // Unemployment: Share of population who were unemployed
	
	putexcel C12 = (`=long12_unemp1534_nat_pop'/`=inac_unemp1534_nat_pop') E12 = (`=long12_unemp1534_migr_pop'/`=inac_unemp1534_migr_pop') // Risk of labour market exclusion: long-term unemployment (12 month)
	
	putexcel C13 = (`=long6_unemp1534_nat_pop'/`=inac_unemp1534_nat_pop') E13 = (`=long6_unemp1534_migr_pop'/`=inac_unemp1534_migr_pop') // Risk of labour market exclusion: long-term unemployment (6 month)
	
	putexcel C14 = (`=long_invo1534_nat_pop'/`=inac_unemp1534_nat_pop') E14 = (`=long_invo1534_migr_pop'/`=inac_unemp1534_migr_pop') // Long-term uemployment >=12 months or inactive involuntary	
	
	putexcel C15 = (`=involuntary1534_nat_pop'/`=inac_unemp1534_nat_pop') E15 = (`=involuntary1534_migr_pop'/`=inac_unemp1534_migr_pop') // Inactive involuntary (available past week, not looking for job)
	
	putexcel C16 = (`=written1534_nat_pop'/`=noself_edu1534_nat_pop') E16 = (`=written1534_migr_pop'/`=noself_edu1534_migr_pop') // Share of population with written contract
	
	putexcel C17 = (`=informal1534_nat_pop'/`=job1534_nat_pop') E17 = (`=informal1534_migr_pop'/`=job1534_migr_pop') // Share of population with an informal job	
	
    // Share of population with an informal job (OECD def)
	
	putexcel C19 = (`=tempJob1534_nat_pop'/`=noself_edu1534_nat_pop') E19 = (`=tempJob1534_migr_pop'/`=noself_edu1534_migr_pop') // Types of contracts: Share of population in temporary contracts	

	putexcel C20 = (`=more50h1534_nat_pop'/`=hours1534_nat_pop') E20 = (`=more50h1534_migr_pop'/`=hours1534_migr_pop')  // Working hours: long (more than 50) hours
	
	putexcel C21 = (`=less30h1534_nat_pop'/`=hours1534_nat_pop') E21 = (`=less30h1534_migr_pop'/`=hours1534_migr_pop')  // Working hours: long (less than 30) hours	
	
	putexcel C22 = (`=highSkill1534_nat_pop'/`=NotMili1534_nat_pop') E22 = (`=highSkill1534_migr_pop'/`=NotMili1534_migr_pop') // Job skills: share of working population in highly skilled jobs
	
	putexcel C23 = (`=lowSkill1534_nat_pop'/`=NotMili1534_nat_pop') E23 = (`=lowSkill1534_migr_pop'/`=NotMili1534_migr_pop') // Job skills: share of working population in low-skilled jobs 
		
	putexcel C24 = (`=overquali1534_nat_pop'/`=NotEduNotMili1534_nat_pop') E24 = (`=overquali1534_migr_pop'/`=NotEduNotMili1534_migr_pop') // Overqualification: share of highly educated individuals who work in low- or medium-skilled jobs

	putexcel C25 = (`=selfEmp1534_nat_pop'/`=Notagri_emp1534_nat_pop') E25 = (`=selfEmp1534_migr_pop'/`=Notagri_emp1534_migr_pop')   // Self-employment: share of population who work in their own firms or businesses
	
	putexcel C26 = (`=pubSec1534_nat_pop'/`=NoSelf1534_nat_pop') E26 = (`=pubSec1534_migr_pop'/`=NoSelf1534_migr_pop')   // Employment in the public sector
	
	putexcel C27 = (`=nmwage1534_nat')  E27 = (`=nmwage1534_migr') // Nominal monthly wage (USD)
	
	
	** SIMPLE CHARACTERISTICS (15 - 34)
	
	putexcel C33 = (`=survey_nat_pop') E33 = (`=survey_migr_pop') // Total sample size: persons
	
	putexcel C34 = (`=survey_nat_1534') E34 = (`=survey_migr_1534') // Total sample size: persons 15-64
	
	putexcel C36 = (`=nat_pop') E36 = (`=migr_pop') // Total population (with sample loadings)
	
	putexcel C37 = (`=total_nat_1534') E37 = (`=total_migr_1534') // Total persons 15-64 (with sample loadings)
	
	
	** LABOUR MARKET INDICATORS FOR PEOPLE OF AGES FROM 35 TO 64
	
	putexcel D8 = (`=job3564_nat_pop'/`=workAge3564_nat_pop') F8 = (`=job3564_migr_pop'/`=workAge3564_migr_pop') // Share of population with a job
	
	putexcel D9 = (`=econoAct3564_nat_pop'/`=workAge3564_nat_pop') F9 = (`=econoAct3564_migr_pop'/`=workAge3564_migr_pop') // Activity: Share participating in the labour force
	
	putexcel D10 = (`=inactive3564_nat_pop'/`=workAge3564_nat_pop') F10 = (`=inactive3564_migr_pop'/`=workAge3564_migr_pop')  // Economically inactive people
	
	putexcel D11 = (`=unemp3564_nat_pop'/`=econoActWorkAge3564_nat_pop') F11 = (`=unemp3564_migr_pop'/`=econoActWorkAge3564_migr_pop') // Unemployment: Share of population who were unemployed
	
	putexcel D12 = (`=long12_unemp3564_nat_pop'/`=inac_unemp3564_nat_pop') F12 = (`=long12_unemp3564_migr_pop'/`=inac_unemp3564_migr_pop') // Risk of labour market exclusion: long-term unemployment (12 month)
	
	putexcel D13 = (`=long6_unemp3564_nat_pop'/`=inac_unemp3564_nat_pop') F13 = (`=long6_unemp3564_migr_pop'/`=inac_unemp3564_migr_pop') // Risk of labour market exclusion: long-term unemployment (6 month)
	
	putexcel D14 = (`=long_invo3564_nat_pop'/`=inac_unemp3564_nat_pop') F14 = (`=long_invo3564_migr_pop'/`=inac_unemp3564_migr_pop') // Long-term uemployment >=12 months or inactive involuntary	
	
	putexcel D15 = (`=involuntary3564_nat_pop'/`=inac_unemp3564_nat_pop') F15 = (`=involuntary3564_migr_pop'/`=inac_unemp3564_migr_pop') // Inactive involuntary (available past week, not looking for job)
	
	putexcel D16 = (`=written3564_nat_pop'/`=noself_edu3564_nat_pop') F16 = (`=written3564_migr_pop'/`=noself_edu3564_migr_pop') // Share of population with written contract
	
	putexcel D17 = (`=informal3564_nat_pop'/`=job3564_nat_pop') F17 = (`=informal3564_migr_pop'/`=job3564_migr_pop') // Share of population with an informal job	
	
    // Share of population with an informal job (OECD def)
	
	putexcel D19 = (`=tempJob3564_nat_pop'/`=noself_edu3564_nat_pop') F19 = (`=tempJob3564_migr_pop'/`=noself_edu3564_migr_pop') // Types of contracts: Share of population in temporary contracts	

	putexcel D20 = (`=more50h3564_nat_pop'/`=hours3564_nat_pop') F20 = (`=more50h3564_migr_pop'/`=hours3564_migr_pop')  // Working hours: long (more than 50) hours
	
	putexcel D21 = (`=less30h3564_nat_pop'/`=hours3564_nat_pop') F21 = (`=less30h3564_migr_pop'/`=hours3564_migr_pop')  // Working hours: long (less than 30) hours	
	
	putexcel D22 = (`=highSkill3564_nat_pop'/`=NotMili3564_nat_pop') F22 = (`=highSkill3564_migr_pop'/`=NotMili3564_migr_pop') // Job skills: share of working population in highly skilled jobs
	
	putexcel D23 = (`=lowSkill3564_nat_pop'/`=NotMili3564_nat_pop') F23 = (`=lowSkill3564_migr_pop'/`=NotMili3564_migr_pop') // Job skills: share of working population in low-skilled jobs 
		
	putexcel D24 = (`=overquali3564_nat_pop'/`=NotEduNotMili3564_nat_pop') F24 = (`=overquali3564_migr_pop'/`=NotEduNotMili3564_migr_pop') // Overqualification: share of highly educated individuals who work in low- or medium-skilled jobs

	putexcel D25 = (`=selfEmp3564_nat_pop'/`=Notagri_emp3564_nat_pop') F25 = (`=selfEmp3564_migr_pop'/`=Notagri_emp3564_migr_pop')   // Self-employment: share of population who work in their own firms or businesses
	
	putexcel D26 = (`=pubSec3564_nat_pop'/`=NoSelf3564_nat_pop') F26 = (`=pubSec3564_migr_pop'/`=NoSelf3564_migr_pop')   // Employment in the public sector
	
	putexcel D27 = (`=nmwage3564_nat')  F27 = (`=nmwage3564_migr') // Nominal monthly wage (USD)
	
	** SIMPLE CHARACTERISTICS (35 - 64)
	
	putexcel D34 = (`=survey_nat_3564') F34 = (`=survey_migr_3564') // Total sample size: persons 15-64
	
	putexcel D37 = (`=total_nat_3564') F37 = (`=total_migr_3564') // Total persons 15-64 (with sample loadings)
	
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
	
	****************************************************************************
	** Living conditions: Number of rooms needed

	* # of adults and children per household
	gen adult=1 if edad_ci>=18
	replace adult=0 if edad_ci<18 & !mi(edad_ci)
	bys idh_ch:	egen adult_hh=total(adult)
	gen child=1 if edad_ci<18
	replace child=0 if edad_ci>=18 & !mi(edad_ci)
	bys idh_ch:	egen child_hh=total(child)

	* presence of a couple in the household
	bys  idh_ch:egen couple=sum((cond((relacion_ci==2),1,0))/2)

	* number of rooms needed
	rename dorm_ch room
	gen livingroom=1 // 1 living room is neede for all hh
	gen room_child=ceil(child_hh/2) // 1 room for every two additional children
	gen room_adult=ceil(adult_hh/2) // 1 room for every two additional adults
	replace room_adult=room_adult+1 if couple==0 & adult_hh>=2 // if there is no couple in hh, first two adults have their own room
	gen room_need = livingroom+room_child+room_adult

	* overcrowded dwelling
	gen over=0
	replace over=1 if room+1<room_need
	replace over=. if room==.
	la var 	over "overcrowded dwelling"
	
	****************************************************************************
	** Household income
	
	* Total household income
	egen totIncome=rowtotal(ylm_ch ylnm_ch ynlm_ch rentaimp_ch remesas_ch)
	
	*adjust income to 2020 USD PPP
	gen disp_income=totIncome/1.80
	
	* disposable equivalised income
	gen disp_equi_income=disp_income/sqrt(nmiembros_ch)
	
	* disposable income - distribution
	xtile inc_dec=disp_equi_income if edad_ci>15, n(10)
	
	* disposable equivalised income - median 
	egen med_income=max(disp_equi_income) if inc_dec==5
	egen med_inc=max(med_income)
	drop med_income

	* dummy for the lowest decile
	gen low_dec=(inc_dec==1)
	replace low_dec=. if inc_dec==.

	* dummy for the highest decile
	gen high_dec=(inc_dec==10)
	replace high_dec=. if inc_dec==.
	
	****************************************************************************
	** Poverty rate
	gen poverty=0
	replace poverty=1 if disp_equi_income<0.6*med_inc
	replace poverty=. if disp_equi_income==.|med_inc==.
	
	****************************************************************************
	**Living conditions: deprived
	gen toilet_depr=(!inlist(p111,1,2,3))
	gen water_depr=(aguared_ch!=1)
	gen fuel_depr=(combust_ch!=1)
	egen depr = rowtotal(toilet_depr water_depr fuel_depr)
		
********************************************************************* STATISTICS
********************************************************************************
********************************************************************************

	** CALCULATION OF INDICATORS
	
	** POPULATION
	
	* Total population calculated according to expansion factor
	sum uno if migrante_ci!=. & inrange(edad_ci,15,34) [fw=factor_ci]
	scalar tot_pop = `=r(N)'
	
	* Migrant population calculated according to expansion factor
	sum uno if migrante_ci==1 [fw=factor_ci]
	scalar migr_pop = `=r(N)'
	
	* Native population calculated according to expansion factor
	sum uno if migrante_ci==0 [fw=factor_ci]
	scalar nat_pop = `=r(N)'
	
	* Share of working age population (15-34)
	sum uno if inrange(edad_ci,15,34) & migrante_ci==1 [fw=factor_ci]
	scalar workAge1534_migr_pop = `=r(N)'
	sum uno if inrange(edad_ci,15,34) & migrante_ci==0 [fw=factor_ci]
	scalar workAge1534_nat_pop = `=r(N)'
	sum uno if inrange(edad_ci,15,34) [fw=factor_ci]
	scalar workAge1534_pop = `=r(N)'
		
	* Share of labour force population (15-34)
	sum uno if inrange(edad_ci,15,34) & pea_ci == 1 & migrante_ci==1 [fw=factor_ci]
	scalar econoAct1534_migr_pop = `=r(N)'
	sum uno if inrange(edad_ci,15,34) & pea_ci == 1 & migrante_ci==0 [fw=factor_ci]
	scalar econoAct1534_nat_pop = `=r(N)'
	sum uno if inrange(edad_ci,15,34) & pea_ci == 1 [fw=factor_ci]
	scalar econoAct1534_pop = `=r(N)'
	
	* Share of Employment rate  (15-34)
	sum uno if inrange(edad_ci,15,34) & emp_ci == 1 & migrante_ci==1 [fw=factor_ci]
	scalar emp1534_migr_pop = `=r(N)'
	sum uno if inrange(edad_ci,15,34) & emp_ci == 1 & migrante_ci==0 [fw=factor_ci]
	scalar emp1534_nat_pop = `=r(N)'
	sum uno if inrange(edad_ci,15,34) & emp_ci == 1 [fw=factor_ci]
	scalar emp1534_pop = `=r(N)'
	
	* Share of working age population (35-64)
	sum uno if inrange(edad_ci,35,64) & migrante_ci==1 [fw=factor_ci]
	scalar workAge3564_migr_pop = `=r(N)'
	sum uno if inrange(edad_ci,35,64) & migrante_ci==0 [fw=factor_ci]
	scalar workAge3564_nat_pop = `=r(N)'
	sum uno if inrange(edad_ci,35,64) [fw=factor_ci]
	scalar workAge3564_pop = `=r(N)'
		
	* Share of labour force population (35-64)
	sum uno if inrange(edad_ci,35,64) & pea_ci == 1 & migrante_ci==1 [fw=factor_ci]
	scalar econoAct3564_migr_pop = `=r(N)'
	sum uno if inrange(edad_ci,35,64) & pea_ci == 1 & migrante_ci==0 [fw=factor_ci]
	scalar econoAct3564_nat_pop = `=r(N)'
	sum uno if inrange(edad_ci,35,64) & pea_ci == 1 [fw=factor_ci]
	scalar econoAct3564_pop = `=r(N)'
	
	* Share of Employment rate  (35-64)
	sum uno if inrange(edad_ci,35,64) & emp_ci == 1 & migrante_ci==1 [fw=factor_ci]
	scalar emp_migr3564_pop = `=r(N)'
	sum uno if inrange(edad_ci,35,64) & emp_ci == 1 & migrante_ci==0 [fw=factor_ci]
	scalar emp_nat3564_pop = `=r(N)'
	sum uno if inrange(edad_ci,35,64) & emp_ci == 1 [fw=factor_ci]
	scalar emp3564_pop = `=r(N)'
	

	** CALCULATION OF INDICATORS BY MIGRANTS AND NATIVES
	
	foreach var in 1 0 {
		
		** LABOUR MARKET INDICATORS (BY AGE)
		
		************************************************************************
		** People of ages from 15 to 34
		
		* Share of population with a job (15-34)
		sum uno if inrange(edad_ci,15,34) & emp_ci==1 & migrante_ci==`var' [fw=factor_ci]
		scalar job1534_``var'_label'_pop = `=r(N)'
		
		* Activity: Share participating in the labour force (15-34)
		sum uno if inrange(edad_ci,15,34) & pea_ci==1 & migrante_ci==`var' [fw=factor_ci]
		scalar econoAct1534_``var'_label'_pop = `=r(N)'
		
		* Economically inactive people (15-34)
		sum uno if inrange(edad_ci,15,34) & (condocup_ci == 3) & migrante_ci==`var' [fw=factor_ci] 
		scalar inactive1534_``var'_label'_pop = `=r(N)'
		
		* Unemployment: Share of population who were unemployed (15-34)
		sum uno if inrange(edad_ci,15,34) & desemp_ci==1 & migrante_ci==`var' [fw=factor_ci] 
		scalar unemp1534_``var'_label'_pop = `=r(N)'
		
		sum uno if (pea_ci==1 | asiste_ci==1) & inrange(edad_ci,15,34) & migrante_ci==`var' [fw=factor_ci]
		scalar econoActWorkAge1534_``var'_label'_pop = `=r(N)'
		
		* Risk of labour market exclusion: long-term unemployment (12 months) (15-34)
		sum uno if inrange(edad_ci,15,34) & (more_12==1 & desemp_ci==1) & migrante_ci==`var' [fw=factor_ci]
		scalar long12_unemp1534_``var'_label'_pop = `=r(N)'
		
		sum uno if inrange(edad_ci,15,34) & (desemp_ci==1 | condocup_ci==3) & durades_ci!=. & migrante_ci==`var' [fw=factor_ci] 
		scalar inac_unemp1534_``var'_label'_pop = `=r(N)'
		
		* Risk of labour market exclusion: long-term unemployment (6 months) (15-34)
		sum uno if inrange(edad_ci,15,34) & (more_6==1 & desemp_ci==1) & migrante_ci==`var' [fw=factor_ci]
		scalar long6_unemp1534_``var'_label'_pop = `=r(N)'
		
		* Risk of labour market exclusion: long-term uemployment >=12 months or inactive involuntary (15-34)
		sum uno if inrange(edad_ci,15,34) & (desalent_ci==1 | (more_12==1 & desemp_ci==1)) & migrante_ci==`var' [fw=factor_ci]
		scalar long_invo1534_``var'_label'_pop = `=r(N)'
		
		* Risk of labour market exclusion: Inactive involuntary (available past week, not looking for job) (15-34)
		sum uno if inrange(edad_ci,15,34) & desalent_ci==1 & migrante_ci==`var' [fw=factor_ci]
		scalar involuntary1534_``var'_label'_pop = `=r(N)'
		
		* Share of population with written contract (15-34)
		sum uno if inrange(edad_ci,15,34) & inlist(tipocontrato_ci,0,1,2) & migrante_ci==`var' [fw=factor_ci]
		scalar written1534_``var'_label'_pop = `=r(N)'		
		
		* Share of population with an informal job (15-34)
		sum uno if inrange(edad_ci,15,34) & informal==1 & migrante_ci==`var' [fw=factor_ci]
		scalar informal1534_``var'_label'_pop = `=r(N)'
		
		* Types of contracts:  Share of population in temporary contracts (15-34)
		sum uno if inrange(edad_ci,15,34) & tipocontrato_ci==2 & migrante_ci==`var' [fw=factor_ci] 
		scalar tempJob1534_``var'_label'_pop = `=r(N)'
		
		sum uno if inrange(edad_ci,15,34) & categopri_ci!=2 & asiste_ci!=1 & emp_ci==1 & migrante_ci==`var' [fw=factor_ci]
		scalar noself_edu1534_``var'_label'_pop = `=r(N)'
		
		* Working hours: long hours >= 50 (15-34)
		sum uno if inrange(edad_ci,15,34) & more_50==1 & emp_ci == 1 & migrante_ci==`var' [fw=factor_ci]
		scalar more50h1534_``var'_label'_pop = `=r(N)'
		
		sum uno if inrange(edad_ci,15,34) & by_hours==1 & emp_ci == 1 & migrante_ci==`var' [fw=factor_ci]
		scalar hours1534_``var'_label'_pop = `=r(N)'	
	
		* Working hours: long hours < 30 (15-34)
		sum uno if inrange(edad_ci,15,34) & less_30==1 & emp_ci == 1 & migrante_ci==`var' [fw=factor_ci]
		scalar less30h1534_``var'_label'_pop = `=r(N)'

		* Job skills: share of working population in highly skilled jobs (15-34)
		sum uno if high_skilled==1 & inrange(edad_ci,15,34) & migrante_ci==`var' [fw=factor_ci]
		scalar highSkill1534_``var'_label'_pop = `=r(N)'		
		
		* Job skills: share of working population in low-skilled jobs (15-34)
		sum uno if low_skilled==1 & inrange(edad_ci,15,34) & migrante_ci==`var' [fw=factor_ci]
		scalar lowSkill1534_``var'_label'_pop = `=r(N)'
		
		sum uno if emp_ci==1 & inrange(edad_ci,15,34) & ISCO!=0 & migrante_ci==`var' [fw=factor_ci]
		scalar NotMili1534_``var'_label'_pop = `=r(N)'
		
		* Overqualification: share of highly educated individuals who work in low- or medium-skilled jobs (15-34)
		sum uno if overqualificated==1 & inrange(edad_ci,15,34) & migrante_ci==`var' & inrange(ISCED,4,9) [fw=factor_ci]
		scalar overquali1534_``var'_label'_pop = `=r(N)'
		
		sum uno if emp_ci==1 & inrange(edad_ci,15,34) & asiste_ci!=1 & ISCO!=0 & migrante_ci==`var' [fw=factor_ci]
		scalar NotEduNotMili1534_``var'_label'_pop = `=r(N)'
		
		* Self-employment: share of population who works in their own firms or businesses (15-34)
		sum uno if (categopri_ci==1 | categopri_ci==2) & inrange(edad_ci,15,34) & migrante_ci==`var' [fw=factor_ci]
		scalar selfEmp1534_``var'_label'_pop = `=r(N)'
		
		sum uno if inrange(edad_ci,15,34) & rama_ci!=1 & emp_ci==1 & migrante_ci==`var' [fw=factor_ci]
		scalar Notagri_emp1534_``var'_label'_pop = `=r(N)'
		
		* Employment in the public sector (15-34)
		sum uno if spublico_ci==1 & inrange(edad_ci,15,34) & migrante_ci==`var' [fw=factor_ci]
		scalar pubSec1534_``var'_label'_pop = `=r(N)'
		
		sum uno if inrange(edad_ci,15,34) & emp_ci==1 & categopri_ci!=2 & migrante_ci==`var' [fw=factor_ci]
		scalar NoSelf1534_``var'_label'_pop = `=r(N)'
		
		* Nominal monthly wage (USD) (15-34)
		sum nmwage if migrante_ci==`var' & inrange(edad_ci,15,34) [fw=factor_ci]
		scalar nmwage1534_``var'_label' = `=r(mean)'
		
		** SAMPLE CHARACTERISTICS
		
		* Total sample size: persons 
		sum uno if migrante_ci==`var'
		scalar survey_``var'_label'_pop = `=r(N)'
		
		* Total sample size: persons 15-34
		sum uno if inrange(edad_ci,15,34) & migrante_ci==`var'
		scalar survey_``var'_label'_1534 = `=r(N)'

		* Total persons 15-34 (with sample loadings)
		sum uno if inrange(edad_ci,15,34) & migrante_ci==`var' [fw=factor_ci]
		scalar total_``var'_label'_1534 = `=r(N)'
		
		************************************************************************
		** People of ages from 35 to 64
		
		* Share of population with a job (35-64)
		sum uno if inrange(edad_ci,35,64) & emp_ci==1 & migrante_ci==`var' [fw=factor_ci]
		scalar job3564_``var'_label'_pop = `=r(N)'
		
		* Activity: Share participating in the labour force (35-64)
		sum uno if inrange(edad_ci,35,64) & pea_ci==1 & migrante_ci==`var' [fw=factor_ci]
		scalar econoAct3564_``var'_label'_pop = `=r(N)'
		
		* Economically inactive people (35-64)
		sum uno if inrange(edad_ci,35,64) & (condocup_ci == 3) & migrante_ci==`var' [fw=factor_ci] 
		scalar inactive3564_``var'_label'_pop = `=r(N)'
		
		* Unemployment: Share of population who were unemployed (35-64)
		sum uno if inrange(edad_ci,35,64) & desemp_ci==1 & migrante_ci==`var' [fw=factor_ci] 
		scalar unemp3564_``var'_label'_pop = `=r(N)'
		
		sum uno if (pea_ci==1 | asiste_ci==1) & inrange(edad_ci,35,64) & migrante_ci==`var' [fw=factor_ci]
		scalar econoActWorkAge3564_``var'_label'_pop = `=r(N)'
		
		* Risk of labour market exclusion: long-term unemployment (12 months) (35-64)
		sum uno if inrange(edad_ci,35,64) & (more_12==1 & desemp_ci==1) & migrante_ci==`var' [fw=factor_ci]
		scalar long12_unemp3564_``var'_label'_pop = `=r(N)'
		
		sum uno if inrange(edad_ci,35,64) & (desemp_ci==1 | condocup_ci==3) & durades_ci!=. & migrante_ci==`var' [fw=factor_ci] 
		scalar inac_unemp3564_``var'_label'_pop = `=r(N)'
		
		* Risk of labour market exclusion: long-term unemployment (6 months) (35-64)
		sum uno if inrange(edad_ci,35,64) & (more_6==1 & desemp_ci==1) & migrante_ci==`var' [fw=factor_ci]
		scalar long6_unemp3564_``var'_label'_pop = `=r(N)'
		
		* Risk of labour market exclusion: long-term unemployment >=12 months or inactive involuntary (35-64)
		sum uno if inrange(edad_ci,35,64) & (desalent_ci==1 | (more_12==1 & desemp_ci==1)) & migrante_ci==`var' [fw=factor_ci]
		scalar long_invo3564_``var'_label'_pop = `=r(N)'
		
		* Risk of labour market exclusion: Inactive involuntary (available past week, not looking for job) (35-64)
		sum uno if inrange(edad_ci,35,64) & desalent_ci==1 & migrante_ci==`var' [fw=factor_ci]
		scalar involuntary3564_``var'_label'_pop = `=r(N)'
		
		* Share of population with written contract (35-64)
		sum uno if inrange(edad_ci,35,64) & inlist(tipocontrato_ci,0,1,2) & migrante_ci==`var' [fw=factor_ci]
		scalar written3564_``var'_label'_pop = `=r(N)'		
		
		* Share of population with an informal job (35-64)
		sum uno if inrange(edad_ci,35,64) & informal==1 & migrante_ci==`var' [fw=factor_ci]
		scalar informal3564_``var'_label'_pop = `=r(N)'
		
		* Types of contracts:  Share of population in temporary contracts (35-64)
		sum uno if inrange(edad_ci,35,64) & tipocontrato_ci==2 & migrante_ci==`var' [fw=factor_ci] 
		scalar tempJob3564_``var'_label'_pop = `=r(N)'
		
		sum uno if inrange(edad_ci,35,64) & categopri_ci!=2 & asiste_ci!=1 & emp_ci==1 & migrante_ci==`var' [fw=factor_ci]
		scalar noself_edu3564_``var'_label'_pop = `=r(N)'
		
		* Working hours: long hours >= 50 (35-64)
		sum uno if inrange(edad_ci,35,64) & more_50==1 & emp_ci == 1 & migrante_ci==`var' [fw=factor_ci]
		scalar more50h3564_``var'_label'_pop = `=r(N)'
		
		sum uno if inrange(edad_ci,35,64) & by_hours==1 & emp_ci == 1 & migrante_ci==`var' [fw=factor_ci]
		scalar hours3564_``var'_label'_pop = `=r(N)'	
	
		* Working hours: long hours < 30 (35-64)
		sum uno if inrange(edad_ci,35,64) & less_30==1 & emp_ci == 1 & migrante_ci==`var' [fw=factor_ci]
		scalar less30h3564_``var'_label'_pop = `=r(N)'

		* Job skills: share of working population in highly skilled jobs (35-64)
		sum uno if high_skilled==1 & inrange(edad_ci,35,64) & migrante_ci==`var' [fw=factor_ci]
		scalar highSkill3564_``var'_label'_pop = `=r(N)'		
		
		* Job skills: share of working population in low-skilled jobs (35-64)
		sum uno if low_skilled==1 & inrange(edad_ci,35,64) & migrante_ci==`var' [fw=factor_ci]
		scalar lowSkill3564_``var'_label'_pop = `=r(N)'
		
		sum uno if emp_ci==1 & inrange(edad_ci,35,64) & ISCO!=0 & migrante_ci==`var' [fw=factor_ci]
		scalar NotMili3564_``var'_label'_pop = `=r(N)'
		
		* Overqualification: share of highly educated individuals who work in low- or medium-skilled jobs (35-64)
		sum uno if overqualificated==1 & inrange(edad_ci,35,64) & migrante_ci==`var' & inrange(ISCED,4,9) [fw=factor_ci]
		scalar overquali3564_``var'_label'_pop = `=r(N)'
		
		sum uno if emp_ci==1 & inrange(edad_ci,35,64) & asiste_ci!=1 & ISCO!=0 & migrante_ci==`var' [fw=factor_ci]
		scalar NotEduNotMili3564_``var'_label'_pop = `=r(N)'
		
		* Self-employment: share of population who works in their own firms or businesses (35-64)
		sum uno if (categopri_ci==1 | categopri_ci==2) & inrange(edad_ci,35,64) & migrante_ci==`var' [fw=factor_ci]
		scalar selfEmp3564_``var'_label'_pop = `=r(N)'
		
		sum uno if inrange(edad_ci,35,64) & rama_ci!=1 & emp_ci==1 & migrante_ci==`var' [fw=factor_ci]
		scalar Notagri_emp3564_``var'_label'_pop = `=r(N)'
		
		* Employment in the public sector (35-64)
		sum uno if spublico_ci==1 & inrange(edad_ci,35,64) & migrante_ci==`var' [fw=factor_ci]
		scalar pubSec3564_``var'_label'_pop = `=r(N)'
		
		sum uno if inrange(edad_ci,35,64) & emp_ci==1 & categopri_ci!=2 & migrante_ci==`var' [fw=factor_ci]
		scalar NoSelf3564_``var'_label'_pop = `=r(N)'
		
		* Nominal monthly wage (USD) (35-64)
		sum nmwage if migrante_ci==`var' & inrange(edad_ci,35,64) [fw=factor_ci]
		scalar nmwage3564_``var'_label' = `=r(mean)'
		
		** SAMPLE CHARACTERISTICS
		
		* Total sample size: persons 35-64
		sum uno if inrange(edad_ci,35,64) & migrante_ci==`var'
		scalar survey_``var'_label'_3564 = `=r(N)'

		* Total persons 35-64 (with sample loadings)
		sum uno if inrange(edad_ci,35,64) & migrante_ci==`var' [fw=factor_ci]
		scalar total_``var'_label'_3564 = `=r(N)'
		
	}
	
******************************************************** EXCEL OUTPUTS

	putexcel set "C:\Users\jcamilop\OneDrive - Inter-American Development Bank Group\OECD\03 Outputs\Resultados por edad.xlsx", sheet("Peru") modify
	putexcel describe
	
	
	** LABOUR MARKET INDICATORS FOR PEOPLE OF AGES FROM 15 TO 34
	
	putexcel C8 = (`=job1534_nat_pop'/`=workAge1534_nat_pop') E8 = (`=job1534_migr_pop'/`=workAge1534_migr_pop') // Share of population with a job
	
	putexcel C9 = (`=econoAct1534_nat_pop'/`=workAge1534_nat_pop') E9 = (`=econoAct1534_migr_pop'/`=workAge1534_migr_pop') // Activity: Share participating in the labour force
	
	putexcel C10 = (`=inactive1534_nat_pop'/`=workAge1534_nat_pop') E10 = (`=inactive1534_migr_pop'/`=workAge1534_migr_pop')  // Economically inactive people
	
	putexcel C11 = (`=unemp1534_nat_pop'/`=econoActWorkAge1534_nat_pop') E11 = (`=unemp1534_migr_pop'/`=econoActWorkAge1534_migr_pop') // Unemployment: Share of population who were unemployed
	
	putexcel C12 = (`=long12_unemp1534_nat_pop'/`=inac_unemp1534_nat_pop') E12 = (`=long12_unemp1534_migr_pop'/`=inac_unemp1534_migr_pop') // Risk of labour market exclusion: long-term unemployment (12 month)
	
	putexcel C13 = (`=long6_unemp1534_nat_pop'/`=inac_unemp1534_nat_pop') E13 = (`=long6_unemp1534_migr_pop'/`=inac_unemp1534_migr_pop') // Risk of labour market exclusion: long-term unemployment (6 month)
	
	putexcel C14 = (`=long_invo1534_nat_pop'/`=inac_unemp1534_nat_pop') E14 = (`=long_invo1534_migr_pop'/`=inac_unemp1534_migr_pop') // Long-term uemployment >=12 months or inactive involuntary	
	
	putexcel C15 = (`=involuntary1534_nat_pop'/`=inac_unemp1534_nat_pop') E15 = (`=involuntary1534_migr_pop'/`=inac_unemp1534_migr_pop') // Inactive involuntary (available past week, not looking for job)
	
	putexcel C16 = (`=written1534_nat_pop'/`=noself_edu1534_nat_pop') E16 = (`=written1534_migr_pop'/`=noself_edu1534_migr_pop') // Share of population with written contract
	
	putexcel C17 = (`=informal1534_nat_pop'/`=job1534_nat_pop') E17 = (`=informal1534_migr_pop'/`=job1534_migr_pop') // Share of population with an informal job	
	
    // Share of population with an informal job (OECD def)
	
	putexcel C19 = (`=tempJob1534_nat_pop'/`=noself_edu1534_nat_pop') E19 = (`=tempJob1534_migr_pop'/`=noself_edu1534_migr_pop') // Types of contracts: Share of population in temporary contracts	

	putexcel C20 = (`=more50h1534_nat_pop'/`=hours1534_nat_pop') E20 = (`=more50h1534_migr_pop'/`=hours1534_migr_pop')  // Working hours: long (more than 50) hours
	
	putexcel C21 = (`=less30h1534_nat_pop'/`=hours1534_nat_pop') E21 = (`=less30h1534_migr_pop'/`=hours1534_migr_pop')  // Working hours: long (less than 30) hours	
	
	putexcel C22 = (`=highSkill1534_nat_pop'/`=NotMili1534_nat_pop') E22 = (`=highSkill1534_migr_pop'/`=NotMili1534_migr_pop') // Job skills: share of working population in highly skilled jobs
	
	putexcel C23 = (`=lowSkill1534_nat_pop'/`=NotMili1534_nat_pop') E23 = (`=lowSkill1534_migr_pop'/`=NotMili1534_migr_pop') // Job skills: share of working population in low-skilled jobs 
		
	putexcel C24 = (`=overquali1534_nat_pop'/`=NotEduNotMili1534_nat_pop') E24 = (`=overquali1534_migr_pop'/`=NotEduNotMili1534_migr_pop') // Overqualification: share of highly educated individuals who work in low- or medium-skilled jobs

	putexcel C25 = (`=selfEmp1534_nat_pop'/`=Notagri_emp1534_nat_pop') E25 = (`=selfEmp1534_migr_pop'/`=Notagri_emp1534_migr_pop')   // Self-employment: share of population who work in their own firms or businesses
	
	putexcel C26 = (`=pubSec1534_nat_pop'/`=NoSelf1534_nat_pop') E26 = (`=pubSec1534_migr_pop'/`=NoSelf1534_migr_pop')   // Employment in the public sector
	
	putexcel C27 = (`=nmwage1534_nat')  E27 = (`=nmwage1534_migr') // Nominal monthly wage (USD)
	
	
	** SIMPLE CHARACTERISTICS (15 - 34)
	
	putexcel C33 = (`=survey_nat_pop') E33 = (`=survey_migr_pop') // Total sample size: persons
	
	putexcel C34 = (`=survey_nat_1534') E34 = (`=survey_migr_1534') // Total sample size: persons 15-64
	
	putexcel C36 = (`=nat_pop') E36 = (`=migr_pop') // Total population (with sample loadings)
	
	putexcel C37 = (`=total_nat_1534') E37 = (`=total_migr_1534') // Total persons 15-64 (with sample loadings)
	
	
	** LABOUR MARKET INDICATORS FOR PEOPLE OF AGES FROM 35 TO 64
	
	putexcel D8 = (`=job3564_nat_pop'/`=workAge3564_nat_pop') F8 = (`=job3564_migr_pop'/`=workAge3564_migr_pop') // Share of population with a job
	
	putexcel D9 = (`=econoAct3564_nat_pop'/`=workAge3564_nat_pop') F9 = (`=econoAct3564_migr_pop'/`=workAge3564_migr_pop') // Activity: Share participating in the labour force
	
	putexcel D10 = (`=inactive3564_nat_pop'/`=workAge3564_nat_pop') F10 = (`=inactive3564_migr_pop'/`=workAge3564_migr_pop')  // Economically inactive people
	
	putexcel D11 = (`=unemp3564_nat_pop'/`=econoActWorkAge3564_nat_pop') F11 = (`=unemp3564_migr_pop'/`=econoActWorkAge3564_migr_pop') // Unemployment: Share of population who were unemployed
	
	putexcel D12 = (`=long12_unemp3564_nat_pop'/`=inac_unemp3564_nat_pop') F12 = (`=long12_unemp3564_migr_pop'/`=inac_unemp3564_migr_pop') // Risk of labour market exclusion: long-term unemployment (12 month)
	
	putexcel D13 = (`=long6_unemp3564_nat_pop'/`=inac_unemp3564_nat_pop') F13 = (`=long6_unemp3564_migr_pop'/`=inac_unemp3564_migr_pop') // Risk of labour market exclusion: long-term unemployment (6 month)
	
	putexcel D14 = (`=long_invo3564_nat_pop'/`=inac_unemp3564_nat_pop') F14 = (`=long_invo3564_migr_pop'/`=inac_unemp3564_migr_pop') // Long-term uemployment >=12 months or inactive involuntary	
	
	putexcel D15 = (`=involuntary3564_nat_pop'/`=inac_unemp3564_nat_pop') F15 = (`=involuntary3564_migr_pop'/`=inac_unemp3564_migr_pop') // Inactive involuntary (available past week, not looking for job)
	
	putexcel D16 = (`=written3564_nat_pop'/`=noself_edu3564_nat_pop') F16 = (`=written3564_migr_pop'/`=noself_edu3564_migr_pop') // Share of population with written contract
	
	putexcel D17 = (`=informal3564_nat_pop'/`=job3564_nat_pop') F17 = (`=informal3564_migr_pop'/`=job3564_migr_pop') // Share of population with an informal job	
	
    // Share of population with an informal job (OECD def)
	
	putexcel D19 = (`=tempJob3564_nat_pop'/`=noself_edu3564_nat_pop') F19 = (`=tempJob3564_migr_pop'/`=noself_edu3564_migr_pop') // Types of contracts: Share of population in temporary contracts	

	putexcel D20 = (`=more50h3564_nat_pop'/`=hours3564_nat_pop') F20 = (`=more50h3564_migr_pop'/`=hours3564_migr_pop')  // Working hours: long (more than 50) hours
	
	putexcel D21 = (`=less30h3564_nat_pop'/`=hours3564_nat_pop') F21 = (`=less30h3564_migr_pop'/`=hours3564_migr_pop')  // Working hours: long (less than 30) hours	
	
	putexcel D22 = (`=highSkill3564_nat_pop'/`=NotMili3564_nat_pop') F22 = (`=highSkill3564_migr_pop'/`=NotMili3564_migr_pop') // Job skills: share of working population in highly skilled jobs
	
	putexcel D23 = (`=lowSkill3564_nat_pop'/`=NotMili3564_nat_pop') F23 = (`=lowSkill3564_migr_pop'/`=NotMili3564_migr_pop') // Job skills: share of working population in low-skilled jobs 
		
	putexcel D24 = (`=overquali3564_nat_pop'/`=NotEduNotMili3564_nat_pop') F24 = (`=overquali3564_migr_pop'/`=NotEduNotMili3564_migr_pop') // Overqualification: share of highly educated individuals who work in low- or medium-skilled jobs

	putexcel D25 = (`=selfEmp3564_nat_pop'/`=Notagri_emp3564_nat_pop') F25 = (`=selfEmp3564_migr_pop'/`=Notagri_emp3564_migr_pop')   // Self-employment: share of population who work in their own firms or businesses
	
	putexcel D26 = (`=pubSec3564_nat_pop'/`=NoSelf3564_nat_pop') F26 = (`=pubSec3564_migr_pop'/`=NoSelf3564_migr_pop')   // Employment in the public sector
	
	putexcel D27 = (`=nmwage3564_nat')  F27 = (`=nmwage3564_migr') // Nominal monthly wage (USD)
	
	** SIMPLE CHARACTERISTICS (35 - 64)
	
	putexcel D34 = (`=survey_nat_3564') F34 = (`=survey_migr_3564') // Total sample size: persons 15-64
	
	putexcel D37 = (`=total_nat_3564') F37 = (`=total_migr_3564') // Total persons 15-64 (with sample loadings)
	
	
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
	sum uno if migrante_ci!=. & inrange(edad_ci,15,34) [fw=factor_ci]
	scalar tot_pop = `=r(N)'
	
	* Migrant population calculated according to expansion factor
	sum uno if migrante_ci==1 [fw=factor_ci]
	scalar migr_pop = `=r(N)'
	
	* Native population calculated according to expansion factor
	sum uno if migrante_ci==0 [fw=factor_ci]
	scalar nat_pop = `=r(N)'
	
	* Share of working age population (15-34)
	sum uno if inrange(edad_ci,15,34) & migrante_ci==1 [fw=factor_ci]
	scalar workAge1534_migr_pop = `=r(N)'
	sum uno if inrange(edad_ci,15,34) & migrante_ci==0 [fw=factor_ci]
	scalar workAge1534_nat_pop = `=r(N)'
	sum uno if inrange(edad_ci,15,34) [fw=factor_ci]
	scalar workAge1534_pop = `=r(N)'
		
	* Share of labour force population (15-34)
	sum uno if inrange(edad_ci,15,34) & pea_ci == 1 & migrante_ci==1 [fw=factor_ci]
	scalar econoAct1534_migr_pop = `=r(N)'
	sum uno if inrange(edad_ci,15,34) & pea_ci == 1 & migrante_ci==0 [fw=factor_ci]
	scalar econoAct1534_nat_pop = `=r(N)'
	sum uno if inrange(edad_ci,15,34) & pea_ci == 1 [fw=factor_ci]
	scalar econoAct1534_pop = `=r(N)'
	
	* Share of Employment rate  (15-34)
	sum uno if inrange(edad_ci,15,34) & emp_ci == 1 & migrante_ci==1 [fw=factor_ci]
	scalar emp1534_migr_pop = `=r(N)'
	sum uno if inrange(edad_ci,15,34) & emp_ci == 1 & migrante_ci==0 [fw=factor_ci]
	scalar emp1534_nat_pop = `=r(N)'
	sum uno if inrange(edad_ci,15,34) & emp_ci == 1 [fw=factor_ci]
	scalar emp1534_pop = `=r(N)'
	
	* Share of working age population (35-64)
	sum uno if inrange(edad_ci,35,64) & migrante_ci==1 [fw=factor_ci]
	scalar workAge3564_migr_pop = `=r(N)'
	sum uno if inrange(edad_ci,35,64) & migrante_ci==0 [fw=factor_ci]
	scalar workAge3564_nat_pop = `=r(N)'
	sum uno if inrange(edad_ci,35,64) [fw=factor_ci]
	scalar workAge3564_pop = `=r(N)'
		
	* Share of labour force population (35-64)
	sum uno if inrange(edad_ci,35,64) & pea_ci == 1 & migrante_ci==1 [fw=factor_ci]
	scalar econoAct3564_migr_pop = `=r(N)'
	sum uno if inrange(edad_ci,35,64) & pea_ci == 1 & migrante_ci==0 [fw=factor_ci]
	scalar econoAct3564_nat_pop = `=r(N)'
	sum uno if inrange(edad_ci,35,64) & pea_ci == 1 [fw=factor_ci]
	scalar econoAct3564_pop = `=r(N)'
	
	* Share of Employment rate  (35-64)
	sum uno if inrange(edad_ci,35,64) & emp_ci == 1 & migrante_ci==1 [fw=factor_ci]
	scalar emp_migr3564_pop = `=r(N)'
	sum uno if inrange(edad_ci,35,64) & emp_ci == 1 & migrante_ci==0 [fw=factor_ci]
	scalar emp_nat3564_pop = `=r(N)'
	sum uno if inrange(edad_ci,35,64) & emp_ci == 1 [fw=factor_ci]
	scalar emp3564_pop = `=r(N)'
	

	** CALCULATION OF INDICATORS BY MIGRANTS AND NATIVES
	
	foreach var in 1 0 {
		
		** LABOUR MARKET INDICATORS (BY AGE)
		
		************************************************************************
		** People of ages from 15 to 34
		
		* Share of population with a job (15-34)
		sum uno if inrange(edad_ci,15,34) & emp_ci==1 & migrante_ci==`var' [fw=factor_ci]
		scalar job1534_``var'_label'_pop = `=r(N)'
		
		* Activity: Share participating in the labour force (15-34)
		sum uno if inrange(edad_ci,15,34) & pea_ci==1 & migrante_ci==`var' [fw=factor_ci]
		scalar econoAct1534_``var'_label'_pop = `=r(N)'
		
		* Economically inactive people (15-34)
		sum uno if inrange(edad_ci,15,34) & (condocup_ci == 3) & migrante_ci==`var' [fw=factor_ci] 
		scalar inactive1534_``var'_label'_pop = `=r(N)'
		
		* Unemployment: Share of population who were unemployed (15-34)
		sum uno if inrange(edad_ci,15,34) & desemp_ci==1 & migrante_ci==`var' [fw=factor_ci] 
		scalar unemp1534_``var'_label'_pop = `=r(N)'
		
		sum uno if (pea_ci==1 | asiste_ci==1) & inrange(edad_ci,15,34) & migrante_ci==`var' [fw=factor_ci]
		scalar econoActWorkAge1534_``var'_label'_pop = `=r(N)'
		
		* Risk of labour market exclusion: long-term unemployment (12 months) (15-34)
		*sum uno if inrange(edad_ci,15,34) & (more_12==1 & desemp_ci==1) & migrante_ci==`var' [fw=factor_ci]
		*scalar long12_unemp1534_``var'_label'_pop = `=r(N)'
		
		*sum uno if inrange(edad_ci,15,34) & (desemp_ci==1 | condocup_ci==3) & durades_ci!=. & migrante_ci==`var' [fw=factor_ci] 
		*scalar inac_unemp1534_``var'_label'_pop = `=r(N)'
		
		* Risk of labour market exclusion: long-term unemployment (6 months) (15-34)
		*sum uno if inrange(edad_ci,15,34) & (more_6==1 & desemp_ci==1) & migrante_ci==`var' [fw=factor_ci]
		*scalar long6_unemp1534_``var'_label'_pop = `=r(N)'
		
		* Risk of labour market exclusion: long-term uemployment >=12 months or inactive involuntary (15-34)
		*sum uno if inrange(edad_ci,15,34) & (desalent_ci==1 | (more_12==1 & desemp_ci==1)) & migrante_ci==`var' [fw=factor_ci]
		*scalar long_invo1534_``var'_label'_pop = `=r(N)'
		
		* Risk of labour market exclusion: Inactive involuntary (available past week, not looking for job) (15-34)
		*sum uno if inrange(edad_ci,15,34) & desalent_ci==1 & migrante_ci==`var' [fw=factor_ci]
		*scalar involuntary1534_``var'_label'_pop = `=r(N)'
		
		* Share of population with written contract (15-34)
		*sum uno if inrange(edad_ci,15,34) & inlist(tipocontrato_ci,0,1,2) & migrante_ci==`var' [fw=factor_ci]
		*scalar written1534_``var'_label'_pop = `=r(N)'		
		
		* Share of population with an informal job (15-34)
		*sum uno if inrange(edad_ci,15,34) & informal==1 & migrante_ci==`var' [fw=factor_ci]
		*scalar informal1534_``var'_label'_pop = `=r(N)'
		
		* Types of contracts:  Share of population in temporary contracts (15-34)
		*sum uno if inrange(edad_ci,15,34) & tipocontrato_ci==2 & migrante_ci==`var' [fw=factor_ci] 
		*scalar tempJob1534_``var'_label'_pop = `=r(N)'
		
		*sum uno if inrange(edad_ci,15,34) & categopri_ci!=2 & asiste_ci!=1 & emp_ci==1 & migrante_ci==`var' [fw=factor_ci]
		*scalar noself_edu1534_``var'_label'_pop = `=r(N)'
		
		* Working hours: long hours >= 50 (15-34)
		sum uno if inrange(edad_ci,15,34) & more_50==1 & emp_ci == 1 & migrante_ci==`var' [fw=factor_ci]
		scalar more50h1534_``var'_label'_pop = `=r(N)'
		
		sum uno if inrange(edad_ci,15,34) & by_hours==1 & emp_ci == 1 & migrante_ci==`var' [fw=factor_ci]
		scalar hours1534_``var'_label'_pop = `=r(N)'	
	
		* Working hours: long hours < 30 (15-34)
		sum uno if inrange(edad_ci,15,34) & less_30==1 & emp_ci == 1 & migrante_ci==`var' [fw=factor_ci]
		scalar less30h1534_``var'_label'_pop = `=r(N)'

		* Job skills: share of working population in highly skilled jobs (15-34)
		*sum uno if high_skilled==1 & inrange(edad_ci,15,34) & migrante_ci==`var' [fw=factor_ci]
		*scalar highSkill1534_``var'_label'_pop = `=r(N)'		
		
		* Job skills: share of working population in low-skilled jobs (15-34)
		*sum uno if low_skilled==1 & inrange(edad_ci,15,34) & migrante_ci==`var' [fw=factor_ci]
		*scalar lowSkill1534_``var'_label'_pop = `=r(N)'
		
		*sum uno if emp_ci==1 & inrange(edad_ci,15,34) & ISCO!=0 & migrante_ci==`var' [fw=factor_ci]
		*scalar NotMili1534_``var'_label'_pop = `=r(N)'
		
		* Overqualification: share of highly educated individuals who work in low- or medium-skilled jobs (15-34)
		*sum uno if overqualificated==1 & inrange(edad_ci,15,34) & migrante_ci==`var' & inrange(ISCED,4,9) [fw=factor_ci]
		*scalar overquali1534_``var'_label'_pop = `=r(N)'
		
		*sum uno if emp_ci==1 & inrange(edad_ci,15,34) & asiste_ci!=1 & ISCO!=0 & migrante_ci==`var' [fw=factor_ci]
		*scalar NotEduNotMili1534_``var'_label'_pop = `=r(N)'
		
		* Self-employment: share of population who works in their own firms or businesses (15-34)
		sum uno if (categopri_ci==1 | categopri_ci==2) & inrange(edad_ci,15,34) & migrante_ci==`var' [fw=factor_ci]
		scalar selfEmp1534_``var'_label'_pop = `=r(N)'
		
		sum uno if inrange(edad_ci,15,34) & rama_ci!=1 & emp_ci==1 & migrante_ci==`var' [fw=factor_ci]
		scalar Notagri_emp1534_``var'_label'_pop = `=r(N)'
		
		* Employment in the public sector (15-34)
		sum uno if spublico_ci==1 & inrange(edad_ci,15,34) & migrante_ci==`var' [fw=factor_ci]
		scalar pubSec1534_``var'_label'_pop = `=r(N)'
		
		sum uno if inrange(edad_ci,15,34) & emp_ci==1 & categopri_ci!=2 & migrante_ci==`var' [fw=factor_ci]
		scalar NoSelf1534_``var'_label'_pop = `=r(N)'
		
		* Nominal monthly wage (USD) (15-34)
		sum nmwage if migrante_ci==`var' & inrange(edad_ci,15,34) [fw=factor_ci]
		scalar nmwage1534_``var'_label' = `=r(mean)'
		
		** SAMPLE CHARACTERISTICS
		
		* Total sample size: persons 
		sum uno if migrante_ci==`var'
		scalar survey_``var'_label'_pop = `=r(N)'
		
		* Total sample size: persons 15-34
		sum uno if inrange(edad_ci,15,34) & migrante_ci==`var'
		scalar survey_``var'_label'_1534 = `=r(N)'

		* Total persons 15-34 (with sample loadings)
		sum uno if inrange(edad_ci,15,34) & migrante_ci==`var' [fw=factor_ci]
		scalar total_``var'_label'_1534 = `=r(N)'
		
		************************************************************************
		** People of ages from 35 to 64
		
		* Share of population with a job (35-64)
		sum uno if inrange(edad_ci,35,64) & emp_ci==1 & migrante_ci==`var' [fw=factor_ci]
		scalar job3564_``var'_label'_pop = `=r(N)'
		
		* Activity: Share participating in the labour force (35-64)
		sum uno if inrange(edad_ci,35,64) & pea_ci==1 & migrante_ci==`var' [fw=factor_ci]
		scalar econoAct3564_``var'_label'_pop = `=r(N)'
		
		* Economically inactive people (35-64)
		sum uno if inrange(edad_ci,35,64) & (condocup_ci == 3) & migrante_ci==`var' [fw=factor_ci] 
		scalar inactive3564_``var'_label'_pop = `=r(N)'
		
		* Unemployment: Share of population who were unemployed (35-64)
		sum uno if inrange(edad_ci,35,64) & desemp_ci==1 & migrante_ci==`var' [fw=factor_ci] 
		scalar unemp3564_``var'_label'_pop = `=r(N)'
		
		sum uno if (pea_ci==1 | asiste_ci==1) & inrange(edad_ci,35,64) & migrante_ci==`var' [fw=factor_ci]
		scalar econoActWorkAge3564_``var'_label'_pop = `=r(N)'
		
		* Risk of labour market exclusion: long-term unemployment (12 months) (35-64)
		*sum uno if inrange(edad_ci,35,64) & (more_12==1 & desemp_ci==1) & migrante_ci==`var' [fw=factor_ci]
		*scalar long12_unemp3564_``var'_label'_pop = `=r(N)'
		
		*sum uno if inrange(edad_ci,35,64) & (desemp_ci==1 | condocup_ci==3) & durades_ci!=. & migrante_ci==`var' [fw=factor_ci] 
		*scalar inac_unemp3564_``var'_label'_pop = `=r(N)'
		
		* Risk of labour market exclusion: long-term unemployment (6 months) (35-64)
		*sum uno if inrange(edad_ci,35,64) & (more_6==1 & desemp_ci==1) & migrante_ci==`var' [fw=factor_ci]
		*scalar long6_unemp3564_``var'_label'_pop = `=r(N)'
		
		* Risk of labour market exclusion: long-term unemployment >=12 months or inactive involuntary (35-64)
		*sum uno if inrange(edad_ci,35,64) & (desalent_ci==1 | (more_12==1 & desemp_ci==1)) & migrante_ci==`var' [fw=factor_ci]
		*scalar long_invo3564_``var'_label'_pop = `=r(N)'
		
		* Risk of labour market exclusion: Inactive involuntary (available past week, not looking for job) (35-64)
		*sum uno if inrange(edad_ci,35,64) & desalent_ci==1 & migrante_ci==`var' [fw=factor_ci]
		*scalar involuntary3564_``var'_label'_pop = `=r(N)'
		
		* Share of population with written contract (35-64)
		*sum uno if inrange(edad_ci,35,64) & inlist(tipocontrato_ci,0,1,2) & migrante_ci==`var' [fw=factor_ci]
		*scalar written3564_``var'_label'_pop = `=r(N)'		
		
		* Share of population with an informal job (35-64)
		*sum uno if inrange(edad_ci,35,64) & informal==1 & migrante_ci==`var' [fw=factor_ci]
		*scalar informal3564_``var'_label'_pop = `=r(N)'
		
		* Types of contracts:  Share of population in temporary contracts (35-64)
		*sum uno if inrange(edad_ci,35,64) & tipocontrato_ci==2 & migrante_ci==`var' [fw=factor_ci] 
		*scalar tempJob3564_``var'_label'_pop = `=r(N)'
		
		*sum uno if inrange(edad_ci,35,64) & categopri_ci!=2 & asiste_ci!=1 & emp_ci==1 & migrante_ci==`var' [fw=factor_ci]
		*scalar noself_edu3564_``var'_label'_pop = `=r(N)'
		
		* Working hours: long hours >= 50 (35-64)
		sum uno if inrange(edad_ci,35,64) & more_50==1 & emp_ci == 1 & migrante_ci==`var' [fw=factor_ci]
		scalar more50h3564_``var'_label'_pop = `=r(N)'
		
		sum uno if inrange(edad_ci,35,64) & by_hours==1 & emp_ci == 1 & migrante_ci==`var' [fw=factor_ci]
		scalar hours3564_``var'_label'_pop = `=r(N)'	
	
		* Working hours: long hours < 30 (35-64)
		sum uno if inrange(edad_ci,35,64) & less_30==1 & emp_ci == 1 & migrante_ci==`var' [fw=factor_ci]
		scalar less30h3564_``var'_label'_pop = `=r(N)'

		* Job skills: share of working population in highly skilled jobs (35-64)
		*sum uno if high_skilled==1 & inrange(edad_ci,35,64) & migrante_ci==`var' [fw=factor_ci]
		*scalar highSkill3564_``var'_label'_pop = `=r(N)'		
		
		* Job skills: share of working population in low-skilled jobs (35-64)
		*sum uno if low_skilled==1 & inrange(edad_ci,35,64) & migrante_ci==`var' [fw=factor_ci]
		*scalar lowSkill3564_``var'_label'_pop = `=r(N)'
		
		*sum uno if emp_ci==1 & inrange(edad_ci,35,64) & ISCO!=0 & migrante_ci==`var' [fw=factor_ci]
		*scalar NotMili3564_``var'_label'_pop = `=r(N)'
		
		* Overqualification: share of highly educated individuals who work in low- or medium-skilled jobs (35-64)
		*sum uno if overqualificated==1 & inrange(edad_ci,35,64) & migrante_ci==`var' & inrange(ISCED,4,9) [fw=factor_ci]
		*scalar overquali3564_``var'_label'_pop = `=r(N)'
		
		*sum uno if emp_ci==1 & inrange(edad_ci,35,64) & asiste_ci!=1 & ISCO!=0 & migrante_ci==`var' [fw=factor_ci]
		*scalar NotEduNotMili3564_``var'_label'_pop = `=r(N)'
		
		* Self-employment: share of population who works in their own firms or businesses (35-64)
		sum uno if (categopri_ci==1 | categopri_ci==2) & inrange(edad_ci,35,64) & migrante_ci==`var' [fw=factor_ci]
		scalar selfEmp3564_``var'_label'_pop = `=r(N)'
		
		sum uno if inrange(edad_ci,35,64) & rama_ci!=1 & emp_ci==1 & migrante_ci==`var' [fw=factor_ci]
		scalar Notagri_emp3564_``var'_label'_pop = `=r(N)'
		
		* Employment in the public sector (35-64)
		sum uno if spublico_ci==1 & inrange(edad_ci,35,64) & migrante_ci==`var' [fw=factor_ci]
		scalar pubSec3564_``var'_label'_pop = `=r(N)'
		
		sum uno if inrange(edad_ci,35,64) & emp_ci==1 & categopri_ci!=2 & migrante_ci==`var' [fw=factor_ci]
		scalar NoSelf3564_``var'_label'_pop = `=r(N)'
		
		* Nominal monthly wage (USD) (35-64)
		sum nmwage if migrante_ci==`var' & inrange(edad_ci,35,64) [fw=factor_ci]
		scalar nmwage3564_``var'_label' = `=r(mean)'
		
		** SAMPLE CHARACTERISTICS
		
		* Total sample size: persons 35-64
		sum uno if inrange(edad_ci,35,64) & migrante_ci==`var'
		scalar survey_``var'_label'_3564 = `=r(N)'

		* Total persons 35-64 (with sample loadings)
		sum uno if inrange(edad_ci,35,64) & migrante_ci==`var' [fw=factor_ci]
		scalar total_``var'_label'_3564 = `=r(N)'
		
	}
	
******************************************************** EXCEL OUTPUTS

	putexcel set "C:\Users\jcamilop\OneDrive - Inter-American Development Bank Group\OECD\03 Outputs\Resultados por edad.xlsx", sheet("T&T") modify
	putexcel describe
	
	
	** LABOUR MARKET INDICATORS FOR PEOPLE OF AGES FROM 15 TO 34
	
	putexcel C8 = (`=job1534_nat_pop'/`=workAge1534_nat_pop') E8 = (`=job1534_migr_pop'/`=workAge1534_migr_pop') // Share of population with a job
	
	putexcel C9 = (`=econoAct1534_nat_pop'/`=workAge1534_nat_pop') E9 = (`=econoAct1534_migr_pop'/`=workAge1534_migr_pop') // Activity: Share participating in the labour force
	
	putexcel C10 = (`=inactive1534_nat_pop'/`=workAge1534_nat_pop') E10 = (`=inactive1534_migr_pop'/`=workAge1534_migr_pop')  // Economically inactive people
	
	putexcel C11 = (`=unemp1534_nat_pop'/`=econoActWorkAge1534_nat_pop') E11 = (`=unemp1534_migr_pop'/`=econoActWorkAge1534_migr_pop') // Unemployment: Share of population who were unemployed
	
	*putexcel C12 = (`=long12_unemp1534_nat_pop'/`=inac_unemp1534_nat_pop') E12 = (`=long12_unemp1534_migr_pop'/`=inac_unemp1534_migr_pop') // Risk of labour market exclusion: long-term unemployment (12 month)
	
	*putexcel C13 = (`=long6_unemp1534_nat_pop'/`=inac_unemp1534_nat_pop') E13 = (`=long6_unemp1534_migr_pop'/`=inac_unemp1534_migr_pop') // Risk of labour market exclusion: long-term unemployment (6 month)
	
	*putexcel C14 = (`=long_invo1534_nat_pop'/`=inac_unemp1534_nat_pop') E14 = (`=long_invo1534_migr_pop'/`=inac_unemp1534_migr_pop') // Long-term uemployment >=12 months or inactive involuntary	
	
	*putexcel C15 = (`=involuntary1534_nat_pop'/`=inac_unemp1534_nat_pop') E15 = (`=involuntary1534_migr_pop'/`=inac_unemp1534_migr_pop') // Inactive involuntary (available past week, not looking for job)
	
	*putexcel C16 = (`=written1534_nat_pop'/`=noself_edu1534_nat_pop') E16 = (`=written1534_migr_pop'/`=noself_edu1534_migr_pop') // Share of population with written contract
	
	*putexcel C17 = (`=informal1534_nat_pop'/`=job1534_nat_pop') E17 = (`=informal1534_migr_pop'/`=job1534_migr_pop') // Share of population with an informal job	
	
    // Share of population with an informal job (OECD def)
	
	*putexcel C19 = (`=tempJob1534_nat_pop'/`=noself_edu1534_nat_pop') E19 = (`=tempJob1534_migr_pop'/`=noself_edu1534_migr_pop') // Types of contracts: Share of population in temporary contracts	

	putexcel C20 = (`=more50h1534_nat_pop'/`=hours1534_nat_pop') E20 = (`=more50h1534_migr_pop'/`=hours1534_migr_pop')  // Working hours: long (more than 50) hours
	
	putexcel C21 = (`=less30h1534_nat_pop'/`=hours1534_nat_pop') E21 = (`=less30h1534_migr_pop'/`=hours1534_migr_pop')  // Working hours: long (less than 30) hours	
	
	*putexcel C22 = (`=highSkill1534_nat_pop'/`=NotMili1534_nat_pop') E22 = (`=highSkill1534_migr_pop'/`=NotMili1534_migr_pop') // Job skills: share of working population in highly skilled jobs
	
	*putexcel C23 = (`=lowSkill1534_nat_pop'/`=NotMili1534_nat_pop') E23 = (`=lowSkill1534_migr_pop'/`=NotMili1534_migr_pop') // Job skills: share of working population in low-skilled jobs 
		
	*putexcel C24 = (`=overquali1534_nat_pop'/`=NotEduNotMili1534_nat_pop') E24 = (`=overquali1534_migr_pop'/`=NotEduNotMili1534_migr_pop') // Overqualification: share of highly educated individuals who work in low- or medium-skilled jobs

	putexcel C25 = (`=selfEmp1534_nat_pop'/`=Notagri_emp1534_nat_pop') E25 = (`=selfEmp1534_migr_pop'/`=Notagri_emp1534_migr_pop')   // Self-employment: share of population who work in their own firms or businesses
	
	putexcel C26 = (`=pubSec1534_nat_pop'/`=NoSelf1534_nat_pop') E26 = (`=pubSec1534_migr_pop'/`=NoSelf1534_migr_pop')   // Employment in the public sector
	
	putexcel C27 = (`=nmwage1534_nat')  E27 = (`=nmwage1534_migr') // Nominal monthly wage (USD)
	
	
	** SIMPLE CHARACTERISTICS (15 - 34)
	
	putexcel C33 = (`=survey_nat_pop') E33 = (`=survey_migr_pop') // Total sample size: persons
	
	putexcel C34 = (`=survey_nat_1534') E34 = (`=survey_migr_1534') // Total sample size: persons 15-64
	
	putexcel C36 = (`=nat_pop') E36 = (`=migr_pop') // Total population (with sample loadings)
	
	putexcel C37 = (`=total_nat_1534') E37 = (`=total_migr_1534') // Total persons 15-64 (with sample loadings)
	
	
	** LABOUR MARKET INDICATORS FOR PEOPLE OF AGES FROM 35 TO 64
	
	putexcel D8 = (`=job3564_nat_pop'/`=workAge3564_nat_pop') F8 = (`=job3564_migr_pop'/`=workAge3564_migr_pop') // Share of population with a job
	
	putexcel D9 = (`=econoAct3564_nat_pop'/`=workAge3564_nat_pop') F9 = (`=econoAct3564_migr_pop'/`=workAge3564_migr_pop') // Activity: Share participating in the labour force
	
	putexcel D10 = (`=inactive3564_nat_pop'/`=workAge3564_nat_pop') F10 = (`=inactive3564_migr_pop'/`=workAge3564_migr_pop')  // Economically inactive people
	
	putexcel D11 = (`=unemp3564_nat_pop'/`=econoActWorkAge3564_nat_pop') F11 = (`=unemp3564_migr_pop'/`=econoActWorkAge3564_migr_pop') // Unemployment: Share of population who were unemployed
	
	*putexcel D12 = (`=long12_unemp3564_nat_pop'/`=inac_unemp3564_nat_pop') F12 = (`=long12_unemp3564_migr_pop'/`=inac_unemp3564_migr_pop') // Risk of labour market exclusion: long-term unemployment (12 month)
	
	*putexcel D13 = (`=long6_unemp3564_nat_pop'/`=inac_unemp3564_nat_pop') F13 = (`=long6_unemp3564_migr_pop'/`=inac_unemp3564_migr_pop') // Risk of labour market exclusion: long-term unemployment (6 month)
	
	*putexcel D14 = (`=long_invo3564_nat_pop'/`=inac_unemp3564_nat_pop') F14 = (`=long_invo3564_migr_pop'/`=inac_unemp3564_migr_pop') // Long-term uemployment >=12 months or inactive involuntary	
	
	*putexcel D15 = (`=involuntary3564_nat_pop'/`=inac_unemp3564_nat_pop') F15 = (`=involuntary3564_migr_pop'/`=inac_unemp3564_migr_pop') // Inactive involuntary (available past week, not looking for job)
	
	*putexcel D16 = (`=written3564_nat_pop'/`=noself_edu3564_nat_pop') F16 = (`=written3564_migr_pop'/`=noself_edu3564_migr_pop') // Share of population with written contract
	
	*putexcel D17 = (`=informal3564_nat_pop'/`=job3564_nat_pop') F17 = (`=informal3564_migr_pop'/`=job3564_migr_pop') // Share of population with an informal job	
	
    // Share of population with an informal job (OECD def)
	
	*putexcel D19 = (`=tempJob3564_nat_pop'/`=noself_edu3564_nat_pop') F19 = (`=tempJob3564_migr_pop'/`=noself_edu3564_migr_pop') // Types of contracts: Share of population in temporary contracts	

	putexcel D20 = (`=more50h3564_nat_pop'/`=hours3564_nat_pop') F20 = (`=more50h3564_migr_pop'/`=hours3564_migr_pop')  // Working hours: long (more than 50) hours
	
	putexcel D21 = (`=less30h3564_nat_pop'/`=hours3564_nat_pop') F21 = (`=less30h3564_migr_pop'/`=hours3564_migr_pop')  // Working hours: long (less than 30) hours	
	
	*putexcel D22 = (`=highSkill3564_nat_pop'/`=NotMili3564_nat_pop') F22 = (`=highSkill3564_migr_pop'/`=NotMili3564_migr_pop') // Job skills: share of working population in highly skilled jobs
	
	*putexcel D23 = (`=lowSkill3564_nat_pop'/`=NotMili3564_nat_pop') F23 = (`=lowSkill3564_migr_pop'/`=NotMili3564_migr_pop') // Job skills: share of working population in low-skilled jobs 
		
	*putexcel D24 = (`=overquali3564_nat_pop'/`=NotEduNotMili3564_nat_pop') F24 = (`=overquali3564_migr_pop'/`=NotEduNotMili3564_migr_pop') // Overqualification: share of highly educated individuals who work in low- or medium-skilled jobs

	putexcel D25 = (`=selfEmp3564_nat_pop'/`=Notagri_emp3564_nat_pop') F25 = (`=selfEmp3564_migr_pop'/`=Notagri_emp3564_migr_pop')   // Self-employment: share of population who work in their own firms or businesses
	
	putexcel D26 = (`=pubSec3564_nat_pop'/`=NoSelf3564_nat_pop') F26 = (`=pubSec3564_migr_pop'/`=NoSelf3564_migr_pop')   // Employment in the public sector
	
	putexcel D27 = (`=nmwage3564_nat')  F27 = (`=nmwage3564_migr') // Nominal monthly wage (USD)
	
	** SIMPLE CHARACTERISTICS (35 - 64)
	
	putexcel D34 = (`=survey_nat_3564') F34 = (`=survey_migr_3564') // Total sample size: persons 15-64
	
	putexcel D37 = (`=total_nat_3564') F37 = (`=total_migr_3564') // Total persons 15-64 (with sample loadings)
	

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
	sum uno if migrante_ci!=. & inrange(edad_ci,15,34) [fw=factor_ci]
	scalar tot_pop = `=r(N)'
	
	* Migrant population calculated according to expansion factor
	sum uno if migrante_ci==1 [fw=factor_ci]
	scalar migr_pop = `=r(N)'
	
	* Native population calculated according to expansion factor
	sum uno if migrante_ci==0 [fw=factor_ci]
	scalar nat_pop = `=r(N)'
	
	* Share of working age population (15-34)
	sum uno if inrange(edad_ci,15,34) & migrante_ci==1 [fw=factor_ci]
	scalar workAge1534_migr_pop = `=r(N)'
	sum uno if inrange(edad_ci,15,34) & migrante_ci==0 [fw=factor_ci]
	scalar workAge1534_nat_pop = `=r(N)'
	sum uno if inrange(edad_ci,15,34) [fw=factor_ci]
	scalar workAge1534_pop = `=r(N)'
		
	* Share of labour force population (15-34)
	sum uno if inrange(edad_ci,15,34) & pea_ci == 1 & migrante_ci==1 [fw=factor_ci]
	scalar econoAct1534_migr_pop = `=r(N)'
	sum uno if inrange(edad_ci,15,34) & pea_ci == 1 & migrante_ci==0 [fw=factor_ci]
	scalar econoAct1534_nat_pop = `=r(N)'
	sum uno if inrange(edad_ci,15,34) & pea_ci == 1 [fw=factor_ci]
	scalar econoAct1534_pop = `=r(N)'
	
	* Share of Employment rate  (15-34)
	sum uno if inrange(edad_ci,15,34) & emp_ci == 1 & migrante_ci==1 [fw=factor_ci]
	scalar emp1534_migr_pop = `=r(N)'
	sum uno if inrange(edad_ci,15,34) & emp_ci == 1 & migrante_ci==0 [fw=factor_ci]
	scalar emp1534_nat_pop = `=r(N)'
	sum uno if inrange(edad_ci,15,34) & emp_ci == 1 [fw=factor_ci]
	scalar emp1534_pop = `=r(N)'
	
	* Share of working age population (35-64)
	sum uno if inrange(edad_ci,35,64) & migrante_ci==1 [fw=factor_ci]
	scalar workAge3564_migr_pop = `=r(N)'
	sum uno if inrange(edad_ci,35,64) & migrante_ci==0 [fw=factor_ci]
	scalar workAge3564_nat_pop = `=r(N)'
	sum uno if inrange(edad_ci,35,64) [fw=factor_ci]
	scalar workAge3564_pop = `=r(N)'
		
	* Share of labour force population (35-64)
	sum uno if inrange(edad_ci,35,64) & pea_ci == 1 & migrante_ci==1 [fw=factor_ci]
	scalar econoAct3564_migr_pop = `=r(N)'
	sum uno if inrange(edad_ci,35,64) & pea_ci == 1 & migrante_ci==0 [fw=factor_ci]
	scalar econoAct3564_nat_pop = `=r(N)'
	sum uno if inrange(edad_ci,35,64) & pea_ci == 1 [fw=factor_ci]
	scalar econoAct3564_pop = `=r(N)'
	
	* Share of Employment rate  (35-64)
	sum uno if inrange(edad_ci,35,64) & emp_ci == 1 & migrante_ci==1 [fw=factor_ci]
	scalar emp_migr3564_pop = `=r(N)'
	sum uno if inrange(edad_ci,35,64) & emp_ci == 1 & migrante_ci==0 [fw=factor_ci]
	scalar emp_nat3564_pop = `=r(N)'
	sum uno if inrange(edad_ci,35,64) & emp_ci == 1 [fw=factor_ci]
	scalar emp3564_pop = `=r(N)'
	

	** CALCULATION OF INDICATORS BY MIGRANTS AND NATIVES
	
	foreach var in 1 0 {
		
		** LABOUR MARKET INDICATORS (BY AGE)
		
		************************************************************************
		** People of ages from 15 to 34
		
		* Share of population with a job (15-34)
		sum uno if inrange(edad_ci,15,34) & emp_ci==1 & migrante_ci==`var' [fw=factor_ci]
		scalar job1534_``var'_label'_pop = `=r(N)'
		
		* Activity: Share participating in the labour force (15-34)
		sum uno if inrange(edad_ci,15,34) & pea_ci==1 & migrante_ci==`var' [fw=factor_ci]
		scalar econoAct1534_``var'_label'_pop = `=r(N)'
		
		* Economically inactive people (15-34)
		sum uno if inrange(edad_ci,15,34) & (condocup_ci == 3) & migrante_ci==`var' [fw=factor_ci] 
		scalar inactive1534_``var'_label'_pop = `=r(N)'
		
		* Unemployment: Share of population who were unemployed (15-34)
		sum uno if inrange(edad_ci,15,34) & desemp_ci==1 & migrante_ci==`var' [fw=factor_ci] 
		scalar unemp1534_``var'_label'_pop = `=r(N)'
		
		sum uno if (pea_ci==1 | asiste_ci==1) & inrange(edad_ci,15,34) & migrante_ci==`var' [fw=factor_ci]
		scalar econoActWorkAge1534_``var'_label'_pop = `=r(N)'
		
		* Risk of labour market exclusion: long-term unemployment (12 months) (15-34)
		sum uno if inrange(edad_ci,15,34) & (more_12==1 & desemp_ci==1) & migrante_ci==`var' [fw=factor_ci]
		scalar long12_unemp1534_``var'_label'_pop = `=r(N)'
		
		sum uno if inrange(edad_ci,15,34) & (desemp_ci==1 | condocup_ci==3) & durades_ci!=. & migrante_ci==`var' [fw=factor_ci] 
		scalar inac_unemp1534_``var'_label'_pop = `=r(N)'
		
		* Risk of labour market exclusion: long-term unemployment (6 months) (15-34)
		sum uno if inrange(edad_ci,15,34) & (more_6==1 & desemp_ci==1) & migrante_ci==`var' [fw=factor_ci]
		scalar long6_unemp1534_``var'_label'_pop = `=r(N)'
		
		* Risk of labour market exclusion: long-term uemployment >=12 months or inactive involuntary (15-34)
		sum uno if inrange(edad_ci,15,34) & (desalent_ci==1 | (more_12==1 & desemp_ci==1)) & migrante_ci==`var' [fw=factor_ci]
		scalar long_invo1534_``var'_label'_pop = `=r(N)'
		
		* Risk of labour market exclusion: Inactive involuntary (available past week, not looking for job) (15-34)
		sum uno if inrange(edad_ci,15,34) & desalent_ci==1 & migrante_ci==`var' [fw=factor_ci]
		scalar involuntary1534_``var'_label'_pop = `=r(N)'
		
		* Share of population with written contract (15-34)
		sum uno if inrange(edad_ci,15,34) & (cotizando_ci== 1) & migrante_ci==`var' [fw=factor_ci]
		scalar written1534_``var'_label'_pop = `=r(N)'		
		
		* Share of population with an informal job (15-34)
		sum uno if inrange(edad_ci,15,34) & informal==1 & migrante_ci==`var' [fw=factor_ci]
		scalar informal1534_``var'_label'_pop = `=r(N)'
		
		* Types of contracts:  Share of population in temporary contracts (15-34)
		sum uno if inrange(edad_ci,15,34) & tipocontrato_ci==2 & migrante_ci==`var' [fw=factor_ci] 
		scalar tempJob1534_``var'_label'_pop = `=r(N)'
		
		sum uno if inrange(edad_ci,15,34) & categopri_ci!=2 & asiste_ci!=1 & emp_ci==1 & migrante_ci==`var' [fw=factor_ci]
		scalar noself_edu1534_``var'_label'_pop = `=r(N)'
		
		* Working hours: long hours >= 50 (15-34)
		sum uno if inrange(edad_ci,15,34) & more_50==1 & emp_ci == 1 & migrante_ci==`var' [fw=factor_ci]
		scalar more50h1534_``var'_label'_pop = `=r(N)'
		
		sum uno if inrange(edad_ci,15,34) & by_hours==1 & emp_ci == 1 & migrante_ci==`var' [fw=factor_ci]
		scalar hours1534_``var'_label'_pop = `=r(N)'	
	
		* Working hours: long hours < 30 (15-34)
		sum uno if inrange(edad_ci,15,34) & less_30==1 & emp_ci == 1 & migrante_ci==`var' [fw=factor_ci]
		scalar less30h1534_``var'_label'_pop = `=r(N)'

		* Job skills: share of working population in highly skilled jobs (15-34)
		sum uno if high_skilled==1 & inrange(edad_ci,15,34) & migrante_ci==`var' [fw=factor_ci]
		scalar highSkill1534_``var'_label'_pop = `=r(N)'		
		
		* Job skills: share of working population in low-skilled jobs (15-34)
		sum uno if low_skilled==1 & inrange(edad_ci,15,34) & migrante_ci==`var' [fw=factor_ci]
		scalar lowSkill1534_``var'_label'_pop = `=r(N)'
		
		sum uno if emp_ci==1 & inrange(edad_ci,15,34) & ISCO!=0 & migrante_ci==`var' [fw=factor_ci]
		scalar NotMili1534_``var'_label'_pop = `=r(N)'
		
		* Overqualification: share of highly educated individuals who work in low- or medium-skilled jobs (15-34)
		sum uno if overqualificated==1 & inrange(edad_ci,15,34) & migrante_ci==`var' & inrange(ISCED,4,9) [fw=factor_ci]
		scalar overquali1534_``var'_label'_pop = `=r(N)'
		
		sum uno if emp_ci==1 & inrange(edad_ci,15,34) & asiste_ci!=1 & ISCO!=0 & migrante_ci==`var' [fw=factor_ci]
		scalar NotEduNotMili1534_``var'_label'_pop = `=r(N)'
		
		* Self-employment: share of population who works in their own firms or businesses (15-34)
		sum uno if (categopri_ci==1 | categopri_ci==2) & inrange(edad_ci,15,34) & migrante_ci==`var' [fw=factor_ci]
		scalar selfEmp1534_``var'_label'_pop = `=r(N)'
		
		sum uno if inrange(edad_ci,15,34) & rama_ci!=1 & emp_ci==1 & migrante_ci==`var' [fw=factor_ci]
		scalar Notagri_emp1534_``var'_label'_pop = `=r(N)'
		
		* Employment in the public sector (15-34)
		sum uno if spublico_ci==1 & inrange(edad_ci,15,34) & migrante_ci==`var' [fw=factor_ci]
		scalar pubSec1534_``var'_label'_pop = `=r(N)'
		
		sum uno if inrange(edad_ci,15,34) & emp_ci==1 & categopri_ci!=2 & migrante_ci==`var' [fw=factor_ci]
		scalar NoSelf1534_``var'_label'_pop = `=r(N)'
		
		* Nominal monthly wage (USD) (15-34)
		sum nmwage if migrante_ci==`var' & inrange(edad_ci,15,34) [fw=factor_ci]
		scalar nmwage1534_``var'_label' = `=r(mean)'
		
		** SAMPLE CHARACTERISTICS
		
		* Total sample size: persons 
		sum uno if migrante_ci==`var'
		scalar survey_``var'_label'_pop = `=r(N)'
		
		* Total sample size: persons 15-34
		sum uno if inrange(edad_ci,15,34) & migrante_ci==`var'
		scalar survey_``var'_label'_1534 = `=r(N)'

		* Total persons 15-34 (with sample loadings)
		sum uno if inrange(edad_ci,15,34) & migrante_ci==`var' [fw=factor_ci]
		scalar total_``var'_label'_1534 = `=r(N)'
		
		************************************************************************
		** People of ages from 35 to 64
		
		* Share of population with a job (35-64)
		sum uno if inrange(edad_ci,35,64) & emp_ci==1 & migrante_ci==`var' [fw=factor_ci]
		scalar job3564_``var'_label'_pop = `=r(N)'
		
		* Activity: Share participating in the labour force (35-64)
		sum uno if inrange(edad_ci,35,64) & pea_ci==1 & migrante_ci==`var' [fw=factor_ci]
		scalar econoAct3564_``var'_label'_pop = `=r(N)'
		
		* Economically inactive people (35-64)
		sum uno if inrange(edad_ci,35,64) & (condocup_ci == 3) & migrante_ci==`var' [fw=factor_ci] 
		scalar inactive3564_``var'_label'_pop = `=r(N)'
		
		* Unemployment: Share of population who were unemployed (35-64)
		sum uno if inrange(edad_ci,35,64) & desemp_ci==1 & migrante_ci==`var' [fw=factor_ci] 
		scalar unemp3564_``var'_label'_pop = `=r(N)'
		
		sum uno if (pea_ci==1 | asiste_ci==1) & inrange(edad_ci,35,64) & migrante_ci==`var' [fw=factor_ci]
		scalar econoActWorkAge3564_``var'_label'_pop = `=r(N)'
		
		* Risk of labour market exclusion: long-term unemployment (12 months) (35-64)
		sum uno if inrange(edad_ci,35,64) & (more_12==1 & desemp_ci==1) & migrante_ci==`var' [fw=factor_ci]
		scalar long12_unemp3564_``var'_label'_pop = `=r(N)'
		
		sum uno if inrange(edad_ci,35,64) & (desemp_ci==1 | condocup_ci==3) & durades_ci!=. & migrante_ci==`var' [fw=factor_ci] 
		scalar inac_unemp3564_``var'_label'_pop = `=r(N)'
		
		* Risk of labour market exclusion: long-term unemployment (6 months) (35-64)
		sum uno if inrange(edad_ci,35,64) & (more_6==1 & desemp_ci==1) & migrante_ci==`var' [fw=factor_ci]
		scalar long6_unemp3564_``var'_label'_pop = `=r(N)'
		
		* Risk of labour market exclusion: long-term unemployment >=12 months or inactive involuntary (35-64)
		sum uno if inrange(edad_ci,35,64) & (desalent_ci==1 | (more_12==1 & desemp_ci==1)) & migrante_ci==`var' [fw=factor_ci]
		scalar long_invo3564_``var'_label'_pop = `=r(N)'
		
		* Risk of labour market exclusion: Inactive involuntary (available past week, not looking for job) (35-64)
		sum uno if inrange(edad_ci,35,64) & desalent_ci==1 & migrante_ci==`var' [fw=factor_ci]
		scalar involuntary3564_``var'_label'_pop = `=r(N)'
		
		* Share of population with written contract (35-64)
		sum uno if inrange(edad_ci,35,64) & (cotizando_ci== 1) & migrante_ci==`var' [fw=factor_ci]
		scalar written3564_``var'_label'_pop = `=r(N)'		
		
		* Share of population with an informal job (35-64)
		sum uno if inrange(edad_ci,35,64) & informal==1 & migrante_ci==`var' [fw=factor_ci]
		scalar informal3564_``var'_label'_pop = `=r(N)'
		
		* Types of contracts:  Share of population in temporary contracts (35-64)
		sum uno if inrange(edad_ci,35,64) & tipocontrato_ci==2 & migrante_ci==`var' [fw=factor_ci] 
		scalar tempJob3564_``var'_label'_pop = `=r(N)'
		
		sum uno if inrange(edad_ci,35,64) & categopri_ci!=2 & asiste_ci!=1 & emp_ci==1 & migrante_ci==`var' [fw=factor_ci]
		scalar noself_edu3564_``var'_label'_pop = `=r(N)'
		
		* Working hours: long hours >= 50 (35-64)
		sum uno if inrange(edad_ci,35,64) & more_50==1 & emp_ci == 1 & migrante_ci==`var' [fw=factor_ci]
		scalar more50h3564_``var'_label'_pop = `=r(N)'
		
		sum uno if inrange(edad_ci,35,64) & by_hours==1 & emp_ci == 1 & migrante_ci==`var' [fw=factor_ci]
		scalar hours3564_``var'_label'_pop = `=r(N)'	
	
		* Working hours: long hours < 30 (35-64)
		sum uno if inrange(edad_ci,35,64) & less_30==1 & emp_ci == 1 & migrante_ci==`var' [fw=factor_ci]
		scalar less30h3564_``var'_label'_pop = `=r(N)'

		* Job skills: share of working population in highly skilled jobs (35-64)
		sum uno if high_skilled==1 & inrange(edad_ci,35,64) & migrante_ci==`var' [fw=factor_ci]
		scalar highSkill3564_``var'_label'_pop = `=r(N)'		
		
		* Job skills: share of working population in low-skilled jobs (35-64)
		sum uno if low_skilled==1 & inrange(edad_ci,35,64) & migrante_ci==`var' [fw=factor_ci]
		scalar lowSkill3564_``var'_label'_pop = `=r(N)'
		
		sum uno if emp_ci==1 & inrange(edad_ci,35,64) & ISCO!=0 & migrante_ci==`var' [fw=factor_ci]
		scalar NotMili3564_``var'_label'_pop = `=r(N)'
		
		* Overqualification: share of highly educated individuals who work in low- or medium-skilled jobs (35-64)
		sum uno if overqualificated==1 & inrange(edad_ci,35,64) & migrante_ci==`var' & inrange(ISCED,4,9) [fw=factor_ci]
		scalar overquali3564_``var'_label'_pop = `=r(N)'
		
		sum uno if emp_ci==1 & inrange(edad_ci,35,64) & asiste_ci!=1 & ISCO!=0 & migrante_ci==`var' [fw=factor_ci]
		scalar NotEduNotMili3564_``var'_label'_pop = `=r(N)'
		
		* Self-employment: share of population who works in their own firms or businesses (35-64)
		sum uno if (categopri_ci==1 | categopri_ci==2) & inrange(edad_ci,35,64) & migrante_ci==`var' [fw=factor_ci]
		scalar selfEmp3564_``var'_label'_pop = `=r(N)'
		
		sum uno if inrange(edad_ci,35,64) & rama_ci!=1 & emp_ci==1 & migrante_ci==`var' [fw=factor_ci]
		scalar Notagri_emp3564_``var'_label'_pop = `=r(N)'
		
		* Employment in the public sector (35-64)
		sum uno if spublico_ci==1 & inrange(edad_ci,35,64) & migrante_ci==`var' [fw=factor_ci]
		scalar pubSec3564_``var'_label'_pop = `=r(N)'
		
		sum uno if inrange(edad_ci,35,64) & emp_ci==1 & categopri_ci!=2 & migrante_ci==`var' [fw=factor_ci]
		scalar NoSelf3564_``var'_label'_pop = `=r(N)'
		
		* Nominal monthly wage (USD) (35-64)
		sum nmwage if migrante_ci==`var' & inrange(edad_ci,35,64) [fw=factor_ci]
		scalar nmwage3564_``var'_label' = `=r(mean)'
		
		** SAMPLE CHARACTERISTICS
		
		* Total sample size: persons 35-64
		sum uno if inrange(edad_ci,35,64) & migrante_ci==`var'
		scalar survey_``var'_label'_3564 = `=r(N)'

		* Total persons 35-64 (with sample loadings)
		sum uno if inrange(edad_ci,35,64) & migrante_ci==`var' [fw=factor_ci]
		scalar total_``var'_label'_3564 = `=r(N)'
		
	}
	
******************************************************** EXCEL OUTPUTS

	putexcel set "C:\Users\jcamilop\OneDrive - Inter-American Development Bank Group\OECD\03 Outputs\Resultados por edad.xlsx", sheet("Uruguay") modify
	putexcel describe
	
	
	** LABOUR MARKET INDICATORS FOR PEOPLE OF AGES FROM 15 TO 34
	
	putexcel C8 = (`=job1534_nat_pop'/`=workAge1534_nat_pop') E8 = (`=job1534_migr_pop'/`=workAge1534_migr_pop') // Share of population with a job
	
	putexcel C9 = (`=econoAct1534_nat_pop'/`=workAge1534_nat_pop') E9 = (`=econoAct1534_migr_pop'/`=workAge1534_migr_pop') // Activity: Share participating in the labour force
	
	putexcel C10 = (`=inactive1534_nat_pop'/`=workAge1534_nat_pop') E10 = (`=inactive1534_migr_pop'/`=workAge1534_migr_pop')  // Economically inactive people
	
	putexcel C11 = (`=unemp1534_nat_pop'/`=econoActWorkAge1534_nat_pop') E11 = (`=unemp1534_migr_pop'/`=econoActWorkAge1534_migr_pop') // Unemployment: Share of population who were unemployed
	
	putexcel C12 = (`=long12_unemp1534_nat_pop'/`=inac_unemp1534_nat_pop') E12 = (`=long12_unemp1534_migr_pop'/`=inac_unemp1534_migr_pop') // Risk of labour market exclusion: long-term unemployment (12 month)
	
	putexcel C13 = (`=long6_unemp1534_nat_pop'/`=inac_unemp1534_nat_pop') E13 = (`=long6_unemp1534_migr_pop'/`=inac_unemp1534_migr_pop') // Risk of labour market exclusion: long-term unemployment (6 month)
	
	putexcel C14 = (`=long_invo1534_nat_pop'/`=inac_unemp1534_nat_pop') E14 = (`=long_invo1534_migr_pop'/`=inac_unemp1534_migr_pop') // Long-term uemployment >=12 months or inactive involuntary	
	
	putexcel C15 = (`=involuntary1534_nat_pop'/`=inac_unemp1534_nat_pop') E15 = (`=involuntary1534_migr_pop'/`=inac_unemp1534_migr_pop') // Inactive involuntary (available past week, not looking for job)
	
	putexcel C16 = (`=written1534_nat_pop'/`=econoAct1534_nat_pop') E16 = (`=written1534_migr_pop'/`=econoAct1534_migr_pop') // Share of population with written contract
	
	putexcel C17 = (`=informal1534_nat_pop'/`=job1534_nat_pop') E17 = (`=informal1534_migr_pop'/`=job1534_migr_pop') // Share of population with an informal job	
	
    // Share of population with an informal job (OECD def)
	
	putexcel C19 = (`=tempJob1534_nat_pop'/`=noself_edu1534_nat_pop') E19 = (`=tempJob1534_migr_pop'/`=noself_edu1534_migr_pop') // Types of contracts: Share of population in temporary contracts	

	putexcel C20 = (`=more50h1534_nat_pop'/`=hours1534_nat_pop') E20 = (`=more50h1534_migr_pop'/`=hours1534_migr_pop')  // Working hours: long (more than 50) hours
	
	putexcel C21 = (`=less30h1534_nat_pop'/`=hours1534_nat_pop') E21 = (`=less30h1534_migr_pop'/`=hours1534_migr_pop')  // Working hours: long (less than 30) hours	
	
	putexcel C22 = (`=highSkill1534_nat_pop'/`=NotMili1534_nat_pop') E22 = (`=highSkill1534_migr_pop'/`=NotMili1534_migr_pop') // Job skills: share of working population in highly skilled jobs
	
	putexcel C23 = (`=lowSkill1534_nat_pop'/`=NotMili1534_nat_pop') E23 = (`=lowSkill1534_migr_pop'/`=NotMili1534_migr_pop') // Job skills: share of working population in low-skilled jobs 
		
	putexcel C24 = (`=overquali1534_nat_pop'/`=NotEduNotMili1534_nat_pop') E24 = (`=overquali1534_migr_pop'/`=NotEduNotMili1534_migr_pop') // Overqualification: share of highly educated individuals who work in low- or medium-skilled jobs

	putexcel C25 = (`=selfEmp1534_nat_pop'/`=Notagri_emp1534_nat_pop') E25 = (`=selfEmp1534_migr_pop'/`=Notagri_emp1534_migr_pop')   // Self-employment: share of population who work in their own firms or businesses
	
	putexcel C26 = (`=pubSec1534_nat_pop'/`=NoSelf1534_nat_pop') E26 = (`=pubSec1534_migr_pop'/`=NoSelf1534_migr_pop')   // Employment in the public sector
	
	putexcel C27 = (`=nmwage1534_nat')  E27 = (`=nmwage1534_migr') // Nominal monthly wage (USD)
	
	
	** SIMPLE CHARACTERISTICS (15 - 34)
	
	putexcel C33 = (`=survey_nat_pop') E33 = (`=survey_migr_pop') // Total sample size: persons
	
	putexcel C34 = (`=survey_nat_1534') E34 = (`=survey_migr_1534') // Total sample size: persons 15-64
	
	putexcel C36 = (`=nat_pop') E36 = (`=migr_pop') // Total population (with sample loadings)
	
	putexcel C37 = (`=total_nat_1534') E37 = (`=total_migr_1534') // Total persons 15-64 (with sample loadings)
	
	
	** LABOUR MARKET INDICATORS FOR PEOPLE OF AGES FROM 35 TO 64
	
	putexcel D8 = (`=job3564_nat_pop'/`=workAge3564_nat_pop') F8 = (`=job3564_migr_pop'/`=workAge3564_migr_pop') // Share of population with a job
	
	putexcel D9 = (`=econoAct3564_nat_pop'/`=workAge3564_nat_pop') F9 = (`=econoAct3564_migr_pop'/`=workAge3564_migr_pop') // Activity: Share participating in the labour force
	
	putexcel D10 = (`=inactive3564_nat_pop'/`=workAge3564_nat_pop') F10 = (`=inactive3564_migr_pop'/`=workAge3564_migr_pop')  // Economically inactive people
	
	putexcel D11 = (`=unemp3564_nat_pop'/`=econoActWorkAge3564_nat_pop') F11 = (`=unemp3564_migr_pop'/`=econoActWorkAge3564_migr_pop') // Unemployment: Share of population who were unemployed
	
	putexcel D12 = (`=long12_unemp3564_nat_pop'/`=inac_unemp3564_nat_pop') F12 = (`=long12_unemp3564_migr_pop'/`=inac_unemp3564_migr_pop') // Risk of labour market exclusion: long-term unemployment (12 month)
	
	putexcel D13 = (`=long6_unemp3564_nat_pop'/`=inac_unemp3564_nat_pop') F13 = (`=long6_unemp3564_migr_pop'/`=inac_unemp3564_migr_pop') // Risk of labour market exclusion: long-term unemployment (6 month)
	
	putexcel D14 = (`=long_invo3564_nat_pop'/`=inac_unemp3564_nat_pop') F14 = (`=long_invo3564_migr_pop'/`=inac_unemp3564_migr_pop') // Long-term uemployment >=12 months or inactive involuntary	
	
	putexcel D15 = (`=involuntary3564_nat_pop'/`=inac_unemp3564_nat_pop') F15 = (`=involuntary3564_migr_pop'/`=inac_unemp3564_migr_pop') // Inactive involuntary (available past week, not looking for job)
	
	putexcel D16 = (`=written3564_nat_pop'/`=econoAct3564_nat_pop') F16 = (`=written3564_migr_pop'/`=econoAct3564_migr_pop') // Share of population with written contract
	
	putexcel D17 = (`=informal3564_nat_pop'/`=job3564_nat_pop') F17 = (`=informal3564_migr_pop'/`=job3564_migr_pop') // Share of population with an informal job	
	
    // Share of population with an informal job (OECD def)
	
	putexcel D19 = (`=tempJob3564_nat_pop'/`=noself_edu3564_nat_pop') F19 = (`=tempJob3564_migr_pop'/`=noself_edu3564_migr_pop') // Types of contracts: Share of population in temporary contracts	

	putexcel D20 = (`=more50h3564_nat_pop'/`=hours3564_nat_pop') F20 = (`=more50h3564_migr_pop'/`=hours3564_migr_pop')  // Working hours: long (more than 50) hours
	
	putexcel D21 = (`=less30h3564_nat_pop'/`=hours3564_nat_pop') F21 = (`=less30h3564_migr_pop'/`=hours3564_migr_pop')  // Working hours: long (less than 30) hours	
	
	putexcel D22 = (`=highSkill3564_nat_pop'/`=NotMili3564_nat_pop') F22 = (`=highSkill3564_migr_pop'/`=NotMili3564_migr_pop') // Job skills: share of working population in highly skilled jobs
	
	putexcel D23 = (`=lowSkill3564_nat_pop'/`=NotMili3564_nat_pop') F23 = (`=lowSkill3564_migr_pop'/`=NotMili3564_migr_pop') // Job skills: share of working population in low-skilled jobs 
		
	putexcel D24 = (`=overquali3564_nat_pop'/`=NotEduNotMili3564_nat_pop') F24 = (`=overquali3564_migr_pop'/`=NotEduNotMili3564_migr_pop') // Overqualification: share of highly educated individuals who work in low- or medium-skilled jobs

	putexcel D25 = (`=selfEmp3564_nat_pop'/`=Notagri_emp3564_nat_pop') F25 = (`=selfEmp3564_migr_pop'/`=Notagri_emp3564_migr_pop')   // Self-employment: share of population who work in their own firms or businesses
	
	putexcel D26 = (`=pubSec3564_nat_pop'/`=NoSelf3564_nat_pop') F26 = (`=pubSec3564_migr_pop'/`=NoSelf3564_migr_pop')   // Employment in the public sector
	
	putexcel D27 = (`=nmwage3564_nat')  F27 = (`=nmwage3564_migr') // Nominal monthly wage (USD)
	
	** SIMPLE CHARACTERISTICS (35 - 64)
	
	putexcel D34 = (`=survey_nat_3564') F34 = (`=survey_migr_3564') // Total sample size: persons 15-64
	
	putexcel D37 = (`=total_nat_3564') F37 = (`=total_migr_3564') // Total persons 15-64 (with sample loadings)
