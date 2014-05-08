# Variable Descriptions
# 
# 
#General
#	  timeslice - how many hours to use as a time slice
#	  sec.ts - seconds in time slice
#	  alpha - present weight value for exponentially weighted avg
#	  nweight - number of previous samples to include in moving average
#	  nastrings - strings to replace with NA (for data scrubbing)
#	  nperiods - number of periods of size sec.ts in usable data set
#	  positions - temporary variable used to sort dataframes
#	  s - summary class for getting quartiles
#	  q1 - 1st Quartile (25%)
#	  q3 - 3rd Quartile (75%)
#	  time.ts - vector of timestamps corresponding to the beginning of a time slice
#	  start.time - time at which both crime and twitter data are available
#	  stop.time - time when crime and twitter data are no longer both available
#	  data.ts - dataframe for holding time sliced data
#
#Crime data
# 	rawcrimedata - raw data from partially scrubbed csv file with format: "04/12/2014  09:00:00"
# 	ctime - vector of unix timestamps at which times a crime occurred
# 	firstcrime - unix timestamp of first crime data point
# 	lastcrime - unix timestamp of last crime data point
# 	intertime - vector of inter-arrival times of crimes (i.e. ctime[i]-ctime[i-1])
# 	cwma - weighted moving average of crime interarrival time, used to smooth plots
# 	crimedata - dataframe for holding ctime, intertime, and wma or intertime
# 	ncrimes - number of crimes in a sec.ts sized period
# 	crimedata.ts - data frame to hold time and ncrimes
# 
#Twitter data
#	  rawtwitterdata - raw data from partially scrubbed csv file with format ...(time, sentiment)
#	  ttime - vector of timestamps where tweets were recieved
#	  sentiment - vector of sentiment values for all tweets
#   twma - twitter sentiment weighted moving average
#	  twitterdata - dataframe to store ttimes and sentiments
#	  low/med/hisent[.ts] - subset of twitterdata where sentiment is high for each tweet, and (.ts) for each time slice
#	  l,m,h - character vectors filled with their respective letters
#		  to give categorical sentiment values to each tweet (low medium and high respectively)
#	  sentcat - character vector with categorical sentiment values
#	  sentiment.ts - vector of sentiment values for time slices
#	  sentcat.ts - char vector with categorical sentiment values for time slices
twitter.data.file.name = "/home/bigshawn/sulis/data/tweets-formatted.csv"
crime.data.file.name = "/home/bigshawn/sulis/data/rawcrimedata.csv"
timeslice = 1 #hours
sec.ts=60*60*timeslice
talpha = 0.2 #ema present value
calpha = 0.1
cnweight = 30
tnweight = 300
nastrings = c("","NA","Critical Error","Error 440: Invalid String Length (too long or too short)")


######################################################################################
# Crime Data Import
rawcrimedata=read.csv(crime.data.file.name,header=FALSE,sep=",")
rawcrimedata = rawcrimedata$V1

ctime = vector(mode = "numeric",length = length(rawcrimedata))
ctime = as.numeric(strptime(rawcrimedata,format="%m/%d/%Y\t%H:%M:%S",tz="EST"))

positions = order(ctime,decreasing=FALSE)
ctime = ctime[positions]
firstcrime = min(ctime)
lastcrime = max(ctime)

intertime = vector(mode = "numeric", length = length(rawcrimedata))
intertime[0]=0
for (i in 2:length(rawcrimedata)){
  intertime[i] = ctime[i]-ctime[i-1]
}

#weighted moving average
cwma = vector(mode = "numeric", length = length(rawcrimedata))
cwma[0]=intertime[0]
for (i in 2:length(rawcrimedata)){
  cwma[i] = mean(intertime[(i-min(i,cnweight)):i])
  #cwma[i] = calpha*intertime[i]+(1-calpha)*cwma[i-1]
} 
#plot(ctime, cwma, type="l") #for debugging

crimedata = data.frame(ctime,intertime,cwma)


