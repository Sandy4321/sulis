# =========================================================================
# Title:        TwitterMiner.R
# Author:       Liam Cusack
# Date:         February, 2014
# Details:  	Tool for collecting twitter data from baltimore
#               
# License:      BSD Simplified License
#               http://www.opensource.org/license/BSD-3-Clause
#               Copyright (c) 2014, Liam Cusack
#               All rights reserved
# =========================================================================

# include libraries
require(twitteR)
require(plyr)

getTwitterData = function(keyword){
	# get english tweets including keyword
	statuses = searchTwitter(keyword, n=500, lang="en",sinceID = NULL, geocode="39.312957, -76.618119, 10km",retryOnRateLimit=10)
	return(statuses)
}
# searchTwitter details:
#   sinceID: save max tweet id from previous search, 
#     use as parameter for next search
#   Usage
#		searchTwitter(searchString, n=25, lang=NULL, since=NULL, until=NULL,
#			locale=NULL, geocode=NULL, sinceID=NULL,
#			retryOnRateLimit=120, ...)
#
#
# getCurRateLimitInfo details
#	getCurRateLimitInfo(resources="statuses")
#	option for more parameters to cURL

twitterMiner = function(){
	neg = readLines("negative_words.txt")
	for(ii in neg){
		statuses=getTwitterData(ii)
		twitterdata
	}
	
}


