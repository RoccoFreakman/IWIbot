#!/bin/bash
#
# Copyright 2017 IBM Corp. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the “License”);
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#  https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an “AS IS” BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Load configuration variables
source local.env

function usage() {
  echo -e "Usage: $0 [--install,--uninstall,--env]"
}

function install() {
  echo -e "Deploying OpenWhisk actions, triggers, and rules for IWIBot"

   echo "Deploy Joke Action with HTTP-VERB GET"
  cd openwhisk/joke
  # preserve dev deps
  mv node_modules .mod
  # install only prod deps
  npm install --production
  # zip all but skip the dev deps
  zip -r action.zip package.json lib/Joke.js node_modules
  # delete prod deps
  rm -rf node_modules
  # recover dev deps
  mv .mod node_modules
  # install zip in openwhisk
  wsk action create testJoke --kind nodejs:6 action.zip --web true
  wsk api create -n "iwibot Test API" /iwibotTest /joke get testJoke --response-type json
  cd ../..

   echo "Deploy Meal Action with HTTP-VERB GET"
  cd openwhisk/meal
  # preserve dev deps
  mv node_modules .mod
  # install only prod deps
  npm install --production
  # zip all but skip the dev deps
  zip -rq action.zip package.json lib/Meal.js node_modules
  # delete prod deps
  rm -rf node_modules
  # recover dev deps
  mv .mod node_modules
  # install zip in openwhisk
  wsk action create test/Meal --kind nodejs:6 action.zip --web true
  wsk api create /iwibotTest /meal get test/Meal --response-type json
  cd ../..

   echo "Deploy Router Action with HTTP-VERB POST"
  cd openwhisk/router
  # preserve dev deps
  mv node_modules .mod
  # install only prod deps
  npm install --production
  # zip all but skip the dev deps
  zip -r action.zip package.json lib node_modules
  # delete prod deps
  rm -rf node_modules
  # recover dev deps
  mv .mod node_modules
  # install zip in openwhisk
  wsk action create test/Router --kind nodejs:6 action.zip --web true
  wsk api create /iwibotTest /router post test/Router --response-type http
  cd ../..

   echo "Deploy Timetables Action with HTTP-VERB POST"
  cd openwhisk/timetables
  # preserve dev deps
  mv node_modules .mod
  # install only prod deps
  npm install --production
  # zip all but skip the dev deps
  zip -rq action.zip package.json lib node_modules
  # delete prod deps
  rm -rf node_modules
  # recover dev deps
  mv .mod node_modules
  # install zip in openwhisk
  wsk action create testTimetables --kind nodejs:6 action.zip --web true
  wsk api create /iwibotTest /timetables post testTimetables --response-type json
  cd ../..


   echo "Deploy Weather Action with HTTP-VERB POST"
  cd openwhisk/weather
  # preserve dev deps
  mv node_modules .mod
  # install only prod deps
  npm install --production
  # zip all but skip the dev deps
  zip -rq action.zip package.json lib node_modules
  # delete prod deps
  rm -rf node_modules
  # recover dev deps
  mv .mod node_modules
  # install zip in openwhisk
  wsk action create test/Weather --kind nodejs:6 action.zip --web true
  wsk api create /iwibotTest /weather post test/Weather --response-type json
  cd ../..

  echo -e "Deployment Complete!"
}

function uninstall() {
  echo -e "Undeploying..."

  echo "Removing API actions..."
  wsk api delete /iwibotTest

  echo "Removing actions..."
  wsk action delete test/Meal
  wsk action delete test/Router
  wsk action delete test/Timetables
  wsk action delete test/Joke
  wsk action delete test/Weather
  echo -e "Undeployment Complete"
}

case "$1" in
"--install" )
install
;;
"--uninstall" )
uninstall
;;
* )
usage
;;
esac