data <- read.csv('ATPW70.csv')

## Dependent variables
#share
data$share <- (data$SHAREINFO1_a_W70+data$SHAREINFO1_b_W70)
data$share<-ifelse(data$share>8,NA,data$share)
unique(data$share)
table(data$share)
hist(data$share)

#speak
data$speak <- ifelse(is.na(data$CONTACTHOMEF2_W70), data$CONTACTPHONEF1_W70, data$CONTACTHOMEF2_W70)
data$speak<-ifelse(data$speak>8,NA,data$speak)
table(data$speak)

#con_trac_engage
data$con_trac_engage <- data$speak+data$share

#Quarantine
data$quarantine <- ifelse(is.na(data$HEALTHRECF1_W70),data$HEALTHRECF2_W70,data$HEALTHRECF1_W70)
data$quarantine<-ifelse(data$quarantine>8,NA,data$quarantine)

#Independent variables
# Religious engagement
data$ATTENDMONTH<-ifelse(data$ATTENDMONTH==99,NA,data$ATTENDMONTH)
data$ATTENDONLINE<-ifelse(data$ATTENDONLINE==99,NA,data$ATTENDONLINE)
data$religious<-ifelse(data$ATTENDMONTH==1 | data$ATTENDONLINE==1,1,
                       ifelse(is.na(data$ATTENDMONTH)& is.na(data$ATTENDONLINE),NA,0))
table(data$religious)
summary(data$religious)

# social media usage
data$smedia <- ifelse(data$SNSUSE_W7==1,1,
                    ifelse(data$SNSUSE_W7==2,0,NA))
table(data$smedia)

# Knowledge of contact tracing
data$ctknow <- ifelse(data$CTKNOW1_W70==99,NA,data$CTKNOW1_W70)
table(data$ctknow)

# Trust in health organization
data$horgtrust<-ifelse(data$RECSAFE_a_W70==99,NA,data$RECSAFE_a_W70)
table(data$horgtrust)

# Trust in government
data$govtrust <- ifelse(data$RECSAFE_d_W70==99,NA,data$RECSAFE_d_W70)
table(data$govtrust)

# Party affiliation
data$party <- ifelse(data$PARTY_W70==1,1,
                     ifelse(data$PARTY_W70==2,0,
                            ifelse(data$PARTYLN_W70==1,1,
                                   ifelse(data$PARTYLN_W70==2,0,NA))))
unique(data$party)
table(data$party)

#combine all columns into new data
data1 <- na.omit(data[,c('speak','share','con_trac_engage','quarantine',
                         'religious','smedia','ctknow','horgtrust','govtrust','party')])

## DESCRIPTIVE STATISTICS
# descriptive statistics
attach(data)
summary(quarantine)
summary(con_trac_engage)
summary(religious)
summary(smedia)
summary(ctknow)
summary(horgtrust)
summary(govtrust)
summary(party)
hist(horgtrust)
hist(govtrust)
detach(data)

attach(data1)
sd(quarantine)
sd(con_trac_engage)
sd(religious)
sd(smedia)
sd(ctknow)
sd(horgtrust)
sd(govtrust)
sd(party)
detach(data1)

# correlation between variables
round(cor(as.matrix(data1[,c("con_trac_engage",
                          "quarantine",
                          "religious",
                          "smedia",
                          "ctknow",
                          "govtrust",
                          "party")]), use = "complete"), 4)
install.packages("corrplot")
install.packages("scico")
library(corrplot)
library(scico)
corrplot(cor(as.matrix(data1[,c("con_trac_engage",
                             "quarantine",
                             "religious",
                             "smedia",
                             "ctknow",
                             "govtrust",
                             "party")]), use = "complete"),
         col = scico(200, palette = "vik", direction = -1),
         tl.col = "black")

##BASIC REGRESSION MODEL
# Original models
lm_quarantine<-lm(quarantine~religious+smedia+ctknow+govtrust+party)
summary(lm_quarantine)

par(mfcol=c(2,2))
plot(lm_quarantine)

lm_con_tracing<-lm(con_trac_engage~religious+smedia+ctknow+govtrust+party)
summary(lm_con_tracing)
plot(lm_con_tracing)

