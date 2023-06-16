****keep testing plot shares****

clear all

tab labforce 
tab labforce, nolab

gen lf=.
replace lf=0 if labforce==1
replace lf=1 if labforce==2


tab empstat if lf==1, gen(empstat)
tab empstat if lf==1, nolab

gen insample=1 if occ>=3000 & occ<=3647

gen ph=1 if occ==2025


gen dent=.
replace dent=0 if insample==1
replace dent=1 if occ==3010 | occ==3310 | occ==3640

gen phys=.
replace phys=0 if insample==1
replace phys=1 if occ>=3060 & occ<=3110
replace phys=1 if occ==3225 | occ==3258 | occ==3500 | occ==3645
replace phys=1 if occ==3260 | occ==3261 
replace phys=1 if occ>=3600 & occ<=3605


gen low=.
replace low=0 if insample==1
replace low=1 if occ==3310 | occ==3640 | occ==3225 | occ==3258 | occ==3500 | occ==3645
replace low=1 if occ>=3600 & occ<=3605

gen high=.
replace high=0 if insample==1 & low==1
replace high=1 if insample==1 & low==0

gen phys_high=phys*high
gen phys_low=phys*low
gen dent_high=dent*high 
gen dent_low=dent*low 

egen id=group(month year)

***select and code mo-yr as quarters***

gen quarter=.
replace quarter=1 if year==2018 & (month>=3 & month<=8)
replace quarter=2 if year==2018 & (month>=9 & month<=11)
replace quarter=3 if year==2018 & (month==12)
replace quarter=3 if year==2019 & (month<=2)
replace quarter=4 if year==2019 & (month>=3 & month<=5)

replace quarter=5 if year==2019 & (month>=6 & month<=8)
replace quarter=6 if year==2019 & (month>=9 & month<=11)
replace quarter=7 if year==2019 & (month==12)
replace quarter=7 if year==2020 & (month<=2)
replace quarter=8 if year==2020 & (month>=3 & month<=5)

replace quarter=9 if year==2020 & (month>=6 & month<=8)
replace quarter=10 if year==2020 & (month>=9 & month<=11)
replace quarter=11 if year==2020 & (month==12)
replace quarter=11 if year==2021 & (month<=2)
replace quarter=12 if year==2021 & (month>=3 & month<=5)

replace quarter=13 if year==2021 & (month>=6 & month<=8)
replace quarter=14 if year==2021 & (month>=9 & month<=11)
replace quarter=15 if year==2021 & (month==12)
replace quarter=15 if year==2022 & (month<=2)
replace quarter=16 if year==2022 & (month>=3 & month<=5)


**gen subgroups**
gen nhw=0
replace nhw=1 if race==100 & hispan==0

gen hisp=0
replace hisp=1 if hispan!=0

gen nhb=0
foreach n of numlist 200 801 805 806 807 810 811 814 816 818{
	replace nhb=1 if hispan==0 & race==`n'
}

gen indig=0
foreach n of numlist 300 652 802 804 808 809 812 813 815 817 819{
replace indig=1 if hispan==0 & race==`n'
}

gen asia=0
replace asia=1 if race==651 | race==803

gen racegroup=.
replace racegroup=1 if nhw==1
replace racegroup=2 if nhb==1
replace racegroup=3 if hisp==1
replace racegroup=4 if indig==1
replace racegroup=5 if asia==1

 
gen female=0
replace female=1 if sex==2

gen nonmetro=0 if metro!=1 & metro!=0
replace nonmetro=1 if metro==1



*metfips county
*statecensus

tab region, gen(dumreg)

gen newreg1=1 if dumreg1==1 | dumreg2==1
gen newreg2=1 if dumreg3==1 | dumreg4==1

replace newreg1=1 if statefip==10 | statefip==11 | statefip==24

gen newreg3=1 if dumreg5==1 & newreg1!=1
replace newreg3=1 if dumreg6==1 | dumreg7==1


gen newreg4=1 if dumreg8==1
gen newreg5=1 if dumreg9==1

drop region

gen region=.
foreach n of numlist 1/5{
	replace region=`n' if newreg`n'==1
}

gen imp_wt=wtfinl
replace imp_wt=asecwth if wtfinl==.
replace imp_wt=imp_wt/14

save formeansplot_22.dta, replace


foreach x in racegroup metro region{
	foreach y in insample phys_high phys_low dent_high dent_low ph{
		
clear all

use formeansplot_22.dta

 plotshares `x' if `y'==1 & empstat1==1 , over(year) xlab(2010(1)2022)   scheme(tab2)
 plotmeans empstat1 if `y'==1 , over(year)  xlab(2010(1)2022)  scheme(tab2)
 
 graph save `y'`x'.gph, replace
 graph export `y'`x'.tif, replace
 
}
}

gen all=1

foreach x in racegroup {
	foreach y in  low{
	

 plotshares `x' if `y'==1 & empstat1==1 , over(year) xlab(2010(1)2022)   scheme(tab2)
 plotmeans empstat1 if `y'==1 , over(year)  xlab(2010(1)2022)  scheme(tab2)
 
 graph save `y'`x'.gph, replace
 graph export `y'`x'.tif, replace
	
}
}

graph combine allracegroup.gph lowracegroup.gph, ycommon