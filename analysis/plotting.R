sentiment = data.ts$sentiment
#for (i in 1:length(sentiment)){
#  sentiment[i] = ((sentiment[i]-min(sentiment))/(max(sentiment)-min(sentiment))-0.5)*30
#}
ncrimes = data.ts$ncrimes
time = data.ts$time

par(mar=c(5,4,4,4))
plot(time,sentiment,type="l",pch=1,col=3,xlab="Timestamp",ylab="",main="Total Sentiment vs Crime Rate")
mtext("sentiment",side=2,line=2,col=3)
abline(lm(sentiment~I(1:length(sentiment))),col=3)
par(new=T)
plot(time,ncrimes,type="l",axes=F,xlab="",ylab="",pch=2,col=4)
axis(side=4)
abline(lm(ncrimes~I(1:length(ncrimes))),col=4)
mtext("crime rate",side=4,line=2,col=4)

if(FALSE){
intertime = crimedata$intertime
ctime = crimedata$ctime
sentiments = twitterdata$sentiment
ttime = twitterdata$ttime

par(mar=c(5,4,4,4))
plot(ttime,sentiments,type="l",pch=1,col=3,xlab="Timestamp",ylab="",main="Sentiment vs Crime Interarrival (absolute)")
mtext("sentiment",side=2,line=2,col=3)
abline(lm(sentiments~I(1:length(sentiments))),col=3)
par(new=T)
plot(ctime,intertime,type="l",axes=F,ylim=c(-20000:20000),xlab="",ylab="",pch=2,col=4)
axis(side=4)
abline(lm(intertime~I(1:length(intertime))),col=4)
mtext("crime interarrival time",side=4,line=2,col=4)
}


#cleanup workspace
keepvars = c('crimedata','twitterdata','data.ts','start.time','timeslice',
             'nperiods','predictive.corrs','direct.corr','predictive.conds',
             'direct.cond','window')
rm(list=setdiff(ls(),keepvars))