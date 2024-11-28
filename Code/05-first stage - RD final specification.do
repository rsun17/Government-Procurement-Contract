use "03-prepare data - type & merge.dta", clear

rename 合同金额 contract_amount
drop if contract_amount<=0
drop if contract_amount<30.415 //p1

//take log
gen logvalue=log( contract_amount )
gen logdistance=logvalue - log(threshold2)



//baseline: Linear fit, MSE-optimal bandwidth, IMSE-optimal no. of bins, triangular kernel



//1.
//a.
rdbwselect open logdistance, bwselect(mserd)
//limit the graph to bandwidth within 0.743

//use rdplot to generate rd mean variables for the twoway plots below
//if need to adjust any setup, please adjust it here
rdplot open logdistance if logdistance >=-0.743 &  logdistance <=0.743 , nbins(30) binselect(es) kernel(triangle) p(2) genvars

tw (scatter rdplot_mean_y rdplot_mean_x if rdplot_mean_x<=0.743 & rdplot_mean_x>=-0.743, msymbol(smcircle)) ///
(lfit open logdistance if logdistance<0 & logdistance>=-0.743,fcolor(none)) ///
(lfit open logdistance if logdistance>=0 & logdistance<=0.743,fcolor(none)) ///
(qfit open logdistance if logdistance<0 & logdistance>=-0.743,fcolor(none)) ///
(qfit open logdistance if logdistance>=0 & logdistance<=0.743,fcolor(none)), ///
xline(0) legend(off) scheme(lean2) graphregion(color(white)) yla(, nogrid) ytitle("means of the open bidding dummy") xtitle("logdistance")


//2.a
net install lpdensity, replace
local bandwidth_left = e(h_l)
local bandwidth_right = e(h_r)
rddensity logdistance, plot nohistogram plot_range(-`bandwidth_left' `bandwidth_right') graph_opt(scheme(lean2) graphregion(color(white)) yla(, nogrid) xtitle("logdistance") leg(off)) 

//2b problem: what bandwidth to use
//bandwidth result assymmetric but don't know why
rddensity logdistance, p(1)
rddensity logdistance, p(2)
rddensity logdistance, p(3)


//3.a.
/*
rdrobust open logdistance //everything is default
rdrobust open logdistance, p(2) //quadratic fit
rdrobust open logdistance, h(1 1) //arbitrary bandwidth
*/

eststo base: rdrobust open logdistance 
eststo quadratic: rdrobust open logdistance, p(2) 
eststo arbitrary: rdrobust open logdistance, h(1 1)

esttab


//3b, 4a & 4b
//regressions are run below first to record numbers and then type in STATA for graphing

//3b
rdbwselect open logdistance
//run regression based on bandwidths [0.5, 1, 1.5, 2] times of the MSE-optimal 
rdrobust open logdistance, h(0.743*0.5)
rdrobust open logdistance, h(0.743)
rdrobust open logdistance, h(0.743*1.5)
rdrobust open logdistance, h(0.743*2)


//4a
forvalues x = -1.5(0.5)1.5 {
	if `x' > 0 {
		local condition = "if logdistance >= 0"
	}
	else if `x' < 0 {
		local condition = "if logdistance < 0"
	}
	else {
		local condition = ""
	}

	rdrobust open logdistance `condition', c(`x')
}


//the alternative result without the local conditions above
forvalues x = -1.5(0.5)1.5 {
	rdrobust open logdistance , c(`x')
}



//4b
////run regression based on different Donut Hole Radius (0 0.02, 0.04, 0.06, 0.08, 0.1, 0.12) logdistance ranges from -11 to 14
//(0, 0.1, 0.2, 0.3, 0.4, 0.5) when x ranges from -30 to 30
forvalues k = 0(0.02)0.13 {
	rdrobust open logdistance if abs(logdistance) >= `k'
}

	

//3b. sensitivity to bandwidth [0.5, 1, 1.5, 2] times of the MSE-optimal
//record the treatment effect (average, upper bound, and lower bound) from the four regressions into a new dataset
clear
input bandwidth ce lb ub
0.3715   0.22367   0.19531   0.252032
0.743    0.21734   0.196783   0.237896
1.1145   0.18914   0.172113   0.206161
1.486    0.18118   0.166154   0.196199
end
list

//graph the range plot and scatterplot separately
twoway (rcap lb ub bandwidth)(scatter ce bandwidth), yline(0, lcolor(black) lpattern(dash)) ///
xlabel(0.3695 "MSE_0.5" 0.739 "MSE_1" 1.1085 "MSE_1.5" 1.478 "MSE_2" , labsize(small)) xscale(range(0.3 1.5)) ///
legend(off) yscale(range(0 0.27)) ///
xtitle(bandwidth) ytitle("RD Treatment Effect") graphregion(color(white)) ///
ylabel(0(.03)0.27) scheme(lean2) yla(, nogrid)

//4a. RD Estimation for True and Artificial Cutoffs

//data input from above
clear
input cutoff ce lb ub
-1.5   -0.04068  -0.09421  0.01284
-1    0.0566    -0.0004    0.1137
-0.5   0.00612  -0.03232   0.04456
0    0.21737    0.1968    0.2379
0.5    -0.00342  -0.04758   0.04073
1    0.00362    -0.02729    0.03452
1.5    -0.04826    -0.0911    -0.00547
end
list

//graphing
twoway (rcap lb ub cutoff)(scatter ce cutoff), yline(0, lcolor(black) lpattern(dash)) ///
legend(off) yscale(range(0 0.3)) ///
xtitle("Cutoff (x = 0 true cutoff)") ytitle("RD Treatment Effect") graphregion(color(white)) ///
ylabel(-0.1(0.1)0.3) scheme(lean2) yla(, nogrid) xlabel(-1.5(.5)1.5)


//the alternative result without the local conditions above
clear
input cutoff ce lb ub
-1.5   0.00058  -0.02662  0.027787
-1    -0.03388   -0.06030    -0.0075
-0.5   -0.00799  -0.03282   0.01684
0    0.21737    0.1968    0.2379
0.5    -0.03167  -0.051443   -0.01189
1    -0.00039    -0.02521    0.02443
1.5    -0.04127    -0.07439    -0.00815
end
list

//graphing
twoway (rcap lb ub cutoff)(scatter ce cutoff), yline(0, lcolor(black) lpattern(dash)) ///
legend(off) yscale(range(0 0.3)) ///
xtitle("Cutoff (x = 0 true cutoff)") ytitle("RD Treatment Effect") graphregion(color(white)) ///
ylabel(-0.1(0.1)0.3) scheme(lean2) yla(, nogrid) xlabel(-1.5(.5)1.5)



//4b. donut hole approach 

clear
input radius ce lb ub
0           0.2174        0.1968        0.2379
0.02        0.2440        0.2196        0.2683
0.04        0.2416        0.2161        0.2670
0.06        0.2213        0.1963        0.2464
0.08        0.1900        0.1663        0.2138
0.10        0.1596        0.1372        0.1819
0.12        0.1518        0.1267        0.1768
end
list

twoway (rcap lb ub radius)(scatter ce radius), yline(0, lcolor(black) lpattern(dash)) ///
legend(off) yscale(range(0 0.3)) ///
xtitle("Donut Hole Radius") ytitle("RD Treatment Effect") graphregion(color(white)) ///
ylabel(0.1(0.05)0.3) scheme(lean2) yla(, nogrid) xlabel(0(.02)0.13)

