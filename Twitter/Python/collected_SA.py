import urllib2
import urllib
import csv
import time

sentdexAuth = '[INSERT SENTDEX AUTH]'

text = open('baltimore_tweets.txt', 'r')

try:
	for line in text:
		full = line
	    tweet = line.split('::')[1]
	    encoded_text = urllib.quote(tweet)
	    API_Call = 'http://sentdex.com/api/api.php?text='+encoded_text+'&auth='+sentdexAuth
	    output = urllib2.urlopen(API_Call).read()
	    SaveMe = full + '::' + output + '\n'
	    print SaveMe
	    sulis = open('collected_SA.csv', 'a')
	    sulis.write(SaveMe)
	    sulis.close()
	    time.sleep(0.1)


