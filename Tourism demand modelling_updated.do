//declare panel data
destring inter, replace
encode country, gen(country_num)
xtset country_num year
xtset c_id year
xtdescribe
gen temp2=CRU_new*CRU_new

// check vif 
*High VIF in polynomial terms (CRU_new temp2) is expected and usually tolerated because the interpretation focuses on the combined shape, not the individual coefficients.
regress inter CRU_new temp2 preci gdppc pop 
estat vif
regress dom CRU_new temp2 preci gdppc pop 
estat vif

//Global results

//Hausman tests
*according to Hausman test, the Fixed-effect model is prefered
xtreg inter CRU_new temp2 preci gdppc pop, fe
est store FE
xtreg inter CRU_new temp2 preci gdppc pop, re
est store RE
hausman FE RE, sigmamore

xtreg dom CRU_new temp2 preci gdppc pop, fe
est store FE
xtreg dom CRU_new temp2 preci gdppc pop, re
est store RE
hausman FE RE, sigmamore

//Global-domestic
xtreg dom CRU_new temp2 preci gdppc pop, fe level(90) vce( robust) 
xtreg dom CRU_new temp2 preci gdppc pop i.year, fe level(90) vce( robust) 
*By comparing the Root Mean Square Error (RMSE) of each model, we found that excluding the year-fixed term (i.year) in the Global-domestic panel is superior. 

//RMSE check
drop yhat
predict yhat , xb
corr inter yhat 

drop yhat
predict yhat , xb
corr dom yhat 

drop resid
gen resid = inter - yhat 
sum resid
display sqrt(r(Var))  

drop resid
gen resid = dom - yhat 
sum resid
display sqrt(r(Var))   

//Global-international 
xtreg inter CRU_new temp2 preci gdppc pop, fe level(90) vce(robust) 
xtreg inter CRU_new temp2 preci gdppc pop i.year, fe level(90)  vce(robust) 

*By comparing the Root Mean Square Error (RMSE) of each model, we found that adding the year-fixed term (i.year) in the Global-international panel is superior. 

//robustness test
//heteroskedasticity check -heteroskedasticity
xttest3
//cross-sectional dependence check (CD) - cross-sectional dependence
xtcsd, pesaran abs
//serial correlation check -autocorrelation
xtserial inter CRU_new temp2 preci gdppc pop 
xtserial dom CRU_new temp2 preci gdppc pop 

//Regression with Driscoll-Kraay standard errors
tab year , gen(yd_)
drop yd_1
xtscc inter CRU_new temp2 preci gdppc pop yd_*, fe level (90)  //Global-international 
xtscc dom CRU_new temp2 preci gdppc pop, fe level (90) //Global-domestic


//climate-zoning models

*allowing the error covariance matrix to differ across climate regimes


//tropical zone (N=71)
//tropical-international 
xtreg inter CRU_new temp2 preci gdppc pop if cla=="tropi", fe //superior
est store FE
xtreg inter CRU_new temp2 preci gdppc pop if cla=="tropi", re 
est store RE
hausman FE RE, sigmamore

xtreg inter CRU_new temp2 preci gdppc pop if cla=="tropi", fe level(90) vce(robust) 
xtreg inter CRU_new temp2 preci gdppc pop i.year if cla=="tropi", fe level(90) vce(robust) //(superior, smaller RMSE)

xtscc inter CRU_new temp2 preci gdppc pop yd_* if cla=="tropi", fe level (90) // tropical-international model

*tropical-domestic
xtreg dom CRU_new temp2 preci gdppc pop if cla=="tropi", fe //superior
est store FE
xtreg dom CRU_new temp2 preci gdppc pop if cla=="tropi", re 
est store RE
hausman FE RE, sigmamore

xtreg dom CRU_new temp2 preci gdppc pop if cla=="tropi", fe level(90) 
xtreg dom CRU_new temp2 preci gdppc pop i.year if cla=="tropi", fe level(90) //(superior, smaller RMSE)

xtscc dom CRU_new temp2 preci gdppc pop yd_* if cla=="tropi", fe level (90) //tropical-domestic model

// Arid (N=30)
//aird-international 
xtreg inter CRU_new temp2 preci gdppc pop if cla=="arid", fe
est store FE
xtreg inter CRU_new temp2 preci gdppc pop  if cla=="arid", re //superior
est store RE
hausman FE RE, sigmamore
*Since the Hausman test fails to reject the null hypothesis of random effects at the significance level, this indicates that individual effects are not correlated with the explanatory variables. 

