setwd('C:\\Users\\maria\\Desktop\\Statistics Project')
getwd()

library(readxl)
abstention_election <- read_excel("Group18_Dataset.xlsx", sheet = 'R_Dataset')
View(abstention_election)
attach(abstention_election)


#RESEARCH QUESTION: 

#'What were the drivers of abstention in the portuguese presidential elections of 2021?'
#After the fervor at the beginning of the democratic regime, are the Portuguese taking democracy for granted? 
#Since voting is one of the ultimate symbols of democracy, and since it is the only way for citizens to express 
#the direction they want society to take, would be expected that most citizens would take to the streets to vote. 
#However, in Portugal, abstention continues to reach very considerable levels.
#To make matters worse, there is the Covid-19 pandemic, forcing many citizens to stay at home. 
#In order to get around this situation, measures were taken ''The electoral administration took several measures (...) 
#which include early voting in mobility (...), an exceptional regime of early voting (...) , the reinforcement of polling stations (...)'',
# so that the situation would not be catastrophic.
#However, ''More than 60% of voters did not go to the polls, more than in any presidential election (...)''
#Is Covid-19's incidence related to abstention in the 2019 Presidential Elections, or are there other factors 
#that caused people not to go to vote?
#This study will focus on the main factors driving the abstention rate in the Portuguese’s 2021 Presidential Elections, 
#considering the pandemic situation and socio-demographic aspects of each municipality.
#To find out, a cross-sectional analysis was performed on the abstention rate, against several variables.

#METHODOLOGY

#Data on the abstention rate in the different regions in Portugal in 2021 was collected through "Pordata".
#In addition, we also collected data on the various factors that through research could have the most effect on the 
#abstention rate, such as the number of accumulated covid cases per 100k Inhabitants; levels of education; annual average 
#of unemployed people per region and the percentage of adults and women per region.
#It is important to note that it was verified a priori that there were no missing values.
#Moreover 
# Moreover the normality of the residuals was analysed using the QQ plot, and the Durbin-Watson test was performed to detect 
#the presence of autocorrelation in the residuals of a regression.
#Finally, it was performed the Breusch-Pagan and White Special tests to check for heteroskedasticity and it was also checked for 
#misspecification, using the Reset test.



#CORRELATION
cor(abstention_election)
 
#abs and adults: -0.201034041
#covid_incidence e abs: 0.16309349
 
#low_educ e avg_unemployed:0.943342583
#med_educ e avg_unemployed:0.950864290
#high_educ e avg_unemployed:: 0.917907302
#med_educ e low_educ: 0.973497829
#high_educ e low_educ:0.856755962
#high_educ e med_educ:0.89583347


#Graphics
library(ggplot2)

ggplot(abstention_election,aes(x=adults, y=log_abs)) +
  geom_point() +
  geom_smooth(method='lm', se=FALSE) +
  theme_minimal()


ggplot(abstention_election,aes(x=covid_incidence, y=log_abs)) +
  geom_point() +
  geom_smooth(method='lm', se=FALSE) +
  theme_minimal()                #log transformation on covid_incidence



ggplot(abstention_election,aes(x=avg_unemployed, y=log_abs)) +
  geom_point() +
  geom_smooth(method='lm', se=FALSE) +
  theme_minimal()



ggplot(abstention_election,aes(x=women, y=log_abs)) +
  geom_point() +
  geom_smooth(method='lm', se=FALSE) +
  theme_minimal()


ggplot(abstention_election,aes(x=low_educ, y=log_abs)) +
  geom_point() +
  geom_smooth(method='lm', se=FALSE) +
  theme_minimal()


ggplot(abstention_election,aes(x=med_educ, y=log_abs)) +
  geom_point() +
  geom_smooth(method='lm', se=FALSE) +
  theme_minimal()


ggplot(abstention_election,aes(x=high_educ, y=log_abs)) +
  geom_point() +
  geom_smooth(method='lm', se=FALSE) +
  theme_minimal()



#Preliminary models

summary(lm(log_abs ~ covid_incidence + women + adults + avg_unemployed + low_educ +
             med_educ + high_educ, data=abstention_election))   #without transformation

#if p<0.05 we reject the null hypothesis, so the variables 'covid_incidence' and 'adults' are statistically significant.


