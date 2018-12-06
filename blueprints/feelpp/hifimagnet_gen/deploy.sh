#!/bin/bash

# Possible argument {up,down}

arg=$1

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/" && pwd )"
ROOT_DIR=${SCRIPT_DIR}/../../../

APP=$(basename "${PWD}")
JOB=${APP}_generic

UPLOAD_DIR=${SCRIPT_DIR}/upload
TOSCA=blueprint.yaml
LOCAL=local-blueprint-inputs.yaml
LOCAL_DIR=../

NO_DEBUG=""
DEBUG=${2:-${NO_DEBUG}} # from "-v" to "-vvv"

echo "DEBUG=$DEBUG"

cd "${UPLOAD_DIR}" || {
    echo "no upload directory present"
    echo "SCRIPT_DIR=${SCRIPT_DIR}"
    exit
}

case $arg in
    "up" )
	if [ ! -f "${ROOT_DIR}/${LOCAL}" ]; then
	    echo "${ROOT_DIR}/${LOCAL} does not exist! See doc or blueprint examples!"
	    exit 1
	fi

        cfy blueprints validate "${TOSCA}"
	isOK=$?
	if [ $isOK != 0 ]; then
	   exit 1
	fi
	cfy blueprints upload "${DEBUG}" -b "${JOB}" "${TOSCA}"
	isOK=$?
	if [ $isOK != 0 ]; then
	   exit 1
	fi
        # read -n 1 -s -p "Press any key to continue"
        # echo ''
        cfy deployments create "${DEBUG}" -b "${JOB}" -i "${LOCAL_DIR}/${LOCAL}" --skip-plugins-validation "${JOB}"
	isOK=$?
	if [ $isOK != 0 ]; then
	   exit 1
	fi
        # read -n 1 -s -p "Press any key to continue"
        # echo ''
        cfy executions start "${DEBUG}" -d "${JOB}" install
	isOK=$?
	if [ $isOK != 0 ]; then
	   exit 1
	fi
        read -n 1 -s -p "Press any key to continue"
        echo ''
        cfy executions start "${DEBUG}" -d "${JOB}" run_jobs
        ;;

    "down" )
        echo "Uninstalling deployment ${JOB}..."
        cfy executions start "${DEBUG}" uninstall -d "${JOB}" -p ignore_failure=true
        echo "Deleting deployment ${JOB}..."
        cfy deployments delete  "${DEBUG}" "${JOB}"
        echo "Deleting blueprint ${JOB}..."
        cfy blueprints delete  "${DEBUG}" "${JOB}"
        ;;

    "pkg")
        cd "${SCRIPT_DIR}" || exit
        echo "Creating package..."
        export COPYFILE_DISABLE=1
        tar --transform s/^upload/"${APP}"/ --exclude='#*#' --exclude='*~' -cvzf "${APP}.tar.gz" upload
        ;;
    "check" )
	echo "Checking yaml files ${JOB}..."
	find "${SCRIPT_DIR}" -name \*.yaml -execdir sh -c 'yamllint -d "{extends: relaxed, rules: {line-length: {max: 120}}}"  $0' {} \;
	echo "Checking shell scripts ${JOB}..."
	find "${SCRIPT_DIR}" -name \*.sh -execdir sh -c 'shellcheck -e SC2086 $0' {} \;
	;;
    *)
        echo "arg: $arg"
        echo "usage: $0 [option]"
        echo ""
        echo "options:"
        echo "      up     send to orchestrator"
        echo "    down     remove from orchestrator"
        echo "     pkg     create a package for marketplace (for portal usage)"
        echo ""
        ;;
esac
