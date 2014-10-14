# Hue Proxy

This is a ruby reimplementation of [jarvisinc/PhilipsHueRemoteAPI](https://github.com/jarvisinc/PhilipsHueRemoteAPI). It runs on Heroku, and correctly authenticates for Philips' secret remote API.

No reads are possible through the remote API, other than `GET /api`, which returns everything about the hub you're connected to.

# Setup
Grab your keys as described in [these unofficial docs](http://blog.paulshi.me/technical/2013/11/27/Philips-Hue-Remote-API-Explained.html), and prepare your `BRIDGEID` and `ACCESSTOKEN` to set as environment variables. Deploy it to Heroku by using the button below using your keys and start firing off requests at `/api`.

[![Deploy](https://www.herokucdn.com/deploy/button.png)](https://heroku.com/deploy)

The proxy currently expects a username/key of `0`, so the correct URL to post to for the first light is `/api/0/lights/1`.