xtscc inter CRU_new temp2 preci gdppc pop yd_* if cla=="arid",  pooled level (90) //aird-international model

//aird-domestic ： 
xtreg dom CRU_new temp2 preci gdppc pop i.year if cla=="arid", fe
est store FE
xtreg dom CRU_new temp2 preci gdppc pop i.year if cla=="arid", re //superior 
est store RE
hausman FE RE, sigmamore

xtscc dom CRU_new temp2 preci gdppc pop yd_* if cla=="arid", pooled level (90) //aird-domestic model


// Temperate zone:
*The temperate zone encompasses a total of 59 countries, yet climate variations are immense. Using the Köppen climate classification system, we broadly categorize them into three types: humid subtropical, mediterranean, and oceanic climates. When regression with Driscoll-Kraay standard errors exhibits significant variation with FGLS model results, different FGLS structures will be employed to test robustness.

//Subtropical (N=22)
// Sub-international
xtreg inter CRU_new temp2 preci gdppc pop if cla=="sub", fe //superior 
est store FE
xtreg inter CRU_new temp2 preci gdppc pop  if cla=="sub", re 
est store RE
hausman FE RE, sigmamore

xtscc inter CRU_new temp2 preci gdppc pop yd_* if cla=="sub", fe level (90) // The coefficients of all variables have undergone significant changes, indicating the overfitting problem in the small panel. Besides, the R^2 decreases. 

//Model 1: 
xtscc inter CRU_new temp2 preci gdppc pop  if cla=="sub", fe level (90) 

//Model 2: 
*Feasible Generalized Least Squares (FGLS) estimation is particularly suitable for panels with a limited number of cross-sectional units and a comparatively longer time dimension (N < T), as it allows for panel-specific heteroskedasticity and contemporaneous correlation across panels. In small panels, conventional fixed-effects estimators with cluster-robust standard errors may suffer from imprecise variance estimation due to the limited number of clusters, whereas FGLS provides more efficient estimates under structured error covariance assumptions.

xtgls inter CRU_new temp2 preci gdppc pop i.c_id if cla=="sub", panels(correlated) level(90) // Sub-international model

*The coefficients returned by these models are similar in both direction and magnitude.

// Sub-domestic 
xtreg dom CRU_new temp2 preci gdppc pop if cla=="sub", fe
est store FE
xtreg dom CRU_new temp2 preci gdppc pop  if cla=="sub", re //superior 
est store RE
hausman FE RE, sigmamore
*Since the Hausman test fails to reject the null hypothesis of random effects at the significance level, this indicates that individual effects are not correlated with the explanatory variables. 

xtscc dom CRU_new temp2 preci gdppc pop yd_* if cla=="sub", pooled level (90)  
xtgls dom CRU_new temp2 preci gdppc pop i.year if cla=="sub", panels(correlated)  level(90) // Sub-domestic model

*The coefficients returned by these models are similar in both direction and magnitude.

/// Mediterranean (N=15)
*The climate-based subsample, constructed using capital-city climate classifications, involves a smaller number of observations and introduces larger cross-country temperature dispersion. The limitation increases estimation uncertainty and leads to larger standard errors relative to the full or bigger sample modellings. However, this limitation will be mitigated through subsequent calibration. Please see the Supplementary Information for further details. 

* Mediterranean-international
xtreg inter CRU_new temp2 preci gdppc pop if cla=="medi", fe //superior
est store FE
xtreg inter CRU_new temp2 preci gdppc pop if cla=="medi", re 
est store RE
hausman FE RE, sigmamore

xtscc inter CRU_new temp2  preci gdppc pop yd_* if cla=="medi",  fe level (90) // The coefficients of all variables have undergone significant changes, indicating the overfitting problem in the small panel.

//Model 1: FE
xtscc inter CRU_new temp2 preci gdppc pop if cla=="medi",  fe level (90)

//Model 2: FGLS
xtgls inter CRU_new temp2 preci gdppc pop i.c_id if cla=="medi", panels(correlated) level(90) 
xtgls inter CRU_new temp2 preci gdppc pop i.c_id if cla=="medi", panels(correlated) corr(psar1) level(90)
xtgls inter CRU_new temp2 preci gdppc pop if cla=="medi", panels(hetero)  level(90) 
xtgls inter CRU_new temp2 preci gdppc pop  if cla=="medi", panels(correlated) corr(psar1) level(90) //Mediterranean-international model

