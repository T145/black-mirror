import twint
import sys
sys.dont_write_bytecode = True

# might be "shadow-banned" for being a bot,
# therefore Profile is needed
c = twint.Config()
c.Hide_output = True
c.Username = "Certego_Intel"
c.Since = "2021-1-1"
c.Store_object = True
c.Store_json = True
c.Output = "tweets.json"
twint.run.Profile(c)