library(stargazer)
stargazer(lm_quarantine,lm_con_tracing,title="Table 4. Original Models",align=TRUE,type="html",out="model.doc")

## Lm model
attach(data1)

# quarantine lm
res <- lm(quarantine~religious + smedia + ctknow  + govtrust + party+ horgtrust)
summary(res) 
plot(res)

# lm1
lm1 <- lm(con_trac_engage~ religious + smedia + ctknow  + govtrust + party)
summary(lm1) 
plot(lm1)
AIC(lm1)

# lm2
lm2 <- lm(con_trac_engage~ religious + smedia + ctknow  + govtrust + horgtrust+ party)
summary(lm2)
plot(lm2)
AIC(lm2)

# lm3
lm3<- lm(con_trac_engage~ smedia + cctknow + chorgtrust + cgovtrust + party*religious)
summary(lm3)
plot(lm3)
AIC(lm3)

# lm3 center
lm3<- lm(con_trac_engage~ smedia + cctknow + chorgtrust + cgovtrust+party+religious)
summary(lm3)
plot(lm3)
AIC(lm3)

##ASSUMPTIONS DIAGNOSE OF ORIGINAL REGRESSION MODEL

# linearity
myvars <- c("con_trac_engage", "ctknow","govtrust")
newdata <- data1[myvars]
pairs(newdata,panel=panel.smooth)
png('corr.png', width = 6, height = 4, units = 'in', res=400)
dev.off()

library(car)
png('ctknow.png', width = 4, height = 4, units = 'in', res=400)
scatterplot(con_trac_engage ~ ctknow, 
            data = data1,
            boxplots = F,
            grid = F,
            jitter = list(x = 1),
            col = rgb(0,0,0,.25),
            pch = 16,
            cex = .5,
            regLine = list(method = lm,
                           lty = 1,
                           lwd = 2,
                           col = 1),
            smooth = list(method = loess,
                          spread = T,
                          lty.smooth = 2,
                          lwd.smooth = 2,
                          col.smooth = "red",
                          lty.spread = 3,
                          lwd.spread = 2,
                          col.spread = "red"))
dev.off()

png('govtrust.png', width = 4, height = 4, units = 'in', res=400)
scatterplot(con_trac_engage ~ govtrust, 
            data = data1,
            boxplots = F,
            grid = F,
            jitter = list(x = 1),
            col = rgb(0,0,0,.25),
            pch = 16,
            cex = .5,
            regLine = list(method = lm,
                           lty = 1,
                           lwd = 2,
                           col = 1),
            smooth = list(method = loess,
                          spread = T,
                          lty.smooth = 2,
                          lwd.smooth = 2,
                          col.smooth = "red",
                          lty.spread = 3,
                          lwd.spread = 2,
                          col.spread = "red"))
dev.off()


## Homoskedasticity
png('Homoskedasticity.png', width = 5, height = 4, units = 'in', res=400)
scatterplot(x = fitted(lm1), 
            y = resid(lm1),
            main = "Figure 5. Residuals vs Fitted, model 1",
            boxplots = F,
            grid = F,
            col = rgb(0,0,0,.5),
            pch = 16,
            cex = .5,
            regLine = F,
            smooth = list(method = loess,
                          spread = T,
                          lty.smooth = 2,
                          lwd.smooth = 2,
                          col.smooth = "red",
                          lty.spread = 3,
                          lwd.spread = 2,
                          col.spread = "red"))
dev.off()

png('Homoskedasticity2.png', width = 6, height = 4, units = 'in', res=400)
scatterplot(x = fitted(lm1), 
            y = abs(resid(lm1)),
            main = "Figure 6. Abs value of Residuals vs Fitted, model 1",
            boxplots = F,
            grid = F,
            col = rgb(0,0,0,.5),
            pch = 16,
            cex = .5,
            regLine = list(method = lm,
                           lty = 1,
                           lwd = 2,
                           col = 1),
            smooth = list(method = loess,
                          spread = T,
                          lty.smooth = 2,
                          lwd.smooth = 2,
                          col.smooth = "red",
                          lty.spread = 3,
                          lwd.spread = 2,
                          col.spread = "red"))
