#!/usr/bin/env sh
SCRIPT_DIR=`dirname $0`
PROJECT_PATH=`dirname ${SCRIPT_DIR}` 
TEST_DIR=`dirname ${SCRIPT_DIR}`/t

cat $PROJECT_PATH/src/*coffee | coffee -s -p > $PROJECT_PATH/lib/jackalope.js

coffee $TEST_DIR/Jackalope.coffee
coffee $TEST_DIR/TypeConstraints.coffee
