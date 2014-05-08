
stop.time = start.time+nperiods*timeslice*60*60
nevents = nrow(crimedata)
ntweets = nrow(twitterdata)
tweets.per.event = floor(ntweets/nevents)


s = summary(twitterdata$sentiment)
q1 = s['1st Qu.']
q3 = s['3rd Qu.']

lowsent = subset(twitterdata,subset=(twitterdata$sentiment<q1))

low.num = nrow(lowsent)
low.times = vector(mode="numeric")
low.sent = vector(mode="character")
i=tweets.per.event
j=1
while(i<=low.num){
  i=min(low.num,i)
  low.times[j] = lowsent$ttime[i]
  low.sent[j] = "l"
  i=i+tweets.per.event
  j=j+1
}

medsent = subset(twitterdata,subset=(twitterdata$sentiment>=q1 & twitterdata$sentiment<=q3))

med.num = nrow(medsent)
med.times = vector(mode="numeric")
med.sent = vector(mode="character")
i=tweets.per.event
j=1
while(i<=med.num){
  i=min(med.num,i)
  med.times[j] = medsent$ttime[i]
  med.sent[j] = "m"
  i=i+tweets.per.event
  j=j+1
}

hisent = subset(twitterdata,subset=(twitterdata$sentiment>q3))

hi.num = nrow(hisent)
hi.times = vector(mode="numeric")
hi.sent = vector(mode="character")
i=tweets.per.event
j=1
while(i<=hi.num){
  i=min(hi.num,i)
  hi.times[j] = hisent$ttime[i]
  hi.sent[j] = "h"
  i=i+tweets.per.event
  j=j+1
}

time = c(low.times,med.times,hi.times)
sent = c(low.sent,med.sent,hi.sent)

events = data.frame(time,sent)


positions = order(events$time,decreasing=FALSE)
events = events[positions,]

write.csv(events, file="events.csv",row.names=FALSE)

#cleanup workspace
keepvars = c('crimedata','twitterdata','data.ts','start.time','timeslice',
             'nperiods','predictive.corrs','direct.corr','predictive.conds',
             'direct.cond','window')
rm(list=setdiff(ls(),keepvars))