* Mediterranean-domestic 
xtreg dom CRU_new temp2 preci gdppc pop  if cla=="medi", fe
est store FE
xtreg dom CRU_new temp2 preci gdppc pop  if cla=="medi", re //superior
est store RE
hausman FE RE, sigmamore

xtscc dom CRU_new temp2 preci gdppc pop yd_* if cla=="medi", pooled level (90) //If this model holds true, the turning point of the U-shaped relationship occurs at 38.58 degrees.

xtreg dom CRU_new  preci gdppc pop if cla=="medi", fe
est store FE
xtreg dom CRU_new preci gdppc pop  if cla=="medi", re //superior
est store RE
hausman FE RE, sigmamore

xtreg dom CRU_new preci gdppc pop i.year if cla=="medi", re vce(robust) //Mediterranean-domestic model
*The reversal of temperature effects indicates strong common time shocks, year effets have to be considered)

//robustness test
xtgls dom CRU_new  preci gdppc pop i.year if cla=="medi", panels(correlated) corr(psar1)  level(90) 
xtgls dom CRU_new  preci gdppc pop if cla=="medi", panels(correlated) corr(psar1)  level(90)  
xtgls dom CRU_new preci gdppc pop  if cla=="medi", panels(hetero)  level(90) 


// marine (N=22)
//marine-international 
xtreg inter CRU_new preci gdppc pop  if cla=="marine", fe //superior
est store FE
xtreg inter CRU_new preci gdppc pop if cla=="marine", re
est store RE
hausman FE RE, sigmamore

xtscc inter CRU_new  preci gdppc pop yd_* if cla=="marine",  fe level (90) // // The coefficients of all variables have undergone significant changes, indicating the overfitting problem in the small panel.

//Model 1: FE
xtscc inter CRU_new  preci gdppc pop if cla=="marine",  fe level (90) 

//Model 2: FGLS
xtgls inter CRU_new preci gdppc pop i.c_id  if cla=="marine", panels(correlated)  level(90) //marine-international model
*The coefficients returned by these models are similar in both direction and magnitude.


//marine-domestic 
xtreg dom CRU_new  preci gdppc pop if cla=="marine", fe //superior
est store FE
xtreg dom CRU_new  preci gdppc pop  if cla=="marine", re 
est store RE
hausman FE RE, sigmamore

xtscc dom CRU_new  preci gdppc pop yd_* if cla=="marine",  fe level (90) // year dummies should not be added as Multicollinearity issue in the small panel

//Model 1: FE
xtscc dom CRU_new  preci gdppc pop if cla=="marine",  fe level (90) 

//Model 2: FGLS
xtgls dom CRU_new  preci gdppc pop i.c_id if cla=="marine", panels(correlated) level(90) // marine-domestic model
*The coefficients returned by these models are similar in both direction and magnitude.



*Continental (N=21)
//Continental-international 
xtreg inter CRU_new  preci gdppc pop  if cla=="contin", fe //superior
est store FE
xtreg inter CRU_new preci gdppc pop if cla=="contin", re
est store RE
hausman FE RE, sigmamore

xtscc inter CRU_new  preci gdppc pop yd_*  if cla=="contin" ,  fe level (90) // year dummies should not be added as Multicollinearity issue in the small panel

//Model 1: FE
xtscc inter CRU_new  preci gdppc pop  if cla=="contin" ,  fe level (90) 

//Model 2: FGLS
xtgls inter CRU_new preci gdppc pop i.c_id  if cla=="contin", panels(correlated)  level(90) //Continental-international model

*The coefficients returned by these models are similar in both direction and magnitude.

//Continental-domestic 
xtreg dom CRU_new  preci gdppc pop  if cla=="contin", fe  //superior
est store FE
xtreg dom CRU_new  preci gdppc pop if cla=="contin", re
est store RE
hausman FE RE, sigmamore

xtscc dom CRU_new  preci gdppc pop yd_*  if cla=="contin" ,  fe level (90) // year dummies should not be added as Multicollinearity issue in the small panel 

//Model 1: FE
xtscc dom CRU_new  preci gdppc pop  if cla=="contin" ,  fe level (90) 

//Model 2: FGLS
xtgls dom CRU_new  preci gdppc pop i.c_id if cla=="contin", panels(correlated)  level(90) // Continental-domestic model

*The coefficients returned by these models are similar in both direction and magnitude.
