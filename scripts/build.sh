#!/usr/bin/env sh
SCRIPT_DIR=`dirname $0`
PROJECT_PATH=`dirname ${SCRIPT_DIR}` 
TEST_DIR=`dirname ${SCRIPT_DIR}`/t

assert_tests_ok () {
    if [ $? -ne 0 ]
    then
        echo "\nBUILD FAILED\nTest returned no-zero exit status, build failed\n"
        exit 1;
    fi    
}

cat $PROJECT_PATH/src/*coffee | coffee -s -p > $PROJECT_PATH/lib/jackalope.js

coffee $TEST_DIR/Jackalope.coffee
assert_tests_ok

coffee $TEST_DIR/TypeConstraints.coffee
assert_tests_ok