summary(lm(log_abs ~ log(covid_incidence + 1) + women + adults + avg_unemployed + low_educ +
             med_educ + high_educ, data=abstention_election)) #com transformação. metemos +1 porque temos valor a zero

#After considering the results, it can be seen that the first model has a significant p-value 
#at 5% (0.01521), making it possible to state that the model is overall significant.
#Additionally, the variable 'women' was removed from the model, since it is not significant and 
#therefore not relevant for analysis.


#RESULTS

#According to the results obtained by applying a Multiple Linear Regression Model containing all the initial variables, 
#the ones related with education and gender are not statistically significant. Simultaneously, these are the variables 
#less correlated with the dependent variable. Hence, a second MLR model was tested excluding the variable women from the model.
#The variables concerning education were maintained. 
#The second model considered covid incidence and adults to be statistically significant at a, 5% and 1%, respectively, significance 
#levels. Moreover, it was possible to conclude that if the number of accumulated cases in Last 14 Days per 100k Inhabitants increases by 1, 
#it is expected for the abstention rate to increase by 0.000728%, ceteris paribus. Additionally, if an individual is between 18 and 64 years old, 
#it is expected to vote 13.84% more times than an elderly person, holding other factors constant.
#Aiming to verify the presence of heteroskedasticity and the evidence of functional form misspecification, the White Special test, and Reset 
#Test were performed. In both tests, p-value was higher than 5%, thus not rejecting the null hypothesis, meaning that there is not 
#evidence of heteroskedasticity, and the model is well specified.
#Regarding the normality test, and after observing the graph, it is possible to conclude that residuals follows a normal distribution.
#From the output of the Durbin-Watson we can see that the test statistic is 1.97 and the corresponding p-value is 0.024 Since this p-value is less 
#than 0.05, we can reject the null hypothesis and conclude that the residuals in this regression model are autocorrelated.


#Candidate model


reg2 <- (lm(log_abs ~ covid_incidence + adults + avg_unemployed + low_educ +
              med_educ + high_educ, data=abstention_election))  

summary(reg2)


#Breusch-Pagan Test

library(lmtest)
bptest(reg2)

#White special
bptest(reg2, ~ I(fitted(reg2)) + I(fitted(reg2)^2))
summary(lm(resid(reg2)^2 ~ I(fitted(reg2)) + I(fitted(reg2)^2)) )   
#the null is reject at 5% of significance level, therefore, there is no evidence of heteroskedasticity



#RESET test
reset(reg2) #don't reject 



#Testing the normality of the residuals
residuals = resid(reg2)
qqnorm(residuals) #So we can see that we have approximately a normal distribution of the residual


#Checking the correlation of the residuals
library(car)
library(caTools)

durbinWatsonTest(residuals)
1-pnorm(1.973911) #p-value
#Reject the null hypothesis meaning that the errors are autocorrelated.

#H0 (null hypothesis): There is no correlation among the residuals.
#H1 (alternative hypothesis): The residuals are autocorrelated


#CONCLUSION
#According to the results of the different tests performed, it was concluded that the variables ‘adults’ and ‘covid_incidence’ 
#were important explanatory factors of the abstention rate in the Portuguese Presidential Elections of 2021. Additionally, as 
#age and covid incidence increases the Abstention Rate will also increase. Therefore, in this case the correlation between 
#both variables explain an association and they do not represent, spurious correlations.
#It is also important to highlight that most variables are irrelevant for this study case in particular. Simultaneously, there 
#were some limitations regarding the choice of the variables to include in the model due to lack of data availability for the year. 
#Finally, aiming to improve the abstention rate results in Portugal, it would be interesting to develop awareness campaigns among the 
#oldest populations, while creating mechanisms which facilitate the voting process for these people. 


#REFERENCES
#1.
#Rodrigues, S. (2021) Abstenção Bate recorde mas não chega a cenário catastrofista, PÚBLICO. Público. 
#Available at: https://www.publico.pt/2021/01/24/politica/noticia/abstencao-bate-recorde-607-nao-chega-cenario-catastrofista-1947740

#2.
#Portugal.gov.pt (no date) Medidas para as Eleições Presidenciais em Pandemia, XXII Governo - República Portuguesa. 
#Available at: https://www.portugal.gov.pt/pt/gc22/comunicacao/noticia?i=medidas-para-as-eleicoes-presidenciais-em-pandemia