dev.off()
## Normality of Residuals
par(mfcol=c(1,2))
hist(resid(lm1), border = "white", main = "Figure 7.Histogram of model 1 residuals", breaks = 100)
plot(lm1, which = 2, main = "Figure 8.Q-Q Plot of model 1 residuals")

## MODEL ITERATION
# omitted var
cor.test(horgtrust, religious, use = "complete.obs")
cor.test(horgtrust, party, use = "complete.obs")
cor.test(horgtrust, govtrust, use = "complete.obs")
cor.test(horgtrust, smedia, use = "complete.obs")
cor.test(horgtrust, ctknow, use = "complete.obs")

lmh<- lm(con_trac_engage~ horgtrust )
summary(lmh)
stargazer(lmh, type="html", title = "Table 6.Regression Results of Omitted Relevant Variable", align = TRUE ,out = 'lmh.html' )


## outlier
par(mfcol=c(1,2))
plot(lm2, main = "Figure 9.Cook's distance, model 2", which = 4)
plot(lm2, main = "Figure 10.Residuals vs Leverage, model 2", which = 5)
kable(data1[c(2451, 7916, 9331), c('speak','share','con_trac_engage','quarantine',
                                   'religious','smedia','ctknow','horgtrust','govtrust','party')],
      type="html")

data2 <- data1[c(2451, 7916, 9331), c('speak','share','con_trac_engage','quarantine',
                                      'religious','smedia','ctknow','horgtrust','govtrust','party')]

data3 <- data1[c(-2454, -7939, -9359), c('speak','share','con_trac_engage','quarantine',
                                      'religious','smedia','ctknow','horgtrust','govtrust','party')]
attach(data3)

plot(lm1, which = 2, main = "Figure Residuals vs Fitted, model 1")

## Diagnosis improvement
par(mfcol=c(1,2))
plot(lm1, which = 1, main = "Figure 11. Residuals vs Fitted, model 1")
plot(lm1, which = 2, main = "Figure 13. Q-Q Plot of residuals, model 1")
plot(lm1, which = 5, main = "Figure 15. Residuals vs Leverage, model 1")
plot(lm3, which = 1, main = "Figure 12. Residuals vs Fitted, model 3")
plot(lm3, which = 2, main = "Figure 14. Q-Q Plot of residuals, model 3")
plot(lm3, which = 5, main = "Figure 16. Residuals vs Leverage, model 3")

# stargazer lm models
stargazer(lm1,lm2,lm3, type="html", title = "Table 8.Regression Results, Model 1, 2, 3", align = TRUE ,out = '3 models.html' )
library(stargazer)

# center variable
data1$cctknow <- data1$ctknow-mean(data1$ctknow)
data1$chorgtrust  <- data1$horgtrust -mean(data1$horgtrust)
data1$cgovtrust   <- data1$govtrust  -mean(data1$govtrust)

#interaction plot
par(mfcol=c(1,1))
data1plot <- data1[, c('con_trac_engage',
                       'religious','smedia','ctknow','horgtrust','govtrust','party')]
data1plot$smedia <- 0
data1plot$ctknow <- 0
data1plot$horgtrust <- 0
data1plot$govtrust <- 0

data1plot$fit<-predict(lm3,data1plot)
data1plot$party<-factor(data1plot$party, levels=c(0,1), 
                        labels=c("Democrat","Republican")) 

png('interaction plot.png', width = 7, height = 4, units = 'in', res=400)
with(data1plot[!is.na(data1plot$party) &
                 !is.na(data1plot$religious) &
                 !is.na(data1plot$con_trac_engage),],
     interaction.plot(x.factor=factor(religious),
                      trace.factor = factor(party),
                      response = con_trac_engage,
                      xlab="Religious engagement(0~no, 1~yes)",
                      ylab="Contact tracing willingness",
                      main="Fugure 17. Interaction between Party and Religious",
                      col=c("orange","blue"),
                      trace.label = "Party",
                      lwd = 4))

dev.off()





