#!/bin/bash -e
# The -e flag enables interpretation of the following backslash-escaped characters in each STRING:
# Copyright (c) 2021, WSO2 Inc. (http://wso2.org) All Rights Reserved.
#
# WSO2 Inc. licenses this file to you under the Apache License,
# Version 2.0 (the "License"); you may not use this file except
# in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.
#
# ----------------------------------------------------------------------------
# Run Ballerina Performance Tests
# ----------------------------------------------------------------------------

. ./performance_test_config.sh

#The declare is a builtin command of the bash shell. It is used to declare shell variables and functions, set their attributes and display their values. An "associative array" variable (declare -A) is an array of key-value pairs whose values are indexed by a keyword.
declare -A test_scenario0=(
    [name]="create Database"
    [description]="Create one database with a given id"
    [users]=$NUM_USERS
    [rampUpPeriod]=$RAMP_UP_TIME
    [protocol]="http"
    [method]="POST"
    [path]="/create/database"
    [port]=$PORT_CREATE
    [host]=$HOST
)

declare -A test_scenario1=(
    [name]="create Container"
    [description]="Create one container with a given id"
    [users]=$NUM_USERS
    [rampUpPeriod]=$RAMP_UP_TIME
    [protocol]="http"
    [method]="POST"
    [path]="/create/container"
    [port]=$PORT_CREATE
    [host]=$HOST
)

declare -A test_scenario2=(
    [name]="create Document"
    [description]="Create one document with a given id"
    [users]=$NUM_USERS
    [rampUpPeriod]=$RAMP_UP_TIME
    [protocol]="http"
    [method]="POST"
    [path]="/create/document"
    [port]=$PORT_CREATE
    [host]=$HOST
)

declare -A test_scenario3=(
    [name]="create Stored Procedure"
    [description]="Create one stored procedure with a given id"
    [users]=$NUM_USERS
    [rampUpPeriod]=$RAMP_UP_TIME
    [protocol]="http"
    [method]="POST"
    [path]="/create/storedprocedure"
    [port]=$PORT_CREATE
    [host]=$HOST
)

declare -A test_scenario4=(
    [name]="create User Defined Function"
    [description]="Create one user defined function with a given id"
    [users]=$NUM_USERS
    [rampUpPeriod]=$RAMP_UP_TIME
    [protocol]="http"
    [method]="POST"
    [path]="/create/userdefinedfunction"
    [port]=$PORT_CREATE
    [host]=$HOST
)

declare -A test_scenario5=(
    [name]="create Trigger"
    [description]="Create one trigger with a given id"
    [users]=$NUM_USERS
    [rampUpPeriod]=$RAMP_UP_TIME
    [protocol]="http"
    [method]="POST"
    [path]="/create/trigger"
    [port]=$PORT_CREATE
    [host]=$HOST
)

declare -A test_scenario6=(
    [name]="create User"
    [description]="Create one user with a given id"
    [users]=$NUM_USERS
    [rampUpPeriod]=$RAMP_UP_TIME
    [protocol]="http"
    [method]="POST"
    [path]="/create/user"
    [port]=$PORT_CREATE_CREATE
    [host]=$HOST
)
##
declare -A test_get_scenario0=(
    [name]="Get Database"
    [description]="Get database with a given id"
    [users]=$NUM_USERS
    [rampUpPeriod]=$RAMP_UP_TIME
    [protocol]="http"
    [method]="GET"
    [path]="/list/database"
    [port]=$PORT_GET
    [host]=$HOST
)

declare -A test_get_scenario1=(
    [name]="Get Container"
    [description]="Get container with a given id"
    [users]=$NUM_USERS
    [rampUpPeriod]=$RAMP_UP_TIME
    [protocol]="http"
    [method]="GET"
    [path]="/list/container"
    [port]=$PORT_GET
    [host]=$HOST
)

declare -A test_get_scenario2=(
    [name]="Get Document"
    [description]="Get document with a given id"
    [users]=$NUM_USERS
    [rampUpPeriod]=$RAMP_UP_TIME
    [protocol]="http"
    [method]="GET"
    [path]="/list/document"
    [port]=$PORT_GET
    [host]=$HOST
)

declare -A test_get_scenario3=(
    [name]="Get Permission"
    [description]="Get trigger with a given id"
    [users]=$NUM_USERS
    [rampUpPeriod]=$RAMP_UP_TIME
    [protocol]="http"
    [method]="GET"
    [path]="/list/permission"
    [port]=$PORT_GET
    [host]=$HOST
)

declare -A test_get_scenario4=(
    [name]="Get User"
    [description]="Get user with a given id"
    [users]=$NUM_USERS
    [rampUpPeriod]=$RAMP_UP_TIME
    [protocol]="http"
    [method]="GET"
    [path]="/list/user"
    [port]=$PORT_GET
    [host]=$HOST
)


function execute_test() {
    eval "declare -A element="${1#*=}

	echo ${element[name]}
	sh ${JMETER_HOME}/bin/jmeter -n -t $JMX_FILE -Jhost=${element[host]} -Jport=${element[port]} -Jprotocol=${element[protocol]} -Jusers=${element[users]} -Jpath=${element[path]} -Jmethod=${element[method]} -JrampUpPeriod=${element[rampUpPeriod]} -l $OUTPUT_FILE_CREATE
	sleep $THREAD_SLEEP_TIME
}

function execute_get_test() {
    eval "declare -A element="${1#*=}

	echo ${element[name]}
	sh ${JMETER_HOME}/bin/jmeter -n -t $JMX_FILE -Jhost=${element[host]} -Jport=${element[port]} -Jprotocol=${element[protocol]} -Jusers=${element[users]} -Jpath=${element[path]} -Jmethod=${element[method]} -JrampUpPeriod=${element[rampUpPeriod]} -l $OUTPUT_FILE_GET
	sleep $THREAD_SLEEP_TIME
}

#The whole point of a subshell is that it doesn't affect the calling session. In bash a subshell is a child process, other shells differ but even then a variable setting in a subshell does not affect the caller. By definition.
execute_test "$(declare -p test_scenario0)" 
execute_test "$(declare -p test_scenario1)" 
execute_test "$(declare -p test_scenario2)" 
execute_test "$(declare -p test_scenario3)" 
execute_test "$(declare -p test_scenario4)" 
execute_test "$(declare -p test_scenario5)" 
execute_test "$(declare -p test_scenario6)" 

execute_get_test "$(declare -p test_get_scenario0)" 
execute_get_test "$(declare -p test_get_scenario1)" 
execute_get_test "$(declare -p test_get_scenario2)" 
execute_get_test "$(declare -p test_get_scenario3)" 
execute_get_test "$(declare -p test_get_scenario4)" 

#gets the directory name of file containing the command.
#script_dir=$(dirname "$0")

#A dot in that context means to "source" the contents of that file into the current shell. Files such as this are often used to incorporate setup commands such as adding things to ones environment variables.
#. $script_dir/perf-test-common.sh