####NOTE####
#high crime rate will be the first quartile (low interarrival times=> high crime rate)
s = summary(crimedata$intertime)
q1 = s['1st Qu.']
q3 = s['3rd Qu.']

hirate = subset(crimedata,subset=(crimedata$intertime<=q1))
hirate$ratecat[1:nrow(hirate)] = "l"

medrate = subset(crimedata,subset=(crimedata$intertime>q1 & crimedata$intertime<=q3))
medrate$ratecat[1:nrow(medrate)] = "m"

lowrate  = subset(crimedata,subset=(crimedata$intertime>q3))
lowrate$ratecat[1:nrow(lowrate)] = "h"

crimedata = rbind(lowrate,medrate,hirate)
positions = order(crimedata$ctime,decreasing=FALSE)
crimedata = crimedata[positions,]
######################################################################################

######################################################################################
# Twitter Sentiment Data Import
rawtwitterdata=read.csv(twitter.data.file.name,header=FALSE,sep=",",quote="",fill=TRUE,strip.white=TRUE,na.strings=nastrings)
ttime = rawtwitterdata$V1
#ttime = as.numeric(rawtwitterdata$V1)
sentiment = as.numeric(rawtwitterdata$V2)

twitterdata = data.frame(ttime,sentiment)
twitterdata = subset(twitterdata,subset=(!is.na(twitterdata$sentiment) & !is.na(twitterdata$ttime)))

firsttweet = min(twitterdata$ttime)
lasttweet = max(twitterdata$ttime)

positions = order(twitterdata$ttime,decreasing=FALSE)
twitterdata = twitterdata[positions,]

s = summary(twitterdata$sentiment)
q1 = s['1st Qu.']
q3 = s['3rd Qu.']

lowsent = subset(twitterdata,subset=(twitterdata$sentiment<q1))
lowsent$sentcat[1:nrow(lowsent)] = "l"

medsent = subset(twitterdata,subset=(twitterdata$sentiment>=q1 & twitterdata$sentiment<=q3))
medsent$sentcat[1:nrow(medsent)] = "m"

hisent  = subset(twitterdata,subset=(twitterdata$sentiment>q3))
hisent$sentcat[1:nrow(hisent)] = "h"

twitterdata = rbind(lowsent,medsent,hisent)
positions = order(twitterdata$ttime,decreasing=FALSE)
twitterdata = twitterdata[positions,]

#weighted moving average
twma = vector(mode = "numeric", length = nrow(twitterdata))
twma[0]=twitterdata$sentiment[0]
for (i in 2:nrow(twitterdata)){
  #twma[i] = mean(twitterdata$sentiment[(i-min(i,tnweight)):i])
  twma[i] = talpha*twitterdata$sentiment[i]+(1-talpha)*twma[i-1]
} 
twitterdata$twma = twma
#plot(twitterdata$ttime,twitterdata$twma,type="l")

####################################################################################

#setup time slices
start.time = max(firsttweet,firstcrime)
stop.time = min(lasttweet,lastcrime)
nperiods = ceiling((stop.time-start.time)/sec.ts)
time = vector(mode="numeric",length=nperiods)
t0=start.time
for(i in 1:nperiods){
  time[i]=t0
  t1=t0+sec.ts
  t0=t1
}
twitterdata = subset(twitterdata,subset=(twitterdata$ttime>=start.time & twitterdata$ttime<=stop.time))
crimedata = subset(crimedata,subset = (crimedata$ctime>=start.time & crimedata$ctime<=stop.time))
########################################################################################
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
q1.ts = as.numeric(s.ts['1st Qu.'])
q3.ts = as.numeric(s.ts['3rd Qu.'])

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
q1.ts = as.numeric(s.ts['1st Qu.'])
q3.ts = as.numeric(s.ts['3rd Qu.'])

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

# 
# 
# 
# Write data to files
write.csv(crimedata, file="crimedataoutput.csv")
write.csv(twitterdata, file="twitterdataoutput.csv")
write.csv(data.ts, file="tsdataoutput.csv")
