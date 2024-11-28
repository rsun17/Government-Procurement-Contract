cd "C:\Users\flora\Dropbox\RA- Flora Gu\Data"
use "03-prepare data - type & merge.dta", clear

rename 合同金额 contract_amount
drop if contract_amount<=0
drop if contract_amount<30.415 //p1

//take log
gen logvalue=log( contract_amount )
gen logdistance=logvalue - log(threshold2)

cd "C:\Users\flora\Dropbox\RA- Flora Gu\Result\first stage - RD results"
//1.
//a.
rdplot open logdistance, p(1) graph_options(name(g1, replace))
rdplot open logdistance, p(2) graph_options(name(g2, replace))
rdplot open logdistance, p(4) graph_options(name(g3, replace))
graph combine g1 g2 g3, title("all observations")
graph export g_total.pdf, replace

//b.
tabstat logdistance, statistics( p90 p10 )
rdplot open logdistance if logdistance>-6.571283 & logdistance<0.7390758, p(1) graph_options(name(g4, replace))
rdplot open logdistance if logdistance>-6.571283 & logdistance<0.7390758, p(2) graph_options(name(g5, replace))
rdplot open logdistance if logdistance>-6.571283 & logdistance<0.7390758, p(4) graph_options(name(g6, replace))
graph combine g4 g5 g6, title("10-90%")
graph export g_drop10.pdf, replace

rdplot open logdistance if logdistance>log(0.5) & logdistance<log(2), p(1) graph_options(name(g7, replace))
rdplot open logdistance if logdistance>log(0.5) & logdistance<log(2), p(2) graph_options(name(g8, replace))
rdplot open logdistance if logdistance>log(0.5) & logdistance<log(2), p(4) graph_options(name(g9, replace))
graph combine g7 g8 g9, title("random value log(0.5) to log(2)")
graph export g_random1.pdf, replace

rdplot open logdistance if logdistance>-0.1 & logdistance<0.1, p(1) graph_options(name(g10, replace))
rdplot open logdistance if logdistance>-0.1 & logdistance<0.1, p(2) graph_options(name(g11, replace))
rdplot open logdistance if logdistance>-0.1 & logdistance<0.1, p(4) graph_options(name(g12, replace))
graph combine g10 g11 g12, title("random value -0.1 to 0.1")
graph export g_random2.pdf, replace

rdplot open logdistance if logdistance>-0.739*2 & logdistance<0.739*2 , p(1) graph_options(name(g13, replace))
rdplot open logdistance if logdistance>-0.739*2  & logdistance<0.739*2, p(2) graph_options(name(g14, replace))
rdplot open logdistance if logdistance>-0.739*2 & logdistance<0.739*2, p(4) graph_options(name(g15, replace))
graph combine g13 g14 g15, title("2 times the MSE-optimal bandwidth")
graph export g_mse2.pdf, replace

rdplot open logdistance if logdistance>-0.739*4 & logdistance<0.739*4, p(1) graph_options(name(g16, replace))
rdplot open logdistance if logdistance>-0.739*4 & logdistance<0.739*4, p(2) graph_options(name(g17, replace))
rdplot open logdistance if logdistance>-0.739*4 & logdistance<0.739*4, p(4) graph_options(name(g18, replace))
graph combine g16 g17 g18, title("4 times the MSE-optimal bandwidth")
graph export g_mse4.pdf, replace

//c.

rdplot open logdistance, binselect(es)
rdplot open logdistance, binselect(qs)

//2.
histogram logdistance, xline(0)
gen distance = contract_amount - threshold2
histogram distance, xline(0) //non-log values did not make the histogram look better.

histogram threshold2
summarize threshold2 //standard deviation of threshold is 929269.6.


//logdistance -0.1 to 0.1
count if logdistance>-0.1 & logdistance<0
count if logdistance> 0 & logdistance<0.1
bitesti 15353 5137 0.5

count if logdistance>log(0.5) & logdistance<0
count if logdistance> 0 & logdistance<log(2)
bitesti 96440 37168 1/2

rddensity logdistance

//3.
//Kernal
rdrobust open logdistance, kernel(triangular)
rdrobust open logdistance, kernel(uniform)

//Polynomial order
rdrobust open logdistance, p(1)
rdrobust open logdistance, p(2)

//Bandwidth selection 
rdrobust open logdistance, bwselect(mserd)
rdrobust open logdistance, bwselect(msetwo)
rdrobust open logdistance, bwselect(cerrd)
rdrobust open logdistance, bwselect(certwo)

rdrobust open logdistance, h(2) //visually linear
rdrobust open logdistance, h(1)



//sensitivity to bandwidth figure 

//run regression based on bandwidths [0.5, 1, 1.5, 2] times of the MSE-optimal 
rdrobust open logdistance if logdistance>-0.739*0.5 & logdistance<0.739*0.5
rdrobust open logdistance if logdistance>-0.739 & logdistance<0.739
rdrobust open logdistance if logdistance>-0.739*1.5 & logdistance<0.739*1.5
rdrobust open logdistance if logdistance>-0.739*2 & logdistance<0.739*2 

//record the treatment effect (average, upper bound, and lower bound) from the four regressions into a new dataset
clear
input bandwidth ce lb ub
0.3695   0.10574   0.041638   0.169839
0.739    0.15102   0.102973   0.199063
1.1085   0.19978   0.161142   0.23841
1.478    0.22624   0.199342   0.25314
end
list

//graph the range plot and scatterplot separately
twoway (rcap lb ub bandwidth)(scatter ce bandwidth), yline(0, lcolor(black) lpattern(dash)) ///
xlabel(0.3695 "MSE_0.5" 0.739 "MSE_1" 1.1085 "MSE_1.5" 1.478 "MSE_2" , labsize(small)) xscale(range(0.3 1.5)) ///
legend(off) yscale(range(0 0.27)) ///
xtitle(bandwidth) ytitle("RD Treatment Effect") graphregion(color(white)) 




