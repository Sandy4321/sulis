# =========================================================================
# Title:        TwitterMiner.R
# Author:       Liam Cusack
# Date:         February, 2014
# Details:  	Tool that formats raw twitter data for analysis
#               
# License:      BSD Simplified License
#               http://www.opensource.org/license/BSD-3-Clause
#               Copyright (c) 2014, Liam Cusack
#               All rights reserved
# =========================================================================

# include libraries
require(twitteR)
require(plyr)

# define "tolower error handling" function 
tryTolower = function(x)
{
	# create missing value
	y = NA
	# tryCatch error
	try_error = tryCatch(tolower(x), error=function(e) e)
	# if not an error
	if (!inherits(try_error, "error"))
	y = tolower(x)
	# result
	return(y)
}

# s is a group of statuses
formatTwitterData = function(s){
	txt = formatStatusText(s)
}

# s is a group of statuses
formatStatusText = function(s){
	txt = sapply(s, function(x) x$getText())
	# remove @s
	txt = gsub("@\\w+", "", txt)
	# remove punctuation
	txt = gsub("[[:punct:]]", "", txt)
	# remove numbers
	txt = gsub("[[:digit:]]", "", txt)
	# remove links
	txt = gsub("http\\w+", "", txt)
	# remove extra spaces
	txt = gsub("[ \t]{2,}", "", txt)
	txt = gsub("^\\s+|\\s+$", "", txt)
	# make everything lower case
	txt = sapply(txt, tryTolower)
	# remove empty entries
	txt = some_txt[!is.na(some_txt)]
	return(txt)
	
}
