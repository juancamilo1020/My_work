********************************************************************************
********************************************************************************
********************************************************************************
****** BARBADOS - LABOUR FORCE SURVEY 2016 *************************************
	
	clear all
	set more off, perm
	set maxvar 15000
	scalar drop _all

	** Base de datos
	cd "/Users/juancamiloperdomo/Library/CloudStorage/OneDrive-Inter-AmericanDevelopmentBankGroup/Otros/Indicadores PNUD/Bases de datos"
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
	** Población total según factores de expansión
	sum uno if migrante_ci!=. & edad_ci>=18 [fw=factor_ci]
	scalar tot_pob = `=r(N)'
	
	****************************************************************************
	** Población migrante según factores de expansión
	sum uno if migrante_ci==1 & edad_ci>=18 [fw=factor_ci]
	scalar migr_pob = `=r(N)'
	
	****************************************************************************
	** Población nativa según factores de expansión
	sum uno if migrante_ci==0 & edad_ci>=18 [fw=factor_ci]
	scalar nat_pob = `=r(N)'
	
	****************************************************************************
	** Nivel educativo
	gen nivel_educ = 0 if eduno_ci == 1
	replace nivel_educ = 1 if edupre_ci == 1 & edupc_ci == 0
	replace nivel_educ = 2 if edupc_ci == 1 & edusc_ci == 0
	replace nivel_educ = 3 if edusc_ci == 1 & eduuc_ci == 0
	replace nivel_educ = 4 if eduuc_ci == 1
	
	****************************************************************************
	** Cálculo de indicadores por migrantes y nativos
	
	foreach var in 1 0 {
		
		* Grupos de edades
		sum uno if inrange(edad_ci,18,25) & migrante_ci==`var' [fw=factor_ci]
		scalar pob_``var'_label'_1825 = `=r(N)' // 18 - 25 years
		
		sum uno if inrange(edad_ci,26,45) & migrante_ci==`var' [fw=factor_ci]
		scalar pob_``var'_label'_2645 = `=r(N)' // 26 - 45 years

		sum uno if inrange(edad_ci,46,64) & migrante_ci==`var' [fw=factor_ci]
		scalar pob_``var'_label'_4664 = `=r(N)'	//46 - 64 years
		
		sum uno if inrange(edad_ci,65,.) & migrante_ci==`var' [fw=factor_ci]
		scalar pob_``var'_label'_65mas = `=r(N)'  // 65 older years
		
		* Mujeres
		sum uno if sexo_ci==2 & migrante_ci==`var' [fw=factor_ci]
		scalar mujer_``var'_label'_pob =`=r(N)' 
		
		* Menos de educación terciaria
		sum uno if nivel_educ<4 & migrante_ci==`var' [fw=factor_ci]
		scalar EduTerc_``var'_label'_pob = `=r(N)'	
		
		sum uno if nivel_educ!=. & migrante_ci==`var' [fw=factor_ci]
		scalar NMEdu_``var'_label'_pob = `=r(N)'
		
		* Población desempleada
		sum uno if inrange(edad_ci,15,64) & desemp_ci==1 & migrante_ci==`var' [fw=factor_ci] 
		scalar desemp_``var'_label'_pob = `=r(N)'
		
		sum uno if inrange(edad_ci,15,64) & pea_ci==1 & migrante_ci==`var' [fw=factor_ci]
		scalar econoAct_``var'_label'_pob = `=r(N)'
	
		}
	
******************************************************** EXCEL OUTPUTS

	putexcel set "/Users/juancamiloperdomo/Library/CloudStorage/OneDrive-Inter-AmericanDevelopmentBankGroup/Otros/Indicadores PNUD/Documentos/Resultados Septiembre.xlsx", sheet("Indicadores") modify
	putexcel describe
	
	
	************************** Indicadores demográficos ***********************
	
	* Edades 
	putexcel C5 = (`=pob_nat_1825'/`=nat_pob') // 18 - 25
	putexcel C6 = (`=pob_nat_2645'/`=nat_pob') // 26 - 45
	putexcel C7 = (`=pob_nat_4664'/`=nat_pob') // 46 - 64
	putexcel C8 = (`=pob_nat_65mas'/`=nat_pob') // 65 más
	
	* Mujeres
	putexcel C10 = (`=mujer_nat_pob'/`=nat_pob')
	
	** Terciaria completa
	putexcel C11 = (`=EduTerc_nat_pob'/`=NMEdu_nat_pob')
	
	* Población desempleada
	putexcel C12 = (`=desemp_nat_pob'/`=econoAct_nat_pob')
	
	
********************************************************************************
********************************************************************************
********************************************************************************
****** CHILE - ENCUESTA DE CARACTERIZACIÓN SOCIOECONÓMICA NACIONAL 2020 ********
	
	clear all
	set more off, perm
	set maxvar 15000
	scalar drop _all

	** Base de datos
	cd  "/Users/juancamiloperdomo/Library/CloudStorage/OneDrive-Inter-AmericanDevelopmentBankGroup/Otros/Indicadores PNUD/Bases de datos"
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
	** Población total según factores de expansión
	sum uno if migrante_ci!=. & edad_ci>=18 [fw=factor_ci]
	scalar tot_pob = `=r(N)'
	
	****************************************************************************
	** Población migrante según factores de expansión
	sum uno if migrante_ci==1 & edad_ci>=18 [fw=factor_ci]
	scalar migr_pob = `=r(N)'
	
	****************************************************************************
	** Población nativa según factores de expansión
	sum uno if migrante_ci==0 & edad_ci>=18 [fw=factor_ci]
	scalar nat_pob = `=r(N)'
	
	****************************************************************************
	** Nivel educativo
	gen nivel_educ = 0 if eduno_ci == 1
	replace nivel_educ = 1 if edupre_ci == 1 & edupc_ci == 0
	replace nivel_educ = 2 if edupc_ci == 1 & edusc_ci == 0
	replace nivel_educ = 3 if edusc_ci == 1 & eduuc_ci == 0
	replace nivel_educ = 4 if eduuc_ci == 1
	
	****************************************************************************
	** Cálculo de indicadores por migrantes y nativos
	
	foreach var in 1 0 {
		
		* Grupos de edades
		sum uno if inrange(edad_ci,18,25) & migrante_ci==`var' [fw=factor_ci]
		scalar pob_``var'_label'_1825 = `=r(N)' // 18 - 25 years
		
		sum uno if inrange(edad_ci,26,45) & migrante_ci==`var' [fw=factor_ci]
		scalar pob_``var'_label'_2645 = `=r(N)' // 26 - 45 years

		sum uno if inrange(edad_ci,46,64) & migrante_ci==`var' [fw=factor_ci]
		scalar pob_``var'_label'_4664 = `=r(N)'	//46 - 64 years
		
		sum uno if inrange(edad_ci,65,.) & migrante_ci==`var' [fw=factor_ci]
		scalar pob_``var'_label'_65mas = `=r(N)'  // 65 older years
		
		* Mujeres
		sum uno if sexo_ci==2 & migrante_ci==`var' [fw=factor_ci]
		scalar mujer_``var'_label'_pob =`=r(N)' 
		
		* Menos de educación terciaria
		sum uno if nivel_educ<4 & migrante_ci==`var' [fw=factor_ci]
		scalar EduTerc_``var'_label'_pob = `=r(N)'	
		
		sum uno if nivel_educ!=. & migrante_ci==`var' [fw=factor_ci]
		scalar NMEdu_``var'_label'_pob = `=r(N)'
		
		* Población desempleada
		sum uno if inrange(edad_ci,15,64) & desemp_ci==1 & migrante_ci==`var' [fw=factor_ci] 
		scalar desemp_``var'_label'_pob = `=r(N)'
		
		sum uno if inrange(edad_ci,15,64) & pea_ci==1 & migrante_ci==`var' [fw=factor_ci]
		scalar econoAct_``var'_label'_pob = `=r(N)'
	
		}
	
******************************************************** EXCEL OUTPUTS

	putexcel set "/Users/juancamiloperdomo/Library/CloudStorage/OneDrive-Inter-AmericanDevelopmentBankGroup/Otros/Indicadores PNUD/Documentos/Resultados Septiembre.xlsx", sheet("Indicadores") modify
	putexcel describe
	
	
	************************** Indicadores demográficos ***********************
	
	* Edades 
	putexcel D5 = (`=pob_nat_1825'/`=nat_pob') // 18 - 25
	putexcel D6 = (`=pob_nat_2645'/`=nat_pob') // 26 - 45
	putexcel D7 = (`=pob_nat_4664'/`=nat_pob') // 46 - 64
	putexcel D8 = (`=pob_nat_65mas'/`=nat_pob') // 65 más
	
	* Mujeres
	putexcel D10 = (`=mujer_nat_pob'/`=nat_pob')
	
	** Terciaria completa
	putexcel D11 = (`=EduTerc_nat_pob'/`=NMEdu_nat_pob')
	
	* Población desempleada
	putexcel D12 = (`=desemp_nat_pob'/`=econoAct_nat_pob')
	
********************************************************************************
********************************************************************************
********************************************************************************
****** COLOMBIA - GRAN ENCUESTA INTEGRADA DE HOGARES 2020 **********************
	
	clear all
	set more off, perm
	set maxvar 15000
	scalar drop _all

	** DATASET
	cd "/Users/juancamiloperdomo/Library/CloudStorage/OneDrive-Inter-AmericanDevelopmentBankGroup/Otros/Indicadores PNUD/Bases de datos"
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
	** Población total según factores de expansión
	sum uno if migrante_ci!=. & edad_ci>=18 [fw=factor_ci]
	scalar tot_pob = `=r(N)'
	
	****************************************************************************
	** Población migrante según factores de expansión
	sum uno if migrante_ci==1 & edad_ci>=18 [fw=factor_ci]
	scalar migr_pob = `=r(N)'
	
	****************************************************************************
	** Población nativa según factores de expansión
	sum uno if migrante_ci==0 & edad_ci>=18 [fw=factor_ci]
	scalar nat_pob = `=r(N)'
	
	****************************************************************************
	** Nivel educativo
	gen nivel_educ = 0 if eduno_ci == 1
	replace nivel_educ = 1 if edupre_ci == 1 & edupc_ci == 0
	replace nivel_educ = 2 if edupc_ci == 1 & edusc_ci == 0
	replace nivel_educ = 3 if edusc_ci == 1 & eduuc_ci == 0
	replace nivel_educ = 4 if eduuc_ci == 1
	
	****************************************************************************
	** Cálculo de indicadores por migrantes y nativos
	
	foreach var in 1 0 {
		
		* Grupos de edades
		sum uno if inrange(edad_ci,18,25) & migrante_ci==`var' [fw=factor_ci]
		scalar pob_``var'_label'_1825 = `=r(N)' // 18 - 25 years
		
		sum uno if inrange(edad_ci,26,45) & migrante_ci==`var' [fw=factor_ci]
		scalar pob_``var'_label'_2645 = `=r(N)' // 26 - 45 years

		sum uno if inrange(edad_ci,46,64) & migrante_ci==`var' [fw=factor_ci]
		scalar pob_``var'_label'_4664 = `=r(N)'	//46 - 64 years
		
		sum uno if inrange(edad_ci,65,.) & migrante_ci==`var' [fw=factor_ci]
		scalar pob_``var'_label'_65mas = `=r(N)'  // 65 older years
		
		* Mujeres
		sum uno if sexo_ci==2 & migrante_ci==`var' [fw=factor_ci]
		scalar mujer_``var'_label'_pob =`=r(N)' 
		
		* Menos de educación terciaria
		sum uno if nivel_educ<4 & migrante_ci==`var' [fw=factor_ci]
		scalar EduTerc_``var'_label'_pob = `=r(N)'	

		sum uno if nivel_educ!=. & migrante_ci==`var' [fw=factor_ci]
		scalar NMEdu_``var'_label'_pob = `=r(N)'
		
		* Población desempleada
		sum uno if inrange(edad_ci,15,64) & desemp_ci==1 & migrante_ci==`var' [fw=factor_ci] 
		scalar desemp_``var'_label'_pob = `=r(N)'
		
		sum uno if inrange(edad_ci,15,64) & pea_ci==1 & migrante_ci==`var' [fw=factor_ci]
		scalar econoAct_``var'_label'_pob = `=r(N)'
	
		}
	
******************************************************** EXCEL OUTPUTS

	putexcel set "/Users/juancamiloperdomo/Library/CloudStorage/OneDrive-Inter-AmericanDevelopmentBankGroup/Otros/Indicadores PNUD/Documentos/Resultados Septiembre.xlsx", sheet("Indicadores") modify
	putexcel describe
	
	
	************************** Indicadores demográficos ***********************
	
	* Edades 

	putexcel E5 = (`=pob_nat_1825'/`=nat_pob') // 18 - 25
	putexcel E6 = (`=pob_nat_2645'/`=nat_pob') // 26 - 45
	putexcel E7 = (`=pob_nat_4664'/`=nat_pob') // 46 - 64
	putexcel E8 = (`=pob_nat_65mas'/`=nat_pob') // 65 más
	
	* Mujeres
	putexcel E10 = (`=mujer_nat_pob'/`=nat_pob')
	
	** Terciaria completa
	putexcel E11 = (`=EduTerc_nat_pob'/`=NMEdu_nat_pob')
	
	* Población desempleada
	putexcel E12 = (`=desemp_nat_pob'/`=econoAct_nat_pob')
		
		
********************************************************************************
********************************************************************************
********************************************************************************
****** COSTA RICA - ENCUESTA NACIONAL DE HOGARES 2020 **************************
	
	clear all
	set more off, perm
	set maxvar 15000
	scalar drop _all

	** DATASET
	cd "/Users/juancamiloperdomo/Library/CloudStorage/OneDrive-Inter-AmericanDevelopmentBankGroup/Otros/Indicadores PNUD/Bases de datos"
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
	** Población total según factores de expansión
	sum uno if migrante_ci!=. & edad_ci>=18 [fw=factor_ci]
	scalar tot_pob = `=r(N)'
	
	****************************************************************************
	** Población migrante según factores de expansión
	sum uno if migrante_ci==1 & edad_ci>=18 [fw=factor_ci]
	scalar migr_pob = `=r(N)'
	
	****************************************************************************
	** Población nativa según factores de expansión
	sum uno if migrante_ci==0 & edad_ci>=18 [fw=factor_ci]
	scalar nat_pob = `=r(N)'
	
	****************************************************************************
	** Nivel educativo
	gen nivel_educ = 0 if eduno_ci == 1
	replace nivel_educ = 1 if edupre_ci == 1 & edupc_ci == 0
	replace nivel_educ = 2 if edupc_ci == 1 & edusc_ci == 0
	replace nivel_educ = 3 if edusc_ci == 1 & eduuc_ci == 0
	replace nivel_educ = 4 if eduuc_ci == 1
	
	****************************************************************************
	** Cálculo de indicadores por migrantes y nativos
	
	foreach var in 1 0 {
		
		* Grupos de edades
		sum uno if inrange(edad_ci,18,25) & migrante_ci==`var' [fw=factor_ci]
		scalar pob_``var'_label'_1825 = `=r(N)' // 18 - 25 years
		
		sum uno if inrange(edad_ci,26,45) & migrante_ci==`var' [fw=factor_ci]
		scalar pob_``var'_label'_2645 = `=r(N)' // 26 - 45 years

		sum uno if inrange(edad_ci,46,64) & migrante_ci==`var' [fw=factor_ci]
		scalar pob_``var'_label'_4664 = `=r(N)'	//46 - 64 years
		
		sum uno if inrange(edad_ci,65,.) & migrante_ci==`var' [fw=factor_ci]
		scalar pob_``var'_label'_65mas = `=r(N)'  // 65 older years
		
		* Mujeres
		sum uno if sexo_ci==2 & migrante_ci==`var' [fw=factor_ci]
		scalar mujer_``var'_label'_pob =`=r(N)' 
		
		* Menos de educación terciaria
		sum uno if nivel_educ<4 & migrante_ci==`var' [fw=factor_ci]
		scalar EduTerc_``var'_label'_pob = `=r(N)'	
		
		sum uno if nivel_educ!=. & migrante_ci==`var' [fw=factor_ci]
		scalar NMEdu_``var'_label'_pob = `=r(N)'
		
		* Población desempleada
		sum uno if inrange(edad_ci,15,64) & desemp_ci==1 & migrante_ci==`var' [fw=factor_ci] 
		scalar desemp_``var'_label'_pob = `=r(N)'
		
		sum uno if inrange(edad_ci,15,64) & pea_ci==1 & migrante_ci==`var' [fw=factor_ci]
		scalar econoAct_``var'_label'_pob = `=r(N)'
	
		}
	
******************************************************** EXCEL OUTPUTS

	putexcel set "/Users/juancamiloperdomo/Library/CloudStorage/OneDrive-Inter-AmericanDevelopmentBankGroup/Otros/Indicadores PNUD/Documentos/Resultados Septiembre.xlsx", sheet("Indicadores") modify
	putexcel describe
	
	
	************************** Indicadores demográficos ***********************
	
	* Edades 

	putexcel F5 = (`=pob_nat_1825'/`=nat_pob') // 18 - 25
	putexcel F6 = (`=pob_nat_2645'/`=nat_pob') // 26 - 45
	putexcel F7 = (`=pob_nat_4664'/`=nat_pob') // 46 - 64
	putexcel F8 = (`=pob_nat_65mas'/`=nat_pob') // 65 más
	
	* Mujeres
	putexcel F10 = (`=mujer_nat_pob'/`=nat_pob')
	
	** Terciaria completa
	putexcel F11 = (`=EduTerc_nat_pob'/`=NMEdu_nat_pob')
	
	* Población desempleada
	putexcel F12 = (`=desemp_nat_pob'/`=econoAct_nat_pob')	
		
	
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
	cd "/Users/juancamiloperdomo/Library/CloudStorage/OneDrive-Inter-AmericanDevelopmentBankGroup/Otros/Indicadores PNUD/Bases de datos"
	use "ECU_2021a_BID.dta", replace

	gen uno=1
	replace factor_ci=round(factor_ci/4) // Applies when the expansion factor is a non-integer number
	
	****************************************************************************
	** LOCALS
		local 1_label = "migr"
		local 0_label = "nat"
		
		local 1_sexo = "masc_"
		local 2_sexo = "fem_"
	
	****************************************************************************
	** Población total según factores de expansión
	sum uno if migrante_ci!=. & edad_ci>=18 [fw=factor_ci]
	scalar tot_pob = `=r(N)'
	
	****************************************************************************
	** Población migrante según factores de expansión
	sum uno if migrante_ci==1 & edad_ci>=18 [fw=factor_ci]
	scalar migr_pob = `=r(N)'
	
	****************************************************************************
	** Población nativa según factores de expansión
	sum uno if migrante_ci==0 & edad_ci>=18 [fw=factor_ci]
	scalar nat_pob = `=r(N)'
	
	****************************************************************************
	** Nivel educativo
	gen nivel_educ = 0 if eduno_ci == 1
	replace nivel_educ = 1 if edupre_ci == 1 & edupc_ci == 0
	replace nivel_educ = 2 if edupc_ci == 1 & edusc_ci == 0
	replace nivel_educ = 3 if edusc_ci == 1 & eduuc_ci == 0
	replace nivel_educ = 4 if eduuc_ci == 1
	
	****************************************************************************
	** Cálculo de indicadores por migrantes y nativos
	
	foreach var in 1 0 {
		
		* Grupos de edades
		sum uno if inrange(edad_ci,18,25) & migrante_ci==`var' [fw=factor_ci]
		scalar pob_``var'_label'_1825 = `=r(N)' // 18 - 25 years
		
		sum uno if inrange(edad_ci,26,45) & migrante_ci==`var' [fw=factor_ci]
		scalar pob_``var'_label'_2645 = `=r(N)' // 26 - 45 years

		sum uno if inrange(edad_ci,46,64) & migrante_ci==`var' [fw=factor_ci]
		scalar pob_``var'_label'_4664 = `=r(N)'	//46 - 64 years
		
		sum uno if inrange(edad_ci,65,.) & migrante_ci==`var' [fw=factor_ci]
		scalar pob_``var'_label'_65mas = `=r(N)'  // 65 older years
		
		* Mujeres
		sum uno if sexo_ci==2 & migrante_ci==`var' [fw=factor_ci]
		scalar mujer_``var'_label'_pob =`=r(N)' 
		
		* Menos de educación terciaria
		sum uno if nivel_educ<4 & migrante_ci==`var' [fw=factor_ci]
		scalar EduTerc_``var'_label'_pob = `=r(N)'	
		
		sum uno if nivel_educ!=. & migrante_ci==`var' [fw=factor_ci]
		scalar NMEdu_``var'_label'_pob = `=r(N)'
		
		* Población desempleada
		sum uno if inrange(edad_ci,15,64) & desemp_ci==1 & migrante_ci==`var' [fw=factor_ci] 
		scalar desemp_``var'_label'_pob = `=r(N)'
		
		sum uno if inrange(edad_ci,15,64) & pea_ci==1 & migrante_ci==`var' [fw=factor_ci]
		scalar econoAct_``var'_label'_pob = `=r(N)'
	
		}
	
******************************************************** EXCEL OUTPUTS

	putexcel set "/Users/juancamiloperdomo/Library/CloudStorage/OneDrive-Inter-AmericanDevelopmentBankGroup/Otros/Indicadores PNUD/Documentos/Resultados Septiembre.xlsx", sheet("Indicadores") modify
	putexcel describe
	
	
	************************** Indicadores demográficos ***********************
	
	* Edades 

	putexcel G5 = (`=pob_nat_1825'/`=nat_pob') // 18 - 25
	putexcel G6 = (`=pob_nat_2645'/`=nat_pob') // 26 - 45
	putexcel G7 = (`=pob_nat_4664'/`=nat_pob') // 46 - 64
	putexcel G8 = (`=pob_nat_65mas'/`=nat_pob') // 65 más
	
	* Mujeres
	putexcel G10 = (`=mujer_nat_pob'/`=nat_pob')
	
	** Terciaria completa
	putexcel G11 = (`=EduTerc_nat_pob'/`=NMEdu_nat_pob')
	
	* Población desempleada
	putexcel G12 = (`=desemp_nat_pob'/`=econoAct_nat_pob')
		
	
********************************************************************************
********************************************************************************
********************************************************************************
****** PERÚ - ENCUESTA NACIONAL DE HOGARES 2020 ********************************
	
	clear all
	set more off, perm
	set maxvar 15000
	scalar drop _all

	** DATASET
	cd "/Users/juancamiloperdomo/Library/CloudStorage/OneDrive-Inter-AmericanDevelopmentBankGroup/Otros/Indicadores PNUD/Bases de datos"
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
	** Población total según factores de expansión
	sum uno if migrante_ci!=. & edad_ci>=18 [fw=factor_ci]
	scalar tot_pob = `=r(N)'
	
	****************************************************************************
	** Población migrante según factores de expansión
	sum uno if migrante_ci==1 & edad_ci>=18 [fw=factor_ci]
	scalar migr_pob = `=r(N)'
	
	****************************************************************************
	** Población nativa según factores de expansión
	sum uno if migrante_ci==0 & edad_ci>=18 [fw=factor_ci]
	scalar nat_pob = `=r(N)'
	
	****************************************************************************
	** Nivel educativo
	gen nivel_educ = 0 if eduno_ci == 1
	replace nivel_educ = 1 if edupre_ci == 1 & edupc_ci == 0
	replace nivel_educ = 2 if edupc_ci == 1 & edusc_ci == 0
	replace nivel_educ = 3 if edusc_ci == 1 & eduuc_ci == 0
	replace nivel_educ = 4 if eduuc_ci == 1
	
	****************************************************************************
	** Cálculo de indicadores por migrantes y nativos
	
	foreach var in 1 0 {
		
		* Grupos de edades
		sum uno if inrange(edad_ci,18,25) & migrante_ci==`var' [fw=factor_ci]
		scalar pob_``var'_label'_1825 = `=r(N)' // 18 - 25 years
		
		sum uno if inrange(edad_ci,26,45) & migrante_ci==`var' [fw=factor_ci]
		scalar pob_``var'_label'_2645 = `=r(N)' // 26 - 45 years

		sum uno if inrange(edad_ci,46,64) & migrante_ci==`var' [fw=factor_ci]
		scalar pob_``var'_label'_4664 = `=r(N)'	//46 - 64 years
		
		sum uno if inrange(edad_ci,65,.) & migrante_ci==`var' [fw=factor_ci]
		scalar pob_``var'_label'_65mas = `=r(N)'  // 65 older years
		
		* Mujeres
		sum uno if sexo_ci==2 & migrante_ci==`var' [fw=factor_ci]
		scalar mujer_``var'_label'_pob =`=r(N)' 
		
		* Menos de educación terciaria
		sum uno if nivel_educ<4 & migrante_ci==`var' [fw=factor_ci]
		scalar EduTerc_``var'_label'_pob = `=r(N)'	
		
		sum uno if nivel_educ!=. & migrante_ci==`var' [fw=factor_ci]
		scalar NMEdu_``var'_label'_pob = `=r(N)'
		
		* Población desempleada
		sum uno if inrange(edad_ci,15,64) & desemp_ci==1 & migrante_ci==`var' [fw=factor_ci] 
		scalar desemp_``var'_label'_pob = `=r(N)'
		
		sum uno if inrange(edad_ci,15,64) & pea_ci==1 & migrante_ci==`var' [fw=factor_ci]
		scalar econoAct_``var'_label'_pob = `=r(N)'
	
		}
	
******************************************************** EXCEL OUTPUTS

	putexcel set "/Users/juancamiloperdomo/Library/CloudStorage/OneDrive-Inter-AmericanDevelopmentBankGroup/Otros/Indicadores PNUD/Documentos/Resultados Septiembre.xlsx", sheet("Indicadores") modify
	putexcel describe
	
	
	************************** Indicadores demográficos ***********************
	
	* Edades 

	putexcel H5 = (`=pob_nat_1825'/`=nat_pob') // 18 - 25
	putexcel H6 = (`=pob_nat_2645'/`=nat_pob') // 26 - 45
	putexcel H7 = (`=pob_nat_4664'/`=nat_pob') // 46 - 64
	putexcel H8 = (`=pob_nat_65mas'/`=nat_pob') // 65 más
	
	* Mujeres
	putexcel H10 = (`=mujer_nat_pob'/`=nat_pob')
	
	** Terciaria completa
	putexcel H11 = (`=EduTerc_nat_pob'/`=NMEdu_nat_pob')
	
	* Población desempleada
	putexcel H12 = (`=desemp_nat_pob'/`=econoAct_nat_pob')
		

********************************************************************************
********************************************************************************
********************************************************************************
****************************** MÉXICO 2020  ************************************
	
	clear all
	set more off, perm
	set maxvar 15000
	scalar drop _all

	** DATASET
	cd "/Users/juancamiloperdomo/Library/CloudStorage/OneDrive-Inter-AmericanDevelopmentBankGroup/Otros/Indicadores PNUD/Bases de datos"
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
	** Población total según factores de expansión
	sum uno if migrante_ci!=. & edad_ci>=18 [fw=factor_ci]
	scalar tot_pob = `=r(N)'
	
	****************************************************************************
	** Población migrante según factores de expansión
	sum uno if migrante_ci==1 & edad_ci>=18 [fw=factor_ci]
	scalar migr_pob = `=r(N)'
	
	****************************************************************************
	** Población nativa según factores de expansión
	sum uno if migrante_ci==0 & edad_ci>=18 [fw=factor_ci]
	scalar nat_pob = `=r(N)'
	
	****************************************************************************
	** Nivel educativo
	gen nivel_educ = 0 if eduno_ci == 1
	replace nivel_educ = 1 if edupre_ci == 1 & edupc_ci == 0
	replace nivel_educ = 2 if edupc_ci == 1 & edusc_ci == 0
	replace nivel_educ = 3 if edusc_ci == 1 & eduuc_ci == 0
	replace nivel_educ = 4 if eduuc_ci == 1
	
	****************************************************************************
	** Cálculo de indicadores por migrantes y nativos
	
	foreach var in 1 0 {
		
		* Grupos de edades
		sum uno if inrange(edad_ci,18,25) & migrante_ci==`var' [fw=factor_ci]
		scalar pob_``var'_label'_1825 = `=r(N)' // 18 - 25 years
		
		sum uno if inrange(edad_ci,26,45) & migrante_ci==`var' [fw=factor_ci]
		scalar pob_``var'_label'_2645 = `=r(N)' // 26 - 45 years

		sum uno if inrange(edad_ci,46,64) & migrante_ci==`var' [fw=factor_ci]
		scalar pob_``var'_label'_4664 = `=r(N)'	//46 - 64 years
		
		sum uno if inrange(edad_ci,65,.) & migrante_ci==`var' [fw=factor_ci]
		scalar pob_``var'_label'_65mas = `=r(N)'  // 65 older years
		
		* Mujeres
		sum uno if sexo_ci==2 & migrante_ci==`var' [fw=factor_ci]
		scalar mujer_``var'_label'_pob =`=r(N)' 
		
		* Menos de educación terciaria
		sum uno if nivel_educ<4 & migrante_ci==`var' [fw=factor_ci]
		scalar EduTerc_``var'_label'_pob = `=r(N)'	
		
		sum uno if nivel_educ!=. & migrante_ci==`var' [fw=factor_ci]
		scalar NMEdu_``var'_label'_pob = `=r(N)'
		
		* Población desempleada
		sum uno if inrange(edad_ci,15,64) & desemp_ci==1 & migrante_ci==`var' [fw=factor_ci] 
		scalar desemp_``var'_label'_pob = `=r(N)'
		
		sum uno if inrange(edad_ci,15,64) & pea_ci==1 & migrante_ci==`var' [fw=factor_ci]
		scalar econoAct_``var'_label'_pob = `=r(N)'
	
		}
	
******************************************************** EXCEL OUTPUTS

	putexcel set "/Users/juancamiloperdomo/Library/CloudStorage/OneDrive-Inter-AmericanDevelopmentBankGroup/Otros/Indicadores PNUD/Documentos/Resultados Septiembre.xlsx", sheet("Indicadores") modify
	putexcel describe
	
	
	************************** Indicadores demográficos ***********************
	
	* Edades 

	putexcel I5 = (`=pob_nat_1825'/`=nat_pob') // 18 - 25
	putexcel I6 = (`=pob_nat_2645'/`=nat_pob') // 26 - 45
	putexcel I7 = (`=pob_nat_4664'/`=nat_pob') // 46 - 64
	putexcel I8 = (`=pob_nat_65mas'/`=nat_pob') // 65 más
	
	* Mujeres
	putexcel I10 = (`=mujer_nat_pob'/`=nat_pob')
	
	** Terciaria completa
	putexcel I11 = (`=EduTerc_nat_pob'/`=NMEdu_nat_pob')
	
	* Población desempleada
	putexcel I12 = (`=desemp_nat_pob'/`=econoAct_nat_pob')
		
		
********************************************************************************
********************************************************************************
********************************************************************************
****** REP DOMINICANA - ENCUESTA NACIONAL CONTINUA DE FUERZA DE TRABAJO 2020 ***
	
	clear all
	set more off, perm
	set maxvar 15000
	scalar drop _all

	** DATASET
	cd "/Users/juancamiloperdomo/Library/CloudStorage/OneDrive-Inter-AmericanDevelopmentBankGroup/Otros/Indicadores PNUD/Bases de datos"
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
	** Población total según factores de expansión
	sum uno if migrante_ci!=. & edad_ci>=18 [fw=factor_ci]
	scalar tot_pob = `=r(N)'
	
	****************************************************************************
	** Población migrante según factores de expansión
	sum uno if migrante_ci==1 & edad_ci>=18 [fw=factor_ci]
	scalar migr_pob = `=r(N)'
	
	****************************************************************************
	** Población nativa según factores de expansión
	sum uno if migrante_ci==0 & edad_ci>=18 [fw=factor_ci]
	scalar nat_pob = `=r(N)'
	
	****************************************************************************
	** Nivel educativo
	gen nivel_educ = 0 if eduno_ci == 1
	replace nivel_educ = 1 if edupre_ci == 1 & edupc_ci == 0
	replace nivel_educ = 2 if edupc_ci == 1 & edusc_ci == 0
	replace nivel_educ = 3 if edusc_ci == 1 & eduuc_ci == 0
	replace nivel_educ = 4 if eduuc_ci == 1
	
	****************************************************************************
	** Cálculo de indicadores por migrantes y nativos
	
	foreach var in 1 0 {
		
		* Grupos de edades
		sum uno if inrange(edad_ci,18,25) & migrante_ci==`var' [fw=factor_ci]
		scalar pob_``var'_label'_1825 = `=r(N)' // 18 - 25 years
		
		sum uno if inrange(edad_ci,26,45) & migrante_ci==`var' [fw=factor_ci]
		scalar pob_``var'_label'_2645 = `=r(N)' // 26 - 45 years

		sum uno if inrange(edad_ci,46,64) & migrante_ci==`var' [fw=factor_ci]
		scalar pob_``var'_label'_4664 = `=r(N)'	//46 - 64 years
		
		sum uno if inrange(edad_ci,65,.) & migrante_ci==`var' [fw=factor_ci]
		scalar pob_``var'_label'_65mas = `=r(N)'  // 65 older years
		
		* Mujeres
		sum uno if sexo_ci==2 & migrante_ci==`var' [fw=factor_ci]
		scalar mujer_``var'_label'_pob =`=r(N)' 
		
		* Menos de educación terciaria
		sum uno if nivel_educ<4 & migrante_ci==`var' [fw=factor_ci]
		scalar EduTerc_``var'_label'_pob = `=r(N)'	
		
		sum uno if nivel_educ!=. & migrante_ci==`var' [fw=factor_ci]
		scalar NMEdu_``var'_label'_pob = `=r(N)'
		
		* Población desempleada
		sum uno if inrange(edad_ci,15,64) & desemp_ci==1 & migrante_ci==`var' [fw=factor_ci] 
		scalar desemp_``var'_label'_pob = `=r(N)'
		
		sum uno if inrange(edad_ci,15,64) & pea_ci==1 & migrante_ci==`var' [fw=factor_ci]
		scalar econoAct_``var'_label'_pob = `=r(N)'
	
		}
	
******************************************************** EXCEL OUTPUTS

	putexcel set "/Users/juancamiloperdomo/Library/CloudStorage/OneDrive-Inter-AmericanDevelopmentBankGroup/Otros/Indicadores PNUD/Documentos/Resultados Septiembre.xlsx", sheet("Indicadores") modify
	putexcel describe
	
	
	************************** Indicadores demográficos ***********************
	
	* Edades 

	putexcel J5 = (`=pob_nat_1825'/`=nat_pob') // 18 - 25
	putexcel J6 = (`=pob_nat_2645'/`=nat_pob') // 26 - 45
	putexcel J7 = (`=pob_nat_4664'/`=nat_pob') // 46 - 64
	putexcel J8 = (`=pob_nat_65mas'/`=nat_pob') // 65 más
	
	* Mujeres
	putexcel J10 = (`=mujer_nat_pob'/`=nat_pob')
	
	** Terciaria completa
	putexcel J11 = (`=EduTerc_nat_pob'/`=NMEdu_nat_pob')
	
	* Población desempleada
	putexcel J12 = (`=desemp_nat_pob'/`=econoAct_nat_pob')
	
	
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
	cd "/Users/juancamiloperdomo/Library/CloudStorage/OneDrive-Inter-AmericanDevelopmentBankGroup/Otros/Indicadores PNUD/Bases de datos"
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
	** Población total según factores de expansión
	sum uno if migrante_ci!=. & edad_ci>=18 [fw=factor_ci]
	scalar tot_pob = `=r(N)'
	
	****************************************************************************
	** Población migrante según factores de expansión
	sum uno if migrante_ci==1 & edad_ci>=18 [fw=factor_ci]
	scalar migr_pob = `=r(N)'
	
	****************************************************************************
	** Población nativa según factores de expansión
	sum uno if migrante_ci==0 & edad_ci>=18 [fw=factor_ci]
	scalar nat_pob = `=r(N)'
	
	****************************************************************************
	** Nivel educativo
	gen nivel_educ = 0 if eduno_ci == 1
	replace nivel_educ = 1 if edupre_ci == 1 & edupc_ci == 0
	replace nivel_educ = 2 if edupc_ci == 1 & edusc_ci == 0
	replace nivel_educ = 3 if edusc_ci == 1 & eduuc_ci == 0
	replace nivel_educ = 4 if eduuc_ci == 1
	
	****************************************************************************
	** Cálculo de indicadores por migrantes y nativos
	
	foreach var in 1 0 {
		
		* Grupos de edades
		sum uno if inrange(edad_ci,18,25) & migrante_ci==`var' [fw=factor_ci]
		scalar pob_``var'_label'_1825 = `=r(N)' // 18 - 25 years
		
		sum uno if inrange(edad_ci,26,45) & migrante_ci==`var' [fw=factor_ci]
		scalar pob_``var'_label'_2645 = `=r(N)' // 26 - 45 years

		sum uno if inrange(edad_ci,46,64) & migrante_ci==`var' [fw=factor_ci]
		scalar pob_``var'_label'_4664 = `=r(N)'	//46 - 64 years
		
		sum uno if inrange(edad_ci,65,.) & migrante_ci==`var' [fw=factor_ci]
		scalar pob_``var'_label'_65mas = `=r(N)'  // 65 older years
		
		* Mujeres
		sum uno if sexo_ci==2 & migrante_ci==`var' [fw=factor_ci]
		scalar mujer_``var'_label'_pob =`=r(N)' 
		
		* Menos de educación terciaria
		sum uno if nivel_educ<4 & migrante_ci==`var' [fw=factor_ci]
		scalar EduTerc_``var'_label'_pob = `=r(N)'	
		
		sum uno if nivel_educ!=. & migrante_ci==`var' [fw=factor_ci]
		scalar NMEdu_``var'_label'_pob = `=r(N)'
		
		* Población desempleada
		sum uno if inrange(edad_ci,15,64) & desemp_ci==1 & migrante_ci==`var' [fw=factor_ci] 
		scalar desemp_``var'_label'_pob = `=r(N)'
		
		sum uno if inrange(edad_ci,15,64) & pea_ci==1 & migrante_ci==`var' [fw=factor_ci]
		scalar econoAct_``var'_label'_pob = `=r(N)'
	
		}
	
******************************************************** EXCEL OUTPUTS

	putexcel set "/Users/juancamiloperdomo/Library/CloudStorage/OneDrive-Inter-AmericanDevelopmentBankGroup/Otros/Indicadores PNUD/Documentos/Resultados Septiembre.xlsx", sheet("Indicadores") modify
	putexcel describe
	
	
	************************** Indicadores demográficos ***********************
	
	* Edades 

	putexcel K5 = (`=pob_nat_1825'/`=nat_pob') // 18 - 25
	putexcel K6 = (`=pob_nat_2645'/`=nat_pob') // 26 - 45
	putexcel K7 = (`=pob_nat_4664'/`=nat_pob') // 46 - 64
	putexcel K8 = (`=pob_nat_65mas'/`=nat_pob') // 65 más
	
	* Mujeres
	putexcel K10 = (`=mujer_nat_pob'/`=nat_pob')
	
	** Terciaria completa
	putexcel K11 = (`=EduTerc_nat_pob'/`=NMEdu_nat_pob')
	
	* Población desempleada
	putexcel K12 = (`=desemp_nat_pob'/`=econoAct_nat_pob')
		