twitter.data.file.name = "twitterdataoutput.csv"
crime.data.file.name = "crimedataoutput.csv"
twitterdata=read.csv(twitter.data.file.name,sep=",",quote="",fill=TRUE,strip.white=TRUE,col.names=c('n','ttime','sentiment','sentcat','twma'))
crimedata=read.csv(crime.data.file.name,sep=",")

#setup time vector
timeslice = 8 #hours
sec.ts=60*60*timeslice
start.time = max(min(twitterdata$ttime), min(crimedata$ctime))
stop.time = min(max(twitterdata$ttime), max(crimedata$ctime))
nperiods = ceiling((stop.time-start.time)/sec.ts)
time = vector(mode="numeric",length=nperiods)
t0=start.time
for(i in 1:nperiods){
  time[i]=t0
  t1=t0+sec.ts
  t0=t1
}

#Sum crime over time slices
ncrimes= vector(mode="numeric",length=nperiods)
t0 = start.time
for(i in 1:nperiods){
  ncrimes[i]=nrow(subset(crimedata,subset=(crimedata$ctime<(time[i+1]) & crimedata$ctime>=(time[i]))))/timeslice
}

# Sum sentiment over time slice

sentiment.ts = vector(mode="numeric",length=nperiods)
t0 = start.time
for(i in 1:nperiods){
  sentiment.ts[i] = sum(as.numeric(subset(twitterdata,subset=(twitterdata$ttime<(time[i+1]) & twitterdata$ttime>=(time[i])),select="sentiment")$sentiment))
}

data.ts = data.frame(time,sentiment.ts,ncrimes)

#categorize sentiment in time slices
s.ts = summary(data.ts$sentiment.ts)
q1.ts = s.ts['1st Qu.']
q3.ts = s.ts['3rd Qu.']

lowsent.ts = subset(data.ts,subset=(data.ts$sentiment.ts<q1.ts))
lowsent.ts$sentcat[1:nrow(lowsent.ts)] = "l"

medsent.ts = subset(data.ts,subset=(data.ts$sentiment.ts>=q1.ts & data.ts$sentiment.ts<=q3.ts))
medsent.ts$sentcat[1:nrow(medsent.ts)] = "m"

hisent.ts  = subset(data.ts,subset=(data.ts$sentiment.ts>q3.ts))
hisent.ts$sentcat[1:nrow(hisent.ts)] = "h"

data.ts = rbind(lowsent.ts,medsent.ts,hisent.ts)
positions = order(data.ts$time,decreasing=FALSE)
data.ts = data.ts[positions,]
data.ts$sentcat = factor(data.ts$sentcat, levels=c('h','m','l'))

#categorize crime rate in time slices
####NOTE####
#high crime rate will be the first quartile (low interarrival times=> high crime rate)
s.ts = summary(data.ts$ncrimes)
q1.ts = s.ts['1st Qu.']
q3.ts = s.ts['3rd Qu.']

hirate.ts = subset(data.ts,subset=(data.ts$ncrimes<q1.ts))
hirate.ts$ratecat[1:nrow(hirate.ts)] = "l"

medrate.ts = subset(data.ts,subset=(data.ts$ncrimes>=q1.ts & data.ts$ncrimes<=q3.ts))
if(nrow(medrate.ts)!=0) {medrate.ts$ratecat[1:nrow(medrate.ts)] = "m"}

lowrate.ts  = subset(data.ts,subset=(data.ts$ncrimes>q3.ts))
lowrate.ts$ratecat[1:nrow(lowrate.ts)] = "h"

data.ts = rbind(lowrate.ts,medrate.ts,hirate.ts)
positions = order(data.ts$time,decreasing=FALSE)
data.ts = data.ts[positions,]
data.ts$ratecat = factor(data.ts$ratecat, levels=c('h','m','l'))



# clean up workspace

keepvars = c('crimedata','twitterdata','data.ts','start.time','timeslice','nperiods')
rm(list=setdiff(ls(),keepvars))

write.csv(data.ts, file="tsdataoutput.csv")
