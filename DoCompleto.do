********************************************************************************
********************************************************************************
********************************************************************************
****** BARBADOS - LABOUR FORCE SURVEY 2016 *************************************
	
	clear all
	set more off, perm
	set maxvar 15000
	scalar drop _all

	** Base de datos
	cd "C:\Users\JCAMILOP\OneDrive - Inter-American Development Bank Group\Otros\Indicadores PNUD\Bases de datos"
	use "BRB_2016m1_m6_BID.dta", replace

	gen uno=1
	replace factor_ci=round(factor_ci) // Applies when the expansion factor is a non-integer numbers
	gen migrante_ci = (ntlty != 0) if ntlty != 9
	replace migrante_ci = 0 if migrante_ci == .
	
	****************************************************************************
	** LOCALS
		local 1_label = "migr"
		local 0_label = "nat"
		
		local 1_sexo = "masc_"
		local 2_sexo = "fem_"
		
	****************************************************************************
	** Tamaño del hogar
	by idh_ch, sort: egen nmiembros=sum(relacion_ci>=1 & relacion_ci<5)	
	by idh_ch, sort: egen nhijos=sum(relacion_ci==3)
	
	****************************************************************************
	** Informalidad
	*gen informal = 1 if cotizando_ci != 1 & emp_ci==1
	*replace informal =1 if informal!=1 & afiliado_ci != 1 & emp_ci==1
	
	****************************************************************************
	** Muestra total
	sum uno if migrante_ci!=.
	scalar tot_muestra = `=r(N)'
	
	****************************************************************************
	** Muestra migrantes
	sum uno if migrante_ci==1
	scalar migr_muestra = `=r(N)'
	
	****************************************************************************
	** Muestra nativos
	sum uno if migrante_ci==0
	scalar nat_muestra = `=r(N)'
	
	****************************************************************************
	** Población total según factores de expansión
	sum uno if migrante_ci!=. [fw=factor_ci]
	scalar tot_pob = `=r(N)'
	
	****************************************************************************
	** Población migrante según factores de expansión
	sum uno if migrante_ci==1 [fw=factor_ci]
	scalar migr_pob = `=r(N)'
	
	****************************************************************************
	** Población nativa según factores de expansión
	sum uno if migrante_ci==0 [fw=factor_ci]
	scalar nat_pob = `=r(N)'
	
	****************************************************************************
	** Nivel educativo
	gen nivel_educ = 0 if eduno_ci == 1
	replace nivel_educ = 1 if edupre_ci == 1 & edupc_ci == 0
	replace nivel_educ = 2 if edupc_ci == 1 & edusc_ci == 0
	replace nivel_educ = 3 if edusc_ci == 1 & eduuc_ci == 0
	replace nivel_educ = 4 if eduuc_ci == 1
	
	****************************************************************************
	** Ingresos totales
	egen totIng=rowtotal(ylm_ci ylnm_ci ynlm_ci ynlnm_ci remesas_ci)
	
	****************************************************************************
	** Distribución ingresos
	xtile ing_dec=totIng if edad_ci>15 & pea_ci==1, n(10)
	
	* Decil 1
	gen dec_1=(ing_dec==1)
	replace dec_1=. if ing_dec==.

	* Decil 2
	gen dec_2=(ing_dec==2)
	replace dec_2=. if ing_dec==.

	* Decil 3
	gen dec_3=(ing_dec==3)
	replace dec_3=. if ing_dec==.
	
	* Decil 4
	gen dec_4=(ing_dec==4)
	replace dec_4=. if ing_dec==.

	* Decil 5 
	gen dec_5=(ing_dec==5)
	replace dec_5=. if ing_dec==.

	* Decil 6
	gen dec_6=(ing_dec==6)
	replace dec_6=. if ing_dec==.
	
	* Decil 7
	gen dec_7=(ing_dec==7)
	replace dec_7=. if ing_dec==.

	* Decil 8
	gen dec_8=(ing_dec==8)
	replace dec_8=. if ing_dec==.

	* Decil 9
	gen dec_9=(ing_dec==9)
	replace dec_9=. if ing_dec==.
	
	* Decil 10
	gen dec_10=(ing_dec==10)
	replace dec_10=. if ing_dec==.
	
	****************************************************************************
	** Cálculo de indicadores por migrantes y nativos
	
	foreach var in 1 0 {
		
		*********************** Indicadores demográficos ***********************	
		
		* Mujeres
		sum uno if sexo_ci==2 & migrante_ci==`var' [fw=factor_ci]
		scalar mujer_``var'_label'_pob =`=r(N)'
		
		* Mujeres muestra
		sum uno if sexo_ci==2 & migrante_ci==`var'
		scalar mujer_``var'_label'_muestra =`=r(N)'
		
		* Grupos de edades
		sum uno if inrange(edad_ci,0,14) & migrante_ci==`var' [fw=factor_ci]
		scalar pob_``var'_label'_014 = `=r(N)' // 0 - 14 years
		
		sum uno if inrange(edad_ci,15,24) & migrante_ci==`var' [fw=factor_ci]
		scalar pob_``var'_label'_1524 = `=r(N)' // 15 - 24 years

		sum uno if inrange(edad_ci,25,39) & migrante_ci==`var' [fw=factor_ci]
		scalar pob_``var'_label'_2539 = `=r(N)' // 25 - 39 years
		
		sum uno if inrange(edad_ci,40,54) & migrante_ci==`var' [fw=factor_ci]
		scalar pob_``var'_label'_4054 = `=r(N)' // 40 - 54 years

		sum uno if inrange(edad_ci,55,64) & migrante_ci==`var' [fw=factor_ci]
		scalar pob_``var'_label'_5564 = `=r(N)'	//55 - 64 years
		
		sum uno if inrange(edad_ci,65,.) & migrante_ci==`var' [fw=factor_ci]
		scalar pob_``var'_label'_65mas = `=r(N)'  // 65 older years
		
		* Muestra grupos de edades
		sum uno if inrange(edad_ci,0,14) & migrante_ci==`var'
		scalar muestra_``var'_label'_014 = `=r(N)' // 0 - 14 years
		
		sum uno if inrange(edad_ci,15,24) & migrante_ci==`var'
		scalar muestra_``var'_label'_1524 = `=r(N)' // 15 - 24 years

		sum uno if inrange(edad_ci,25,39) & migrante_ci==`var'
		scalar muestra_``var'_label'_2539 = `=r(N)' // 25 - 39 years
		
		sum uno if inrange(edad_ci,40,54) & migrante_ci==`var'
		scalar muestra_``var'_label'_4054 = `=r(N)' // 40 - 54 years

		sum uno if inrange(edad_ci,55,64) & migrante_ci==`var'
		scalar muestra_``var'_label'_5564 = `=r(N)'	//55 - 64 years
		
		sum uno if inrange(edad_ci,65,.) & migrante_ci==`var'
		scalar muestra_``var'_label'_65mas = `=r(N)'  // 65 older years
		
		* Tamaño del hogar
		sum nmiembros if migrante_ci==`var' [fw=factor_ci]
		scalar tam_``var'_label'_hogar = `=r(mean)'
		
		* Muestra tamaño hogar
		sum nmiembros if migrante_ci==`var'
		scalar Mtam_``var'_label'_hogar = `=r(N)'
		
		* Número de hijos
		sum nhijos if migrante_ci==`var' [fw=factor_ci]
		scalar num_``var'_label'_hijos = `=r(mean)'
		
		* Muestra número de hijos
		sum nhijos if migrante_ci==`var'
		scalar Mnum_``var'_label'_hijos = `=r(N)'
		
		
		********** Indicadores por ubicación geográfica ***********************

		* Porcentaje en zonas urbanas
		sum uno if zona_c==1 & migrante_ci==`var' [fw=factor_ci]
		scalar urbana_``var'_label'_pob = `=r(N)'
		
		* Muestra en zonas urbanas
		sum uno if zona_c==1 & migrante_ci==`var'
		scalar urbana_``var'_label'_muestra = `=r(N)'
		
		* Porcentaje en zonas rurales
		sum uno if zona_c==1 & migrante_ci==`var' [fw=factor_ci]
		scalar rural_``var'_label'_pob = `=r(N)'
		
		* Muestra en zonas rurales
		sum uno if zona_c==1 & migrante_ci==`var'
		scalar rural_``var'_label'_muestra = `=r(N)'
		
		* Porcentaje en ciudad capital
		*sum uno if region_c==17 & migrante_ci==`var' [fw=factor_ci]
		*scalar capital_``var'_label'_pob = `=r(N)'
		
		* Muestra en ciudad capital
		*sum uno if region_c== & migrante_ci==`var'
		*scalar capital_``var'_label'_muestra = `=r(N)'
		
		
		************* Indicadores por nivel de educación completo **************
		
		* Ningún nivel educativo completado
		sum uno if nivel_educ==0 & migrante_ci==`var' [fw=factor_ci]
		scalar NoEdu_``var'_label'_pob = `=r(N)'
		
		* Muestra ningún nivel educativo completado
		sum uno if nivel_educ==0 & migrante_ci==`var'
		scalar NoEdu_``var'_label'_muestra = `=r(N)'
		
		* Preescolar
		sum uno if nivel_educ==1 & migrante_ci==`var' [fw=factor_ci]
		scalar EduPre_``var'_label'_pob = `=r(N)'
		
		* Muestra preescolar
		sum uno if nivel_educ==1 & migrante_ci==`var'
		scalar EduPre_``var'_label'_muestra = `=r(N)'
		
		* Primaria
		sum uno if nivel_educ==2 & migrante_ci==`var' [fw=factor_ci]
		scalar EduPrim_``var'_label'_pob = `=r(N)'
		
		* Muestra primaria
		sum uno if nivel_educ==2 & migrante_ci==`var'
		scalar EduPrim_``var'_label'_muestra = `=r(N)'
		
		* Secundaria
		sum uno if nivel_educ==3 & migrante_ci==`var' [fw=factor_ci]
		scalar EduSecu_``var'_label'_pob = `=r(N)'
		
		* Muestra secundaria
		sum uno if nivel_educ==3 & migrante_ci==`var'
		scalar EduSecu_``var'_label'_muestra = `=r(N)'
		
		* Terciaria
		sum uno if nivel_educ==4 & migrante_ci==`var' [fw=factor_ci]
		scalar EduTerc_``var'_label'_pob = `=r(N)'
		
		sum uno if nivel_educ!=. & migrante_ci==`var' [fw=factor_ci]
		scalar NMEdu_``var'_label'_pob = `=r(N)'
		
		* Muestra terciaria
		sum uno if nivel_educ==4 & migrante_ci==`var'
		scalar EduTerc_``var'_label'_muestra = `=r(N)'		
		
		
		**************** Indicadores por situación laboral *********************
		
		* Población en edad de trabajar
		sum uno if inrange(edad_ci,15,64) & migrante_ci==`var' [fw=factor_ci]
		scalar edadTrab_``var'_label'_pob = `=r(N)'
		
		* Muestra en edad de trabajar
		sum uno if inrange(edad_ci,15,64) & migrante_ci==`var'
		scalar edadTrab_``var'_label'_muestra = `=r(N)'
		
		* Población económicamente activa
		sum uno if inrange(edad_ci,15,64) & pea_ci==1 & migrante_ci==`var' [fw=factor_ci]
		scalar econoAct_``var'_label'_pob = `=r(N)'
		
		* Muestra económicamente activa
		sum uno if inrange(edad_ci,15,64) & pea_ci==1 & migrante_ci==`var'
		scalar econoAct_``var'_label'_muestra = `=r(N)'
		
		* Población empleada
		sum uno if inrange(edad_ci,15,64) & emp_ci==1 & migrante_ci==`var' [fw=factor_ci]
		scalar emp_``var'_label'_pob = `=r(N)'
		
		* Muestra empleada
		sum uno if inrange(edad_ci,15,64) & emp_ci==1 & migrante_ci==`var'
		scalar emp_``var'_label'_muestra = `=r(N)'
		
		* Población desempleada
		sum uno if inrange(edad_ci,15,64) & desemp_ci==1 & migrante_ci==`var' [fw=factor_ci] 
		scalar desemp_``var'_label'_pob = `=r(N)'
		
		* Muestra desempleada
		sum uno if inrange(edad_ci,15,64) & desemp_ci==1 & migrante_ci==`var'
		scalar desemp_``var'_label'_muestra = `=r(N)'
		
		* Informales
		*sum uno if inrange(edad_ci,15,64) & informal==1 & migrante_ci==`var' [fw=factor_ci]
		*scalar informal_``var'_label'_pob = `=r(N)'
		
		* Muestra informales
		*sum uno if inrange(edad_ci,15,64) & informal==1 & migrante_ci==`var'
		*scalar informal_``var'_label'_muestra = `=r(N)'	
		
		**************** Indicadores por categorías de ingresos ****************
		
		* Decil 1
		sum uno if migrante_ci==`var' & dec_1 == 1 [fw=factor_ci]
		scalar D1_``var'_label'_pob = `=r(N)'
		
		* Muestra decil 1
		sum uno if migrante_ci==`var' & dec_1 == 1
		scalar D1_``var'_label'_muestra = `=r(N)'

		* Decil 2
		sum uno if migrante_ci==`var' & dec_2 == 1 [fw=factor_ci]
		scalar D2_``var'_label'_pob = `=r(N)'
		
		* Muestra decil 2
		sum uno if migrante_ci==`var' & dec_2 == 1
		scalar D2_``var'_label'_muestra = `=r(N)'
		
		* Decil 3
		sum uno if migrante_ci==`var' & dec_3 == 1 [fw=factor_ci]
		scalar D3_``var'_label'_pob = `=r(N)'
		
		* Muestra decil 3
		sum uno if migrante_ci==`var' & dec_3 == 1
		scalar D3_``var'_label'_muestra = `=r(N)'
		
		* Decil 4
		sum uno if migrante_ci==`var' & dec_4 == 1 [fw=factor_ci]
		scalar D4_``var'_label'_pob = `=r(N)'
		
		* Muestra decil 4
		sum uno if migrante_ci==`var' & dec_4 == 1
		scalar D4_``var'_label'_muestra = `=r(N)'
		
		* Decil 5
		sum uno if migrante_ci==`var' & dec_5 == 1 [fw=factor_ci]
		scalar D5_``var'_label'_pob = `=r(N)'
		
		* Muestra decil 5
		sum uno if migrante_ci==`var' & dec_5 == 1
		scalar D5_``var'_label'_muestra = `=r(N)'
		
		* Decil 6
		sum uno if migrante_ci==`var' & dec_6 == 1 [fw=factor_ci]
		scalar D6_``var'_label'_pob = `=r(N)'
		
		* Muestra decil 6
		sum uno if migrante_ci==`var' & dec_6 == 1
		scalar D6_``var'_label'_muestra = `=r(N)'
		
		* Decil 7
		sum uno if migrante_ci==`var' & dec_7 == 1 [fw=factor_ci]
		scalar D7_``var'_label'_pob = `=r(N)'
		
		* Muestra decil 7
		sum uno if migrante_ci==`var' & dec_7 == 1
		scalar D7_``var'_label'_muestra = `=r(N)'
		
		* Decil 8
		sum uno if migrante_ci==`var' & dec_8 == 1 [fw=factor_ci]
		scalar D8_``var'_label'_pob = `=r(N)'
		
		* Muestra decil 8
		sum uno if migrante_ci==`var' & dec_8 == 1
		scalar D8_``var'_label'_muestra = `=r(N)'
		
		* Decil 9
		sum uno if migrante_ci==`var' & dec_9 == 1 [fw=factor_ci]
		scalar D9_``var'_label'_pob = `=r(N)'
		
		* Muestra decil 9
		sum uno if migrante_ci==`var' & dec_9 == 1
		scalar D9_``var'_label'_muestra = `=r(N)'
		
		* Decil 10
		sum uno if migrante_ci==`var' & dec_10 == 1 [fw=factor_ci]
		scalar D10_``var'_label'_pob = `=r(N)'
		
		* Muestra decil 10
		sum uno if migrante_ci==`var' & dec_10 == 1
		scalar D10_``var'_label'_muestra = `=r(N)'
		
		sum uno if migrante_ci==`var' & (ing_dec!=.) [fw=factor_ci]
		scalar NMIng_``var'_label'_pob = `=r(N)'
	
		}
	
