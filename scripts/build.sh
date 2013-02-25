#!/usr/bin/env sh
SCRIPT_DIR=`dirname $0`
LIBRARY_DIR=`dirname ${SCRIPT_DIR}` 
TEST_DIR=`dirname ${SCRIPT_DIR}`/t
echo node "${SCRIPT_DIR}/stitch-build.js" "${LIBRARY_DIR}/lib/jackalope.js"
node "${SCRIPT_DIR}/stitch-build.js" "${LIBRARY_DIR}/lib/jackalope.js"
coffee $TEST_DIR/Jackalope.coffee
coffee $TEST_DIR/TypeConstraints.coffee
