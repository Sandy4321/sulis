# data structures
#
# words_count
# time word1 word2 word3  ...
# 1     20    50    30    ...
# 2     100   60    20    ...
# 3     ...   ...   ...   ...
# 4     ...   ...   ...   ...
# 
# words_usage
# time word1 word2 word3  ...
# 1     low    med  low   ...
# 2     med    med  low   ...
# 3     ...   ...   ...   ...
# 4     ...   ...   ...   ...
# 


# 
# Utility Variables
val1 = factor(c("l","l","l","m","m","m","h","h","h"),levels=c('h','m','l'))
val2 = factor(c("l","m","h","l","m","h","l","m","h"),levels=c('h','m','l'))
cpairs= data.frame(val1,val2)


entries = nrow(data.ts)
window = 12


sentiment.0 = data.ts$sentiment.ts
ncrimes.0 = data.ts$ncrimes
sentcat.0 = data.ts$sentcat
ratecat.0 = data.ts$ratecat

direct.corr = cor.test(sentiment.0,ncrimes.0,alternate="t",method="pearson",conf.level=0.8)
tempdf = data.frame(sentcat.0,ratecat.0)
condprob = vector(mode="numeric")

corr = vector(mode='numeric')
p = vector(mode='numeric')
for (i in 0:window){
  sent = sentiment.0[1:(length(sentiment.0)-i)]
  crimes = ncrimes.0[(i+1):length(ncrimes.0)]
  tempdf = data.frame(sent,crimes)
  tempcor = cor.test(tempdf$sent,tempdf$crimes,alternate="t",method="pearson",conf.level=0.8)
  corr[i+1] = as.numeric(tempcor['estimate'])
  p[i+1] = as.numeric(tempcor['p.value'])
  
}

correlations = data.frame(corr,p)

condprob = vector(mode="numeric")
indprob = vector(mode="numeric")
diff  = vector(mode="numeric")
predictive.conds = list()
for (i in 0:window){
  sent = sentcat.0[1:(length(sentiment.0)-i)]
  rate = ratecat.0[(i+1):length(ncrimes.0)]
  tempdf = data.frame(sent,rate)
  for (j in 1:nrow(cpairs)){
    c = as.factor(cpairs$val1)[j]
    t = as.factor(cpairs$val2)[j]
    pcnt = nrow(subset(tempdf,subset=(tempdf$sent==t & tempdf$rate==c)))/nperiods
    pt = nrow(subset(tempdf,subset=(tempdf$sent==t)))/nperiods
    condprob[j] = pcnt/pt #P(c|t)
    indprob[j] = nrow(subset(tempdf,subset=(tempdf$rate==c)))/nperiods
    diff[j] = condprob[j]-indprob[j]
    
  }
  
  predictive.conds[[i+1]] =data.frame(as.factor(cpairs$val1),as.factor(cpairs$val2),condprob,indprob,diff)
  names(predictive.conds[[i+1]]) = c('c','t','cp','ip','diff')
}


#cleanup workspace
keepvars = c('crimedata','twitterdata','data.ts','start.time','timeslice',
             'nperiods','correlations','predictive.conds','window')

write.csv(correlations, file="correlations.csv")
write.csv(predictive.conds, file="conditionals.csv")

rm(list=setdiff(ls(),keepvars))