******************************************************** EXCEL OUTPUTS

	putexcel set "C:\Users\JCAMILOP\OneDrive - Inter-American Development Bank Group\Otros\Indicadores PNUD\Documentos\Resultados.xlsx", sheet("Indicadores") modify
	putexcel describe
	
	
	************************** Indicadores demográficos ***********************
	
	** Población
	putexcel C5 = (`=nat_pob'/`=tot_pob') D5 = (`=migr_pob'/`=tot_pob')	// Porcentaje de migrantes
	putexcel C6 = (`=nat_muestra') D6 = (`=migr_muestra')	// Tamaño de la muestra
	putexcel C7 = (`=mujer_nat_pob'/`=nat_pob') D7 = (`=mujer_migr_pob'/`=migr_pob')	// Porcentaje de mujeres
	putexcel C8 = (`=mujer_nat_muestra') D8 = (`=mujer_migr_muestra')	// Tamaño de la muestra
	
	* Edades 
	putexcel C9 = (`=pob_nat_014'/`=nat_pob') D9 = (`=pob_migr_014'/`=migr_pob') // 0 - 14
	putexcel C10 = (`=muestra_nat_014') D10 = (`=muestra_migr_014') // Tamaño de la muestra
	putexcel C11 = (`=pob_nat_1524'/`=nat_pob') D11 = (`=pob_migr_1524'/`=migr_pob') // 15 - 24
	putexcel C12 = (`=muestra_nat_1524') D12 = (`=muestra_migr_1524') // Tamaño de la muestra
	putexcel C13 = (`=pob_nat_2539'/`=nat_pob') D13 = (`=pob_migr_2539'/`=migr_pob') // 25 - 39
	putexcel C14 = (`=muestra_nat_2539') D14 = (`=muestra_migr_2539') // Tamaño de la muestra
	putexcel C15 = (`=pob_nat_4054'/`=nat_pob') D15 = (`=pob_migr_4054'/`=migr_pob') // 40 - 54
	putexcel C16 = (`=muestra_nat_4054') D16 = (`=muestra_migr_4054') // Tamaño de la muestra
	putexcel C17 = (`=pob_nat_5564'/`=nat_pob') D17 = (`=pob_migr_5564'/`=migr_pob') // 55 - 64
	putexcel C18 = (`=muestra_nat_5564') D18 = (`=muestra_migr_5564') // Tamaño de la muestra
	putexcel C19 = (`=pob_nat_65mas'/`=nat_pob') D19 = (`=pob_migr_65mas'/`=migr_pob') // 65 más
	putexcel C20 = (`=muestra_nat_65mas') D20 = (`=muestra_migr_65mas') // Tamaño de la muestra
	
	* Tamaño del hogar
	putexcel C21 = (`=tam_nat_hogar')  D21 = (`=tam_migr_hogar') // Tamaño del hogar
	putexcel C22 = (`=Mtam_nat_hogar')  D22 = (`=Mtam_migr_hogar') // Tamaño de la muestra
	
	* Número de hijos
	putexcel C23 = (`=num_nat_hijos')  D23 = (`=num_migr_hijos') // Número de hijos
	putexcel C24 = (`=Mnum_nat_hijos')  D24 = (`=Mnum_migr_hijos') // Tamaño de la muestra
	
	
	*************** Indicadores por ubicación geográfica ***********************
	
	* Población urbana
	putexcel C26 = (`=urbana_nat_pob'/`=nat_pob') D26 = (`=urbana_migr_pob'/`=migr_pob')	
	putexcel C27 = (`=urbana_nat_muestra') D27 = (`=urbana_migr_muestra') // Tamaño de la muestra
	
	* Población rural
	putexcel C28 = (`=rural_nat_pob'/`=nat_pob') D28 = (`=rural_migr_pob'/`=migr_pob')
	putexcel C29 = (`=rural_nat_muestra') D29 = (`=rural_migr_muestra')	// Tamaño de la muestra	
	
	* Ciudad capital
	*putexcel C30 = (`=capital_nat_pob'/`=nat_pob') D30 = (`=capital_migr_pob'/`=migr_pob')
	*putexcel C31 = (`=capital_nat_muestra') D31 = (`=capital_migr_muestra') // Tamaño de la muestra	
	
	
	************** Indicadores por nivel de educación completo *****************
	
	** Por nivel educativo
	
	* Ningún nivel educativo completado
	putexcel C33 = (`=NoEdu_nat_pob'/`=NMEdu_nat_pob') D33 = (`=NoEdu_migr_pob'/`=NMEdu_migr_pob')
	putexcel C34 = (`=NoEdu_nat_muestra') D34 = (`=NoEdu_migr_muestra')	// Tamaño de la muestra
	
	** Preescolar
	putexcel C35 = (`=EduPre_nat_pob'/`=NMEdu_nat_pob') D35 = (`=EduPre_migr_pob'/`=NMEdu_migr_pob')
	putexcel C36 = (`=EduPre_nat_muestra') D36 = (`=EduPre_migr_muestra')	// Tamaño de la muestra
	
	** Primaria completa
	putexcel C37 = (`=EduPrim_nat_pob'/`=NMEdu_nat_pob') D37 = (`=EduPrim_migr_pob'/`=NMEdu_migr_pob')
	putexcel C38 = (`=EduPrim_nat_muestra') D38 = (`=EduPrim_migr_muestra')	// Tamaño de la muestra
	
	** Secundaria completa
	putexcel C39 = (`=EduSecu_nat_pob'/`=NMEdu_nat_pob') D39 = (`=EduSecu_migr_pob'/`=NMEdu_migr_pob')
	putexcel C40 = (`=EduSecu_nat_muestra') D40 = (`=EduSecu_migr_muestra')	// Tamaño de la muestra
	
	** Terciaria completa
	putexcel C41 = (`=EduTerc_nat_pob'/`=NMEdu_nat_pob') D41 = (`=EduTerc_migr_pob'/`=NMEdu_migr_pob')
	putexcel C42 = (`=EduTerc_nat_muestra') D42 = (`=EduTerc_migr_muestra')	// Tamaño de la muestra
	
	
	****************** Indicadores por situación laboral ***********************
	
	* Población en edad de trabajar
	putexcel C44 = (`=edadTrab_nat_pob'/`=nat_pob') D44 = (`=edadTrab_migr_pob'/`=migr_pob')
	putexcel C45 = (`=edadTrab_nat_muestra') D45 = (`=edadTrab_migr_muestra') // Tamaño de la muestra
	
	* Población económicamente activa
	putexcel C46 = (`=econoAct_nat_pob'/`=edadTrab_nat_pob') D46 = (`=econoAct_migr_pob'/`=edadTrab_migr_pob')
	putexcel C47 = (`=econoAct_nat_muestra') D47 = (`=econoAct_migr_muestra') // Tamaño de la muestra
	
	* Población empleada
	putexcel C48 = (`=emp_nat_pob'/`=econoAct_nat_pob') D48 = (`=emp_migr_pob'/`=econoAct_migr_pob')
	putexcel C49 = (`=emp_nat_muestra') D49 = (`=emp_migr_muestra') // Tamaño de la muestra
	
	* Población desempleada
	putexcel C50 = (`=desemp_nat_pob'/`=econoAct_nat_pob') D50 = (`=desemp_migr_pob'/`=econoAct_migr_pob')
	putexcel C51 = (`=desemp_nat_muestra') D51 = (`=desemp_migr_muestra') // Tamaño de la muestra	
	
	* Población informal
	*putexcel C52 = (`=informal_nat_pob'/`=emp_nat_pob') D52 = (`=informal_migr_pob'/`=emp_migr_pob')
	*putexcel C53 = (`=informal_nat_muestra') D53 = (`=informal_migr_muestra') // Tamaño de la muestra
	
	****************** Indicadores por categorías de ingresos ******************
	
	putexcel C55 = (`=D1_nat_pob'/`=NMIng_nat_pob') D55 = (`=D1_migr_pob'/`=NMIng_migr_pob') // (D1)
	putexcel C56 = (`=D1_nat_muestra') D56 = (`=D1_migr_muestra') // Tamaño muestra
	
	putexcel C57 = (`=D2_nat_pob'/`=NMIng_nat_pob') D57 = (`=D2_migr_pob'/`=NMIng_migr_pob') // (D2)
	putexcel C58 = (`=D2_nat_muestra') D58 = (`=D2_migr_muestra') // Tamaño muestra
	
	putexcel C59 = (`=D3_nat_pob'/`=NMIng_nat_pob') D59 = (`=D3_migr_pob'/`=NMIng_migr_pob') // (D3)
	putexcel C60 = (`=D3_nat_muestra') D60 = (`=D3_migr_muestra') // Tamaño muestra
	
	putexcel C61 = (`=D4_nat_pob'/`=NMIng_nat_pob') D61 = (`=D4_migr_pob'/`=NMIng_migr_pob') // (D4)
	putexcel C62 = (`=D4_nat_muestra') D62 = (`=D4_migr_muestra') // Tamaño muestra
	
	putexcel C63 = (`=D5_nat_pob'/`=NMIng_nat_pob') D63 = (`=D5_migr_pob'/`=NMIng_migr_pob') // (D5)
	putexcel C64 = (`=D5_nat_muestra') D64 = (`=D5_migr_muestra') // Tamaño muestra
	
	putexcel C65 = (`=D6_nat_pob'/`=NMIng_nat_pob') D65 = (`=D6_migr_pob'/`=NMIng_migr_pob') // (D6)
	putexcel C66 = (`=D6_nat_muestra') D66 = (`=D6_migr_muestra') // Tamaño muestra
	
	putexcel C67 = (`=D7_nat_pob'/`=NMIng_nat_pob') D67 = (`=D7_migr_pob'/`=NMIng_migr_pob') // (D7)
	putexcel C68 = (`=D7_nat_muestra') D68 = (`=D7_migr_muestra') // Tamaño muestra
	
	putexcel C69 = (`=D8_nat_pob'/`=NMIng_nat_pob') D69 = (`=D8_migr_pob'/`=NMIng_migr_pob') // (D8)
	putexcel C70 = (`=D8_nat_muestra') D70 = (`=D8_migr_muestra') // Tamaño muestra
	
	putexcel C71 = (`=D9_nat_pob'/`=NMIng_nat_pob') D71 = (`=D9_migr_pob'/`=NMIng_migr_pob') // (D9)
	putexcel C72 = (`=D9_nat_muestra') D72 = (`=D9_migr_muestra') // Tamaño muestra
	
	putexcel C73 = (`=D10_nat_pob'/`=NMIng_nat_pob') D73 = (`=D10_migr_pob'/`=NMIng_migr_pob') // (D10)
	putexcel C74 = (`=D10_nat_muestra') D74 = (`=D10_migr_muestra') // Tamaño muestra
	
	
********************************************************************************
********************************************************************************
********************************************************************************
****** CHILE - ENCUESTA DE CARACTERIZACIÓN SOCIOECONÓMICA NACIONAL 2020 ********
	
	clear all
	set more off, perm
	set maxvar 15000
	scalar drop _all

	** DATASET
	cd "C:\Users\JCAMILOP\OneDrive - Inter-American Development Bank Group\Otros\Indicadores PNUD\Bases de datos"
	use "CHL_2020m11_m12_m1_BID.dta", replace

	gen uno=1
	replace factor_ci=round(factor_ci) // Applies when the expansion factor is a non-integer numbers
	replace migrante_ci = 0 if migrante_ci == .
	
	****************************************************************************
	** LOCALS
		local 1_label = "migr"
		local 0_label = "nat"
		
		local 1_sexo = "masc_"
		local 2_sexo = "fem_"	
	
	****************************************************************************
	** Tamaño del hogar
	by idh_ch, sort: egen nmiembros=sum(relacion_ci>=1 & relacion_ci<5)	
	by idh_ch, sort: egen nhijos=sum(relacion_ci==3)
	
	****************************************************************************
	** Informalidad
	gen informal = 1 if cotizando_ci != 1 & emp_ci==1
	replace informal =1 if informal!=1 & afiliado_ci != 1 & emp_ci==1
	
	****************************************************************************
	** Muestra total
	sum uno if migrante_ci!=.
	scalar tot_muestra = `=r(N)'
	
	****************************************************************************
	** Muestra migrantes
	sum uno if migrante_ci==1
	scalar migr_muestra = `=r(N)'
	
	****************************************************************************
	** Muestra nativos
	sum uno if migrante_ci==0
	scalar nat_muestra = `=r(N)'
	
	****************************************************************************
	** Población total según factores de expansión
	sum uno if migrante_ci!=. [fw=factor_ci]
	scalar tot_pob = `=r(N)'
	
	****************************************************************************
	** Población migrante según factores de expansión
	sum uno if migrante_ci==1 [fw=factor_ci]
	scalar migr_pob = `=r(N)'
	
	****************************************************************************
	** Población nativa según factores de expansión
	sum uno if migrante_ci==0 [fw=factor_ci]
	scalar nat_pob = `=r(N)'
	
	****************************************************************************
	** Nivel educativo
	gen nivel_educ = 0 if eduno_ci == 1
	replace nivel_educ = 1 if edupre_ci == 1 & edupc_ci == 0
	replace nivel_educ = 2 if edupc_ci == 1 & edusc_ci == 0
	replace nivel_educ = 3 if edusc_ci == 1 & eduuc_ci == 0
	replace nivel_educ = 4 if eduuc_ci == 1
	
	****************************************************************************
	** Ingresos totales
	egen totIng=rowtotal(ylm_ci ylnm_ci ynlm_ci ynlnm_ci remesas_ci)
	
	****************************************************************************
	** Distribución ingresos
	xtile ing_dec=totIng if edad_ci>15 & pea_ci==1, n(10)
	
	* Decil 1
	gen dec_1=(ing_dec==1)
	replace dec_1=. if ing_dec==.

	* Decil 2
	gen dec_2=(ing_dec==2)
	replace dec_2=. if ing_dec==.

	* Decil 3
	gen dec_3=(ing_dec==3)
	replace dec_3=. if ing_dec==.
	
	* Decil 4
	gen dec_4=(ing_dec==4)
	replace dec_4=. if ing_dec==.

	* Decil 5 
	gen dec_5=(ing_dec==5)
	replace dec_5=. if ing_dec==.

	* Decil 6
	gen dec_6=(ing_dec==6)
	replace dec_6=. if ing_dec==.
	
	* Decil 7
	gen dec_7=(ing_dec==7)
	replace dec_7=. if ing_dec==.

	* Decil 8
	gen dec_8=(ing_dec==8)
	replace dec_8=. if ing_dec==.

	* Decil 9
	gen dec_9=(ing_dec==9)
	replace dec_9=. if ing_dec==.
	
	* Decil 10
	gen dec_10=(ing_dec==10)
	replace dec_10=. if ing_dec==.
	
	****************************************************************************
	** Cálculo de indicadores por migrantes y nativos
	
	foreach var in 1 0 {
		
		*********************** Indicadores demográficos ***********************	
		
		* Mujeres
		sum uno if sexo_ci==2 & migrante_ci==`var' [fw=factor_ci]
		scalar mujer_``var'_label'_pob =`=r(N)'
		
		* Mujeres muestra
		sum uno if sexo_ci==2 & migrante_ci==`var'
		scalar mujer_``var'_label'_muestra =`=r(N)'
		
		* Grupos de edades
		sum uno if inrange(edad_ci,0,14) & migrante_ci==`var' [fw=factor_ci]
		scalar pob_``var'_label'_014 = `=r(N)' // 0 - 14 years
		
		sum uno if inrange(edad_ci,15,24) & migrante_ci==`var' [fw=factor_ci]
		scalar pob_``var'_label'_1524 = `=r(N)' // 15 - 24 years

		sum uno if inrange(edad_ci,25,39) & migrante_ci==`var' [fw=factor_ci]
		scalar pob_``var'_label'_2539 = `=r(N)' // 25 - 39 years
		
		sum uno if inrange(edad_ci,40,54) & migrante_ci==`var' [fw=factor_ci]
		scalar pob_``var'_label'_4054 = `=r(N)' // 40 - 54 years

		sum uno if inrange(edad_ci,55,64) & migrante_ci==`var' [fw=factor_ci]
		scalar pob_``var'_label'_5564 = `=r(N)'	//55 - 64 years
		
		sum uno if inrange(edad_ci,65,.) & migrante_ci==`var' [fw=factor_ci]
		scalar pob_``var'_label'_65mas = `=r(N)'  // 65 older years
		
		* Muestra grupos de edades
		sum uno if inrange(edad_ci,0,14) & migrante_ci==`var'
		scalar muestra_``var'_label'_014 = `=r(N)' // 0 - 14 years
		
		sum uno if inrange(edad_ci,15,24) & migrante_ci==`var'
		scalar muestra_``var'_label'_1524 = `=r(N)' // 15 - 24 years

		sum uno if inrange(edad_ci,25,39) & migrante_ci==`var'
		scalar muestra_``var'_label'_2539 = `=r(N)' // 25 - 39 years
		
		sum uno if inrange(edad_ci,40,54) & migrante_ci==`var'
		scalar muestra_``var'_label'_4054 = `=r(N)' // 40 - 54 years

		sum uno if inrange(edad_ci,55,64) & migrante_ci==`var'
		scalar muestra_``var'_label'_5564 = `=r(N)'	//55 - 64 years
		
		sum uno if inrange(edad_ci,65,.) & migrante_ci==`var'
		scalar muestra_``var'_label'_65mas = `=r(N)'  // 65 older years
		
		* Tamaño del hogar
		sum nmiembros if migrante_ci==`var' [fw=factor_ci]
		scalar tam_``var'_label'_hogar = `=r(mean)'
		
		* Muestra tamaño hogar
		sum nmiembros if migrante_ci==`var'
		scalar Mtam_``var'_label'_hogar = `=r(N)'
		
		* Número de hijos
		sum nhijos if migrante_ci==`var' [fw=factor_ci]
		scalar num_``var'_label'_hijos = `=r(mean)'
		
		* Muestra número de hijos
		sum nhijos if migrante_ci==`var'
		scalar Mnum_``var'_label'_hijos = `=r(N)'
		
		
		********** Indicadores por ubicación geográfica ***********************

		* Porcentaje en zonas urbanas
		sum uno if zona_c==1 & migrante_ci==`var' [fw=factor_ci]
		scalar urbana_``var'_label'_pob = `=r(N)'
		
		* Muestra en zonas urbanas
		sum uno if zona_c==1 & migrante_ci==`var'
		scalar urbana_``var'_label'_muestra = `=r(N)'
		
		* Porcentaje en zonas rurales
		sum uno if zona_c==0 & migrante_ci==`var' [fw=factor_ci]
		scalar rural_``var'_label'_pob = `=r(N)'
		
		* Muestra en zonas rurales
		sum uno if zona_c==0 & migrante_ci==`var'
		scalar rural_``var'_label'_muestra = `=r(N)'
		
		* Porcentaje en ciudad capital
		sum uno if region_c==13 & migrante_ci==`var' [fw=factor_ci]
		scalar capital_``var'_label'_pob = `=r(N)'
		
		* Muestra en ciudad capital
		sum uno if region_c==13 & migrante_ci==`var'
		scalar capital_``var'_label'_muestra = `=r(N)'
		
		
		************* Indicadores por nivel de educación completo **************
		
		* Ningún nivel educativo completado
		sum uno if nivel_educ==0 & migrante_ci==`var' [fw=factor_ci]
		scalar NoEdu_``var'_label'_pob = `=r(N)'
		
		* Muestra ningún nivel educativo completado
		sum uno if nivel_educ==0 & migrante_ci==`var'
		scalar NoEdu_``var'_label'_muestra = `=r(N)'
		
		* Preescolar
		sum uno if nivel_educ==1 & migrante_ci==`var' [fw=factor_ci]
		scalar EduPre_``var'_label'_pob = `=r(N)'
		
		* Muestra preescolar
		sum uno if nivel_educ==1 & migrante_ci==`var'
		scalar EduPre_``var'_label'_muestra = `=r(N)'
		
		* Primaria
		sum uno if nivel_educ==2 & migrante_ci==`var' [fw=factor_ci]
		scalar EduPrim_``var'_label'_pob = `=r(N)'
		
		* Muestra primaria
		sum uno if nivel_educ==2 & migrante_ci==`var'
		scalar EduPrim_``var'_label'_muestra = `=r(N)'
		
		* Secundaria
		sum uno if nivel_educ==3 & migrante_ci==`var' [fw=factor_ci]
		scalar EduSecu_``var'_label'_pob = `=r(N)'
		
		* Muestra secundaria
		sum uno if nivel_educ==3 & migrante_ci==`var'
		scalar EduSecu_``var'_label'_muestra = `=r(N)'
		
		* Terciaria
		sum uno if nivel_educ==4 & migrante_ci==`var' [fw=factor_ci]
		scalar EduTerc_``var'_label'_pob = `=r(N)'
		
		sum uno if nivel_educ!=. & migrante_ci==`var' [fw=factor_ci]
		scalar NMEdu_``var'_label'_pob = `=r(N)'
		
		* Muestra terciaria
		sum uno if nivel_educ==4 & migrante_ci==`var'
		scalar EduTerc_``var'_label'_muestra = `=r(N)'
		
		
		**************** Indicadores por situación laboral *********************
		
		* Población en edad de trabajar
		sum uno if inrange(edad_ci,15,64) & migrante_ci==`var' [fw=factor_ci]
		scalar edadTrab_``var'_label'_pob = `=r(N)'
		
		* Muestra en edad de trabajar
		sum uno if inrange(edad_ci,15,64) & migrante_ci==`var'
		scalar edadTrab_``var'_label'_muestra = `=r(N)'
		
		* Población económicamente activa
		sum uno if inrange(edad_ci,15,64) & pea_ci==1 & migrante_ci==`var' [fw=factor_ci]
		scalar econoAct_``var'_label'_pob = `=r(N)'
		
		* Muestra económicamente activa
		sum uno if inrange(edad_ci,15,64) & pea_ci==1 & migrante_ci==`var'
		scalar econoAct_``var'_label'_muestra = `=r(N)'
		
		* Población empleada
		sum uno if inrange(edad_ci,15,64) & emp_ci==1 & migrante_ci==`var' [fw=factor_ci]
		scalar emp_``var'_label'_pob = `=r(N)'
		
		* Muestra empleada
		sum uno if inrange(edad_ci,15,64) & emp_ci==1 & migrante_ci==`var'
		scalar emp_``var'_label'_muestra = `=r(N)'
		
		* Población desempleada
		sum uno if inrange(edad_ci,15,64) & desemp_ci==1 & migrante_ci==`var' [fw=factor_ci] 
		scalar desemp_``var'_label'_pob = `=r(N)'
		
		* Muestra desempleada
		sum uno if inrange(edad_ci,15,64) & desemp_ci==1 & migrante_ci==`var'
		scalar desemp_``var'_label'_muestra = `=r(N)'
		
		* Informales
		sum uno if inrange(edad_ci,15,64) & informal==1 & migrante_ci==`var' [fw=factor_ci]
		scalar informal_``var'_label'_pob = `=r(N)'
		
		* Muestra informales
		sum uno if inrange(edad_ci,15,64) & informal==1 & migrante_ci==`var'
		scalar informal_``var'_label'_muestra = `=r(N)'
		
		**************** Indicadores por categorías de ingresos ****************
		
		* Decil 1
		sum uno if migrante_ci==`var' & dec_1 == 1 [fw=factor_ci]
		scalar D1_``var'_label'_pob = `=r(N)'
		
		* Muestra decil 1
		sum uno if migrante_ci==`var' & dec_1 == 1
		scalar D1_``var'_label'_muestra = `=r(N)'

		* Decil 2
		sum uno if migrante_ci==`var' & dec_2 == 1 [fw=factor_ci]
		scalar D2_``var'_label'_pob = `=r(N)'
		
		* Muestra decil 2
		sum uno if migrante_ci==`var' & dec_2 == 1
		scalar D2_``var'_label'_muestra = `=r(N)'
		
		* Decil 3
		sum uno if migrante_ci==`var' & dec_3 == 1 [fw=factor_ci]
		scalar D3_``var'_label'_pob = `=r(N)'
		
		* Muestra decil 3
		sum uno if migrante_ci==`var' & dec_3 == 1
		scalar D3_``var'_label'_muestra = `=r(N)'
		
		* Decil 4
		sum uno if migrante_ci==`var' & dec_4 == 1 [fw=factor_ci]
		scalar D4_``var'_label'_pob = `=r(N)'
		
		* Muestra decil 4
		sum uno if migrante_ci==`var' & dec_4 == 1
		scalar D4_``var'_label'_muestra = `=r(N)'
		
		* Decil 5
		sum uno if migrante_ci==`var' & dec_5 == 1 [fw=factor_ci]
		scalar D5_``var'_label'_pob = `=r(N)'
		
		* Muestra decil 5
		sum uno if migrante_ci==`var' & dec_5 == 1
		scalar D5_``var'_label'_muestra = `=r(N)'
		
		* Decil 6
		sum uno if migrante_ci==`var' & dec_6 == 1 [fw=factor_ci]
		scalar D6_``var'_label'_pob = `=r(N)'
		
		* Muestra decil 6
		sum uno if migrante_ci==`var' & dec_6 == 1
		scalar D6_``var'_label'_muestra = `=r(N)'
		
		* Decil 7
		sum uno if migrante_ci==`var' & dec_7 == 1 [fw=factor_ci]
		scalar D7_``var'_label'_pob = `=r(N)'
		
		* Muestra decil 7
		sum uno if migrante_ci==`var' & dec_7 == 1
		scalar D7_``var'_label'_muestra = `=r(N)'
		
		* Decil 8
		sum uno if migrante_ci==`var' & dec_8 == 1 [fw=factor_ci]
		scalar D8_``var'_label'_pob = `=r(N)'
		
		* Muestra decil 8
		sum uno if migrante_ci==`var' & dec_8 == 1
		scalar D8_``var'_label'_muestra = `=r(N)'
		
		* Decil 9
		sum uno if migrante_ci==`var' & dec_9 == 1 [fw=factor_ci]
		scalar D9_``var'_label'_pob = `=r(N)'
		
		* Muestra decil 9
		sum uno if migrante_ci==`var' & dec_9 == 1
		scalar D9_``var'_label'_muestra = `=r(N)'
		
		* Decil 10
		sum uno if migrante_ci==`var' & dec_10 == 1 [fw=factor_ci]
		scalar D10_``var'_label'_pob = `=r(N)'
		
		* Muestra decil 10
		sum uno if migrante_ci==`var' & dec_10 == 1
		scalar D10_``var'_label'_muestra = `=r(N)'
		
		sum uno if migrante_ci==`var' & (ing_dec!=.) [fw=factor_ci]
		scalar NMIng_``var'_label'_pob = `=r(N)'
	
		}
	
******************************************************** EXCEL OUTPUTS

	putexcel set "C:\Users\JCAMILOP\OneDrive - Inter-American Development Bank Group\Otros\Indicadores PNUD\Documentos\Resultados.xlsx", sheet("Indicadores") modify
	putexcel describe
	
	
	************************** Indicadores demográficos ***********************
	
	** Población
	putexcel E5 = (`=nat_pob'/`=tot_pob') F5 = (`=migr_pob'/`=tot_pob')	// Porcentaje de migrantes
	putexcel E6 = (`=nat_muestra') F6 = (`=migr_muestra')	// Tamaño de la muestra
	putexcel E7 = (`=mujer_nat_pob'/`=nat_pob') F7 = (`=mujer_migr_pob'/`=migr_pob')	// Porcentaje de mujeres
	putexcel E8 = (`=mujer_nat_muestra') F8 = (`=mujer_migr_muestra')	// Tamaño de la muestra
	
	* Edades 
	putexcel E9 = (`=pob_nat_014'/`=nat_pob') F9 = (`=pob_migr_014'/`=migr_pob') // 0 - 14
	putexcel E10 = (`=muestra_nat_014') F10 = (`=muestra_migr_014') // Tamaño de la muestra
	putexcel E11 = (`=pob_nat_1524'/`=nat_pob') F11 = (`=pob_migr_1524'/`=migr_pob') // 15 - 24
	putexcel E12 = (`=muestra_nat_1524') F12 = (`=muestra_migr_1524') // Tamaño de la muestra
	putexcel E13 = (`=pob_nat_2539'/`=nat_pob') F13 = (`=pob_migr_2539'/`=migr_pob') // 25 - 39
	putexcel E14 = (`=muestra_nat_2539') F14 = (`=muestra_migr_2539') // Tamaño de la muestra
	putexcel E15 = (`=pob_nat_4054'/`=nat_pob') F15 = (`=pob_migr_4054'/`=migr_pob') // 40 - 54
	putexcel E16 = (`=muestra_nat_4054') F16 = (`=muestra_migr_4054') // Tamaño de la muestra
	putexcel E17 = (`=pob_nat_5564'/`=nat_pob') F17 = (`=pob_migr_5564'/`=migr_pob') // 55 - 64
	putexcel E18 = (`=muestra_nat_5564') F18 = (`=muestra_migr_5564') // Tamaño de la muestra
	putexcel E19 = (`=pob_nat_65mas'/`=nat_pob') F19 = (`=pob_migr_65mas'/`=migr_pob') // 65 más
	putexcel E20 = (`=muestra_nat_65mas') F20 = (`=muestra_migr_65mas') // Tamaño de la muestra
	
	* Tamaño del hogar
	putexcel E21 = (`=tam_nat_hogar')  F21 = (`=tam_migr_hogar') // Tamaño del hogar
	putexcel E22 = (`=Mtam_nat_hogar')  F22 = (`=Mtam_migr_hogar') // Tamaño de la muestra
	
	* Número de hijos
	putexcel E23 = (`=num_nat_hijos')  F23 = (`=num_migr_hijos') // Número de hijos
	putexcel E24 = (`=Mnum_nat_hijos')  F24 = (`=Mnum_migr_hijos') // Tamaño de la muestra
	
	
	*************** Indicadores por ubicación geográfica ***********************
	
	* Población urbana
	putexcel E26 = (`=urbana_nat_pob'/`=nat_pob') F26 = (`=urbana_migr_pob'/`=migr_pob')	
	putexcel E27 = (`=urbana_nat_muestra') F27 = (`=urbana_migr_muestra') // Tamaño de la muestra
	
	* Población rural
	putexcel E28 = (`=rural_nat_pob'/`=nat_pob') F28 = (`=rural_migr_pob'/`=migr_pob')
	putexcel E29 = (`=rural_nat_muestra') F29 = (`=rural_migr_muestra')	// Tamaño de la muestra	
	
	* Ciudad capital
	putexcel E30 = (`=capital_nat_pob'/`=nat_pob') F30 = (`=capital_migr_pob'/`=migr_pob')
	putexcel E31 = (`=capital_nat_muestra') F31 = (`=capital_migr_muestra') // Tamaño de la muestra	
	
	
	************** Indicadores por nivel de educación completo *****************
	
	** Por nivel educativo
	
	* Ningún nivel educativo completado
	putexcel E33 = (`=NoEdu_nat_pob'/`=NMEdu_nat_pob') F33 = (`=NoEdu_migr_pob'/`=NMEdu_migr_pob')
	putexcel E34 = (`=NoEdu_nat_muestra') F34 = (`=NoEdu_migr_muestra')	// Tamaño de la muestra
	
	** Preescolar
	putexcel E35 = (`=EduPre_nat_pob'/`=NMEdu_nat_pob') F35 = (`=EduPre_migr_pob'/`=NMEdu_migr_pob')
	putexcel E36 = (`=EduPre_nat_muestra') F36 = (`=EduPre_migr_muestra')	// Tamaño de la muestra
	
	** Primaria completa
	putexcel E37 = (`=EduPrim_nat_pob'/`=NMEdu_nat_pob') F37 = (`=EduPrim_migr_pob'/`=NMEdu_migr_pob')
	putexcel E38 = (`=EduPrim_nat_muestra') F38 = (`=EduPrim_migr_muestra')	// Tamaño de la muestra
	
	** Secundaria completa
	putexcel E39 = (`=EduSecu_nat_pob'/`=NMEdu_nat_pob') F39 = (`=EduSecu_migr_pob'/`=NMEdu_migr_pob')
	putexcel E40 = (`=EduSecu_nat_muestra') F40 = (`=EduSecu_migr_muestra')	// Tamaño de la muestra
	
	** Terciaria completa
	putexcel E41 = (`=EduTerc_nat_pob'/`=NMEdu_nat_pob') F41 = (`=EduTerc_migr_pob'/`=NMEdu_migr_pob')
	putexcel E42 = (`=EduTerc_nat_muestra') F42 = (`=EduTerc_migr_muestra')	// Tamaño de la muestra
	
	
	****************** Indicadores por situación laboral ***********************
	
	* Población en edad de trabajar
	putexcel E44 = (`=edadTrab_nat_pob'/`=nat_pob') F44 = (`=edadTrab_migr_pob'/`=migr_pob')
	putexcel E45 = (`=edadTrab_nat_muestra') F45 = (`=edadTrab_migr_muestra') // Tamaño de la muestra
	
	* Población económicamente activa
	putexcel E46 = (`=econoAct_nat_pob'/`=edadTrab_nat_pob') F46 = (`=econoAct_migr_pob'/`=edadTrab_migr_pob')
	putexcel E47 = (`=econoAct_nat_muestra') F47 = (`=econoAct_migr_muestra') // Tamaño de la muestra
	
	* Población empleada
	putexcel E48 = (`=emp_nat_pob'/`=econoAct_nat_pob') F48 = (`=emp_migr_pob'/`=econoAct_migr_pob')
	putexcel E49 = (`=emp_nat_muestra') F49 = (`=emp_migr_muestra') // Tamaño de la muestra
	
	* Población desempleada
	putexcel E50 = (`=desemp_nat_pob'/`=econoAct_nat_pob') F50 = (`=desemp_migr_pob'/`=econoAct_migr_pob')
	putexcel E51 = (`=desemp_nat_muestra') F51 = (`=desemp_migr_muestra') // Tamaño de la muestra	
	
	* Población informal
	putexcel E52 = (`=informal_nat_pob'/`=emp_nat_pob') F52 = (`=informal_migr_pob'/`=emp_migr_pob')
	putexcel E53 = (`=informal_nat_muestra') F53 = (`=informal_migr_muestra') // Tamaño de la muestra
		
	****************** Indicadores por categorías de ingresos ******************
	
	putexcel E55 = (`=D1_nat_pob'/`=NMIng_nat_pob') F55 = (`=D1_migr_pob'/`=NMIng_migr_pob') // (D1)
	putexcel E56 = (`=D1_nat_muestra') F56 = (`=D1_migr_muestra') // Tamaño muestra
	
	putexcel E57 = (`=D2_nat_pob'/`=NMIng_nat_pob') F57 = (`=D2_migr_pob'/`=NMIng_migr_pob') // (D2)
	putexcel E58 = (`=D2_nat_muestra') F58 = (`=D2_migr_muestra') // Tamaño muestra
	
	putexcel E59 = (`=D3_nat_pob'/`=NMIng_nat_pob') F59 = (`=D3_migr_pob'/`=NMIng_migr_pob') // (D3)
	putexcel E60 = (`=D3_nat_muestra') F60 = (`=D3_migr_muestra') // Tamaño muestra
	
	putexcel E61 = (`=D4_nat_pob'/`=NMIng_nat_pob') F61 = (`=D4_migr_pob'/`=NMIng_migr_pob') // (D4)
	putexcel E62 = (`=D4_nat_muestra') F62 = (`=D4_migr_muestra') // Tamaño muestra
	
	putexcel E63 = (`=D5_nat_pob'/`=NMIng_nat_pob') F63 = (`=D5_migr_pob'/`=NMIng_migr_pob') // (D5)
	putexcel E64 = (`=D5_nat_muestra') F64 = (`=D5_migr_muestra') // Tamaño muestra
	
	putexcel E65 = (`=D6_nat_pob'/`=NMIng_nat_pob') F65 = (`=D6_migr_pob'/`=NMIng_migr_pob') // (D6)
	putexcel E66 = (`=D6_nat_muestra') F66 = (`=D6_migr_muestra') // Tamaño muestra
	
	putexcel E67 = (`=D7_nat_pob'/`=NMIng_nat_pob') F67 = (`=D7_migr_pob'/`=NMIng_migr_pob') // (D7)
	putexcel E68 = (`=D7_nat_muestra') F68 = (`=D7_migr_muestra') // Tamaño muestra
	
	putexcel E69 = (`=D8_nat_pob'/`=NMIng_nat_pob') F69 = (`=D8_migr_pob'/`=NMIng_migr_pob') // (D8)
	putexcel E70 = (`=D8_nat_muestra') F70 = (`=D8_migr_muestra') // Tamaño muestra
	
	putexcel E71 = (`=D9_nat_pob'/`=NMIng_nat_pob') F71 = (`=D9_migr_pob'/`=NMIng_migr_pob') // (D9)
	putexcel E72 = (`=D9_nat_muestra') F72 = (`=D9_migr_muestra') // Tamaño muestra
	
	putexcel E73 = (`=D10_nat_pob'/`=NMIng_nat_pob') F73 = (`=D10_migr_pob'/`=NMIng_migr_pob') // (D10)
	putexcel E74 = (`=D10_nat_muestra') F74 = (`=D10_migr_muestra') // Tamaño muestra
	
********************************************************************************
********************************************************************************
********************************************************************************
****** COLOMBIA - GRAN ENCUESTA INTEGRADA DE HOGARES 2020 **********************
	
	clear all
	set more off, perm
	set maxvar 15000
	scalar drop _all

	** DATASET
	cd "C:\Users\JCAMILOP\OneDrive - Inter-American Development Bank Group\Otros\Indicadores PNUD\Bases de datos"
	use "COL_2020t3_BID.dta", replace

	gen uno=1
	replace factor_ci=round(factor_ci) // Applies when the expansion factor is a non-integer numbers
	replace migrante_ci = 0 if migrante_ci == .
	
	****************************************************************************
	** LOCALS
		local 1_label = "migr"
		local 0_label = "nat"
		
		local 1_sexo = "masc_"
		local 2_sexo = "fem_"	
	
	****************************************************************************
	** Tamaño del hogar
	by idh_ch, sort: egen nmiembros=sum(relacion_ci>=1 & relacion_ci<5)	
	by idh_ch, sort: egen nhijos=sum(relacion_ci==3)
	
	****************************************************************************
	** Informalidad
	gen informal = 1 if cotizando_ci != 1 & emp_ci==1
	replace informal =1 if informal!=1 & afiliado_ci != 1 & emp_ci==1
	
	****************************************************************************
	** Muestra total
	sum uno if migrante_ci!=.
	scalar tot_muestra = `=r(N)'
	
	****************************************************************************
	** Muestra migrantes
	sum uno if migrante_ci==1
	scalar migr_muestra = `=r(N)'
	
	****************************************************************************
	** Muestra nativos
	sum uno if migrante_ci==0
	scalar nat_muestra = `=r(N)'
	
	****************************************************************************
	** Población total según factores de expansión
	sum uno if migrante_ci!=. [fw=factor_ci]
	scalar tot_pob = `=r(N)'
	
	****************************************************************************
	** Población migrante según factores de expansión
	sum uno if migrante_ci==1 [fw=factor_ci]
	scalar migr_pob = `=r(N)'
	
	****************************************************************************
	** Población nativa según factores de expansión
	sum uno if migrante_ci==0 [fw=factor_ci]
	scalar nat_pob = `=r(N)'
	
	****************************************************************************
	** Nivel educativo
	gen nivel_educ = 0 if eduno_ci == 1
	replace nivel_educ = 1 if edupre_ci == 1 & edupc_ci == 0
	replace nivel_educ = 2 if edupc_ci == 1 & edusc_ci == 0
	replace nivel_educ = 3 if edusc_ci == 1 & eduuc_ci == 0
	replace nivel_educ = 4 if eduuc_ci == 1
	
	****************************************************************************
	** Ingresos totales
	egen totIng=rowtotal(ylm_ci ylnm_ci ynlm_ci ynlnm_ci remesas_ci)
	
	****************************************************************************
	** Distribución ingresos
	xtile ing_dec=totIng if edad_ci>15 & pea_ci==1, n(10)
	
	* Decil 1
	gen dec_1=(ing_dec==1)
	replace dec_1=. if ing_dec==.

	* Decil 2
	gen dec_2=(ing_dec==2)
	replace dec_2=. if ing_dec==.

	* Decil 3
	gen dec_3=(ing_dec==3)
	replace dec_3=. if ing_dec==.
	
	* Decil 4
	gen dec_4=(ing_dec==4)
	replace dec_4=. if ing_dec==.

	* Decil 5 
	gen dec_5=(ing_dec==5)
	replace dec_5=. if ing_dec==.

	* Decil 6
	gen dec_6=(ing_dec==6)
	replace dec_6=. if ing_dec==.
	
	* Decil 7
	gen dec_7=(ing_dec==7)
	replace dec_7=. if ing_dec==.

	* Decil 8
	gen dec_8=(ing_dec==8)
	replace dec_8=. if ing_dec==.

	* Decil 9
	gen dec_9=(ing_dec==9)
	replace dec_9=. if ing_dec==.
	
	* Decil 10
	gen dec_10=(ing_dec==10)
	replace dec_10=. if ing_dec==.
	
	****************************************************************************
	** Cálculo de indicadores por migrantes y nativos
	
	foreach var in 1 0 {
		
		*********************** Indicadores demográficos ***********************	
		
		* Mujeres
		sum uno if sexo_ci==2 & migrante_ci==`var' [fw=factor_ci]
		scalar mujer_``var'_label'_pob =`=r(N)'
		
		* Mujeres muestra
		sum uno if sexo_ci==2 & migrante_ci==`var'
		scalar mujer_``var'_label'_muestra =`=r(N)'
		
		* Grupos de edades
		sum uno if inrange(edad_ci,0,14) & migrante_ci==`var' [fw=factor_ci]
		scalar pob_``var'_label'_014 = `=r(N)' // 0 - 14 years
		
		sum uno if inrange(edad_ci,15,24) & migrante_ci==`var' [fw=factor_ci]
		scalar pob_``var'_label'_1524 = `=r(N)' // 15 - 24 years

		sum uno if inrange(edad_ci,25,39) & migrante_ci==`var' [fw=factor_ci]
		scalar pob_``var'_label'_2539 = `=r(N)' // 25 - 39 years
		
		sum uno if inrange(edad_ci,40,54) & migrante_ci==`var' [fw=factor_ci]
		scalar pob_``var'_label'_4054 = `=r(N)' // 40 - 54 years

		sum uno if inrange(edad_ci,55,64) & migrante_ci==`var' [fw=factor_ci]
		scalar pob_``var'_label'_5564 = `=r(N)'	//55 - 64 years
		
		sum uno if inrange(edad_ci,65,.) & migrante_ci==`var' [fw=factor_ci]
		scalar pob_``var'_label'_65mas = `=r(N)'  // 65 older years
		
		* Muestra grupos de edades
		sum uno if inrange(edad_ci,0,14) & migrante_ci==`var'
		scalar muestra_``var'_label'_014 = `=r(N)' // 0 - 14 years
		
		sum uno if inrange(edad_ci,15,24) & migrante_ci==`var'
		scalar muestra_``var'_label'_1524 = `=r(N)' // 15 - 24 years

		sum uno if inrange(edad_ci,25,39) & migrante_ci==`var'
		scalar muestra_``var'_label'_2539 = `=r(N)' // 25 - 39 years
		
		sum uno if inrange(edad_ci,40,54) & migrante_ci==`var'
		scalar muestra_``var'_label'_4054 = `=r(N)' // 40 - 54 years

		sum uno if inrange(edad_ci,55,64) & migrante_ci==`var'
		scalar muestra_``var'_label'_5564 = `=r(N)'	//55 - 64 years
		
		sum uno if inrange(edad_ci,65,.) & migrante_ci==`var'
		scalar muestra_``var'_label'_65mas = `=r(N)'  // 65 older years
		
		* Tamaño del hogar
		sum nmiembros if migrante_ci==`var' [fw=factor_ci]
		scalar tam_``var'_label'_hogar = `=r(mean)'
		
		* Muestra tamaño hogar
		sum nmiembros if migrante_ci==`var'
		scalar Mtam_``var'_label'_hogar = `=r(N)'
		
		* Número de hijos
		sum nhijos if migrante_ci==`var' [fw=factor_ci]
		scalar num_``var'_label'_hijos = `=r(mean)'
		
		* Muestra número de hijos
		sum nhijos if migrante_ci==`var'
		scalar Mnum_``var'_label'_hijos = `=r(N)'
		
		
		********** Indicadores por ubicación geográfica ***********************

		* Porcentaje en zonas urbanas
		sum uno if zona_c==1 & migrante_ci==`var' [fw=factor_ci]
		scalar urbana_``var'_label'_pob = `=r(N)'
		
		* Muestra en zonas urbanas
		sum uno if zona_c==1 & migrante_ci==`var'
		scalar urbana_``var'_label'_muestra = `=r(N)'
		
		* Porcentaje en zonas rurales
		sum uno if zona_c==0 & migrante_ci==`var' [fw=factor_ci]
		scalar rural_``var'_label'_pob = `=r(N)'
		
		* Muestra en zonas rurales
		sum uno if zona_c==0 & migrante_ci==`var'
		scalar rural_``var'_label'_muestra = `=r(N)'
		
		* Porcentaje en ciudad capital
		sum uno if region_c==11 & migrante_ci==`var' [fw=factor_ci]
		scalar capital_``var'_label'_pob = `=r(N)'
		
		* Muestra en ciudad capital
		sum uno if region_c==11 & migrante_ci==`var'
		scalar capital_``var'_label'_muestra = `=r(N)'
		
		
		************* Indicadores por nivel de educación completo **************
		
		* Ningún nivel educativo completado
		sum uno if nivel_educ==0 & migrante_ci==`var' [fw=factor_ci]
		scalar NoEdu_``var'_label'_pob = `=r(N)'
		
		* Muestra ningún nivel educativo completado
		sum uno if nivel_educ==0 & migrante_ci==`var'
		scalar NoEdu_``var'_label'_muestra = `=r(N)'
		
		* Preescolar
		sum uno if nivel_educ==1 & migrante_ci==`var' [fw=factor_ci]
		scalar EduPre_``var'_label'_pob = `=r(N)'
		
		* Muestra preescolar
		sum uno if nivel_educ==1 & migrante_ci==`var'
		scalar EduPre_``var'_label'_muestra = `=r(N)'
		
		* Primaria
		sum uno if nivel_educ==2 & migrante_ci==`var' [fw=factor_ci]
		scalar EduPrim_``var'_label'_pob = `=r(N)'
		
		* Muestra primaria
		sum uno if nivel_educ==2 & migrante_ci==`var'
		scalar EduPrim_``var'_label'_muestra = `=r(N)'
		
		* Secundaria
		sum uno if nivel_educ==3 & migrante_ci==`var' [fw=factor_ci]
		scalar EduSecu_``var'_label'_pob = `=r(N)'
		
		* Muestra secundaria
		sum uno if nivel_educ==3 & migrante_ci==`var'
		scalar EduSecu_``var'_label'_muestra = `=r(N)'
		
		* Terciaria
		sum uno if nivel_educ==4 & migrante_ci==`var' [fw=factor_ci]
		scalar EduTerc_``var'_label'_pob = `=r(N)'
		
		sum uno if nivel_educ!=. & migrante_ci==`var' [fw=factor_ci]
		scalar NMEdu_``var'_label'_pob = `=r(N)'
		
		* Muestra terciaria
		sum uno if nivel_educ==4 & migrante_ci==`var'
		scalar EduTerc_``var'_label'_muestra = `=r(N)'
		
		
		**************** Indicadores por situación laboral *********************
		
		* Población en edad de trabajar
		sum uno if inrange(edad_ci,15,64) & migrante_ci==`var' [fw=factor_ci]
		scalar edadTrab_``var'_label'_pob = `=r(N)'
		
		* Muestra en edad de trabajar
		sum uno if inrange(edad_ci,15,64) & migrante_ci==`var'
		scalar edadTrab_``var'_label'_muestra = `=r(N)'
		
		* Población económicamente activa
		sum uno if inrange(edad_ci,15,64) & pea_ci==1 & migrante_ci==`var' [fw=factor_ci]
		scalar econoAct_``var'_label'_pob = `=r(N)'
		
		* Muestra económicamente activa
		sum uno if inrange(edad_ci,15,64) & pea_ci==1 & migrante_ci==`var'
		scalar econoAct_``var'_label'_muestra = `=r(N)'
		
		* Población empleada
		sum uno if inrange(edad_ci,15,64) & emp_ci==1 & migrante_ci==`var' [fw=factor_ci]
		scalar emp_``var'_label'_pob = `=r(N)'
		
		* Muestra empleada
		sum uno if inrange(edad_ci,15,64) & emp_ci==1 & migrante_ci==`var'
		scalar emp_``var'_label'_muestra = `=r(N)'
		
		* Población desempleada
		sum uno if inrange(edad_ci,15,64) & desemp_ci==1 & migrante_ci==`var' [fw=factor_ci] 
		scalar desemp_``var'_label'_pob = `=r(N)'
		
		* Muestra desempleada
		sum uno if inrange(edad_ci,15,64) & desemp_ci==1 & migrante_ci==`var'
		scalar desemp_``var'_label'_muestra = `=r(N)'
		
		* Informales
		sum uno if inrange(edad_ci,15,64) & informal==1 & migrante_ci==`var' [fw=factor_ci]
		scalar informal_``var'_label'_pob = `=r(N)'
		
		* Muestra informales
		sum uno if inrange(edad_ci,15,64) & informal==1 & migrante_ci==`var'
		scalar informal_``var'_label'_muestra = `=r(N)'
		
		**************** Indicadores por categorías de ingresos ****************
		
		* Decil 1
		sum uno if migrante_ci==`var' & dec_1 == 1 [fw=factor_ci]
		scalar D1_``var'_label'_pob = `=r(N)'
		
		* Muestra decil 1
		sum uno if migrante_ci==`var' & dec_1 == 1
		scalar D1_``var'_label'_muestra = `=r(N)'

		* Decil 2
		sum uno if migrante_ci==`var' & dec_2 == 1 [fw=factor_ci]
		scalar D2_``var'_label'_pob = `=r(N)'
		
		* Muestra decil 2
		sum uno if migrante_ci==`var' & dec_2 == 1
		scalar D2_``var'_label'_muestra = `=r(N)'
		
		* Decil 3
		sum uno if migrante_ci==`var' & dec_3 == 1 [fw=factor_ci]
		scalar D3_``var'_label'_pob = `=r(N)'
		
		* Muestra decil 3
		sum uno if migrante_ci==`var' & dec_3 == 1
		scalar D3_``var'_label'_muestra = `=r(N)'
		
		* Decil 4
		sum uno if migrante_ci==`var' & dec_4 == 1 [fw=factor_ci]
		scalar D4_``var'_label'_pob = `=r(N)'
		
		* Muestra decil 4
		sum uno if migrante_ci==`var' & dec_4 == 1
		scalar D4_``var'_label'_muestra = `=r(N)'
		
		* Decil 5
		sum uno if migrante_ci==`var' & dec_5 == 1 [fw=factor_ci]
		scalar D5_``var'_label'_pob = `=r(N)'
		
		* Muestra decil 5
		sum uno if migrante_ci==`var' & dec_5 == 1
		scalar D5_``var'_label'_muestra = `=r(N)'
		
		* Decil 6
		sum uno if migrante_ci==`var' & dec_6 == 1 [fw=factor_ci]
		scalar D6_``var'_label'_pob = `=r(N)'
		
		* Muestra decil 6
		sum uno if migrante_ci==`var' & dec_6 == 1
		scalar D6_``var'_label'_muestra = `=r(N)'
		
		* Decil 7
		sum uno if migrante_ci==`var' & dec_7 == 1 [fw=factor_ci]
		scalar D7_``var'_label'_pob = `=r(N)'
		
		* Muestra decil 7
		sum uno if migrante_ci==`var' & dec_7 == 1
		scalar D7_``var'_label'_muestra = `=r(N)'
		
		* Decil 8
		sum uno if migrante_ci==`var' & dec_8 == 1 [fw=factor_ci]
		scalar D8_``var'_label'_pob = `=r(N)'
		
		* Muestra decil 8
		sum uno if migrante_ci==`var' & dec_8 == 1
		scalar D8_``var'_label'_muestra = `=r(N)'
		
		* Decil 9
		sum uno if migrante_ci==`var' & dec_9 == 1 [fw=factor_ci]
		scalar D9_``var'_label'_pob = `=r(N)'
		
		* Muestra decil 9
		sum uno if migrante_ci==`var' & dec_9 == 1
		scalar D9_``var'_label'_muestra = `=r(N)'
		
		* Decil 10
		sum uno if migrante_ci==`var' & dec_10 == 1 [fw=factor_ci]
		scalar D10_``var'_label'_pob = `=r(N)'
		
		* Muestra decil 10
		sum uno if migrante_ci==`var' & dec_10 == 1
		scalar D10_``var'_label'_muestra = `=r(N)'
		
		sum uno if migrante_ci==`var' & (ing_dec!=.) [fw=factor_ci]
		scalar NMIng_``var'_label'_pob = `=r(N)'
	
		}
	
******************************************************** EXCEL OUTPUTS

	putexcel set "C:\Users\JCAMILOP\OneDrive - Inter-American Development Bank Group\Otros\Indicadores PNUD\Documentos\Resultados.xlsx", sheet("Indicadores") modify
	putexcel describe
	
	
	************************** Indicadores demográficos ***********************
	
	** Población
	putexcel G5 = (`=nat_pob'/`=tot_pob') H5 = (`=migr_pob'/`=tot_pob')	// Porcentaje de migrantes
	putexcel G6 = (`=nat_muestra') H6 = (`=migr_muestra')	// Tamaño de la muestra
	putexcel G7 = (`=mujer_nat_pob'/`=nat_pob') H7 = (`=mujer_migr_pob'/`=migr_pob')	// Porcentaje de mujeres
	putexcel G8 = (`=mujer_nat_muestra') H8 = (`=mujer_migr_muestra')	// Tamaño de la muestra
	
	* Edades 
	putexcel G9 = (`=pob_nat_014'/`=nat_pob') H9 = (`=pob_migr_014'/`=migr_pob') // 0 - 14
	putexcel G10 = (`=muestra_nat_014') H10 = (`=muestra_migr_014') // Tamaño de la muestra
	putexcel G11 = (`=pob_nat_1524'/`=nat_pob') H11 = (`=pob_migr_1524'/`=migr_pob') // 15 - 24
	putexcel G12 = (`=muestra_nat_1524') H12 = (`=muestra_migr_1524') // Tamaño de la muestra
	putexcel G13 = (`=pob_nat_2539'/`=nat_pob') H13 = (`=pob_migr_2539'/`=migr_pob') // 25 - 39
	putexcel G14 = (`=muestra_nat_2539') H14 = (`=muestra_migr_2539') // Tamaño de la muestra
	putexcel G15 = (`=pob_nat_4054'/`=nat_pob') H15 = (`=pob_migr_4054'/`=migr_pob') // 40 - 54
	putexcel G16 = (`=muestra_nat_4054') H16 = (`=muestra_migr_4054') // Tamaño de la muestra
	putexcel G17 = (`=pob_nat_5564'/`=nat_pob') H17 = (`=pob_migr_5564'/`=migr_pob') // 55 - 64
	putexcel G18 = (`=muestra_nat_5564') H18 = (`=muestra_migr_5564') // Tamaño de la muestra
	putexcel G19 = (`=pob_nat_65mas'/`=nat_pob') H19 = (`=pob_migr_65mas'/`=migr_pob') // 65 más
	putexcel G20 = (`=muestra_nat_65mas') H20 = (`=muestra_migr_65mas') // Tamaño de la muestra
	
	* Tamaño del hogar
	putexcel G21 = (`=tam_nat_hogar')  H21 = (`=tam_migr_hogar') // Tamaño del hogar
	putexcel G22 = (`=Mtam_nat_hogar')  H22 = (`=Mtam_migr_hogar') // Tamaño de la muestra
	
	* Número de hijos
	putexcel G23 = (`=num_nat_hijos')  H23 = (`=num_migr_hijos') // Número de hijos
	putexcel G24 = (`=Mnum_nat_hijos')  H24 = (`=Mnum_migr_hijos') // Tamaño de la muestra
	
	
	*************** Indicadores por ubicación geográfica ***********************
	
	* Población urbana
	putexcel G26 = (`=urbana_nat_pob'/`=nat_pob') H26 = (`=urbana_migr_pob'/`=migr_pob')	
	putexcel G27 = (`=urbana_nat_muestra') H27 = (`=urbana_migr_muestra') // Tamaño de la muestra
	
	* Población rural
	putexcel G28 = (`=rural_nat_pob'/`=nat_pob') H28 = (`=rural_migr_pob'/`=migr_pob')
	putexcel G29 = (`=rural_nat_muestra') H29 = (`=rural_migr_muestra')	// Tamaño de la muestra	
	
	* Ciudad capital
	putexcel G30 = (`=capital_nat_pob'/`=nat_pob') H30 = (`=capital_migr_pob'/`=migr_pob')
	putexcel G31 = (`=capital_nat_muestra') H31 = (`=capital_migr_muestra') // Tamaño de la muestra	
	
	
	************** Indicadores por nivel de educación completo *****************
	
	** Por nivel educativo
	
	* Ningún nivel educativo completado
	putexcel G33 = (`=NoEdu_nat_pob'/`=NMEdu_nat_pob') H33 = (`=NoEdu_migr_pob'/`=NMEdu_migr_pob')
	putexcel G34 = (`=NoEdu_nat_muestra') H34 = (`=NoEdu_migr_muestra')	// Tamaño de la muestra
	
	** Preescolar
	putexcel G35 = (`=EduPre_nat_pob'/`=NMEdu_nat_pob') H35 = (`=EduPre_migr_pob'/`=NMEdu_migr_pob')
	putexcel G36 = (`=EduPre_nat_muestra') H36 = (`=EduPre_migr_muestra')	// Tamaño de la muestra
	
	** Primaria completa
	putexcel G37 = (`=EduPrim_nat_pob'/`=NMEdu_nat_pob') H37 = (`=EduPrim_migr_pob'/`=NMEdu_migr_pob')
	putexcel G38 = (`=EduPrim_nat_muestra') H38 = (`=EduPrim_migr_muestra')	// Tamaño de la muestra
	
	** Secundaria completa
	putexcel G39 = (`=EduSecu_nat_pob'/`=NMEdu_nat_pob') H39 = (`=EduSecu_migr_pob'/`=NMEdu_migr_pob')
	putexcel G40 = (`=EduSecu_nat_muestra') H40 = (`=EduSecu_migr_muestra')	// Tamaño de la muestra
	
	** Terciaria completa
	putexcel G41 = (`=EduTerc_nat_pob'/`=NMEdu_nat_pob') H41 = (`=EduTerc_migr_pob'/`=NMEdu_migr_pob')
	putexcel G42 = (`=EduTerc_nat_muestra') H42 = (`=EduTerc_migr_muestra')	// Tamaño de la muestra
	
	
	****************** Indicadores por situación laboral ***********************
	
	* Población en edad de trabajar
	putexcel G44 = (`=edadTrab_nat_pob'/`=nat_pob') H44 = (`=edadTrab_migr_pob'/`=migr_pob')
	putexcel G45 = (`=edadTrab_nat_muestra') H45 = (`=edadTrab_migr_muestra') // Tamaño de la muestra
	
	* Población económicamente activa
	putexcel G46 = (`=econoAct_nat_pob'/`=edadTrab_nat_pob') H46 = (`=econoAct_migr_pob'/`=edadTrab_migr_pob')
	putexcel G47 = (`=econoAct_nat_muestra') H47 = (`=econoAct_migr_muestra') // Tamaño de la muestra
	
	* Población empleada
	putexcel G48 = (`=emp_nat_pob'/`=econoAct_nat_pob') H48 = (`=emp_migr_pob'/`=econoAct_migr_pob')
	putexcel G49 = (`=emp_nat_muestra') H49 = (`=emp_migr_muestra') // Tamaño de la muestra
	
	* Población desempleada
	putexcel G50 = (`=desemp_nat_pob'/`=econoAct_nat_pob') H50 = (`=desemp_migr_pob'/`=econoAct_migr_pob')
	putexcel G51 = (`=desemp_nat_muestra') H51 = (`=desemp_migr_muestra') // Tamaño de la muestra	
	
	* Población informal
	putexcel G52 = (`=informal_nat_pob'/`=emp_nat_pob') H52 = (`=informal_migr_pob'/`=emp_migr_pob')
	putexcel G53 = (`=informal_nat_muestra') H53 = (`=informal_migr_muestra') // Tamaño de la muestra
	
	****************** Indicadores por categorías de ingresos ******************
	
	putexcel G55 = (`=D1_nat_pob'/`=NMIng_nat_pob') H55 = (`=D1_migr_pob'/`=NMIng_migr_pob') // (D1)
	putexcel G56 = (`=D1_nat_muestra') H56 = (`=D1_migr_muestra') // Tamaño muestra
	
	putexcel G57 = (`=D2_nat_pob'/`=NMIng_nat_pob') H57 = (`=D2_migr_pob'/`=NMIng_migr_pob') // (D2)
	putexcel G58 = (`=D2_nat_muestra') H58 = (`=D2_migr_muestra') // Tamaño muestra
	
	putexcel G59 = (`=D3_nat_pob'/`=NMIng_nat_pob') H59 = (`=D3_migr_pob'/`=NMIng_migr_pob') // (D3)
	putexcel G60 = (`=D3_nat_muestra') H60 = (`=D3_migr_muestra') // Tamaño muestra
	
	putexcel G61 = (`=D4_nat_pob'/`=NMIng_nat_pob') H61 = (`=D4_migr_pob'/`=NMIng_migr_pob') // (D4)
	putexcel G62 = (`=D4_nat_muestra') H62 = (`=D4_migr_muestra') // Tamaño muestra
	
	putexcel G63 = (`=D5_nat_pob'/`=NMIng_nat_pob') H63 = (`=D5_migr_pob'/`=NMIng_migr_pob') // (D5)
	putexcel G64 = (`=D5_nat_muestra') H64 = (`=D5_migr_muestra') // Tamaño muestra
	
	putexcel G65 = (`=D6_nat_pob'/`=NMIng_nat_pob') H65 = (`=D6_migr_pob'/`=NMIng_migr_pob') // (D6)
	putexcel G66 = (`=D6_nat_muestra') H66 = (`=D6_migr_muestra') // Tamaño muestra
	
	putexcel G67 = (`=D7_nat_pob'/`=NMIng_nat_pob') H67 = (`=D7_migr_pob'/`=NMIng_migr_pob') // (D7)
	putexcel G68 = (`=D7_nat_muestra') H68 = (`=D7_migr_muestra') // Tamaño muestra
	
	putexcel G69 = (`=D8_nat_pob'/`=NMIng_nat_pob') H69 = (`=D8_migr_pob'/`=NMIng_migr_pob') // (D8)
	putexcel G70 = (`=D8_nat_muestra') H70 = (`=D8_migr_muestra') // Tamaño muestra
	
	putexcel G71 = (`=D9_nat_pob'/`=NMIng_nat_pob') H71 = (`=D9_migr_pob'/`=NMIng_migr_pob') // (D9)
	putexcel G72 = (`=D9_nat_muestra') H72 = (`=D9_migr_muestra') // Tamaño muestra
	
	putexcel G73 = (`=D10_nat_pob'/`=NMIng_nat_pob') H73 = (`=D10_migr_pob'/`=NMIng_migr_pob') // (D10)
	putexcel G74 = (`=D10_nat_muestra') H74 = (`=D10_migr_muestra') // Tamaño muestra
		
		
********************************************************************************
********************************************************************************
********************************************************************************
****** COSTA RICA - ENCUESTA NACIONAL DE HOGARES 2020 **************************
	
	clear all
	set more off, perm
	set maxvar 15000
	scalar drop _all

	** DATASET
	cd "C:\Users\JCAMILOP\OneDrive - Inter-American Development Bank Group\Otros\Indicadores PNUD\Bases de datos"
	use "CRI_2020m7_BID.dta", replace

	gen uno=1
	replace factor_ci=round(factor_ci) // Applies when the expansion factor is a non-integer numbers
	replace migrante_ci = 0 if migrante_ci == .

	****************************************************************************
	** LOCALS
		local 1_label = "migr"
		local 0_label = "nat"
		
		local 1_sexo = "masc_"
		local 2_sexo = "fem_"	
	
	****************************************************************************
	** Tamaño del hogar
	by idh_ch, sort: egen nmiembros=sum(relacion_ci>=1 & relacion_ci<5)	
	by idh_ch, sort: egen nhijos=sum(relacion_ci==3)
	
	****************************************************************************
	** Informalidad
	gen informal = (cotizando_ci != 1 & emp_ci==1)
	
	****************************************************************************
	** Muestra total
	sum uno if migrante_ci!=.
	scalar tot_muestra = `=r(N)'
	
	****************************************************************************
	** Muestra migrantes
	sum uno if migrante_ci==1
	scalar migr_muestra = `=r(N)'
	
	****************************************************************************
	** Muestra nativos
	sum uno if migrante_ci==0
	scalar nat_muestra = `=r(N)'
	
	****************************************************************************
	** Población total según factores de expansión
	sum uno if migrante_ci!=. [fw=factor_ci]
	scalar tot_pob = `=r(N)'
	
	****************************************************************************
	** Población migrante según factores de expansión
	sum uno if migrante_ci==1 [fw=factor_ci]
	scalar migr_pob = `=r(N)'
	
	****************************************************************************
	** Población nativa según factores de expansión
	sum uno if migrante_ci==0 [fw=factor_ci]
	scalar nat_pob = `=r(N)'
	
	****************************************************************************
	** Nivel educativo
	gen nivel_educ = 0 if eduno_ci == 1
	replace nivel_educ = 1 if edupre_ci == 1 & edupc_ci == 0
	replace nivel_educ = 2 if edupc_ci == 1 & edusc_ci == 0
	replace nivel_educ = 3 if edusc_ci == 1 & eduuc_ci == 0
	replace nivel_educ = 4 if eduuc_ci == 1
	
	****************************************************************************
	** Ingresos totales
	egen totIng=rowtotal(ylm_ci ylnm_ci ynlm_ci ynlnm_ci remesas_ci)
	
	****************************************************************************
	** Distribución ingresos
	xtile ing_dec=totIng if edad_ci>15 & pea_ci==1, n(10)
	
	* Decil 1
	gen dec_1=(ing_dec==1)
	replace dec_1=. if ing_dec==.

	* Decil 2
	gen dec_2=(ing_dec==2)
	replace dec_2=. if ing_dec==.

	* Decil 3
	gen dec_3=(ing_dec==3)
	replace dec_3=. if ing_dec==.
	
	* Decil 4
	gen dec_4=(ing_dec==4)
	replace dec_4=. if ing_dec==.

	* Decil 5 
	gen dec_5=(ing_dec==5)
	replace dec_5=. if ing_dec==.

	* Decil 6
	gen dec_6=(ing_dec==6)
	replace dec_6=. if ing_dec==.
	
	* Decil 7
	gen dec_7=(ing_dec==7)
	replace dec_7=. if ing_dec==.

	* Decil 8
	gen dec_8=(ing_dec==8)
	replace dec_8=. if ing_dec==.

	* Decil 9
	gen dec_9=(ing_dec==9)
	replace dec_9=. if ing_dec==.
	
	* Decil 10
	gen dec_10=(ing_dec==10)
	replace dec_10=. if ing_dec==.
	
	****************************************************************************
	** Cálculo de indicadores por migrantes y nativos
	
	foreach var in 1 0 {
		
		*********************** Indicadores demográficos ***********************	
		
		* Mujeres
		sum uno if sexo_ci==2 & migrante_ci==`var' [fw=factor_ci]
		scalar mujer_``var'_label'_pob =`=r(N)'
		
		* Mujeres muestra
		sum uno if sexo_ci==2 & migrante_ci==`var'
		scalar mujer_``var'_label'_muestra =`=r(N)'
		
		* Grupos de edades
		sum uno if inrange(edad_ci,0,14) & migrante_ci==`var' [fw=factor_ci]
		scalar pob_``var'_label'_014 = `=r(N)' // 0 - 14 years
		
		sum uno if inrange(edad_ci,15,24) & migrante_ci==`var' [fw=factor_ci]
		scalar pob_``var'_label'_1524 = `=r(N)' // 15 - 24 years

		sum uno if inrange(edad_ci,25,39) & migrante_ci==`var' [fw=factor_ci]
		scalar pob_``var'_label'_2539 = `=r(N)' // 25 - 39 years
		
		sum uno if inrange(edad_ci,40,54) & migrante_ci==`var' [fw=factor_ci]
		scalar pob_``var'_label'_4054 = `=r(N)' // 40 - 54 years

		sum uno if inrange(edad_ci,55,64) & migrante_ci==`var' [fw=factor_ci]
		scalar pob_``var'_label'_5564 = `=r(N)'	//55 - 64 years
		
		sum uno if inrange(edad_ci,65,.) & migrante_ci==`var' [fw=factor_ci]
		scalar pob_``var'_label'_65mas = `=r(N)'  // 65 older years
		
		* Muestra grupos de edades
		sum uno if inrange(edad_ci,0,14) & migrante_ci==`var'
		scalar muestra_``var'_label'_014 = `=r(N)' // 0 - 14 years
		
		sum uno if inrange(edad_ci,15,24) & migrante_ci==`var'
		scalar muestra_``var'_label'_1524 = `=r(N)' // 15 - 24 years

		sum uno if inrange(edad_ci,25,39) & migrante_ci==`var'
		scalar muestra_``var'_label'_2539 = `=r(N)' // 25 - 39 years
		
		sum uno if inrange(edad_ci,40,54) & migrante_ci==`var'
		scalar muestra_``var'_label'_4054 = `=r(N)' // 40 - 54 years

		sum uno if inrange(edad_ci,55,64) & migrante_ci==`var'
		scalar muestra_``var'_label'_5564 = `=r(N)'	//55 - 64 years
		
		sum uno if inrange(edad_ci,65,.) & migrante_ci==`var'
		scalar muestra_``var'_label'_65mas = `=r(N)'  // 65 older years
		
		* Tamaño del hogar
		sum nmiembros if migrante_ci==`var' [fw=factor_ci]
		scalar tam_``var'_label'_hogar = `=r(mean)'
		
		* Muestra tamaño hogar
		sum nmiembros if migrante_ci==`var'
		scalar Mtam_``var'_label'_hogar = `=r(N)'
		
		* Número de hijos
		sum nhijos if migrante_ci==`var' [fw=factor_ci]
		scalar num_``var'_label'_hijos = `=r(mean)'
		
		* Muestra número de hijos
		sum nhijos if migrante_ci==`var'
		scalar Mnum_``var'_label'_hijos = `=r(N)'
		
		
		********** Indicadores por ubicación geográfica ***********************

		* Porcentaje en zonas urbanas
		sum uno if zona_c==1 & migrante_ci==`var' [fw=factor_ci]
		scalar urbana_``var'_label'_pob = `=r(N)'
		
		* Muestra en zonas urbanas
		sum uno if zona_c==1 & migrante_ci==`var'
		scalar urbana_``var'_label'_muestra = `=r(N)'
		
		* Porcentaje en zonas rurales
		sum uno if zona_c==0 & migrante_ci==`var' [fw=factor_ci]
		scalar rural_``var'_label'_pob = `=r(N)'
		
		* Muestra en zonas rurales
		sum uno if zona_c==0 & migrante_ci==`var'
		scalar rural_``var'_label'_muestra = `=r(N)'
		
		* Porcentaje en ciudad capital
		sum uno if region_c==1 & migrante_ci==`var' [fw=factor_ci]
		scalar capital_``var'_label'_pob = `=r(N)'
		
		* Muestra en ciudad capital
		sum uno if region_c==1 & migrante_ci==`var'
		scalar capital_``var'_label'_muestra = `=r(N)'
		
		
		************* Indicadores por nivel de educación completo **************
		
		* Ningún nivel educativo completado
		sum uno if nivel_educ==0 & migrante_ci==`var' [fw=factor_ci]
		scalar NoEdu_``var'_label'_pob = `=r(N)'
		
		* Muestra ningún nivel educativo completado
		sum uno if nivel_educ==0 & migrante_ci==`var'
		scalar NoEdu_``var'_label'_muestra = `=r(N)'
		
		* Preescolar
		sum uno if nivel_educ==1 & migrante_ci==`var' [fw=factor_ci]
		scalar EduPre_``var'_label'_pob = `=r(N)'
		
		* Muestra preescolar
		sum uno if nivel_educ==1 & migrante_ci==`var'
		scalar EduPre_``var'_label'_muestra = `=r(N)'
		
		* Primaria
		sum uno if nivel_educ==2 & migrante_ci==`var' [fw=factor_ci]
		scalar EduPrim_``var'_label'_pob = `=r(N)'
		
		* Muestra primaria
		sum uno if nivel_educ==2 & migrante_ci==`var'
		scalar EduPrim_``var'_label'_muestra = `=r(N)'
		
		* Secundaria
		sum uno if nivel_educ==3 & migrante_ci==`var' [fw=factor_ci]
		scalar EduSecu_``var'_label'_pob = `=r(N)'
		
		* Muestra secundaria
		sum uno if nivel_educ==3 & migrante_ci==`var'
		scalar EduSecu_``var'_label'_muestra = `=r(N)'
		
		* Terciaria
		sum uno if nivel_educ==4 & migrante_ci==`var' [fw=factor_ci]
		scalar EduTerc_``var'_label'_pob = `=r(N)'
		
		sum uno if nivel_educ!=. & migrante_ci==`var' [fw=factor_ci]
		scalar NMEdu_``var'_label'_pob = `=r(N)'
		
		* Muestra terciaria
		sum uno if nivel_educ==4 & migrante_ci==`var'
		scalar EduTerc_``var'_label'_muestra = `=r(N)'
		
		
		**************** Indicadores por situación laboral *********************
		
		* Población en edad de trabajar
		sum uno if inrange(edad_ci,15,64) & migrante_ci==`var' [fw=factor_ci]
		scalar edadTrab_``var'_label'_pob = `=r(N)'
		
		* Muestra en edad de trabajar
		sum uno if inrange(edad_ci,15,64) & migrante_ci==`var'
		scalar edadTrab_``var'_label'_muestra = `=r(N)'
		
		* Población económicamente activa
		sum uno if inrange(edad_ci,15,64) & pea_ci==1 & migrante_ci==`var' [fw=factor_ci]
		scalar econoAct_``var'_label'_pob = `=r(N)'
		
		* Muestra económicamente activa
		sum uno if inrange(edad_ci,15,64) & pea_ci==1 & migrante_ci==`var'
		scalar econoAct_``var'_label'_muestra = `=r(N)'
		
		* Población empleada
		sum uno if inrange(edad_ci,15,64) & emp_ci==1 & migrante_ci==`var' [fw=factor_ci]
		scalar emp_``var'_label'_pob = `=r(N)'
		
		* Muestra empleada
		sum uno if inrange(edad_ci,15,64) & emp_ci==1 & migrante_ci==`var'
		scalar emp_``var'_label'_muestra = `=r(N)'
		
		* Población desempleada
		sum uno if inrange(edad_ci,15,64) & desemp_ci==1 & migrante_ci==`var' [fw=factor_ci] 
		scalar desemp_``var'_label'_pob = `=r(N)'
		
		* Muestra desempleada
		sum uno if inrange(edad_ci,15,64) & desemp_ci==1 & migrante_ci==`var'
		scalar desemp_``var'_label'_muestra = `=r(N)'
		
		* Informales
		sum uno if inrange(edad_ci,15,64) & informal==1 & migrante_ci==`var' [fw=factor_ci]
		scalar informal_``var'_label'_pob = `=r(N)'
		
		* Muestra informales
		sum uno if inrange(edad_ci,15,64) & informal==1 & migrante_ci==`var'
		scalar informal_``var'_label'_muestra = `=r(N)'
		
		**************** Indicadores por categorías de ingresos ****************
		
		* Decil 1
		sum uno if migrante_ci==`var' & dec_1 == 1 [fw=factor_ci]
		scalar D1_``var'_label'_pob = `=r(N)'
		
		* Muestra decil 1
		sum uno if migrante_ci==`var' & dec_1 == 1
		scalar D1_``var'_label'_muestra = `=r(N)'

		* Decil 2
		sum uno if migrante_ci==`var' & dec_2 == 1 [fw=factor_ci]
		scalar D2_``var'_label'_pob = `=r(N)'
		
		* Muestra decil 2
		sum uno if migrante_ci==`var' & dec_2 == 1
		scalar D2_``var'_label'_muestra = `=r(N)'
		
		* Decil 3
		sum uno if migrante_ci==`var' & dec_3 == 1 [fw=factor_ci]
		scalar D3_``var'_label'_pob = `=r(N)'
		
		* Muestra decil 3
		sum uno if migrante_ci==`var' & dec_3 == 1
		scalar D3_``var'_label'_muestra = `=r(N)'
		
		* Decil 4
		sum uno if migrante_ci==`var' & dec_4 == 1 [fw=factor_ci]
		scalar D4_``var'_label'_pob = `=r(N)'
		
		* Muestra decil 4
		sum uno if migrante_ci==`var' & dec_4 == 1
		scalar D4_``var'_label'_muestra = `=r(N)'
		
		* Decil 5
		sum uno if migrante_ci==`var' & dec_5 == 1 [fw=factor_ci]
		scalar D5_``var'_label'_pob = `=r(N)'
		
		* Muestra decil 5
		sum uno if migrante_ci==`var' & dec_5 == 1
		scalar D5_``var'_label'_muestra = `=r(N)'
		
		* Decil 6
		sum uno if migrante_ci==`var' & dec_6 == 1 [fw=factor_ci]
		scalar D6_``var'_label'_pob = `=r(N)'
		
		* Muestra decil 6
		sum uno if migrante_ci==`var' & dec_6 == 1
		scalar D6_``var'_label'_muestra = `=r(N)'
		
		* Decil 7
		sum uno if migrante_ci==`var' & dec_7 == 1 [fw=factor_ci]
		scalar D7_``var'_label'_pob = `=r(N)'
		
		* Muestra decil 7
		sum uno if migrante_ci==`var' & dec_7 == 1
		scalar D7_``var'_label'_muestra = `=r(N)'
		
		* Decil 8
		sum uno if migrante_ci==`var' & dec_8 == 1 [fw=factor_ci]
		scalar D8_``var'_label'_pob = `=r(N)'
		
		* Muestra decil 8
		sum uno if migrante_ci==`var' & dec_8 == 1
		scalar D8_``var'_label'_muestra = `=r(N)'
		
		* Decil 9
		sum uno if migrante_ci==`var' & dec_9 == 1 [fw=factor_ci]
		scalar D9_``var'_label'_pob = `=r(N)'
		
		* Muestra decil 9
		sum uno if migrante_ci==`var' & dec_9 == 1
		scalar D9_``var'_label'_muestra = `=r(N)'
		
		* Decil 10
		sum uno if migrante_ci==`var' & dec_10 == 1 [fw=factor_ci]
		scalar D10_``var'_label'_pob = `=r(N)'
		
		* Muestra decil 10
		sum uno if migrante_ci==`var' & dec_10 == 1
		scalar D10_``var'_label'_muestra = `=r(N)'
		
		sum uno if migrante_ci==`var' & (ing_dec!=.) [fw=factor_ci]
		scalar NMIng_``var'_label'_pob = `=r(N)'
	
		}
	
******************************************************** EXCEL OUTPUTS

	putexcel set "C:\Users\JCAMILOP\OneDrive - Inter-American Development Bank Group\Otros\Indicadores PNUD\Documentos\Resultados.xlsx", sheet("Indicadores") modify
	putexcel describe
	
	
	************************** Indicadores demográficos ***********************
	
	** Población
	putexcel I5 = (`=nat_pob'/`=tot_pob') J5 = (`=migr_pob'/`=tot_pob')	// Porcentaje de migrantes
	putexcel I6 = (`=nat_muestra') J6 = (`=migr_muestra')	// Tamaño de la muestra
	putexcel I7 = (`=mujer_nat_pob'/`=nat_pob') J7 = (`=mujer_migr_pob'/`=migr_pob')	// Porcentaje de mujeres
	putexcel I8 = (`=mujer_nat_muestra') J8 = (`=mujer_migr_muestra')	// Tamaño de la muestra
	
	* Edades 
	putexcel I9 = (`=pob_nat_014'/`=nat_pob') J9 = (`=pob_migr_014'/`=migr_pob') // 0 - 14
	putexcel I10 = (`=muestra_nat_014') J10 = (`=muestra_migr_014') // Tamaño de la muestra
	putexcel I11 = (`=pob_nat_1524'/`=nat_pob') J11 = (`=pob_migr_1524'/`=migr_pob') // 15 - 24
	putexcel I12 = (`=muestra_nat_1524') J12 = (`=muestra_migr_1524') // Tamaño de la muestra
	putexcel I13 = (`=pob_nat_2539'/`=nat_pob') J13 = (`=pob_migr_2539'/`=migr_pob') // 25 - 39
	putexcel I14 = (`=muestra_nat_2539') J14 = (`=muestra_migr_2539') // Tamaño de la muestra
	putexcel I15 = (`=pob_nat_4054'/`=nat_pob') J15 = (`=pob_migr_4054'/`=migr_pob') // 40 - 54
	putexcel I16 = (`=muestra_nat_4054') J16 = (`=muestra_migr_4054') // Tamaño de la muestra
	putexcel I17 = (`=pob_nat_5564'/`=nat_pob') J17 = (`=pob_migr_5564'/`=migr_pob') // 55 - 64
	putexcel I18 = (`=muestra_nat_5564') J18 = (`=muestra_migr_5564') // Tamaño de la muestra
	putexcel I19 = (`=pob_nat_65mas'/`=nat_pob') J19 = (`=pob_migr_65mas'/`=migr_pob') // 65 más
	putexcel I20 = (`=muestra_nat_65mas') J20 = (`=muestra_migr_65mas') // Tamaño de la muestra
	
	* Tamaño del hogar
	putexcel I21 = (`=tam_nat_hogar')  J21 = (`=tam_migr_hogar') // Tamaño del hogar
	putexcel I22 = (`=Mtam_nat_hogar')  J22 = (`=Mtam_migr_hogar') // Tamaño de la muestra
	
	* Número de hijos
	putexcel I23 = (`=num_nat_hijos')  J23 = (`=num_migr_hijos') // Número de hijos
	putexcel I24 = (`=Mnum_nat_hijos')  J24 = (`=Mnum_migr_hijos') // Tamaño de la muestra
	
	
	*************** Indicadores por ubicación geográfica ***********************
	
	* Población urbana
	putexcel I26 = (`=urbana_nat_pob'/`=nat_pob') J26 = (`=urbana_migr_pob'/`=migr_pob')	
	putexcel I27 = (`=urbana_nat_muestra') J27 = (`=urbana_migr_muestra') // Tamaño de la muestra
	
	* Población rural
	putexcel I28 = (`=rural_nat_pob'/`=nat_pob') J28 = (`=rural_migr_pob'/`=migr_pob')
	putexcel I29 = (`=rural_nat_muestra') J29 = (`=rural_migr_muestra')	// Tamaño de la muestra	
	
	* Ciudad capital
	putexcel I30 = (`=capital_nat_pob'/`=nat_pob') J30 = (`=capital_migr_pob'/`=migr_pob')
	putexcel I31 = (`=capital_nat_muestra') J31 = (`=capital_migr_muestra') // Tamaño de la muestra	
	
	
	************** Indicadores por nivel de educación completo *****************
	
	** Por nivel educativo
	
	* Ningún nivel educativo completado
	putexcel I33 = (`=NoEdu_nat_pob'/`=NMEdu_nat_pob') J33 = (`=NoEdu_migr_pob'/`=NMEdu_migr_pob')
	putexcel I34 = (`=NoEdu_nat_muestra') J34 = (`=NoEdu_migr_muestra')	// Tamaño de la muestra
	
	** Preescolar
	putexcel I35 = (`=EduPre_nat_pob'/`=NMEdu_nat_pob') J35 = (`=EduPre_migr_pob'/`=NMEdu_migr_pob')
	putexcel I36 = (`=EduPre_nat_muestra') J36 = (`=EduPre_migr_muestra')	// Tamaño de la muestra
	
	** Primaria completa
	putexcel I37 = (`=EduPrim_nat_pob'/`=NMEdu_nat_pob') J37 = (`=EduPrim_migr_pob'/`=NMEdu_migr_pob')
	putexcel I38 = (`=EduPrim_nat_muestra') J38 = (`=EduPrim_migr_muestra')	// Tamaño de la muestra
	
	** Secundaria completa
	putexcel I39 = (`=EduSecu_nat_pob'/`=NMEdu_nat_pob') J39 = (`=EduSecu_migr_pob'/`=NMEdu_migr_pob')
	putexcel I40 = (`=EduSecu_nat_muestra') J40 = (`=EduSecu_migr_muestra')	// Tamaño de la muestra
	
	** Terciaria completa
	putexcel I41 = (`=EduTerc_nat_pob'/`=NMEdu_nat_pob') J41 = (`=EduTerc_migr_pob'/`=NMEdu_migr_pob')
	putexcel I42 = (`=EduTerc_nat_muestra') J42 = (`=EduTerc_migr_muestra')	// Tamaño de la muestra
	
	
	****************** Indicadores por situación laboral ***********************
	
	* Población en edad de trabajar
	putexcel I44 = (`=edadTrab_nat_pob'/`=nat_pob') J44 = (`=edadTrab_migr_pob'/`=migr_pob')
	putexcel I45 = (`=edadTrab_nat_muestra') J45 = (`=edadTrab_migr_muestra') // Tamaño de la muestra
	
	* Población económicamente activa
	putexcel I46 = (`=econoAct_nat_pob'/`=edadTrab_nat_pob') J46 = (`=econoAct_migr_pob'/`=edadTrab_migr_pob')
	putexcel I47 = (`=econoAct_nat_muestra') J47 = (`=econoAct_migr_muestra') // Tamaño de la muestra
	
	* Población empleada
	putexcel I48 = (`=emp_nat_pob'/`=econoAct_nat_pob') J48 = (`=emp_migr_pob'/`=econoAct_migr_pob')
	putexcel I49 = (`=emp_nat_muestra') J49 = (`=emp_migr_muestra') // Tamaño de la muestra
	
	* Población desempleada
	putexcel I50 = (`=desemp_nat_pob'/`=econoAct_nat_pob') J50 = (`=desemp_migr_pob'/`=econoAct_migr_pob')
	putexcel I51 = (`=desemp_nat_muestra') J51 = (`=desemp_migr_muestra') // Tamaño de la muestra	
	
	* Población informal
	putexcel I52 = (`=informal_nat_pob'/`=emp_nat_pob') J52 = (`=informal_migr_pob'/`=emp_migr_pob')
	putexcel I53 = (`=informal_nat_muestra') J53 = (`=informal_migr_muestra') // Tamaño de la muestra
	
	
	****************** Indicadores por categorías de ingresos ******************
	
	putexcel I55 = (`=D1_nat_pob'/`=NMIng_nat_pob') J55 = (`=D1_migr_pob'/`=NMIng_migr_pob') // (D1)
	putexcel I56 = (`=D1_nat_muestra') J56 = (`=D1_migr_muestra') // Tamaño muestra
	
	putexcel I57 = (`=D2_nat_pob'/`=NMIng_nat_pob') J57 = (`=D2_migr_pob'/`=NMIng_migr_pob') // (D2)
	putexcel I58 = (`=D2_nat_muestra') J58 = (`=D2_migr_muestra') // Tamaño muestra
	
	putexcel I59 = (`=D3_nat_pob'/`=NMIng_nat_pob') J59 = (`=D3_migr_pob'/`=NMIng_migr_pob') // (D3)
	putexcel I60 = (`=D3_nat_muestra') J60 = (`=D3_migr_muestra') // Tamaño muestra
	
	putexcel I61 = (`=D4_nat_pob'/`=NMIng_nat_pob') J61 = (`=D4_migr_pob'/`=NMIng_migr_pob') // (D4)
	putexcel I62 = (`=D4_nat_muestra') J62 = (`=D4_migr_muestra') // Tamaño muestra
	
	putexcel I63 = (`=D5_nat_pob'/`=NMIng_nat_pob') J63 = (`=D5_migr_pob'/`=NMIng_migr_pob') // (D5)
	putexcel I64 = (`=D5_nat_muestra') J64 = (`=D5_migr_muestra') // Tamaño muestra
	
	putexcel I65 = (`=D6_nat_pob'/`=NMIng_nat_pob') J65 = (`=D6_migr_pob'/`=NMIng_migr_pob') // (D6)
	putexcel I66 = (`=D6_nat_muestra') J66 = (`=D6_migr_muestra') // Tamaño muestra
	
	putexcel I67 = (`=D7_nat_pob'/`=NMIng_nat_pob') J67 = (`=D7_migr_pob'/`=NMIng_migr_pob') // (D7)
	putexcel I68 = (`=D7_nat_muestra') J68 = (`=D7_migr_muestra') // Tamaño muestra
	
	putexcel I69 = (`=D8_nat_pob'/`=NMIng_nat_pob') J69 = (`=D8_migr_pob'/`=NMIng_migr_pob') // (D8)
	putexcel I70 = (`=D8_nat_muestra') J70 = (`=D8_migr_muestra') // Tamaño muestra
	
	putexcel I71 = (`=D9_nat_pob'/`=NMIng_nat_pob') J71 = (`=D9_migr_pob'/`=NMIng_migr_pob') // (D9)
	putexcel I72 = (`=D9_nat_muestra') J72 = (`=D9_migr_muestra') // Tamaño muestra
	
	putexcel I73 = (`=D10_nat_pob'/`=NMIng_nat_pob') J73 = (`=D10_migr_pob'/`=NMIng_migr_pob') // (D10)
	putexcel I74 = (`=D10_nat_muestra') J74 = (`=D10_migr_muestra') // Tamaño muestra	
		
	
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
	cd "C:\Users\JCAMILOP\OneDrive - Inter-American Development Bank Group\Otros\Indicadores PNUD\Bases de datos"
	use "ECU_2021a_BID.dta", replace

	gen uno=1
	replace factor_ci=round(factor_ci/4) // Applies when the expansion factor is a non-integer number
	rename p41 codocupa
	rename p40 codindustria
	
	****************************************************************************
	** LOCALS
		local 1_label = "migr"
		local 0_label = "nat"
		
		local 1_sexo = "masc_"
		local 2_sexo = "fem_"	
	
	****************************************************************************
	** Tamaño del hogar
	by idh_ch, sort: egen nmiembros=sum(relacion_ci>=1 & relacion_ci<5)	
	by idh_ch, sort: egen nhijos=sum(relacion_ci==3)
	
	****************************************************************************
	** Informalidad
	gen informal = (cotizando_ci != 1 & emp_ci==1)
	
	****************************************************************************
	** Muestra total
	sum uno if migrante_ci!=.
	scalar tot_muestra = `=r(N)'
	
	****************************************************************************
	** Muestra migrantes
	sum uno if migrante_ci==1
	scalar migr_muestra = `=r(N)'
	
	****************************************************************************
	** Muestra nativos
	sum uno if migrante_ci==0
	scalar nat_muestra = `=r(N)'
	
	****************************************************************************
	** Población total según factores de expansión
	sum uno if migrante_ci!=. [fw=factor_ci]
	scalar tot_pob = `=r(N)'
	
	****************************************************************************
	** Población migrante según factores de expansión
	sum uno if migrante_ci==1 [fw=factor_ci]
	scalar migr_pob = `=r(N)'
	
	****************************************************************************
	** Población nativa según factores de expansión
	sum uno if migrante_ci==0 [fw=factor_ci]
	scalar nat_pob = `=r(N)'
	
	****************************************************************************
	** Nivel educativo
	gen nivel_educ = 0 if eduno_ci == 1
	replace nivel_educ = 1 if edupre_ci == 1 & edupc_ci == 0
	replace nivel_educ = 2 if edupc_ci == 1 & edusc_ci == 0
	replace nivel_educ = 3 if edusc_ci == 1 & eduuc_ci == 0
	replace nivel_educ = 4 if eduuc_ci == 1
	
	****************************************************************************
	** Ingresos totales
	egen totIng=rowtotal(ylm_ci ylnm_ci ynlm_ci ynlnm_ci remesas_ci)
	
	****************************************************************************
	** Distribución ingresos
	xtile ing_dec=totIng if edad_ci>15 & pea_ci==1, n(10)
	
	* Decil 1
	gen dec_1=(ing_dec==1)
	replace dec_1=. if ing_dec==.

	* Decil 2
	gen dec_2=(ing_dec==2)
	replace dec_2=. if ing_dec==.

	* Decil 3
	gen dec_3=(ing_dec==3)
	replace dec_3=. if ing_dec==.
	
	* Decil 4
	gen dec_4=(ing_dec==4)
	replace dec_4=. if ing_dec==.

	* Decil 5 
	gen dec_5=(ing_dec==5)
	replace dec_5=. if ing_dec==.

	* Decil 6
	gen dec_6=(ing_dec==6)
	replace dec_6=. if ing_dec==.
	
	* Decil 7
	gen dec_7=(ing_dec==7)
	replace dec_7=. if ing_dec==.

	* Decil 8
	gen dec_8=(ing_dec==8)
	replace dec_8=. if ing_dec==.

	* Decil 9
	gen dec_9=(ing_dec==9)
	replace dec_9=. if ing_dec==.
	
	* Decil 10
	gen dec_10=(ing_dec==10)
	replace dec_10=. if ing_dec==.
	
	****************************************************************************
	** Cálculo de indicadores por migrantes y nativos
	
	foreach var in 1 0 {
		
		*********************** Indicadores demográficos ***********************	
		
		* Mujeres
		sum uno if sexo_ci==2 & migrante_ci==`var' [fw=factor_ci]
		scalar mujer_``var'_label'_pob =`=r(N)'
		
		* Mujeres muestra
		sum uno if sexo_ci==2 & migrante_ci==`var'
		scalar mujer_``var'_label'_muestra =`=r(N)'
		
		* Grupos de edades
		sum uno if inrange(edad_ci,0,14) & migrante_ci==`var' [fw=factor_ci]
		scalar pob_``var'_label'_014 = `=r(N)' // 0 - 14 years
		
		sum uno if inrange(edad_ci,15,24) & migrante_ci==`var' [fw=factor_ci]
		scalar pob_``var'_label'_1524 = `=r(N)' // 15 - 24 years

		sum uno if inrange(edad_ci,25,39) & migrante_ci==`var' [fw=factor_ci]
		scalar pob_``var'_label'_2539 = `=r(N)' // 25 - 39 years
		
		sum uno if inrange(edad_ci,40,54) & migrante_ci==`var' [fw=factor_ci]
		scalar pob_``var'_label'_4054 = `=r(N)' // 40 - 54 years

		sum uno if inrange(edad_ci,55,64) & migrante_ci==`var' [fw=factor_ci]
		scalar pob_``var'_label'_5564 = `=r(N)'	//55 - 64 years
		
		sum uno if inrange(edad_ci,65,.) & migrante_ci==`var' [fw=factor_ci]
		scalar pob_``var'_label'_65mas = `=r(N)'  // 65 older years
		
		* Muestra grupos de edades
		sum uno if inrange(edad_ci,0,14) & migrante_ci==`var'
		scalar muestra_``var'_label'_014 = `=r(N)' // 0 - 14 years
		
		sum uno if inrange(edad_ci,15,24) & migrante_ci==`var'
		scalar muestra_``var'_label'_1524 = `=r(N)' // 15 - 24 years

		sum uno if inrange(edad_ci,25,39) & migrante_ci==`var'
		scalar muestra_``var'_label'_2539 = `=r(N)' // 25 - 39 years
		
		sum uno if inrange(edad_ci,40,54) & migrante_ci==`var'
		scalar muestra_``var'_label'_4054 = `=r(N)' // 40 - 54 years

		sum uno if inrange(edad_ci,55,64) & migrante_ci==`var'
		scalar muestra_``var'_label'_5564 = `=r(N)'	//55 - 64 years
		
		sum uno if inrange(edad_ci,65,.) & migrante_ci==`var'
		scalar muestra_``var'_label'_65mas = `=r(N)'  // 65 older years
		
		* Tamaño del hogar
		sum nmiembros if migrante_ci==`var' [fw=factor_ci]
		scalar tam_``var'_label'_hogar = `=r(mean)'
		
		* Muestra tamaño hogar
		sum nmiembros if migrante_ci==`var'
		scalar Mtam_``var'_label'_hogar = `=r(N)'
		
		* Número de hijos
		sum nhijos if migrante_ci==`var' [fw=factor_ci]
		scalar num_``var'_label'_hijos = `=r(mean)'
		
		* Muestra número de hijos
		sum nhijos if migrante_ci==`var'
		scalar Mnum_``var'_label'_hijos = `=r(N)'
		
		
		********** Indicadores por ubicación geográfica ***********************

		* Porcentaje en zonas urbanas
		sum uno if zona_c==1 & migrante_ci==`var' [fw=factor_ci]
		scalar urbana_``var'_label'_pob = `=r(N)'
		
		* Muestra en zonas urbanas
		sum uno if zona_c==1 & migrante_ci==`var'
		scalar urbana_``var'_label'_muestra = `=r(N)'
		
		* Porcentaje en zonas rurales
		sum uno if zona_c==0 & migrante_ci==`var' [fw=factor_ci]
		scalar rural_``var'_label'_pob = `=r(N)'
		
		* Muestra en zonas rurales
		sum uno if zona_c==0 & migrante_ci==`var'
		scalar rural_``var'_label'_muestra = `=r(N)'
		
		* Porcentaje en ciudad capital
		sum uno if region_c==17 & migrante_ci==`var' [fw=factor_ci]
		scalar capital_``var'_label'_pob = `=r(N)'
		
		* Muestra en ciudad capital
		sum uno if region_c==17 & migrante_ci==`var'
		scalar capital_``var'_label'_muestra = `=r(N)'
		
		
		************* Indicadores por nivel de educación completo **************
		
		* Ningún nivel educativo completado
		sum uno if nivel_educ==0 & migrante_ci==`var' [fw=factor_ci]
		scalar NoEdu_``var'_label'_pob = `=r(N)'
		
		* Muestra ningún nivel educativo completado
		sum uno if nivel_educ==0 & migrante_ci==`var'
		scalar NoEdu_``var'_label'_muestra = `=r(N)'
		
		* Preescolar
		sum uno if nivel_educ==1 & migrante_ci==`var' [fw=factor_ci]
		scalar EduPre_``var'_label'_pob = `=r(N)'
		
		* Muestra preescolar
		sum uno if nivel_educ==1 & migrante_ci==`var'
		scalar EduPre_``var'_label'_muestra = `=r(N)'
		
		* Primaria
		sum uno if nivel_educ==2 & migrante_ci==`var' [fw=factor_ci]
		scalar EduPrim_``var'_label'_pob = `=r(N)'
		
		* Muestra primaria
		sum uno if nivel_educ==2 & migrante_ci==`var'
		scalar EduPrim_``var'_label'_muestra = `=r(N)'
		
		* Secundaria
		sum uno if nivel_educ==3 & migrante_ci==`var' [fw=factor_ci]
		scalar EduSecu_``var'_label'_pob = `=r(N)'
		
		* Muestra secundaria
		sum uno if nivel_educ==3 & migrante_ci==`var'
		scalar EduSecu_``var'_label'_muestra = `=r(N)'
		
		* Terciaria
		sum uno if nivel_educ==4 & migrante_ci==`var' [fw=factor_ci]
		scalar EduTerc_``var'_label'_pob = `=r(N)'
		
		sum uno if nivel_educ!=. & migrante_ci==`var' [fw=factor_ci]
		scalar NMEdu_``var'_label'_pob = `=r(N)'
		
		* Muestra terciaria
		sum uno if nivel_educ==4 & migrante_ci==`var'
		scalar EduTerc_``var'_label'_muestra = `=r(N)'
		
		
		**************** Indicadores por situación laboral *********************
		
		* Población en edad de trabajar
		sum uno if inrange(edad_ci,15,64) & migrante_ci==`var' [fw=factor_ci]
		scalar edadTrab_``var'_label'_pob = `=r(N)'
		
		* Muestra en edad de trabajar
		sum uno if inrange(edad_ci,15,64) & migrante_ci==`var'
		scalar edadTrab_``var'_label'_muestra = `=r(N)'
		
		* Población económicamente activa
		sum uno if inrange(edad_ci,15,64) & pea_ci==1 & migrante_ci==`var' [fw=factor_ci]
		scalar econoAct_``var'_label'_pob = `=r(N)'
		
		* Muestra económicamente activa
		sum uno if inrange(edad_ci,15,64) & pea_ci==1 & migrante_ci==`var'
		scalar econoAct_``var'_label'_muestra = `=r(N)'
		
		* Población empleada
		sum uno if inrange(edad_ci,15,64) & emp_ci==1 & migrante_ci==`var' [fw=factor_ci]
		scalar emp_``var'_label'_pob = `=r(N)'
		
		* Muestra empleada
		sum uno if inrange(edad_ci,15,64) & emp_ci==1 & migrante_ci==`var'
		scalar emp_``var'_label'_muestra = `=r(N)'
		
		* Población desempleada
		sum uno if inrange(edad_ci,15,64) & desemp_ci==1 & migrante_ci==`var' [fw=factor_ci] 
		scalar desemp_``var'_label'_pob = `=r(N)'
		
		* Muestra desempleada
		sum uno if inrange(edad_ci,15,64) & desemp_ci==1 & migrante_ci==`var'
		scalar desemp_``var'_label'_muestra = `=r(N)'
		
		* Informales
		sum uno if inrange(edad_ci,15,64) & informal==1 & migrante_ci==`var' [fw=factor_ci]
		scalar informal_``var'_label'_pob = `=r(N)'
		
		* Muestra informales
		sum uno if inrange(edad_ci,15,64) & informal==1 & migrante_ci==`var'
		scalar informal_``var'_label'_muestra = `=r(N)'
		
		**************** Indicadores por categorías de ingresos ****************
		
		* Decil 1
		sum uno if migrante_ci==`var' & dec_1 == 1 [fw=factor_ci]
		scalar D1_``var'_label'_pob = `=r(N)'
		
		* Muestra decil 1
		sum uno if migrante_ci==`var' & dec_1 == 1
		scalar D1_``var'_label'_muestra = `=r(N)'

		* Decil 2
		sum uno if migrante_ci==`var' & dec_2 == 1 [fw=factor_ci]
		scalar D2_``var'_label'_pob = `=r(N)'
		
		* Muestra decil 2
		sum uno if migrante_ci==`var' & dec_2 == 1
		scalar D2_``var'_label'_muestra = `=r(N)'
		
		* Decil 3
		sum uno if migrante_ci==`var' & dec_3 == 1 [fw=factor_ci]
		scalar D3_``var'_label'_pob = `=r(N)'
		
		* Muestra decil 3
		sum uno if migrante_ci==`var' & dec_3 == 1
		scalar D3_``var'_label'_muestra = `=r(N)'
		
		* Decil 4
		sum uno if migrante_ci==`var' & dec_4 == 1 [fw=factor_ci]
		scalar D4_``var'_label'_pob = `=r(N)'
		
		* Muestra decil 4
		sum uno if migrante_ci==`var' & dec_4 == 1
		scalar D4_``var'_label'_muestra = `=r(N)'
		
		* Decil 5
		sum uno if migrante_ci==`var' & dec_5 == 1 [fw=factor_ci]
		scalar D5_``var'_label'_pob = `=r(N)'
		
		* Muestra decil 5
		sum uno if migrante_ci==`var' & dec_5 == 1
		scalar D5_``var'_label'_muestra = `=r(N)'
		
		* Decil 6
		sum uno if migrante_ci==`var' & dec_6 == 1 [fw=factor_ci]
		scalar D6_``var'_label'_pob = `=r(N)'
		
		* Muestra decil 6
		sum uno if migrante_ci==`var' & dec_6 == 1
		scalar D6_``var'_label'_muestra = `=r(N)'
		
		* Decil 7
		sum uno if migrante_ci==`var' & dec_7 == 1 [fw=factor_ci]
		scalar D7_``var'_label'_pob = `=r(N)'
		
		* Muestra decil 7
		sum uno if migrante_ci==`var' & dec_7 == 1
		scalar D7_``var'_label'_muestra = `=r(N)'
		
		* Decil 8
		sum uno if migrante_ci==`var' & dec_8 == 1 [fw=factor_ci]
		scalar D8_``var'_label'_pob = `=r(N)'
		
		* Muestra decil 8
		sum uno if migrante_ci==`var' & dec_8 == 1
		scalar D8_``var'_label'_muestra = `=r(N)'
		
		* Decil 9
		sum uno if migrante_ci==`var' & dec_9 == 1 [fw=factor_ci]
		scalar D9_``var'_label'_pob = `=r(N)'
		
		* Muestra decil 9
		sum uno if migrante_ci==`var' & dec_9 == 1
		scalar D9_``var'_label'_muestra = `=r(N)'
		
		* Decil 10
		sum uno if migrante_ci==`var' & dec_10 == 1 [fw=factor_ci]
		scalar D10_``var'_label'_pob = `=r(N)'
		
		* Muestra decil 10
		sum uno if migrante_ci==`var' & dec_10 == 1
		scalar D10_``var'_label'_muestra = `=r(N)'
		
		sum uno if migrante_ci==`var' & (ing_dec!=.) [fw=factor_ci]
		scalar NMIng_``var'_label'_pob = `=r(N)'
	
		}
	
******************************************************** EXCEL OUTPUTS

	putexcel set "C:\Users\JCAMILOP\OneDrive - Inter-American Development Bank Group\Otros\Indicadores PNUD\Documentos\Resultados.xlsx", sheet("Indicadores") modify
	putexcel describe
	
	
	************************** Indicadores demográficos ***********************
	
	** Población
	putexcel K5 = (`=nat_pob'/`=tot_pob') L5 = (`=migr_pob'/`=tot_pob')	// Porcentaje de migrantes
	putexcel K6 = (`=nat_muestra') L6 = (`=migr_muestra')	// Tamaño de la muestra
	putexcel K7 = (`=mujer_nat_pob'/`=nat_pob') L7 = (`=mujer_migr_pob'/`=migr_pob')	// Porcentaje de mujeres
	putexcel K8 = (`=mujer_nat_muestra') L8 = (`=mujer_migr_muestra')	// Tamaño de la muestra
	
	* Edades 
	putexcel K9 = (`=pob_nat_014'/`=nat_pob') L9 = (`=pob_migr_014'/`=migr_pob') // 0 - 14
	putexcel K10 = (`=muestra_nat_014') L10 = (`=muestra_migr_014') // Tamaño de la muestra
	putexcel K11 = (`=pob_nat_1524'/`=nat_pob') L11 = (`=pob_migr_1524'/`=migr_pob') // 15 - 24
	putexcel K12 = (`=muestra_nat_1524') L12 = (`=muestra_migr_1524') // Tamaño de la muestra
	putexcel K13 = (`=pob_nat_2539'/`=nat_pob') L13 = (`=pob_migr_2539'/`=migr_pob') // 25 - 39
	putexcel K14 = (`=muestra_nat_2539') L14 = (`=muestra_migr_2539') // Tamaño de la muestra
	putexcel K15 = (`=pob_nat_4054'/`=nat_pob') L15 = (`=pob_migr_4054'/`=migr_pob') // 40 - 54
	putexcel K16 = (`=muestra_nat_4054') L16 = (`=muestra_migr_4054') // Tamaño de la muestra
	putexcel K17 = (`=pob_nat_5564'/`=nat_pob') L17 = (`=pob_migr_5564'/`=migr_pob') // 55 - 64
	putexcel K18 = (`=muestra_nat_5564') L18 = (`=muestra_migr_5564') // Tamaño de la muestra
	putexcel K19 = (`=pob_nat_65mas'/`=nat_pob') L19 = (`=pob_migr_65mas'/`=migr_pob') // 65 más
	putexcel K20 = (`=muestra_nat_65mas') L20 = (`=muestra_migr_65mas') // Tamaño de la muestra
	
	* Tamaño del hogar
	putexcel K21 = (`=tam_nat_hogar')  L21 = (`=tam_migr_hogar') // Tamaño del hogar
	putexcel K22 = (`=Mtam_nat_hogar')  L22 = (`=Mtam_migr_hogar') // Tamaño de la muestra
	
	* Número de hijos
	putexcel K23 = (`=num_nat_hijos')  L23 = (`=num_migr_hijos') // Número de hijos
	putexcel K24 = (`=Mnum_nat_hijos')  L24 = (`=Mnum_migr_hijos') // Tamaño de la muestra
	
	
	*************** Indicadores por ubicación geográfica ***********************
	
	* Población urbana
	putexcel K26 = (`=urbana_nat_pob'/`=nat_pob') L26 = (`=urbana_migr_pob'/`=migr_pob')	
	putexcel K27 = (`=urbana_nat_muestra') L27 = (`=urbana_migr_muestra') // Tamaño de la muestra
	
	* Población rural
	putexcel K28 = (`=rural_nat_pob'/`=nat_pob') L28 = (`=rural_migr_pob'/`=migr_pob')
	putexcel K29 = (`=rural_nat_muestra') L29 = (`=rural_migr_muestra')	// Tamaño de la muestra	
	
	* Ciudad capital
	putexcel K30 = (`=capital_nat_pob'/`=nat_pob') L30 = (`=capital_migr_pob'/`=migr_pob')
	putexcel K31 = (`=capital_nat_muestra') L31 = (`=capital_migr_muestra') // Tamaño de la muestra	
	
	
	************** Indicadores por nivel de educación completo *****************
	
	** Por nivel educativo
	
	* Ningún nivel educativo completado
	putexcel K33 = (`=NoEdu_nat_pob'/`=NMEdu_nat_pob') L33 = (`=NoEdu_migr_pob'/`=NMEdu_migr_pob')
	putexcel K34 = (`=NoEdu_nat_muestra') L34 = (`=NoEdu_migr_muestra')	// Tamaño de la muestra
	
	** Preescolar
	putexcel K35 = (`=EduPre_nat_pob'/`=NMEdu_nat_pob') L35 = (`=EduPre_migr_pob'/`=NMEdu_migr_pob')
	putexcel K36 = (`=EduPre_nat_muestra') L36 = (`=EduPre_migr_muestra')	// Tamaño de la muestra
	
	** Primaria completa
	putexcel K37 = (`=EduPrim_nat_pob'/`=NMEdu_nat_pob') L37 = (`=EduPrim_migr_pob'/`=NMEdu_migr_pob')
	putexcel K38 = (`=EduPrim_nat_muestra') L38 = (`=EduPrim_migr_muestra')	// Tamaño de la muestra
	
	** Secundaria completa
	putexcel K39 = (`=EduSecu_nat_pob'/`=NMEdu_nat_pob') L39 = (`=EduSecu_migr_pob'/`=NMEdu_migr_pob')
	putexcel K40 = (`=EduSecu_nat_muestra') L40 = (`=EduSecu_migr_muestra')	// Tamaño de la muestra
	
	** Terciaria completa
	putexcel K41 = (`=EduTerc_nat_pob'/`=NMEdu_nat_pob') L41 = (`=EduTerc_migr_pob'/`=NMEdu_migr_pob')
	putexcel K42 = (`=EduTerc_nat_muestra') L42 = (`=EduTerc_migr_muestra')	// Tamaño de la muestra
	
	
	****************** Indicadores por situación laboral ***********************
	
	* Población en edad de trabajar
	putexcel K44 = (`=edadTrab_nat_pob'/`=nat_pob') L44 = (`=edadTrab_migr_pob'/`=migr_pob')
	putexcel K45 = (`=edadTrab_nat_muestra') L45 = (`=edadTrab_migr_muestra') // Tamaño de la muestra
	
	* Población económicamente activa
	putexcel K46 = (`=econoAct_nat_pob'/`=edadTrab_nat_pob') L46 = (`=econoAct_migr_pob'/`=edadTrab_migr_pob')
	putexcel K47 = (`=econoAct_nat_muestra') L47 = (`=econoAct_migr_muestra') // Tamaño de la muestra
	
	* Población empleada
	putexcel K48 = (`=emp_nat_pob'/`=econoAct_nat_pob') L48 = (`=emp_migr_pob'/`=econoAct_migr_pob')
	putexcel K49 = (`=emp_nat_muestra') L49 = (`=emp_migr_muestra') // Tamaño de la muestra
	
	* Población desempleada
	putexcel K50 = (`=desemp_nat_pob'/`=econoAct_nat_pob') L50 = (`=desemp_migr_pob'/`=econoAct_migr_pob')
	putexcel K51 = (`=desemp_nat_muestra') L51 = (`=desemp_migr_muestra') // Tamaño de la muestra	
	
	* Población informal
	putexcel K52 = (`=informal_nat_pob'/`=emp_nat_pob') L52 = (`=informal_migr_pob'/`=emp_migr_pob')
	putexcel K53 = (`=informal_nat_muestra') L53 = (`=informal_migr_muestra') // Tamaño de la muestra
	
	****************** Indicadores por categorías de ingresos ******************
	
	putexcel K55 = (`=D1_nat_pob'/`=NMIng_nat_pob') L55 = (`=D1_migr_pob'/`=NMIng_migr_pob') // (D1)
	putexcel K56 = (`=D1_nat_muestra') L56 = (`=D1_migr_muestra') // Tamaño muestra
	
	putexcel K57 = (`=D2_nat_pob'/`=NMIng_nat_pob') L57 = (`=D2_migr_pob'/`=NMIng_migr_pob') // (D2)
	putexcel K58 = (`=D2_nat_muestra') L58 = (`=D2_migr_muestra') // Tamaño muestra
	
	putexcel K59 = (`=D3_nat_pob'/`=NMIng_nat_pob') L59 = (`=D3_migr_pob'/`=NMIng_migr_pob') // (D3)
	putexcel K60 = (`=D3_nat_muestra') L60 = (`=D3_migr_muestra') // Tamaño muestra
	
	putexcel K61 = (`=D4_nat_pob'/`=NMIng_nat_pob') L61 = (`=D4_migr_pob'/`=NMIng_migr_pob') // (D4)
	putexcel K62 = (`=D4_nat_muestra') L62 = (`=D4_migr_muestra') // Tamaño muestra
	
	putexcel K63 = (`=D5_nat_pob'/`=NMIng_nat_pob') L63 = (`=D5_migr_pob'/`=NMIng_migr_pob') // (D5)
	putexcel K64 = (`=D5_nat_muestra') L64 = (`=D5_migr_muestra') // Tamaño muestra
	
	putexcel K65 = (`=D6_nat_pob'/`=NMIng_nat_pob') L65 = (`=D6_migr_pob'/`=NMIng_migr_pob') // (D6)
	putexcel K66 = (`=D6_nat_muestra') L66 = (`=D6_migr_muestra') // Tamaño muestra
	
	putexcel K67 = (`=D7_nat_pob'/`=NMIng_nat_pob') L67 = (`=D7_migr_pob'/`=NMIng_migr_pob') // (D7)
	putexcel K68 = (`=D7_nat_muestra') L68 = (`=D7_migr_muestra') // Tamaño muestra
	
	putexcel K69 = (`=D8_nat_pob'/`=NMIng_nat_pob') L69 = (`=D8_migr_pob'/`=NMIng_migr_pob') // (D8)
	putexcel K70 = (`=D8_nat_muestra') L70 = (`=D8_migr_muestra') // Tamaño muestra
	
	putexcel K71 = (`=D9_nat_pob'/`=NMIng_nat_pob') L71 = (`=D9_migr_pob'/`=NMIng_migr_pob') // (D9)
	putexcel K72 = (`=D9_nat_muestra') L72 = (`=D9_migr_muestra') // Tamaño muestra
	
	putexcel K73 = (`=D10_nat_pob'/`=NMIng_nat_pob') L73 = (`=D10_migr_pob'/`=NMIng_migr_pob') // (D10)
	putexcel K74 = (`=D10_nat_muestra') L74 = (`=D10_migr_muestra') // Tamaño muestra
		
	
********************************************************************************
********************************************************************************
********************************************************************************
****** PERÚ - ENCUESTA NACIONAL DE HOGARES 2020 ********************************
	
	clear all
	set more off, perm
	set maxvar 15000
	scalar drop _all

	** DATASET
	cd "C:\Users\JCAMILOP\OneDrive - Inter-American Development Bank Group\Otros\Indicadores PNUD\Bases de datos"
	use "PER_2021a_BID.dta", replace

	gen uno=1
	replace factor_ci=round(factor_ci) // Applies when the expansion factor is a non-integer numbers
	replace migrante_ci = 0 if migrante_ci == .
	
	****************************************************************************
	** LOCALS
		local 1_label = "migr"
		local 0_label = "nat"
		
		local 1_sexo = "masc_"
		local 2_sexo = "fem_"	
	
	****************************************************************************
	** Tamaño del hogar
	by idh_ch, sort: egen nmiembros=sum(relacion_ci>=1 & relacion_ci<5)	
	by idh_ch, sort: egen nhijos=sum(relacion_ci==3)
	
	****************************************************************************
	** Informalidad
	gen informal = (cotizando_ci != 1 & emp_ci==1)
	
	****************************************************************************
	** Muestra total
	sum uno if migrante_ci!=.
	scalar tot_muestra = `=r(N)'
	
	****************************************************************************
	** Muestra migrantes
	sum uno if migrante_ci==1
	scalar migr_muestra = `=r(N)'
	
	****************************************************************************
	** Muestra nativos
	sum uno if migrante_ci==0
	scalar nat_muestra = `=r(N)'
	
	****************************************************************************
	** Población total según factores de expansión
	sum uno if migrante_ci!=. [fw=factor_ci]
	scalar tot_pob = `=r(N)'
	
	****************************************************************************
	** Población migrante según factores de expansión
	sum uno if migrante_ci==1 [fw=factor_ci]
	scalar migr_pob = `=r(N)'
	
	****************************************************************************
	** Población nativa según factores de expansión
	sum uno if migrante_ci==0 [fw=factor_ci]
	scalar nat_pob = `=r(N)'
	
	****************************************************************************
	** Nivel educativo
	gen nivel_educ = 0 if eduno_ci == 1
	replace nivel_educ = 1 if edupre_ci == 1 & edupc_ci == 0
	replace nivel_educ = 2 if edupc_ci == 1 & edusc_ci == 0
	replace nivel_educ = 3 if edusc_ci == 1 & eduuc_ci == 0
	replace nivel_educ = 4 if eduuc_ci == 1
	
	****************************************************************************
	** Ingresos totales
	egen totIng=rowtotal(ylm_ci ylnm_ci ynlm_ci ynlnm_ci remesas_ci)
	
	****************************************************************************
	** Distribución ingresos
	xtile ing_dec=totIng if edad_ci>15 & pea_ci==1, n(10)
	
	* Decil 1
	gen dec_1=(ing_dec==1)
	replace dec_1=. if ing_dec==.

	* Decil 2
	gen dec_2=(ing_dec==2)
	replace dec_2=. if ing_dec==.

	* Decil 3
	gen dec_3=(ing_dec==3)
	replace dec_3=. if ing_dec==.
	
	* Decil 4
	gen dec_4=(ing_dec==4)
	replace dec_4=. if ing_dec==.

	* Decil 5 
	gen dec_5=(ing_dec==5)
	replace dec_5=. if ing_dec==.

	* Decil 6
	gen dec_6=(ing_dec==6)
	replace dec_6=. if ing_dec==.
	
	* Decil 7
	gen dec_7=(ing_dec==7)
	replace dec_7=. if ing_dec==.

	* Decil 8
	gen dec_8=(ing_dec==8)
	replace dec_8=. if ing_dec==.

	* Decil 9
	gen dec_9=(ing_dec==9)
	replace dec_9=. if ing_dec==.
	
	* Decil 10
	gen dec_10=(ing_dec==10)
	replace dec_10=. if ing_dec==.
	
	****************************************************************************
	** Cálculo de indicadores por migrantes y nativos
	
	foreach var in 1 0 {
		
		*********************** Indicadores demográficos ***********************	
		
		* Mujeres
		sum uno if sexo_ci==2 & migrante_ci==`var' [fw=factor_ci]
		scalar mujer_``var'_label'_pob =`=r(N)'
		
		* Mujeres muestra
		sum uno if sexo_ci==2 & migrante_ci==`var'
		scalar mujer_``var'_label'_muestra =`=r(N)'
		
		* Grupos de edades
		sum uno if inrange(edad_ci,0,14) & migrante_ci==`var' [fw=factor_ci]
		scalar pob_``var'_label'_014 = `=r(N)' // 0 - 14 years
		
		sum uno if inrange(edad_ci,15,24) & migrante_ci==`var' [fw=factor_ci]
		scalar pob_``var'_label'_1524 = `=r(N)' // 15 - 24 years

		sum uno if inrange(edad_ci,25,39) & migrante_ci==`var' [fw=factor_ci]
		scalar pob_``var'_label'_2539 = `=r(N)' // 25 - 39 years
		
		sum uno if inrange(edad_ci,40,54) & migrante_ci==`var' [fw=factor_ci]
		scalar pob_``var'_label'_4054 = `=r(N)' // 40 - 54 years

		sum uno if inrange(edad_ci,55,64) & migrante_ci==`var' [fw=factor_ci]
		scalar pob_``var'_label'_5564 = `=r(N)'	//55 - 64 years
		
		sum uno if inrange(edad_ci,65,.) & migrante_ci==`var' [fw=factor_ci]
		scalar pob_``var'_label'_65mas = `=r(N)'  // 65 older years
		
		* Muestra grupos de edades
		sum uno if inrange(edad_ci,0,14) & migrante_ci==`var'
		scalar muestra_``var'_label'_014 = `=r(N)' // 0 - 14 years
		
		sum uno if inrange(edad_ci,15,24) & migrante_ci==`var'
		scalar muestra_``var'_label'_1524 = `=r(N)' // 15 - 24 years

		sum uno if inrange(edad_ci,25,39) & migrante_ci==`var'
		scalar muestra_``var'_label'_2539 = `=r(N)' // 25 - 39 years
		
		sum uno if inrange(edad_ci,40,54) & migrante_ci==`var'
		scalar muestra_``var'_label'_4054 = `=r(N)' // 40 - 54 years

		sum uno if inrange(edad_ci,55,64) & migrante_ci==`var'
		scalar muestra_``var'_label'_5564 = `=r(N)'	//55 - 64 years
		
		sum uno if inrange(edad_ci,65,.) & migrante_ci==`var'
		scalar muestra_``var'_label'_65mas = `=r(N)'  // 65 older years
		
		* Tamaño del hogar
		sum nmiembros if migrante_ci==`var' [fw=factor_ci]
		scalar tam_``var'_label'_hogar = `=r(mean)'
		
		* Muestra tamaño hogar
		sum nmiembros if migrante_ci==`var'
		scalar Mtam_``var'_label'_hogar = `=r(N)'
		
		* Número de hijos
		sum nhijos if migrante_ci==`var' [fw=factor_ci]
		scalar num_``var'_label'_hijos = `=r(mean)'
		
		* Muestra número de hijos
		sum nhijos if migrante_ci==`var'
		scalar Mnum_``var'_label'_hijos = `=r(N)'
		
		
		********** Indicadores por ubicación geográfica ***********************

		* Porcentaje en zonas urbanas
		sum uno if zona_c==1 & migrante_ci==`var' [fw=factor_ci]
		scalar urbana_``var'_label'_pob = `=r(N)'
		
		* Muestra en zonas urbanas
		sum uno if zona_c==1 & migrante_ci==`var'
		scalar urbana_``var'_label'_muestra = `=r(N)'
		
		* Porcentaje en zonas rurales
		sum uno if zona_c==0 & migrante_ci==`var' [fw=factor_ci]
		scalar rural_``var'_label'_pob = `=r(N)'
		
		* Muestra en zonas rurales
		sum uno if zona_c==0 & migrante_ci==`var'
		scalar rural_``var'_label'_muestra = `=r(N)'
		
		* Porcentaje en ciudad capital
		sum uno if region_c==15 & migrante_ci==`var' [fw=factor_ci]
		scalar capital_``var'_label'_pob = `=r(N)'
		
		* Muestra en ciudad capital
		sum uno if region_c==15 & migrante_ci==`var'
		scalar capital_``var'_label'_muestra = `=r(N)'
		
		
		************* Indicadores por nivel de educación completo **************
		
		* Ningún nivel educativo completado
		sum uno if nivel_educ==0 & migrante_ci==`var' [fw=factor_ci]
		scalar NoEdu_``var'_label'_pob = `=r(N)'
		
		* Muestra ningún nivel educativo completado
		sum uno if nivel_educ==0 & migrante_ci==`var'
		scalar NoEdu_``var'_label'_muestra = `=r(N)'
		
		* Preescolar
		sum uno if nivel_educ==1 & migrante_ci==`var' [fw=factor_ci]
		scalar EduPre_``var'_label'_pob = `=r(N)'
		
		* Muestra preescolar
		sum uno if nivel_educ==1 & migrante_ci==`var'
		scalar EduPre_``var'_label'_muestra = `=r(N)'
		
		* Primaria
		sum uno if nivel_educ==2 & migrante_ci==`var' [fw=factor_ci]
		scalar EduPrim_``var'_label'_pob = `=r(N)'
		
		* Muestra primaria
		sum uno if nivel_educ==2 & migrante_ci==`var'
		scalar EduPrim_``var'_label'_muestra = `=r(N)'
		
		* Secundaria
		sum uno if nivel_educ==3 & migrante_ci==`var' [fw=factor_ci]
		scalar EduSecu_``var'_label'_pob = `=r(N)'
		
		* Muestra secundaria
		sum uno if nivel_educ==3 & migrante_ci==`var'
		scalar EduSecu_``var'_label'_muestra = `=r(N)'
		
		* Terciaria
		sum uno if nivel_educ==4 & migrante_ci==`var' [fw=factor_ci]
		scalar EduTerc_``var'_label'_pob = `=r(N)'
		
		sum uno if nivel_educ!=. & migrante_ci==`var' [fw=factor_ci]
		scalar NMEdu_``var'_label'_pob = `=r(N)'
		
		* Muestra terciaria
		sum uno if nivel_educ==4 & migrante_ci==`var'
		scalar EduTerc_``var'_label'_muestra = `=r(N)'
		
		
		**************** Indicadores por situación laboral *********************
		
		* Población en edad de trabajar
		sum uno if inrange(edad_ci,15,64) & migrante_ci==`var' [fw=factor_ci]
		scalar edadTrab_``var'_label'_pob = `=r(N)'
		
		* Muestra en edad de trabajar
		sum uno if inrange(edad_ci,15,64) & migrante_ci==`var'
		scalar edadTrab_``var'_label'_muestra = `=r(N)'
		
		* Población económicamente activa
		sum uno if inrange(edad_ci,15,64) & pea_ci==1 & migrante_ci==`var' [fw=factor_ci]
		scalar econoAct_``var'_label'_pob = `=r(N)'
		
		* Muestra económicamente activa
		sum uno if inrange(edad_ci,15,64) & pea_ci==1 & migrante_ci==`var'
		scalar econoAct_``var'_label'_muestra = `=r(N)'
		
		* Población empleada
		sum uno if inrange(edad_ci,15,64) & emp_ci==1 & migrante_ci==`var' [fw=factor_ci]
		scalar emp_``var'_label'_pob = `=r(N)'
		
		* Muestra empleada
		sum uno if inrange(edad_ci,15,64) & emp_ci==1 & migrante_ci==`var'
		scalar emp_``var'_label'_muestra = `=r(N)'
		
		* Población desempleada
		sum uno if inrange(edad_ci,15,64) & desemp_ci==1 & migrante_ci==`var' [fw=factor_ci] 
		scalar desemp_``var'_label'_pob = `=r(N)'
		
		* Muestra desempleada
		sum uno if inrange(edad_ci,15,64) & desemp_ci==1 & migrante_ci==`var'
		scalar desemp_``var'_label'_muestra = `=r(N)'
		
		* Informales
		sum uno if inrange(edad_ci,15,64) & informal==1 & migrante_ci==`var' [fw=factor_ci]
		scalar informal_``var'_label'_pob = `=r(N)'
		
		* Muestra informales
		sum uno if inrange(edad_ci,15,64) & informal==1 & migrante_ci==`var'
		scalar informal_``var'_label'_muestra = `=r(N)'
		
		**************** Indicadores por categorías de ingresos ****************
		
		* Decil 1
		sum uno if migrante_ci==`var' & dec_1 == 1 [fw=factor_ci]
		scalar D1_``var'_label'_pob = `=r(N)'
		
		* Muestra decil 1
		sum uno if migrante_ci==`var' & dec_1 == 1
		scalar D1_``var'_label'_muestra = `=r(N)'

		* Decil 2
		sum uno if migrante_ci==`var' & dec_2 == 1 [fw=factor_ci]
		scalar D2_``var'_label'_pob = `=r(N)'
		
		* Muestra decil 2
		sum uno if migrante_ci==`var' & dec_2 == 1
		scalar D2_``var'_label'_muestra = `=r(N)'
		
		* Decil 3
		sum uno if migrante_ci==`var' & dec_3 == 1 [fw=factor_ci]
		scalar D3_``var'_label'_pob = `=r(N)'
		
		* Muestra decil 3
		sum uno if migrante_ci==`var' & dec_3 == 1
		scalar D3_``var'_label'_muestra = `=r(N)'
		
		* Decil 4
		sum uno if migrante_ci==`var' & dec_4 == 1 [fw=factor_ci]
		scalar D4_``var'_label'_pob = `=r(N)'
		
		* Muestra decil 4
		sum uno if migrante_ci==`var' & dec_4 == 1
		scalar D4_``var'_label'_muestra = `=r(N)'
		
		* Decil 5
		sum uno if migrante_ci==`var' & dec_5 == 1 [fw=factor_ci]
		scalar D5_``var'_label'_pob = `=r(N)'
		
		* Muestra decil 5
		sum uno if migrante_ci==`var' & dec_5 == 1
		scalar D5_``var'_label'_muestra = `=r(N)'
		
		* Decil 6
		sum uno if migrante_ci==`var' & dec_6 == 1 [fw=factor_ci]
		scalar D6_``var'_label'_pob = `=r(N)'
		
		* Muestra decil 6
		sum uno if migrante_ci==`var' & dec_6 == 1
		scalar D6_``var'_label'_muestra = `=r(N)'
		
		* Decil 7
		sum uno if migrante_ci==`var' & dec_7 == 1 [fw=factor_ci]
		scalar D7_``var'_label'_pob = `=r(N)'
		
		* Muestra decil 7
		sum uno if migrante_ci==`var' & dec_7 == 1
		scalar D7_``var'_label'_muestra = `=r(N)'
		
		* Decil 8
		sum uno if migrante_ci==`var' & dec_8 == 1 [fw=factor_ci]
		scalar D8_``var'_label'_pob = `=r(N)'
		
		* Muestra decil 8
		sum uno if migrante_ci==`var' & dec_8 == 1
		scalar D8_``var'_label'_muestra = `=r(N)'
		
		* Decil 9
		sum uno if migrante_ci==`var' & dec_9 == 1 [fw=factor_ci]
		scalar D9_``var'_label'_pob = `=r(N)'
		
		* Muestra decil 9
		sum uno if migrante_ci==`var' & dec_9 == 1
		scalar D9_``var'_label'_muestra = `=r(N)'
		
		* Decil 10
		sum uno if migrante_ci==`var' & dec_10 == 1 [fw=factor_ci]
		scalar D10_``var'_label'_pob = `=r(N)'
		
		* Muestra decil 10
		sum uno if migrante_ci==`var' & dec_10 == 1
		scalar D10_``var'_label'_muestra = `=r(N)'
		
		sum uno if migrante_ci==`var' & (ing_dec!=.) [fw=factor_ci]
		scalar NMIng_``var'_label'_pob = `=r(N)'
	
		}
	
******************************************************** EXCEL OUTPUTS

	putexcel set "C:\Users\JCAMILOP\OneDrive - Inter-American Development Bank Group\Otros\Indicadores PNUD\Documentos\Resultados.xlsx", sheet("Indicadores") modify
	putexcel describe
	
	
	************************** Indicadores demográficos ***********************
	
	** Población
	putexcel M5 = (`=nat_pob'/`=tot_pob') N5 = (`=migr_pob'/`=tot_pob')	// Porcentaje de migrantes
	putexcel M6 = (`=nat_muestra') N6 = (`=migr_muestra')	// Tamaño de la muestra
	putexcel M7 = (`=mujer_nat_pob'/`=nat_pob') N7 = (`=mujer_migr_pob'/`=migr_pob')	// Porcentaje de mujeres
	putexcel M8 = (`=mujer_nat_muestra') N8 = (`=mujer_migr_muestra')	// Tamaño de la muestra
	
	* Edades 
	putexcel M9 = (`=pob_nat_014'/`=nat_pob') N9 = (`=pob_migr_014'/`=migr_pob') // 0 - 14
	putexcel M10 = (`=muestra_nat_014') N10 = (`=muestra_migr_014') // Tamaño de la muestra
	putexcel M11 = (`=pob_nat_1524'/`=nat_pob') N11 = (`=pob_migr_1524'/`=migr_pob') // 15 - 24
	putexcel M12 = (`=muestra_nat_1524') N12 = (`=muestra_migr_1524') // Tamaño de la muestra
	putexcel M13 = (`=pob_nat_2539'/`=nat_pob') N13 = (`=pob_migr_2539'/`=migr_pob') // 25 - 39
	putexcel M14 = (`=muestra_nat_2539') N14 = (`=muestra_migr_2539') // Tamaño de la muestra
	putexcel M15 = (`=pob_nat_4054'/`=nat_pob') N15 = (`=pob_migr_4054'/`=migr_pob') // 40 - 54
	putexcel M16 = (`=muestra_nat_4054') N16 = (`=muestra_migr_4054') // Tamaño de la muestra
	putexcel M17 = (`=pob_nat_5564'/`=nat_pob') N17 = (`=pob_migr_5564'/`=migr_pob') // 55 - 64
	putexcel M18 = (`=muestra_nat_5564') N18 = (`=muestra_migr_5564') // Tamaño de la muestra
	putexcel M19 = (`=pob_nat_65mas'/`=nat_pob') N19 = (`=pob_migr_65mas'/`=migr_pob') // 65 más
	putexcel M20 = (`=muestra_nat_65mas') N20 = (`=muestra_migr_65mas') // Tamaño de la muestra
	
	* Tamaño del hogar
	putexcel M21 = (`=tam_nat_hogar')  N21 = (`=tam_migr_hogar') // Tamaño del hogar
	putexcel M22 = (`=Mtam_nat_hogar')  N22 = (`=Mtam_migr_hogar') // Tamaño de la muestra
	
	* Número de hijos
	putexcel M23 = (`=num_nat_hijos')  N23 = (`=num_migr_hijos') // Número de hijos
	putexcel M24 = (`=Mnum_nat_hijos')  N24 = (`=Mnum_migr_hijos') // Tamaño de la muestra
	
	
	*************** Indicadores por ubicación geográfica ***********************
	
	* Población urbana
	putexcel M26 = (`=urbana_nat_pob'/`=nat_pob') N26 = (`=urbana_migr_pob'/`=migr_pob')	
	putexcel M27 = (`=urbana_nat_muestra') N27 = (`=urbana_migr_muestra') // Tamaño de la muestra
	
	* Población rural
	putexcel M28 = (`=rural_nat_pob'/`=nat_pob') N28 = (`=rural_migr_pob'/`=migr_pob')
	putexcel M29 = (`=rural_nat_muestra') N29 = (`=rural_migr_muestra')	// Tamaño de la muestra	
	
	* Ciudad capital
	putexcel M30 = (`=capital_nat_pob'/`=nat_pob') N30 = (`=capital_migr_pob'/`=migr_pob')
	putexcel M31 = (`=capital_nat_muestra') N31 = (`=capital_migr_muestra') // Tamaño de la muestra	
	
	
	************** Indicadores por nivel de educación completo *****************
	
	** Por nivel educativo
	
	* Ningún nivel educativo completado
	putexcel M33 = (`=NoEdu_nat_pob'/`=NMEdu_nat_pob') N33 = (`=NoEdu_migr_pob'/`=NMEdu_migr_pob')
	putexcel M34 = (`=NoEdu_nat_muestra') N34 = (`=NoEdu_migr_muestra')	// Tamaño de la muestra
	
	** Preescolar
	putexcel M35 = (`=EduPre_nat_pob'/`=NMEdu_nat_pob') N35 = (`=EduPre_migr_pob'/`=NMEdu_migr_pob')
	putexcel M36 = (`=EduPre_nat_muestra') N36 = (`=EduPre_migr_muestra')	// Tamaño de la muestra
	
	** Primaria completa
	putexcel M37 = (`=EduPrim_nat_pob'/`=NMEdu_nat_pob') N37 = (`=EduPrim_migr_pob'/`=NMEdu_migr_pob')
	putexcel M38 = (`=EduPrim_nat_muestra') N38 = (`=EduPrim_migr_muestra')	// Tamaño de la muestra
	
	** Secundaria completa
	putexcel M39 = (`=EduSecu_nat_pob'/`=NMEdu_nat_pob') N39 = (`=EduSecu_migr_pob'/`=NMEdu_migr_pob')
	putexcel M40 = (`=EduSecu_nat_muestra') N40 = (`=EduSecu_migr_muestra')	// Tamaño de la muestra
	
	** Terciaria completa
	putexcel M41 = (`=EduTerc_nat_pob'/`=NMEdu_nat_pob') N41 = (`=EduTerc_migr_pob'/`=NMEdu_migr_pob')
	putexcel M42 = (`=EduTerc_nat_muestra') N42 = (`=EduTerc_migr_muestra')	// Tamaño de la muestra
	
	
	****************** Indicadores por situación laboral ***********************
	
	* Población en edad de trabajar
	putexcel M44 = (`=edadTrab_nat_pob'/`=nat_pob') N44 = (`=edadTrab_migr_pob'/`=migr_pob')
	putexcel M45 = (`=edadTrab_nat_muestra') N45 = (`=edadTrab_migr_muestra') // Tamaño de la muestra
	
	* Población económicamente activa
	putexcel M46 = (`=econoAct_nat_pob'/`=edadTrab_nat_pob') N46 = (`=econoAct_migr_pob'/`=edadTrab_migr_pob')
	putexcel M47 = (`=econoAct_nat_muestra') N47 = (`=econoAct_migr_muestra') // Tamaño de la muestra
	
	* Población empleada
	putexcel M48 = (`=emp_nat_pob'/`=econoAct_nat_pob') N48 = (`=emp_migr_pob'/`=econoAct_migr_pob')
	putexcel M49 = (`=emp_nat_muestra') N49 = (`=emp_migr_muestra') // Tamaño de la muestra
	
	* Población desempleada
	putexcel M50 = (`=desemp_nat_pob'/`=econoAct_nat_pob') N50 = (`=desemp_migr_pob'/`=econoAct_migr_pob')
	putexcel M51 = (`=desemp_nat_muestra') N51 = (`=desemp_migr_muestra') // Tamaño de la muestra	
	
	* Población informal
	putexcel M52 = (`=informal_nat_pob'/`=emp_nat_pob') N52 = (`=informal_migr_pob'/`=emp_migr_pob')
	putexcel M53 = (`=informal_nat_muestra') N53 = (`=informal_migr_muestra') // Tamaño de la muestra
	
	****************** Indicadores por categorías de ingresos ******************
	
	putexcel M55 = (`=D1_nat_pob'/`=NMIng_nat_pob') N55 = (`=D1_migr_pob'/`=NMIng_migr_pob') // (D1)
	putexcel M56 = (`=D1_nat_muestra') N56 = (`=D1_migr_muestra') // Tamaño muestra
	
	putexcel M57 = (`=D2_nat_pob'/`=NMIng_nat_pob') N57 = (`=D2_migr_pob'/`=NMIng_migr_pob') // (D2)
	putexcel M58 = (`=D2_nat_muestra') N58 = (`=D2_migr_muestra') // Tamaño muestra
	
	putexcel M59 = (`=D3_nat_pob'/`=NMIng_nat_pob') N59 = (`=D3_migr_pob'/`=NMIng_migr_pob') // (D3)
	putexcel M60 = (`=D3_nat_muestra') N60 = (`=D3_migr_muestra') // Tamaño muestra
	
	putexcel M61 = (`=D4_nat_pob'/`=NMIng_nat_pob') N61 = (`=D4_migr_pob'/`=NMIng_migr_pob') // (D4)
	putexcel M62 = (`=D4_nat_muestra') N62 = (`=D4_migr_muestra') // Tamaño muestra
	
	putexcel M63 = (`=D5_nat_pob'/`=NMIng_nat_pob') N63 = (`=D5_migr_pob'/`=NMIng_migr_pob') // (D5)
	putexcel M64 = (`=D5_nat_muestra') N64 = (`=D5_migr_muestra') // Tamaño muestra
	
	putexcel M65 = (`=D6_nat_pob'/`=NMIng_nat_pob') N65 = (`=D6_migr_pob'/`=NMIng_migr_pob') // (D6)
	putexcel M66 = (`=D6_nat_muestra') N66 = (`=D6_migr_muestra') // Tamaño muestra
	
	putexcel M67 = (`=D7_nat_pob'/`=NMIng_nat_pob') N67 = (`=D7_migr_pob'/`=NMIng_migr_pob') // (D7)
	putexcel M68 = (`=D7_nat_muestra') N68 = (`=D7_migr_muestra') // Tamaño muestra
	
	putexcel M69 = (`=D8_nat_pob'/`=NMIng_nat_pob') N69 = (`=D8_migr_pob'/`=NMIng_migr_pob') // (D8)
	putexcel M70 = (`=D8_nat_muestra') N70 = (`=D8_migr_muestra') // Tamaño muestra
	
	putexcel M71 = (`=D9_nat_pob'/`=NMIng_nat_pob') N71 = (`=D9_migr_pob'/`=NMIng_migr_pob') // (D9)
	putexcel M72 = (`=D9_nat_muestra') N72 = (`=D9_migr_muestra') // Tamaño muestra
	
	putexcel M73 = (`=D10_nat_pob'/`=NMIng_nat_pob') N73 = (`=D10_migr_pob'/`=NMIng_migr_pob') // (D10)
	putexcel M74 = (`=D10_nat_muestra') N74 = (`=D10_migr_muestra') // Tamaño muestra
		

********************************************************************************
********************************************************************************
********************************************************************************
****************************** MÉXICO 2020  ************************************
	
	clear all
	set more off, perm
	set maxvar 15000
	scalar drop _all

	** DATASET
	cd "C:\Users\JCAMILOP\OneDrive - Inter-American Development Bank Group\Otros\Indicadores PNUD\Bases de datos"
	use "MEX_2020_censusBID", replace

	gen uno=1
	replace factor_ci=round(factor_ci) // Applies when the expansion factor is a non-integer numbers
	
	replace migrante_ci = 0 if migrante_ci == .
	
	****************************************************************************
	** LOCALS
		local 1_label = "migr"
		local 0_label = "nat"
		
		local 1_sexo = "masc_"
		local 2_sexo = "fem_"	
	
	****************************************************************************
	** Tamaño del hogar
	by idh_ch, sort: egen nmiembros=sum(relacion_ci>=1 & relacion_ci<5)	
	by idh_ch, sort: egen nhijos=sum(relacion_ci==3)
	
	****************************************************************************
	** Informalidad
	*gen informal = 1 if afiliado_ci != 1 & emp_ci==1
	
	****************************************************************************
	** Muestra total
	sum uno if migrante_ci!=.
	scalar tot_muestra = `=r(N)'
	
	****************************************************************************
	** Muestra migrantes
	sum uno if migrante_ci==1
	scalar migr_muestra = `=r(N)'
	
	****************************************************************************
	** Muestra nativos
	sum uno if migrante_ci==0
	scalar nat_muestra = `=r(N)'
	
	****************************************************************************
	** Población total según factores de expansión
	sum uno if migrante_ci!=. [fw=factor_ci]
	scalar tot_pob = `=r(N)'
	
	****************************************************************************
	** Población migrante según factores de expansión
	sum uno if migrante_ci==1 [fw=factor_ci]
	scalar migr_pob = `=r(N)'
	
	****************************************************************************
	** Población nativa según factores de expansión
	sum uno if migrante_ci==0 [fw=factor_ci]
	scalar nat_pob = `=r(N)'
	
	****************************************************************************
	** Nivel educativo
	gen nivel_educ = 1 if aedu_ci < 6 & aedu_ci != .
	replace nivel_educ = 2 if aedu_ci <= 11 & aedu_ci > 6 & aedu_ci != .
	replace nivel_educ = 3 if aedu_ci <= 14 & aedu_ci > 11 & aedu_ci != .
	replace nivel_educ = 4 if aedu_ci > 14 & aedu_ci != .
	
	****************************************************************************
	** Ingresos totales
	egen totIng=rowtotal(ylm_ci)
	
	****************************************************************************
	** Distribución ingresos
	xtile ing_dec=totIng if edad_ci>15 & pea_ci==1, n(10)
	
	* Decil 1
	gen dec_1=(ing_dec==1)
	replace dec_1=. if ing_dec==.

	* Decil 2
	gen dec_2=(ing_dec==2)
	replace dec_2=. if ing_dec==.

	* Decil 3
	gen dec_3=(ing_dec==3)
	replace dec_3=. if ing_dec==.
	
	* Decil 4
	gen dec_4=(ing_dec==4)
	replace dec_4=. if ing_dec==.

	* Decil 5 
	gen dec_5=(ing_dec==5)
	replace dec_5=. if ing_dec==.

	* Decil 6
	gen dec_6=(ing_dec==6)
	replace dec_6=. if ing_dec==.
	
	* Decil 7
	gen dec_7=(ing_dec==7)
	replace dec_7=. if ing_dec==.

	* Decil 8
	gen dec_8=(ing_dec==8)
	replace dec_8=. if ing_dec==.

	* Decil 9
	gen dec_9=(ing_dec==9)
	replace dec_9=. if ing_dec==.
	
	* Decil 10
	gen dec_10=(ing_dec==10)
	replace dec_10=. if ing_dec==.
	
	****************************************************************************
	** Cálculo de indicadores por migrantes y nativos
	
	foreach var in 1 0 {
		
		*********************** Indicadores demográficos ***********************	
		
		* Mujeres
		sum uno if sexo_ci==2 & migrante_ci==`var' [fw=factor_ci]
		scalar mujer_``var'_label'_pob =`=r(N)'
		
		* Mujeres muestra
		sum uno if sexo_ci==2 & migrante_ci==`var'
		scalar mujer_``var'_label'_muestra =`=r(N)'
		
		* Grupos de edades
		sum uno if inrange(edad_ci,0,14) & migrante_ci==`var' [fw=factor_ci]
		scalar pob_``var'_label'_014 = `=r(N)' // 0 - 14 years
		
		sum uno if inrange(edad_ci,15,24) & migrante_ci==`var' [fw=factor_ci]
		scalar pob_``var'_label'_1524 = `=r(N)' // 15 - 24 years

		sum uno if inrange(edad_ci,25,39) & migrante_ci==`var' [fw=factor_ci]
		scalar pob_``var'_label'_2539 = `=r(N)' // 25 - 39 years
		
		sum uno if inrange(edad_ci,40,54) & migrante_ci==`var' [fw=factor_ci]
		scalar pob_``var'_label'_4054 = `=r(N)' // 40 - 54 years

		sum uno if inrange(edad_ci,55,64) & migrante_ci==`var' [fw=factor_ci]
		scalar pob_``var'_label'_5564 = `=r(N)'	//55 - 64 years
		
		sum uno if inrange(edad_ci,65,.) & migrante_ci==`var' [fw=factor_ci]
		scalar pob_``var'_label'_65mas = `=r(N)'  // 65 older years
		
		* Muestra grupos de edades
		sum uno if inrange(edad_ci,0,14) & migrante_ci==`var'
		scalar muestra_``var'_label'_014 = `=r(N)' // 0 - 14 years
		
		sum uno if inrange(edad_ci,15,24) & migrante_ci==`var'
		scalar muestra_``var'_label'_1524 = `=r(N)' // 15 - 24 years

		sum uno if inrange(edad_ci,25,39) & migrante_ci==`var'
		scalar muestra_``var'_label'_2539 = `=r(N)' // 25 - 39 years
		
		sum uno if inrange(edad_ci,40,54) & migrante_ci==`var'
		scalar muestra_``var'_label'_4054 = `=r(N)' // 40 - 54 years

		sum uno if inrange(edad_ci,55,64) & migrante_ci==`var'
		scalar muestra_``var'_label'_5564 = `=r(N)'	//55 - 64 years
		
		sum uno if inrange(edad_ci,65,.) & migrante_ci==`var'
		scalar muestra_``var'_label'_65mas = `=r(N)'  // 65 older years
		
		* Tamaño del hogar
		sum nmiembros if migrante_ci==`var' [fw=factor_ci]
		scalar tam_``var'_label'_hogar = `=r(mean)'
		
		* Muestra tamaño hogar
		sum nmiembros if migrante_ci==`var'
		scalar Mtam_``var'_label'_hogar = `=r(N)'
		
		* Número de hijos
		sum nhijos if migrante_ci==`var' [fw=factor_ci]
		scalar num_``var'_label'_hijos = `=r(mean)'
		
		* Muestra número de hijos
		sum nhijos if migrante_ci==`var'
		scalar Mnum_``var'_label'_hijos = `=r(N)'
		
		
		********** Indicadores por ubicación geográfica ***********************

		* Porcentaje en zonas urbanas
		sum uno if zona_c==1 & migrante_ci==`var' [fw=factor_ci]
		scalar urbana_``var'_label'_pob = `=r(N)'
		
		* Muestra en zonas urbanas
		sum uno if zona_c==1 & migrante_ci==`var'
		scalar urbana_``var'_label'_muestra = `=r(N)'
		
		* Porcentaje en zonas rurales
		sum uno if zona_c==0 & migrante_ci==`var' [fw=factor_ci]
		scalar rural_``var'_label'_pob = `=r(N)'
		
		* Muestra en zonas rurales
		sum uno if zona_c==0 & migrante_ci==`var'
		scalar rural_``var'_label'_muestra = `=r(N)'
		
		* Porcentaje en ciudad capital
		sum uno if region_c==15 & migrante_ci==`var' [fw=factor_ci]
		scalar capital_``var'_label'_pob = `=r(N)'
		
		* Muestra en ciudad capital
		sum uno if region_c==15 & migrante_ci==`var'
		scalar capital_``var'_label'_muestra = `=r(N)'
		
		
		************* Indicadores por nivel de educación completo **************
		
		* Ningún nivel educativo completado
		sum uno if nivel_educ==1 & migrante_ci==`var' [fw=factor_ci]
		scalar NoEdu_``var'_label'_pob = `=r(N)'
		
		* Muestra ningún nivel educativo completado
		sum uno if nivel_educ==1 & migrante_ci==`var'
		scalar NoEdu_``var'_label'_muestra = `=r(N)'
		
		* Primaria
		sum uno if nivel_educ==2 & migrante_ci==`var' [fw=factor_ci]
		scalar EduPrim_``var'_label'_pob = `=r(N)'
		
		* Muestra primaria
		sum uno if nivel_educ==2 & migrante_ci==`var'
		scalar EduPrim_``var'_label'_muestra = `=r(N)'
		
		* Secundaria
		sum uno if nivel_educ==3 & migrante_ci==`var' [fw=factor_ci]
		scalar EduSecu_``var'_label'_pob = `=r(N)'
		
		* Muestra secundaria
		sum uno if nivel_educ==3 & migrante_ci==`var'
		scalar EduSecu_``var'_label'_muestra = `=r(N)'
		
		* Terciaria
		sum uno if nivel_educ==4 & migrante_ci==`var' [fw=factor_ci]
		scalar EduTerc_``var'_label'_pob = `=r(N)'
		
		sum uno if nivel_educ!=. & migrante_ci==`var' [fw=factor_ci]
		scalar NMEdu_``var'_label'_pob = `=r(N)'
		
		* Muestra terciaria
		sum uno if nivel_educ==4 & migrante_ci==`var'
		scalar EduTerc_``var'_label'_muestra = `=r(N)'
		
		
		**************** Indicadores por situación laboral *********************
		
		* Población en edad de trabajar
		sum uno if inrange(edad_ci,15,64) & migrante_ci==`var' [fw=factor_ci]
		scalar edadTrab_``var'_label'_pob = `=r(N)'
		
		* Muestra en edad de trabajar
		sum uno if inrange(edad_ci,15,64) & migrante_ci==`var'
		scalar edadTrab_``var'_label'_muestra = `=r(N)'
		
		* Población económicamente activa
		sum uno if inrange(edad_ci,15,64) & pea_ci==1 & migrante_ci==`var' [fw=factor_ci]
		scalar econoAct_``var'_label'_pob = `=r(N)'
		
		* Muestra económicamente activa
		sum uno if inrange(edad_ci,15,64) & pea_ci==1 & migrante_ci==`var'
		scalar econoAct_``var'_label'_muestra = `=r(N)'
		
		* Población empleada
		sum uno if inrange(edad_ci,15,64) & emp_ci==1 & migrante_ci==`var' [fw=factor_ci]
		scalar emp_``var'_label'_pob = `=r(N)'
		
		* Muestra empleada
		sum uno if inrange(edad_ci,15,64) & emp_ci==1 & migrante_ci==`var'
		scalar emp_``var'_label'_muestra = `=r(N)'
		
		* Población desempleada
		sum uno if inrange(edad_ci,15,64) & desemp_ci==1 & migrante_ci==`var' [fw=factor_ci] 
		scalar desemp_``var'_label'_pob = `=r(N)'
		
		* Muestra desempleada
		sum uno if inrange(edad_ci,15,64) & desemp_ci==1 & migrante_ci==`var'
		scalar desemp_``var'_label'_muestra = `=r(N)'
		
		* Informales
		*sum uno if inrange(edad_ci,15,64) & informal==1 & migrante_ci==`var' [fw=factor_ci]
		*scalar informal_``var'_label'_pob = `=r(N)'
		
		* Muestra informales
		*sum uno if inrange(edad_ci,15,64) & informal==1 & migrante_ci==`var'
		*scalar informal_``var'_label'_muestra = `=r(N)'
		
		**************** Indicadores por categorías de ingresos ****************
		
		* Decil 1
		sum uno if migrante_ci==`var' & dec_1 == 1 [fw=factor_ci]
		scalar D1_``var'_label'_pob = `=r(N)'
		
		* Muestra decil 1
		sum uno if migrante_ci==`var' & dec_1 == 1
		scalar D1_``var'_label'_muestra = `=r(N)'

		* Decil 2
		sum uno if migrante_ci==`var' & dec_2 == 1 [fw=factor_ci]
		scalar D2_``var'_label'_pob = `=r(N)'
		
		* Muestra decil 2
		sum uno if migrante_ci==`var' & dec_2 == 1
		scalar D2_``var'_label'_muestra = `=r(N)'
		
		* Decil 3
		sum uno if migrante_ci==`var' & dec_3 == 1 [fw=factor_ci]
		scalar D3_``var'_label'_pob = `=r(N)'
		
		* Muestra decil 3
		sum uno if migrante_ci==`var' & dec_3 == 1
		scalar D3_``var'_label'_muestra = `=r(N)'
		
		* Decil 4
		sum uno if migrante_ci==`var' & dec_4 == 1 [fw=factor_ci]
		scalar D4_``var'_label'_pob = `=r(N)'
		
		* Muestra decil 4
		sum uno if migrante_ci==`var' & dec_4 == 1
		scalar D4_``var'_label'_muestra = `=r(N)'
		
		* Decil 5
		sum uno if migrante_ci==`var' & dec_5 == 1 [fw=factor_ci]
		scalar D5_``var'_label'_pob = `=r(N)'
		
		* Muestra decil 5
		sum uno if migrante_ci==`var' & dec_5 == 1
		scalar D5_``var'_label'_muestra = `=r(N)'
		
		* Decil 6
		sum uno if migrante_ci==`var' & dec_6 == 1 [fw=factor_ci]
		scalar D6_``var'_label'_pob = `=r(N)'
		
		* Muestra decil 6
		sum uno if migrante_ci==`var' & dec_6 == 1
		scalar D6_``var'_label'_muestra = `=r(N)'
		
		* Decil 7
		sum uno if migrante_ci==`var' & dec_7 == 1 [fw=factor_ci]
		scalar D7_``var'_label'_pob = `=r(N)'
		
		* Muestra decil 7
		sum uno if migrante_ci==`var' & dec_7 == 1
		scalar D7_``var'_label'_muestra = `=r(N)'
		
		* Decil 8
		sum uno if migrante_ci==`var' & dec_8 == 1 [fw=factor_ci]
		scalar D8_``var'_label'_pob = `=r(N)'
		
		* Muestra decil 8
		sum uno if migrante_ci==`var' & dec_8 == 1
		scalar D8_``var'_label'_muestra = `=r(N)'
		
		* Decil 9
		sum uno if migrante_ci==`var' & dec_9 == 1 [fw=factor_ci]
		scalar D9_``var'_label'_pob = `=r(N)'
		
		* Muestra decil 9
		sum uno if migrante_ci==`var' & dec_9 == 1
		scalar D9_``var'_label'_muestra = `=r(N)'
		
		* Decil 10
		sum uno if migrante_ci==`var' & dec_10 == 1 [fw=factor_ci]
		scalar D10_``var'_label'_pob = `=r(N)'
		
		* Muestra decil 10
		sum uno if migrante_ci==`var' & dec_10 == 1
		scalar D10_``var'_label'_muestra = `=r(N)'
		
		sum uno if migrante_ci==`var' & (ing_dec!=.) [fw=factor_ci]
		scalar NMIng_``var'_label'_pob = `=r(N)'
	
		}
	
******************************************************** EXCEL OUTPUTS

	putexcel set "C:\Users\JCAMILOP\OneDrive - Inter-American Development Bank Group\Otros\Indicadores PNUD\Documentos\Resultados.xlsx", sheet("Indicadores") modify
	putexcel describe
	
	
	************************** Indicadores demográficos ***********************
	
	** Población
	putexcel O5 = (`=nat_pob'/`=tot_pob') P5 = (`=migr_pob'/`=tot_pob')	// Porcentaje de migrantes
	putexcel O6 = (`=nat_muestra') P6 = (`=migr_muestra')	// Tamaño de la muestra
	putexcel O7 = (`=mujer_nat_pob'/`=nat_pob') P7 = (`=mujer_migr_pob'/`=migr_pob')	// Porcentaje de mujeres
	putexcel O8 = (`=mujer_nat_muestra') P8 = (`=mujer_migr_muestra')	// Tamaño de la muestra
	
	* Edades 
	putexcel O9 = (`=pob_nat_014'/`=nat_pob') P9 = (`=pob_migr_014'/`=migr_pob') // 0 - 14
	putexcel O10 = (`=muestra_nat_014') P10 = (`=muestra_migr_014') // Tamaño de la muestra
	putexcel O11 = (`=pob_nat_1524'/`=nat_pob') P11 = (`=pob_migr_1524'/`=migr_pob') // 15 - 24
	putexcel O12 = (`=muestra_nat_1524') P12 = (`=muestra_migr_1524') // Tamaño de la muestra
	putexcel O13 = (`=pob_nat_2539'/`=nat_pob') P13 = (`=pob_migr_2539'/`=migr_pob') // 25 - 39
	putexcel O14 = (`=muestra_nat_2539') P14 = (`=muestra_migr_2539') // Tamaño de la muestra
	putexcel O15 = (`=pob_nat_4054'/`=nat_pob') P15 = (`=pob_migr_4054'/`=migr_pob') // 40 - 54
	putexcel O16 = (`=muestra_nat_4054') P16 = (`=muestra_migr_4054') // Tamaño de la muestra
	putexcel O17 = (`=pob_nat_5564'/`=nat_pob') P17 = (`=pob_migr_5564'/`=migr_pob') // 55 - 64
	putexcel O18 = (`=muestra_nat_5564') P18 = (`=muestra_migr_5564') // Tamaño de la muestra
	putexcel O19 = (`=pob_nat_65mas'/`=nat_pob') P19 = (`=pob_migr_65mas'/`=migr_pob') // 65 más
	putexcel O20 = (`=muestra_nat_65mas') P20 = (`=muestra_migr_65mas') // Tamaño de la muestra
	
	* Tamaño del hogar
	putexcel O21 = (`=tam_nat_hogar')  P21 = (`=tam_migr_hogar') // Tamaño del hogar
	putexcel O22 = (`=Mtam_nat_hogar')  P22 = (`=Mtam_migr_hogar') // Tamaño de la muestra
	
	* Número de hijos
	putexcel O23 = (`=num_nat_hijos')  P23 = (`=num_migr_hijos') // Número de hijos
	putexcel O24 = (`=Mnum_nat_hijos')  P24 = (`=Mnum_migr_hijos') // Tamaño de la muestra
	
	
	*************** Indicadores por ubicación geográfica ***********************
	
	* Población urbana
	putexcel O26 = (`=urbana_nat_pob'/`=nat_pob') P26 = (`=urbana_migr_pob'/`=migr_pob')	
	putexcel O27 = (`=urbana_nat_muestra') P27 = (`=urbana_migr_muestra') // Tamaño de la muestra
	
	* Población rural
	putexcel O28 = (`=rural_nat_pob'/`=nat_pob') P28 = (`=rural_migr_pob'/`=migr_pob')
	putexcel O29 = (`=rural_nat_muestra') P29 = (`=rural_migr_muestra')	// Tamaño de la muestra	
	
	* Ciudad capital
	putexcel O30 = (`=capital_nat_pob'/`=nat_pob') P30 = (`=capital_migr_pob'/`=migr_pob')
	putexcel O31 = (`=capital_nat_muestra') P31 = (`=capital_migr_muestra') // Tamaño de la muestra	
	
	
	************** Indicadores por nivel de educación completo *****************
	
	** Por nivel educativo
	
	* Ningún nivel educativo completado
	putexcel O33 = (`=NoEdu_nat_pob'/`=NMEdu_nat_pob') P33 = (`=NoEdu_migr_pob'/`=NMEdu_migr_pob')
	putexcel O34 = (`=NoEdu_nat_muestra') P34 = (`=NoEdu_migr_muestra')	// Tamaño de la muestra
	
	** Primaria completa
	putexcel O37 = (`=EduPrim_nat_pob'/`=NMEdu_nat_pob') P37 = (`=EduPrim_migr_pob'/`=NMEdu_migr_pob')
	putexcel O38 = (`=EduPrim_nat_muestra') P38 = (`=EduPrim_migr_muestra')	// Tamaño de la muestra
	
	** Secundaria completa
	putexcel O39 = (`=EduSecu_nat_pob'/`=NMEdu_nat_pob') P39 = (`=EduSecu_migr_pob'/`=NMEdu_migr_pob')
	putexcel O40 = (`=EduSecu_nat_muestra') P40 = (`=EduSecu_migr_muestra')	// Tamaño de la muestra
	
	** Terciaria completa
	putexcel O41 = (`=EduTerc_nat_pob'/`=NMEdu_nat_pob') P41 = (`=EduTerc_migr_pob'/`=NMEdu_migr_pob')
	putexcel O42 = (`=EduTerc_nat_muestra') P42 = (`=EduTerc_migr_muestra')	// Tamaño de la muestra
	
	
	****************** Indicadores por situación laboral ***********************
	
	* Población en edad de trabajar
	putexcel O44 = (`=edadTrab_nat_pob'/`=nat_pob') P44 = (`=edadTrab_migr_pob'/`=migr_pob')
	putexcel O45 = (`=edadTrab_nat_muestra') P45 = (`=edadTrab_migr_muestra') // Tamaño de la muestra
	
	* Población económicamente activa
	putexcel O46 = (`=econoAct_nat_pob'/`=edadTrab_nat_pob') P46 = (`=econoAct_migr_pob'/`=edadTrab_migr_pob')
	putexcel O47 = (`=econoAct_nat_muestra') P47 = (`=econoAct_migr_muestra') // Tamaño de la muestra
	
	* Población empleada
	putexcel O48 = (`=emp_nat_pob'/`=econoAct_nat_pob') P48 = (`=emp_migr_pob'/`=econoAct_migr_pob')
	putexcel O49 = (`=emp_nat_muestra') P49 = (`=emp_migr_muestra') // Tamaño de la muestra
	
	* Población desempleada
	putexcel O50 = (`=desemp_nat_pob'/`=econoAct_nat_pob') P50 = (`=desemp_migr_pob'/`=econoAct_migr_pob')
	putexcel O51 = (`=desemp_nat_muestra') P51 = (`=desemp_migr_muestra') // Tamaño de la muestra	
	
	* Población informal
	*putexcel O52 = (`=informal_nat_pob'/`=emp_nat_pob') P52 = (`=informal_migr_pob'/`=emp_migr_pob')
	*putexcel O53 = (`=informal_nat_muestra') P53 = (`=informal_migr_muestra') // Tamaño de la muestra
	
	****************** Indicadores por categorías de ingresos ******************
	
	putexcel O55 = (`=D1_nat_pob'/`=NMIng_nat_pob') P55 = (`=D1_migr_pob'/`=NMIng_migr_pob') // (D1)
	putexcel O56 = (`=D1_nat_muestra') P56 = (`=D1_migr_muestra') // Tamaño muestra
	
	putexcel O57 = (`=D2_nat_pob'/`=NMIng_nat_pob') P57 = (`=D2_migr_pob'/`=NMIng_migr_pob') // (D2)
	putexcel O58 = (`=D2_nat_muestra') P58 = (`=D2_migr_muestra') // Tamaño muestra
	
	putexcel O59 = (`=D3_nat_pob'/`=NMIng_nat_pob') P59 = (`=D3_migr_pob'/`=NMIng_migr_pob') // (D3)
	putexcel O60 = (`=D3_nat_muestra') P60 = (`=D3_migr_muestra') // Tamaño muestra
	
	putexcel O61 = (`=D4_nat_pob'/`=NMIng_nat_pob') P61 = (`=D4_migr_pob'/`=NMIng_migr_pob') // (D4)
	putexcel O62 = (`=D4_nat_muestra') P62 = (`=D4_migr_muestra') // Tamaño muestra
	
	putexcel O63 = (`=D5_nat_pob'/`=NMIng_nat_pob') P63 = (`=D5_migr_pob'/`=NMIng_migr_pob') // (D5)
	putexcel O64 = (`=D5_nat_muestra') P64 = (`=D5_migr_muestra') // Tamaño muestra
	
	putexcel O65 = (`=D6_nat_pob'/`=NMIng_nat_pob') P65 = (`=D6_migr_pob'/`=NMIng_migr_pob') // (D6)
	putexcel O66 = (`=D6_nat_muestra') P66 = (`=D6_migr_muestra') // Tamaño muestra
	
	putexcel O67 = (`=D7_nat_pob'/`=NMIng_nat_pob') P67 = (`=D7_migr_pob'/`=NMIng_migr_pob') // (D7)
	putexcel O68 = (`=D7_nat_muestra') P68 = (`=D7_migr_muestra') // Tamaño muestra
	
	putexcel O69 = (`=D8_nat_pob'/`=NMIng_nat_pob') P69 = (`=D8_migr_pob'/`=NMIng_migr_pob') // (D8)
	putexcel O70 = (`=D8_nat_muestra') P70 = (`=D8_migr_muestra') // Tamaño muestra
	
	putexcel O71 = (`=D9_nat_pob'/`=NMIng_nat_pob') P71 = (`=D9_migr_pob'/`=NMIng_migr_pob') // (D9)
	putexcel O72 = (`=D9_nat_muestra') P72 = (`=D9_migr_muestra') // Tamaño muestra
	
	putexcel O73 = (`=D10_nat_pob'/`=NMIng_nat_pob') P73 = (`=D10_migr_pob'/`=NMIng_migr_pob') // (D10)
	putexcel O74 = (`=D10_nat_muestra') P74 = (`=D10_migr_muestra') // Tamaño muestra	
		
		
********************************************************************************
********************************************************************************
********************************************************************************
****** REP DOMINICANA - ENCUESTA NACIONAL CONTINUA DE FUERZA DE TRABAJO 2020 ***
	
	clear all
	set more off, perm
	set maxvar 15000
	scalar drop _all

	** DATASET
	cd "C:\Users\JCAMILOP\OneDrive - Inter-American Development Bank Group\Otros\Indicadores PNUD\Bases de datos"
	use "DOM_2020a_BID.dta", replace

	gen uno=1
	replace factor_ci=round(factor_ci) // Applies when the expansion factor is a non-integer numbers
	replace migrante_ci = 0 if migrante_ci == .
	
	****************************************************************************
	** LOCALS
		local 1_label = "migr"
		local 0_label = "nat"
		
		local 1_sexo = "masc_"
		local 2_sexo = "fem_"	
	
	****************************************************************************
	** Tamaño del hogar
	by idh_ch, sort: egen nmiembros=sum(relacion_ci>=1 & relacion_ci<5)	
	by idh_ch, sort: egen nhijos=sum(relacion_ci==3)
	
	****************************************************************************
	** Informalidad
	gen informal = 1 if afiliado_ci != 1 & emp_ci==1
	
	****************************************************************************
	** Muestra total
	sum uno if migrante_ci!=.
	scalar tot_muestra = `=r(N)'
	
	****************************************************************************
	** Muestra migrantes
	sum uno if migrante_ci==1
	scalar migr_muestra = `=r(N)'
	
	****************************************************************************
	** Muestra nativos
	sum uno if migrante_ci==0
	scalar nat_muestra = `=r(N)'
	
	****************************************************************************
	** Población total según factores de expansión
	sum uno if migrante_ci!=. [fw=factor_ci]
	scalar tot_pob = `=r(N)'
	
	****************************************************************************
	** Población migrante según factores de expansión
	sum uno if migrante_ci==1 [fw=factor_ci]
	scalar migr_pob = `=r(N)'
	
	****************************************************************************
	** Población nativa según factores de expansión
	sum uno if migrante_ci==0 [fw=factor_ci]
	scalar nat_pob = `=r(N)'
	
	****************************************************************************
	** Nivel educativo
	gen nivel_educ = 0 if eduno_ci == 1
	replace nivel_educ = 1 if edupre_ci == 1 & edupc_ci == 0
	replace nivel_educ = 2 if edupc_ci == 1 & edusc_ci == 0
	replace nivel_educ = 3 if edusc_ci == 1 & eduuc_ci == 0
	replace nivel_educ = 4 if eduuc_ci == 1
	
	****************************************************************************
	** Ingresos totales
	egen totIng=rowtotal(ylm_ci ylnm_ci ynlm_ci ynlnm_ci remesas_ci)
	
	****************************************************************************
	** Distribución ingresos
	xtile ing_dec=totIng if edad_ci>15 & pea_ci==1, n(10)
	
	* Decil 1
	gen dec_1=(ing_dec==1)
	replace dec_1=. if ing_dec==.

	* Decil 2
	gen dec_2=(ing_dec==2)
	replace dec_2=. if ing_dec==.

	* Decil 3
	gen dec_3=(ing_dec==3)
	replace dec_3=. if ing_dec==.
	
	* Decil 4
	gen dec_4=(ing_dec==4)
	replace dec_4=. if ing_dec==.

	* Decil 5 
	gen dec_5=(ing_dec==5)
	replace dec_5=. if ing_dec==.

	* Decil 6
	gen dec_6=(ing_dec==6)
	replace dec_6=. if ing_dec==.
	
	* Decil 7
	gen dec_7=(ing_dec==7)
	replace dec_7=. if ing_dec==.

	* Decil 8
	gen dec_8=(ing_dec==8)
	replace dec_8=. if ing_dec==.

	* Decil 9
	gen dec_9=(ing_dec==9)
	replace dec_9=. if ing_dec==.
	
	* Decil 10
	gen dec_10=(ing_dec==10)
	replace dec_10=. if ing_dec==.
	
	****************************************************************************
	** Cálculo de indicadores por migrantes y nativos
	
	foreach var in 1 0 {
		
		*********************** Indicadores demográficos ***********************	
		
		* Mujeres
		sum uno if sexo_ci==2 & migrante_ci==`var' [fw=factor_ci]
		scalar mujer_``var'_label'_pob =`=r(N)'
		
		* Mujeres muestra
		sum uno if sexo_ci==2 & migrante_ci==`var'
		scalar mujer_``var'_label'_muestra =`=r(N)'
		
		* Grupos de edades
		sum uno if inrange(edad_ci,0,14) & migrante_ci==`var' [fw=factor_ci]
		scalar pob_``var'_label'_014 = `=r(N)' // 0 - 14 years
		
		sum uno if inrange(edad_ci,15,24) & migrante_ci==`var' [fw=factor_ci]
		scalar pob_``var'_label'_1524 = `=r(N)' // 15 - 24 years

		sum uno if inrange(edad_ci,25,39) & migrante_ci==`var' [fw=factor_ci]
		scalar pob_``var'_label'_2539 = `=r(N)' // 25 - 39 years
		
		sum uno if inrange(edad_ci,40,54) & migrante_ci==`var' [fw=factor_ci]
		scalar pob_``var'_label'_4054 = `=r(N)' // 40 - 54 years

		sum uno if inrange(edad_ci,55,64) & migrante_ci==`var' [fw=factor_ci]
		scalar pob_``var'_label'_5564 = `=r(N)'	//55 - 64 years
		
		sum uno if inrange(edad_ci,65,.) & migrante_ci==`var' [fw=factor_ci]
		scalar pob_``var'_label'_65mas = `=r(N)'  // 65 older years
		
		* Muestra grupos de edades
		sum uno if inrange(edad_ci,0,14) & migrante_ci==`var'
		scalar muestra_``var'_label'_014 = `=r(N)' // 0 - 14 years
		
		sum uno if inrange(edad_ci,15,24) & migrante_ci==`var'
		scalar muestra_``var'_label'_1524 = `=r(N)' // 15 - 24 years

		sum uno if inrange(edad_ci,25,39) & migrante_ci==`var'
		scalar muestra_``var'_label'_2539 = `=r(N)' // 25 - 39 years
		
		sum uno if inrange(edad_ci,40,54) & migrante_ci==`var'
		scalar muestra_``var'_label'_4054 = `=r(N)' // 40 - 54 years

		sum uno if inrange(edad_ci,55,64) & migrante_ci==`var'
		scalar muestra_``var'_label'_5564 = `=r(N)'	//55 - 64 years
		
		sum uno if inrange(edad_ci,65,.) & migrante_ci==`var'
		scalar muestra_``var'_label'_65mas = `=r(N)'  // 65 older years
		
		* Tamaño del hogar
		sum nmiembros if migrante_ci==`var' [fw=factor_ci]
		scalar tam_``var'_label'_hogar = `=r(mean)'
		
		* Muestra tamaño hogar
		sum nmiembros if migrante_ci==`var'
		scalar Mtam_``var'_label'_hogar = `=r(N)'
		
		* Número de hijos
		sum nhijos if migrante_ci==`var' [fw=factor_ci]
		scalar num_``var'_label'_hijos = `=r(mean)'
		
		* Muestra número de hijos
		sum nhijos if migrante_ci==`var'
		scalar Mnum_``var'_label'_hijos = `=r(N)'
		
		
		********** Indicadores por ubicación geográfica ***********************

		* Porcentaje en zonas urbanas
		sum uno if zona_c==1 & migrante_ci==`var' [fw=factor_ci]
		scalar urbana_``var'_label'_pob = `=r(N)'
		
		* Muestra en zonas urbanas
		sum uno if zona_c==1 & migrante_ci==`var'
		scalar urbana_``var'_label'_muestra = `=r(N)'
		
		* Porcentaje en zonas rurales
		sum uno if zona_c==0 & migrante_ci==`var' [fw=factor_ci]
		scalar rural_``var'_label'_pob = `=r(N)'
		
		* Muestra en zonas rurales
		sum uno if zona_c==0 & migrante_ci==`var'
		scalar rural_``var'_label'_muestra = `=r(N)'
		
		* Porcentaje en ciudad capital
		sum uno if region_c==32 & migrante_ci==`var' [fw=factor_ci]
		scalar capital_``var'_label'_pob = `=r(N)'
		
		* Muestra en ciudad capital
		sum uno if region_c==32 & migrante_ci==`var'
		scalar capital_``var'_label'_muestra = `=r(N)'
		
		
		************* Indicadores por nivel de educación completo **************
		
		* Ningún nivel educativo completado
		sum uno if nivel_educ==0 & migrante_ci==`var' [fw=factor_ci]
		scalar NoEdu_``var'_label'_pob = `=r(N)'
		
		* Muestra ningún nivel educativo completado
		sum uno if nivel_educ==0 & migrante_ci==`var'
		scalar NoEdu_``var'_label'_muestra = `=r(N)'
		
		* Preescolar
		sum uno if nivel_educ==1 & migrante_ci==`var' [fw=factor_ci]
		scalar EduPre_``var'_label'_pob = `=r(N)'
		
		* Muestra preescolar
		sum uno if nivel_educ==1 & migrante_ci==`var'
		scalar EduPre_``var'_label'_muestra = `=r(N)'
		
		* Primaria
		sum uno if nivel_educ==2 & migrante_ci==`var' [fw=factor_ci]
		scalar EduPrim_``var'_label'_pob = `=r(N)'
		
		* Muestra primaria
		sum uno if nivel_educ==2 & migrante_ci==`var'
		scalar EduPrim_``var'_label'_muestra = `=r(N)'
		
		* Secundaria
		sum uno if nivel_educ==3 & migrante_ci==`var' [fw=factor_ci]
		scalar EduSecu_``var'_label'_pob = `=r(N)'
		
		* Muestra secundaria
		sum uno if nivel_educ==3 & migrante_ci==`var'
		scalar EduSecu_``var'_label'_muestra = `=r(N)'
		
		* Terciaria
		sum uno if nivel_educ==4 & migrante_ci==`var' [fw=factor_ci]
		scalar EduTerc_``var'_label'_pob = `=r(N)'
		
		sum uno if nivel_educ!=. & migrante_ci==`var' [fw=factor_ci]
		scalar NMEdu_``var'_label'_pob = `=r(N)'
		
		* Muestra terciaria
		sum uno if nivel_educ==4 & migrante_ci==`var'
		scalar EduTerc_``var'_label'_muestra = `=r(N)'
		
		
		**************** Indicadores por situación laboral *********************
		
		* Población en edad de trabajar
		sum uno if inrange(edad_ci,15,64) & migrante_ci==`var' [fw=factor_ci]
		scalar edadTrab_``var'_label'_pob = `=r(N)'
		
		* Muestra en edad de trabajar
		sum uno if inrange(edad_ci,15,64) & migrante_ci==`var'
		scalar edadTrab_``var'_label'_muestra = `=r(N)'
		
		* Población económicamente activa
		sum uno if inrange(edad_ci,15,64) & pea_ci==1 & migrante_ci==`var' [fw=factor_ci]
		scalar econoAct_``var'_label'_pob = `=r(N)'
		
		* Muestra económicamente activa
		sum uno if inrange(edad_ci,15,64) & pea_ci==1 & migrante_ci==`var'
		scalar econoAct_``var'_label'_muestra = `=r(N)'
		
		* Población empleada
		sum uno if inrange(edad_ci,15,64) & emp_ci==1 & migrante_ci==`var' [fw=factor_ci]
		scalar emp_``var'_label'_pob = `=r(N)'
		
		* Muestra empleada
		sum uno if inrange(edad_ci,15,64) & emp_ci==1 & migrante_ci==`var'
		scalar emp_``var'_label'_muestra = `=r(N)'
		
		* Población desempleada
		sum uno if inrange(edad_ci,15,64) & desemp_ci==1 & migrante_ci==`var' [fw=factor_ci] 
		scalar desemp_``var'_label'_pob = `=r(N)'
		
		* Muestra desempleada
		sum uno if inrange(edad_ci,15,64) & desemp_ci==1 & migrante_ci==`var'
		scalar desemp_``var'_label'_muestra = `=r(N)'
		
		* Informales
		sum uno if inrange(edad_ci,15,64) & informal==1 & migrante_ci==`var' [fw=factor_ci]
		scalar informal_``var'_label'_pob = `=r(N)'
		
		* Muestra informales
		sum uno if inrange(edad_ci,15,64) & informal==1 & migrante_ci==`var'
		scalar informal_``var'_label'_muestra = `=r(N)'
		
		**************** Indicadores por categorías de ingresos ****************
		
		* Decil 1
		sum uno if migrante_ci==`var' & dec_1 == 1 [fw=factor_ci]
		scalar D1_``var'_label'_pob = `=r(N)'
		
		* Muestra decil 1
		sum uno if migrante_ci==`var' & dec_1 == 1
		scalar D1_``var'_label'_muestra = `=r(N)'

		* Decil 2
		sum uno if migrante_ci==`var' & dec_2 == 1 [fw=factor_ci]
		scalar D2_``var'_label'_pob = `=r(N)'
		
		* Muestra decil 2
		sum uno if migrante_ci==`var' & dec_2 == 1
		scalar D2_``var'_label'_muestra = `=r(N)'
		
		* Decil 3
		sum uno if migrante_ci==`var' & dec_3 == 1 [fw=factor_ci]
		scalar D3_``var'_label'_pob = `=r(N)'
		
		* Muestra decil 3
		sum uno if migrante_ci==`var' & dec_3 == 1
		scalar D3_``var'_label'_muestra = `=r(N)'
		
		* Decil 4
		sum uno if migrante_ci==`var' & dec_4 == 1 [fw=factor_ci]
		scalar D4_``var'_label'_pob = `=r(N)'
		
		* Muestra decil 4
		sum uno if migrante_ci==`var' & dec_4 == 1
		scalar D4_``var'_label'_muestra = `=r(N)'
		
		* Decil 5
		sum uno if migrante_ci==`var' & dec_5 == 1 [fw=factor_ci]
		scalar D5_``var'_label'_pob = `=r(N)'
		
		* Muestra decil 5
		sum uno if migrante_ci==`var' & dec_5 == 1
		scalar D5_``var'_label'_muestra = `=r(N)'
		
		* Decil 6
		sum uno if migrante_ci==`var' & dec_6 == 1 [fw=factor_ci]
		scalar D6_``var'_label'_pob = `=r(N)'
		
		* Muestra decil 6
		sum uno if migrante_ci==`var' & dec_6 == 1
		scalar D6_``var'_label'_muestra = `=r(N)'
		
		* Decil 7
		sum uno if migrante_ci==`var' & dec_7 == 1 [fw=factor_ci]
		scalar D7_``var'_label'_pob = `=r(N)'
		
		* Muestra decil 7
		sum uno if migrante_ci==`var' & dec_7 == 1
		scalar D7_``var'_label'_muestra = `=r(N)'
		
		* Decil 8
		sum uno if migrante_ci==`var' & dec_8 == 1 [fw=factor_ci]
		scalar D8_``var'_label'_pob = `=r(N)'
		
		* Muestra decil 8
		sum uno if migrante_ci==`var' & dec_8 == 1
		scalar D8_``var'_label'_muestra = `=r(N)'
		
		* Decil 9
		sum uno if migrante_ci==`var' & dec_9 == 1 [fw=factor_ci]
		scalar D9_``var'_label'_pob = `=r(N)'
		
		* Muestra decil 9
		sum uno if migrante_ci==`var' & dec_9 == 1
		scalar D9_``var'_label'_muestra = `=r(N)'
		
		* Decil 10
		sum uno if migrante_ci==`var' & dec_10 == 1 [fw=factor_ci]
		scalar D10_``var'_label'_pob = `=r(N)'
		
		* Muestra decil 10
		sum uno if migrante_ci==`var' & dec_10 == 1
		scalar D10_``var'_label'_muestra = `=r(N)'
		
		sum uno if migrante_ci==`var' & (ing_dec!=.) [fw=factor_ci]
		scalar NMIng_``var'_label'_pob = `=r(N)'
	
		}
	
******************************************************** EXCEL OUTPUTS

	putexcel set "C:\Users\JCAMILOP\OneDrive - Inter-American Development Bank Group\Otros\Indicadores PNUD\Documentos\Resultados.xlsx", sheet("Indicadores") modify
	putexcel describe
	
	
	************************** Indicadores demográficos ***********************
	
	** Población
	putexcel Q5 = (`=nat_pob'/`=tot_pob') R5 = (`=migr_pob'/`=tot_pob')	// Porcentaje de migrantes
	putexcel Q6 = (`=nat_muestra') R6 = (`=migr_muestra')	// Tamaño de la muestra
	putexcel Q7 = (`=mujer_nat_pob'/`=nat_pob') R7 = (`=mujer_migr_pob'/`=migr_pob')	// Porcentaje de mujeres
	putexcel Q8 = (`=mujer_nat_muestra') R8 = (`=mujer_migr_muestra')	// Tamaño de la muestra
	
	* Edades 
	putexcel Q9 = (`=pob_nat_014'/`=nat_pob') R9 = (`=pob_migr_014'/`=migr_pob') // 0 - 14
	putexcel Q10 = (`=muestra_nat_014') R10 = (`=muestra_migr_014') // Tamaño de la muestra
	putexcel Q11 = (`=pob_nat_1524'/`=nat_pob') R11 = (`=pob_migr_1524'/`=migr_pob') // 15 - 24
	putexcel Q12 = (`=muestra_nat_1524') R12 = (`=muestra_migr_1524') // Tamaño de la muestra
	putexcel Q13 = (`=pob_nat_2539'/`=nat_pob') R13 = (`=pob_migr_2539'/`=migr_pob') // 25 - 39
	putexcel Q14 = (`=muestra_nat_2539') R14 = (`=muestra_migr_2539') // Tamaño de la muestra
	putexcel Q15 = (`=pob_nat_4054'/`=nat_pob') R15 = (`=pob_migr_4054'/`=migr_pob') // 40 - 54
	putexcel Q16 = (`=muestra_nat_4054') R16 = (`=muestra_migr_4054') // Tamaño de la muestra
	putexcel Q17 = (`=pob_nat_5564'/`=nat_pob') R17 = (`=pob_migr_5564'/`=migr_pob') // 55 - 64
	putexcel Q18 = (`=muestra_nat_5564') R18 = (`=muestra_migr_5564') // Tamaño de la muestra
	putexcel Q19 = (`=pob_nat_65mas'/`=nat_pob') R19 = (`=pob_migr_65mas'/`=migr_pob') // 65 más
	putexcel Q20 = (`=muestra_nat_65mas') R20 = (`=muestra_migr_65mas') // Tamaño de la muestra
	
	* Tamaño del hogar
	putexcel Q21 = (`=tam_nat_hogar')  R21 = (`=tam_migr_hogar') // Tamaño del hogar
	putexcel Q22 = (`=Mtam_nat_hogar')  R22 = (`=Mtam_migr_hogar') // Tamaño de la muestra
	
	* Número de hijos
	putexcel Q23 = (`=num_nat_hijos')  R23 = (`=num_migr_hijos') // Número de hijos
	putexcel Q24 = (`=Mnum_nat_hijos')  R24 = (`=Mnum_migr_hijos') // Tamaño de la muestra
	
	
	*************** Indicadores por ubicación geográfica ***********************
	
	* Población urbana
	putexcel Q26 = (`=urbana_nat_pob'/`=nat_pob') R26 = (`=urbana_migr_pob'/`=migr_pob')	
	putexcel Q27 = (`=urbana_nat_muestra') R27 = (`=urbana_migr_muestra') // Tamaño de la muestra
	
	* Población rural
	putexcel Q28 = (`=rural_nat_pob'/`=nat_pob') R28 = (`=rural_migr_pob'/`=migr_pob')
	putexcel Q29 = (`=rural_nat_muestra') R29 = (`=rural_migr_muestra')	// Tamaño de la muestra	
	
	* Ciudad capital
	putexcel Q30 = (`=capital_nat_pob'/`=nat_pob') R30 = (`=capital_migr_pob'/`=migr_pob')
	putexcel Q31 = (`=capital_nat_muestra') R31 = (`=capital_migr_muestra') // Tamaño de la muestra	
	
	
	************** Indicadores por nivel de educación completo *****************
	
	** Por nivel educativo
	
	* Ningún nivel educativo completado
	putexcel Q33 = (`=NoEdu_nat_pob'/`=NMEdu_nat_pob') R33 = (`=NoEdu_migr_pob'/`=NMEdu_migr_pob')
	putexcel Q34 = (`=NoEdu_nat_muestra') R34 = (`=NoEdu_migr_muestra')	// Tamaño de la muestra
	
	** Preescolar
	putexcel Q35 = (`=EduPre_nat_pob'/`=NMEdu_nat_pob') R35 = (`=EduPre_migr_pob'/`=NMEdu_migr_pob')
	putexcel Q36 = (`=EduPre_nat_muestra') R36 = (`=EduPre_migr_muestra')	// Tamaño de la muestra
	
	** Primaria completa
	putexcel Q37 = (`=EduPrim_nat_pob'/`=NMEdu_nat_pob') R37 = (`=EduPrim_migr_pob'/`=NMEdu_migr_pob')
	putexcel Q38 = (`=EduPrim_nat_muestra') R38 = (`=EduPrim_migr_muestra')	// Tamaño de la muestra
	
	** Secundaria completa
	putexcel Q39 = (`=EduSecu_nat_pob'/`=NMEdu_nat_pob') R39 = (`=EduSecu_migr_pob'/`=NMEdu_migr_pob')
	putexcel Q40 = (`=EduSecu_nat_muestra') R40 = (`=EduSecu_migr_muestra')	// Tamaño de la muestra
	
	** Terciaria completa
	putexcel Q41 = (`=EduTerc_nat_pob'/`=NMEdu_nat_pob') R41 = (`=EduTerc_migr_pob'/`=NMEdu_migr_pob')
	putexcel Q42 = (`=EduTerc_nat_muestra') R42 = (`=EduTerc_migr_muestra')	// Tamaño de la muestra
	
	
	****************** Indicadores por situación laboral ***********************
	
	* Población en edad de trabajar
	putexcel Q44 = (`=edadTrab_nat_pob'/`=nat_pob') R44 = (`=edadTrab_migr_pob'/`=migr_pob')
	putexcel Q45 = (`=edadTrab_nat_muestra') R45 = (`=edadTrab_migr_muestra') // Tamaño de la muestra
	
	* Población económicamente activa
	putexcel Q46 = (`=econoAct_nat_pob'/`=edadTrab_nat_pob') R46 = (`=econoAct_migr_pob'/`=edadTrab_migr_pob')
	putexcel Q47 = (`=econoAct_nat_muestra') R47 = (`=econoAct_migr_muestra') // Tamaño de la muestra
	
	* Población empleada
	putexcel Q48 = (`=emp_nat_pob'/`=econoAct_nat_pob') R48 = (`=emp_migr_pob'/`=econoAct_migr_pob')
	putexcel Q49 = (`=emp_nat_muestra') R49 = (`=emp_migr_muestra') // Tamaño de la muestra
	
	* Población desempleada
	putexcel Q50 = (`=desemp_nat_pob'/`=econoAct_nat_pob') R50 = (`=desemp_migr_pob'/`=econoAct_migr_pob')
	putexcel Q51 = (`=desemp_nat_muestra') R51 = (`=desemp_migr_muestra') // Tamaño de la muestra	
	
	* Población informal
	putexcel Q52 = (`=informal_nat_pob'/`=emp_nat_pob') R52 = (`=informal_migr_pob'/`=emp_migr_pob')
	putexcel Q53 = (`=informal_nat_muestra') R53 = (`=informal_migr_muestra') // Tamaño de la muestra
	
	****************** Indicadores por categorías de ingresos ******************
	
	putexcel Q55 = (`=D1_nat_pob'/`=NMIng_nat_pob') R55 = (`=D1_migr_pob'/`=NMIng_migr_pob') // (D1)
	putexcel Q56 = (`=D1_nat_muestra') R56 = (`=D1_migr_muestra') // Tamaño muestra
	
	putexcel Q57 = (`=D2_nat_pob'/`=NMIng_nat_pob') R57 = (`=D2_migr_pob'/`=NMIng_migr_pob') // (D2)
	putexcel Q58 = (`=D2_nat_muestra') R58 = (`=D2_migr_muestra') // Tamaño muestra
	
	putexcel Q59 = (`=D3_nat_pob'/`=NMIng_nat_pob') R59 = (`=D3_migr_pob'/`=NMIng_migr_pob') // (D3)
	putexcel Q60 = (`=D3_nat_muestra') R60 = (`=D3_migr_muestra') // Tamaño muestra
	
	putexcel Q61 = (`=D4_nat_pob'/`=NMIng_nat_pob') R61 = (`=D4_migr_pob'/`=NMIng_migr_pob') // (D4)
	putexcel Q62 = (`=D4_nat_muestra') R62 = (`=D4_migr_muestra') // Tamaño muestra
	
	putexcel Q63 = (`=D5_nat_pob'/`=NMIng_nat_pob') R63 = (`=D5_migr_pob'/`=NMIng_migr_pob') // (D5)
	putexcel Q64 = (`=D5_nat_muestra') R64 = (`=D5_migr_muestra') // Tamaño muestra
	
	putexcel Q65 = (`=D6_nat_pob'/`=NMIng_nat_pob') R65 = (`=D6_migr_pob'/`=NMIng_migr_pob') // (D6)
	putexcel Q66 = (`=D6_nat_muestra') R66 = (`=D6_migr_muestra') // Tamaño muestra
	
	putexcel Q67 = (`=D7_nat_pob'/`=NMIng_nat_pob') R67 = (`=D7_migr_pob'/`=NMIng_migr_pob') // (D7)
	putexcel Q68 = (`=D7_nat_muestra') R68 = (`=D7_migr_muestra') // Tamaño muestra
	
	putexcel Q69 = (`=D8_nat_pob'/`=NMIng_nat_pob') R69 = (`=D8_migr_pob'/`=NMIng_migr_pob') // (D8)
	putexcel Q70 = (`=D8_nat_muestra') R70 = (`=D8_migr_muestra') // Tamaño muestra
	
	putexcel Q71 = (`=D9_nat_pob'/`=NMIng_nat_pob') R71 = (`=D9_migr_pob'/`=NMIng_migr_pob') // (D9)
	putexcel Q72 = (`=D9_nat_muestra') R72 = (`=D9_migr_muestra') // Tamaño muestra
	
	putexcel Q73 = (`=D10_nat_pob'/`=NMIng_nat_pob') R73 = (`=D10_migr_pob'/`=NMIng_migr_pob') // (D10)
	putexcel Q74 = (`=D10_nat_muestra') R74 = (`=D10_migr_muestra') // Tamaño muestra
	
	
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
	cd "C:\Users\JCAMILOP\OneDrive - Inter-American Development Bank Group\Otros\Indicadores PNUD\Bases de datos"
	use "TTO_2015a_BID.dta", replace

	gen uno=1
	replace factor_ci=round(factor_ci) // Applies when the expansion factor is a non-integer numbers
	
	****************************************************************************
	** LOCALS
		local 1_label = "migr"
		local 0_label = "nat"
		
		local 1_sexo = "masc_"
		local 2_sexo = "fem_"	
	
	****************************************************************************
	** Tamaño del hogar
	by idh_ch, sort: egen nmiembros=sum(relacion_ci>=1 & relacion_ci<5)	
	by idh_ch, sort: egen nhijos=sum(relacion_ci==3)
	
	****************************************************************************
	** Informalidad
	gen informal = 1 if cotizando_ci != 1 & emp_ci==1
	replace informal =1 if informal!=1 & afiliado_ci != 1 & emp_ci==1
	
	****************************************************************************
	** Muestra total
	sum uno if migrante_ci!=.
	scalar tot_muestra = `=r(N)'
	
	****************************************************************************
	** Muestra migrantes
	sum uno if migrante_ci==1
	scalar migr_muestra = `=r(N)'
	
	****************************************************************************
	** Muestra nativos
	sum uno if migrante_ci==0
	scalar nat_muestra = `=r(N)'
	
	****************************************************************************
	** Población total según factores de expansión
	sum uno if migrante_ci!=. [fw=factor_ci]
	scalar tot_pob = `=r(N)'
	
	****************************************************************************
	** Población migrante según factores de expansión
	sum uno if migrante_ci==1 [fw=factor_ci]
	scalar migr_pob = `=r(N)'
	
	****************************************************************************
	** Población nativa según factores de expansión
	sum uno if migrante_ci==0 [fw=factor_ci]
	scalar nat_pob = `=r(N)'
	
	****************************************************************************
	** Nivel educativo
	gen nivel_educ = 0 if eduno_ci == 1
	replace nivel_educ = 1 if edupre_ci == 1 & edupc_ci == 0
	replace nivel_educ = 2 if edupc_ci == 1 & edusc_ci == 0
	replace nivel_educ = 3 if edusc_ci == 1 & eduuc_ci == 0
	replace nivel_educ = 4 if eduuc_ci == 1
	
	****************************************************************************
	** Ingresos totales
	egen totIng=rowtotal(ylm_ci ylnm_ci ynlm_ci ynlnm_ci remesas_ci)
	
	****************************************************************************
	** Distribución ingresos
	xtile ing_dec=totIng if edad_ci>15 & pea_ci==1, n(10)
	
	* Decil 1
	gen dec_1=(ing_dec==1)
	replace dec_1=. if ing_dec==.

	* Decil 2
	gen dec_2=(ing_dec==2)
	replace dec_2=. if ing_dec==.

	* Decil 3
	gen dec_3=(ing_dec==3)
	replace dec_3=. if ing_dec==.
	
	* Decil 4
	gen dec_4=(ing_dec==4)
	replace dec_4=. if ing_dec==.

	* Decil 5 
	gen dec_5=(ing_dec==5)
	replace dec_5=. if ing_dec==.

	* Decil 6
	gen dec_6=(ing_dec==6)
	replace dec_6=. if ing_dec==.
	
	* Decil 7
	gen dec_7=(ing_dec==7)
	replace dec_7=. if ing_dec==.

	* Decil 8
	gen dec_8=(ing_dec==8)
	replace dec_8=. if ing_dec==.

	* Decil 9
	gen dec_9=(ing_dec==9)
	replace dec_9=. if ing_dec==.
	
	* Decil 10
	gen dec_10=(ing_dec==10)
	replace dec_10=. if ing_dec==.
	
	****************************************************************************
	** Cálculo de indicadores por migrantes y nativos
	
	foreach var in 1 0 {
		
		*********************** Indicadores demográficos ***********************	
		
		* Mujeres
		sum uno if sexo_ci==2 & migrante_ci==`var' [fw=factor_ci]
		scalar mujer_``var'_label'_pob =`=r(N)'
		
		* Mujeres muestra
		sum uno if sexo_ci==2 & migrante_ci==`var'
		scalar mujer_``var'_label'_muestra =`=r(N)'
		
		* Grupos de edades
		sum uno if inrange(edad_ci,0,14) & migrante_ci==`var' [fw=factor_ci]
		scalar pob_``var'_label'_014 = `=r(N)' // 0 - 14 years
		
		sum uno if inrange(edad_ci,15,24) & migrante_ci==`var' [fw=factor_ci]
		scalar pob_``var'_label'_1524 = `=r(N)' // 15 - 24 years

		sum uno if inrange(edad_ci,25,39) & migrante_ci==`var' [fw=factor_ci]
		scalar pob_``var'_label'_2539 = `=r(N)' // 25 - 39 years
		
		sum uno if inrange(edad_ci,40,54) & migrante_ci==`var' [fw=factor_ci]
		scalar pob_``var'_label'_4054 = `=r(N)' // 40 - 54 years

		sum uno if inrange(edad_ci,55,64) & migrante_ci==`var' [fw=factor_ci]
		scalar pob_``var'_label'_5564 = `=r(N)'	//55 - 64 years
		
		sum uno if inrange(edad_ci,65,.) & migrante_ci==`var' [fw=factor_ci]
		scalar pob_``var'_label'_65mas = `=r(N)'  // 65 older years
		
		* Muestra grupos de edades
		sum uno if inrange(edad_ci,0,14) & migrante_ci==`var'
		scalar muestra_``var'_label'_014 = `=r(N)' // 0 - 14 years
		
		sum uno if inrange(edad_ci,15,24) & migrante_ci==`var'
		scalar muestra_``var'_label'_1524 = `=r(N)' // 15 - 24 years

		sum uno if inrange(edad_ci,25,39) & migrante_ci==`var'
		scalar muestra_``var'_label'_2539 = `=r(N)' // 25 - 39 years
		
		sum uno if inrange(edad_ci,40,54) & migrante_ci==`var'
		scalar muestra_``var'_label'_4054 = `=r(N)' // 40 - 54 years

		sum uno if inrange(edad_ci,55,64) & migrante_ci==`var'
		scalar muestra_``var'_label'_5564 = `=r(N)'	//55 - 64 years
		
		sum uno if inrange(edad_ci,65,.) & migrante_ci==`var'
		scalar muestra_``var'_label'_65mas = `=r(N)'  // 65 older years
		
		* Tamaño del hogar
		sum nmiembros if migrante_ci==`var' [fw=factor_ci]
		scalar tam_``var'_label'_hogar = `=r(mean)'
		
		* Muestra tamaño hogar
		sum nmiembros if migrante_ci==`var'
		scalar Mtam_``var'_label'_hogar = `=r(N)'
		
		* Número de hijos
		sum nhijos if migrante_ci==`var' [fw=factor_ci]
		scalar num_``var'_label'_hijos = `=r(mean)'
		
		* Muestra número de hijos
		sum nhijos if migrante_ci==`var'
		scalar Mnum_``var'_label'_hijos = `=r(N)'
		
		
		********** Indicadores por ubicación geográfica ***********************

		* Porcentaje en zonas urbanas
		sum uno if zona_c==1 & migrante_ci==`var' [fw=factor_ci]
		scalar urbana_``var'_label'_pob = `=r(N)'
		
		* Muestra en zonas urbanas
		sum uno if zona_c==1 & migrante_ci==`var'
		scalar urbana_``var'_label'_muestra = `=r(N)'
		
		* Porcentaje en zonas rurales
		sum uno if zona_c==0 & migrante_ci==`var' [fw=factor_ci]
		scalar rural_``var'_label'_pob = `=r(N)'
		
		* Muestra en zonas rurales
		sum uno if zona_c==0 & migrante_ci==`var'
		scalar rural_``var'_label'_muestra = `=r(N)'
		
		* Porcentaje en ciudad capital
		sum uno if region_c==32 & migrante_ci==`var' [fw=factor_ci]
		scalar capital_``var'_label'_pob = `=r(N)'
		
		* Muestra en ciudad capital
		sum uno if region_c==32 & migrante_ci==`var'
		scalar capital_``var'_label'_muestra = `=r(N)'
		
		
		************* Indicadores por nivel de educación completo **************
		
		* Ningún nivel educativo completado
		sum uno if nivel_educ==0 & migrante_ci==`var' [fw=factor_ci]
		scalar NoEdu_``var'_label'_pob = `=r(N)'
		
		* Muestra ningún nivel educativo completado
		sum uno if nivel_educ==0 & migrante_ci==`var'
		scalar NoEdu_``var'_label'_muestra = `=r(N)'
		
		* Preescolar
		sum uno if nivel_educ==1 & migrante_ci==`var' [fw=factor_ci]
		scalar EduPre_``var'_label'_pob = `=r(N)'
		
		* Muestra preescolar
		sum uno if nivel_educ==1 & migrante_ci==`var'
		scalar EduPre_``var'_label'_muestra = `=r(N)'
		
		* Primaria
		sum uno if nivel_educ==2 & migrante_ci==`var' [fw=factor_ci]
		scalar EduPrim_``var'_label'_pob = `=r(N)'
		
		* Muestra primaria
		sum uno if nivel_educ==2 & migrante_ci==`var'
		scalar EduPrim_``var'_label'_muestra = `=r(N)'
		
		* Secundaria
		sum uno if nivel_educ==3 & migrante_ci==`var' [fw=factor_ci]
		scalar EduSecu_``var'_label'_pob = `=r(N)'
		
		* Muestra secundaria
		sum uno if nivel_educ==3 & migrante_ci==`var'
		scalar EduSecu_``var'_label'_muestra = `=r(N)'
		
		* Terciaria
		sum uno if nivel_educ==4 & migrante_ci==`var' [fw=factor_ci]
		scalar EduTerc_``var'_label'_pob = `=r(N)'
		
		sum uno if nivel_educ!=. & migrante_ci==`var' [fw=factor_ci]
		scalar NMEdu_``var'_label'_pob = `=r(N)'
		
		* Muestra terciaria
		sum uno if nivel_educ==4 & migrante_ci==`var'
		scalar EduTerc_``var'_label'_muestra = `=r(N)'
		
		
		**************** Indicadores por situación laboral *********************
		
		* Población en edad de trabajar
		sum uno if inrange(edad_ci,15,64) & migrante_ci==`var' [fw=factor_ci]
		scalar edadTrab_``var'_label'_pob = `=r(N)'
		
		* Muestra en edad de trabajar
		sum uno if inrange(edad_ci,15,64) & migrante_ci==`var'
		scalar edadTrab_``var'_label'_muestra = `=r(N)'
		
		* Población económicamente activa
		sum uno if inrange(edad_ci,15,64) & pea_ci==1 & migrante_ci==`var' [fw=factor_ci]
		scalar econoAct_``var'_label'_pob = `=r(N)'
		
		* Muestra económicamente activa
		sum uno if inrange(edad_ci,15,64) & pea_ci==1 & migrante_ci==`var'
		scalar econoAct_``var'_label'_muestra = `=r(N)'
		
		* Población empleada
		sum uno if inrange(edad_ci,15,64) & emp_ci==1 & migrante_ci==`var' [fw=factor_ci]
		scalar emp_``var'_label'_pob = `=r(N)'
		
		* Muestra empleada
		sum uno if inrange(edad_ci,15,64) & emp_ci==1 & migrante_ci==`var'
		scalar emp_``var'_label'_muestra = `=r(N)'
		
		* Población desempleada
		sum uno if inrange(edad_ci,15,64) & desemp_ci==1 & migrante_ci==`var' [fw=factor_ci] 
		scalar desemp_``var'_label'_pob = `=r(N)'
		
		* Muestra desempleada
		sum uno if inrange(edad_ci,15,64) & desemp_ci==1 & migrante_ci==`var'
		scalar desemp_``var'_label'_muestra = `=r(N)'
		
		* Informales
		sum uno if inrange(edad_ci,15,64) & informal==1 & migrante_ci==`var' [fw=factor_ci]
		scalar informal_``var'_label'_pob = `=r(N)'
		
		* Muestra informales
		sum uno if inrange(edad_ci,15,64) & informal==1 & migrante_ci==`var'
		scalar informal_``var'_label'_muestra = `=r(N)'
		
		**************** Indicadores por categorías de ingresos ****************
		
		* Decil 1
		sum uno if migrante_ci==`var' & dec_1 == 1 [fw=factor_ci]
		scalar D1_``var'_label'_pob = `=r(N)'
		
		* Muestra decil 1
		sum uno if migrante_ci==`var' & dec_1 == 1
		scalar D1_``var'_label'_muestra = `=r(N)'

		* Decil 2
		sum uno if migrante_ci==`var' & dec_2 == 1 [fw=factor_ci]
		scalar D2_``var'_label'_pob = `=r(N)'
		
		* Muestra decil 2
		sum uno if migrante_ci==`var' & dec_2 == 1
		scalar D2_``var'_label'_muestra = `=r(N)'
		
		* Decil 3
		sum uno if migrante_ci==`var' & dec_3 == 1 [fw=factor_ci]
		scalar D3_``var'_label'_pob = `=r(N)'
		
		* Muestra decil 3
		sum uno if migrante_ci==`var' & dec_3 == 1
		scalar D3_``var'_label'_muestra = `=r(N)'
		
		* Decil 4
		sum uno if migrante_ci==`var' & dec_4 == 1 [fw=factor_ci]
		scalar D4_``var'_label'_pob = `=r(N)'
		
		* Muestra decil 4
		sum uno if migrante_ci==`var' & dec_4 == 1
		scalar D4_``var'_label'_muestra = `=r(N)'
		
		* Decil 5
		sum uno if migrante_ci==`var' & dec_5 == 1 [fw=factor_ci]
		scalar D5_``var'_label'_pob = `=r(N)'
		
		* Muestra decil 5
		sum uno if migrante_ci==`var' & dec_5 == 1
		scalar D5_``var'_label'_muestra = `=r(N)'
		
		* Decil 6
		sum uno if migrante_ci==`var' & dec_6 == 1 [fw=factor_ci]
		scalar D6_``var'_label'_pob = `=r(N)'
		
		* Muestra decil 6
		sum uno if migrante_ci==`var' & dec_6 == 1
		scalar D6_``var'_label'_muestra = `=r(N)'
		
		* Decil 7
		sum uno if migrante_ci==`var' & dec_7 == 1 [fw=factor_ci]
		scalar D7_``var'_label'_pob = `=r(N)'
		
		* Muestra decil 7
		sum uno if migrante_ci==`var' & dec_7 == 1
		scalar D7_``var'_label'_muestra = `=r(N)'
		
		* Decil 8
		sum uno if migrante_ci==`var' & dec_8 == 1 [fw=factor_ci]
		scalar D8_``var'_label'_pob = `=r(N)'
		
		* Muestra decil 8
		sum uno if migrante_ci==`var' & dec_8 == 1
		scalar D8_``var'_label'_muestra = `=r(N)'
		
		* Decil 9
		sum uno if migrante_ci==`var' & dec_9 == 1 [fw=factor_ci]
		scalar D9_``var'_label'_pob = `=r(N)'
		
		* Muestra decil 9
		sum uno if migrante_ci==`var' & dec_9 == 1
		scalar D9_``var'_label'_muestra = `=r(N)'
		
		* Decil 10
		sum uno if migrante_ci==`var' & dec_10 == 1 [fw=factor_ci]
		scalar D10_``var'_label'_pob = `=r(N)'
		
		* Muestra decil 10
		sum uno if migrante_ci==`var' & dec_10 == 1
		scalar D10_``var'_label'_muestra = `=r(N)'
		
		sum uno if migrante_ci==`var' & (ing_dec!=.) [fw=factor_ci]
		scalar NMIng_``var'_label'_pob = `=r(N)'
	
		}
	
******************************************************** EXCEL OUTPUTS

	putexcel set "C:\Users\JCAMILOP\OneDrive - Inter-American Development Bank Group\Otros\Indicadores PNUD\Documentos\Resultados.xlsx", sheet("Indicadores") modify
	putexcel describe
	
	
	************************** Indicadores demográficos ***********************
	
	** Población
	putexcel S5 = (`=nat_pob'/`=tot_pob') T5 = (`=migr_pob'/`=tot_pob')	// Porcentaje de migrantes
	putexcel S6 = (`=nat_muestra') T6 = (`=migr_muestra')	// Tamaño de la muestra
	putexcel S7 = (`=mujer_nat_pob'/`=nat_pob') T7 = (`=mujer_migr_pob'/`=migr_pob')	// Porcentaje de mujeres
	putexcel S8 = (`=mujer_nat_muestra') T8 = (`=mujer_migr_muestra')	// Tamaño de la muestra
	
	* Edades 
	putexcel S9 = (`=pob_nat_014'/`=nat_pob') T9 = (`=pob_migr_014'/`=migr_pob') // 0 - 14
	putexcel S10 = (`=muestra_nat_014') T10 = (`=muestra_migr_014') // Tamaño de la muestra
	putexcel S11 = (`=pob_nat_1524'/`=nat_pob') T11 = (`=pob_migr_1524'/`=migr_pob') // 15 - 24
	putexcel S12 = (`=muestra_nat_1524') T12 = (`=muestra_migr_1524') // Tamaño de la muestra
	putexcel S13 = (`=pob_nat_2539'/`=nat_pob') T13 = (`=pob_migr_2539'/`=migr_pob') // 25 - 39
	putexcel S14 = (`=muestra_nat_2539') T14 = (`=muestra_migr_2539') // Tamaño de la muestra
	putexcel S15 = (`=pob_nat_4054'/`=nat_pob') T15 = (`=pob_migr_4054'/`=migr_pob') // 40 - 54
	putexcel S16 = (`=muestra_nat_4054') T16 = (`=muestra_migr_4054') // Tamaño de la muestra
	putexcel S17 = (`=pob_nat_5564'/`=nat_pob') T17 = (`=pob_migr_5564'/`=migr_pob') // 55 - 64
	putexcel S18 = (`=muestra_nat_5564') T18 = (`=muestra_migr_5564') // Tamaño de la muestra
	putexcel S19 = (`=pob_nat_65mas'/`=nat_pob') T19 = (`=pob_migr_65mas'/`=migr_pob') // 65 más
	putexcel S20 = (`=muestra_nat_65mas') T20 = (`=muestra_migr_65mas') // Tamaño de la muestra
	
	* Tamaño del hogar
	putexcel S21 = (`=tam_nat_hogar')  T21 = (`=tam_migr_hogar') // Tamaño del hogar
	putexcel S22 = (`=Mtam_nat_hogar')  T22 = (`=Mtam_migr_hogar') // Tamaño de la muestra
	
	* Número de hijos
	putexcel S23 = (`=num_nat_hijos')  T23 = (`=num_migr_hijos') // Número de hijos
	putexcel S24 = (`=Mnum_nat_hijos')  T24 = (`=Mnum_migr_hijos') // Tamaño de la muestra
	
	
	*************** Indicadores por ubicación geográfica ***********************
	
	* Población urbana
	putexcel S26 = (`=urbana_nat_pob'/`=nat_pob') T26 = (`=urbana_migr_pob'/`=migr_pob')	
	putexcel S27 = (`=urbana_nat_muestra') T27 = (`=urbana_migr_muestra') // Tamaño de la muestra
	
	* Población rural
	putexcel S28 = (`=rural_nat_pob'/`=nat_pob') T28 = (`=rural_migr_pob'/`=migr_pob')
	putexcel S29 = (`=rural_nat_muestra') T29 = (`=rural_migr_muestra')	// Tamaño de la muestra	
	
	* Ciudad capital
	putexcel S30 = (`=capital_nat_pob'/`=nat_pob') T30 = (`=capital_migr_pob'/`=migr_pob')
	putexcel S31 = (`=capital_nat_muestra') T31 = (`=capital_migr_muestra') // Tamaño de la muestra	
	
	
	************** Indicadores por nivel de educación completo *****************
	
	** Por nivel educativo
	
	* Ningún nivel educativo completado
	putexcel S33 = (`=NoEdu_nat_pob'/`=NMEdu_nat_pob') T33 = (`=NoEdu_migr_pob'/`=NMEdu_migr_pob')
	putexcel S34 = (`=NoEdu_nat_muestra') T34 = (`=NoEdu_migr_muestra')	// Tamaño de la muestra
	
	** Preescolar
	putexcel S35 = (`=EduPre_nat_pob'/`=NMEdu_nat_pob') T35 = (`=EduPre_migr_pob'/`=NMEdu_migr_pob')
	putexcel S36 = (`=EduPre_nat_muestra') T36 = (`=EduPre_migr_muestra')	// Tamaño de la muestra
	
	** Primaria completa
	putexcel S37 = (`=EduPrim_nat_pob'/`=NMEdu_nat_pob') T37 = (`=EduPrim_migr_pob'/`=NMEdu_migr_pob')
	putexcel S38 = (`=EduPrim_nat_muestra') T38 = (`=EduPrim_migr_muestra')	// Tamaño de la muestra
	
	** Secundaria completa
	putexcel S39 = (`=EduSecu_nat_pob'/`=NMEdu_nat_pob') T39 = (`=EduSecu_migr_pob'/`=NMEdu_migr_pob')
	putexcel S40 = (`=EduSecu_nat_muestra') T40 = (`=EduSecu_migr_muestra')	// Tamaño de la muestra
	
	** Terciaria completa
	putexcel S41 = (`=EduTerc_nat_pob'/`=NMEdu_nat_pob') T41 = (`=EduTerc_migr_pob'/`=NMEdu_migr_pob')
	putexcel S42 = (`=EduTerc_nat_muestra') T42 = (`=EduTerc_migr_muestra')	// Tamaño de la muestra
	
	
	****************** Indicadores por situación laboral ***********************
	
	* Población en edad de trabajar
	putexcel S44 = (`=edadTrab_nat_pob'/`=nat_pob') T44 = (`=edadTrab_migr_pob'/`=migr_pob')
	putexcel S45 = (`=edadTrab_nat_muestra') T45 = (`=edadTrab_migr_muestra') // Tamaño de la muestra
	
	* Población económicamente activa
	putexcel S46 = (`=econoAct_nat_pob'/`=edadTrab_nat_pob') T46 = (`=econoAct_migr_pob'/`=edadTrab_migr_pob')
	putexcel S47 = (`=econoAct_nat_muestra') T47 = (`=econoAct_migr_muestra') // Tamaño de la muestra
	
	* Población empleada
	putexcel S48 = (`=emp_nat_pob'/`=econoAct_nat_pob') T48 = (`=emp_migr_pob'/`=econoAct_migr_pob')
	putexcel S49 = (`=emp_nat_muestra') T49 = (`=emp_migr_muestra') // Tamaño de la muestra
	
	* Población desempleada
	putexcel S50 = (`=desemp_nat_pob'/`=econoAct_nat_pob') T50 = (`=desemp_migr_pob'/`=econoAct_migr_pob')
	putexcel S51 = (`=desemp_nat_muestra') T51 = (`=desemp_migr_muestra') // Tamaño de la muestra	
	
	* Población informal
	putexcel S52 = (`=informal_nat_pob'/`=emp_nat_pob') T52 = (`=informal_migr_pob'/`=emp_migr_pob')
	putexcel S53 = (`=informal_nat_muestra') T53 = (`=informal_migr_muestra') // Tamaño de la muestra
	
	****************** Indicadores por categorías de ingresos ******************
	
	putexcel S55 = (`=D1_nat_pob'/`=NMIng_nat_pob') T55 = (`=D1_migr_pob'/`=NMIng_migr_pob') // (D1)
	putexcel S56 = (`=D1_nat_muestra') T56 = (`=D1_migr_muestra') // Tamaño muestra
	
	putexcel S57 = (`=D2_nat_pob'/`=NMIng_nat_pob') T57 = (`=D2_migr_pob'/`=NMIng_migr_pob') // (D2)
	putexcel S58 = (`=D2_nat_muestra') T58 = (`=D2_migr_muestra') // Tamaño muestra
	
	putexcel S59 = (`=D3_nat_pob'/`=NMIng_nat_pob') T59 = (`=D3_migr_pob'/`=NMIng_migr_pob') // (D3)
	putexcel S60 = (`=D3_nat_muestra') T60 = (`=D3_migr_muestra') // Tamaño muestra
	
	putexcel S61 = (`=D4_nat_pob'/`=NMIng_nat_pob') T61 = (`=D4_migr_pob'/`=NMIng_migr_pob') // (D4)
	putexcel S62 = (`=D4_nat_muestra') T62 = (`=D4_migr_muestra') // Tamaño muestra
	
	putexcel S63 = (`=D5_nat_pob'/`=NMIng_nat_pob') T63 = (`=D5_migr_pob'/`=NMIng_migr_pob') // (D5)
	putexcel S64 = (`=D5_nat_muestra') T64 = (`=D5_migr_muestra') // Tamaño muestra
	
	putexcel S65 = (`=D6_nat_pob'/`=NMIng_nat_pob') T65 = (`=D6_migr_pob'/`=NMIng_migr_pob') // (D6)
	putexcel S66 = (`=D6_nat_muestra') T66 = (`=D6_migr_muestra') // Tamaño muestra
	
	putexcel S67 = (`=D7_nat_pob'/`=NMIng_nat_pob') T67 = (`=D7_migr_pob'/`=NMIng_migr_pob') // (D7)
	putexcel S68 = (`=D7_nat_muestra') T68 = (`=D7_migr_muestra') // Tamaño muestra
	
	putexcel S69 = (`=D8_nat_pob'/`=NMIng_nat_pob') T69 = (`=D8_migr_pob'/`=NMIng_migr_pob') // (D8)
	putexcel S70 = (`=D8_nat_muestra') T70 = (`=D8_migr_muestra') // Tamaño muestra
	
	putexcel S71 = (`=D9_nat_pob'/`=NMIng_nat_pob') T71 = (`=D9_migr_pob'/`=NMIng_migr_pob') // (D9)
	putexcel S72 = (`=D9_nat_muestra') T72 = (`=D9_migr_muestra') // Tamaño muestra
	
	putexcel S73 = (`=D10_nat_pob'/`=NMIng_nat_pob') T73 = (`=D10_migr_pob'/`=NMIng_migr_pob') // (D10)
	putexcel S74 = (`=D10_nat_muestra') T74 = (`=D10_migr_muestra') // Tamaño muestra
		
	