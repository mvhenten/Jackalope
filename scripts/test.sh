#!/usr/bin/env sh
SCRIPT_DIR=`dirname $0`
TEST_DIR=`dirname ${SCRIPT_DIR}`/t
coffee $TEST_DIR/Jackalope.coffee
coffee $TEST_DIR/TypeConstraints.coffee
