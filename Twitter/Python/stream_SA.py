from tweepy import Stream
from tweepy import OAuthHandler
from tweepy.streaming import StreamListener
import time
import urllib

ckey = '[INSERT TWITTER CONSUMER KEY]'
csecret = '[INSERT TWITTER CONSUMER SECRET]'
atoken = '[INSERT TWITTER ACCESS TOKEN]'
asecret = '[INSERT TWITTER ACCESS SECRET]'

sentdexAuth = '[INSERT SENTDEX AUTH]'

def sentimentAnalysis(text):
    encoded_text = urllib.quote(text)
    API_Call = 'http://sentdex.com/api/api.php?text='+encoded_text+'&auth='+sentdexAuth
    output = urllib.urlopen(API_Call).read()

    return output

class listener(StreamListener):

    def on_data(self, data):
    	try:
        	#print data

        	tweet = data.split(',"text":"')[1].split('","source')[0]
        	sentimentRating = sentimentAnalysis(tweet)


        	saveMe = str(time.time()) + '::' + tweet + '::' + sentimentRating +'\n'
        	output = open('tweets_with_SA.csv', 'a')
        	output.write(saveMe)
        	output.close()
        	return True
        except BaseException, e:
        	print 'failed on data,', str(e)
        	time.sleep(5)

    def on_error(self, status):
        print status

auth = OAuthHandler(ckey, csecret)
auth.set_access_token(atoken, asecret)
twitterStream = Stream(auth, listener())
twitterStream.filter(locations=[-76.82,39.20, -76.37,39.42])