Spreebot
========

Standalone Sinatra app for receiving Github callbacks related to issues, etc. Spreebot will automatically add/remove labels and provide helpful comments based on predefined activities and comments coming from Github.

## Getting started

```
$ bundle install
$ rackup
```

## Heroku

You can run Spreebot on Heroku using the following commands (you'll need to have installed the Heroku toolbelt already):

```
cd spreebot
heroku create
heroku config:set GITHUB_TOKEN={YOUR-PERSONAL-ACCESS-TOKEN}
git push heroku master
```

this is not be merged :P
