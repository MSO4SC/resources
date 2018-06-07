#!/bin/bash

# Possible argument {up,down}

arg=$1

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/" && pwd )"
ROOT_DIR=${SCRIPT_DIR}/../../../
UPLOAD_DIR=${SCRIPT_DIR}/upload
JOB=feelpp_toolboxes
APP=feelpp_toolboxes
TOSCA=blueprint.yaml
LOCAL=local-blueprint-inputs.yaml
LOCAL_DIR=../../../../

declare -a toolbox=("solid"
"fluid"
"heat"
"heatfluid"
"thermoelectric"
)
declare -a toolbox_default_cases=( "\"github:{path:toolboxes/solid/cantilever}\""
"\"github:{path:toolboxes/fluid/TurekHron}\"" 
"\"github:{path:toolboxes/heat/thermo2d}\"" 
"\"github:{path:toolboxes/heatfluid/NaturalConvection/cavity}\"" 
"\"github:{path:toolboxes/thermoelectric/test}\"" 
)

usage()
{
    echo "usage: $0 [CMD] config_name"
    echo ""
    echo "options:"
    echo "      up     send to orchestrator"
    echo "    down     remove from orchestrator"
    echo "     pkg     create a package for marketplace (For portal usage)"
    echo ""
    echo "config_name:"
    echo "    Base name of the config available in config directory."
    echo "    torsionbar example is used by default."
    echo ""
    echo "Example: ./deploy up"
    echo "         ./deploy down"
    echo "         ./deploy pkg"
}


if [ ! -f "${ROOT_DIR}/${LOCAL}" ]; then
    echo "${ROOT_DIR}/${LOCAL} does not exist! See doc or blueprint examples!"
    exit 1
fi


case $arg in
    "up" )
        cd ${UPLOAD_DIR}
        cfy blueprints upload -b "${JOB}" "${TOSCA}"
        read -n 1 -s -p "Press any key to continue"
        echo ''
        cfy deployments create -b "${JOB}" -i "${LOCAL_DIR}/${LOCAL}" --skip-plugins-validation ${JOB}
        read -n 1 -s -p "Press any key to continue"
        echo ''
        cfy executions start -d "${JOB}" install
        read -n 1 -s -p "Press any key to continue"
        echo ''
        cfy executions start -d "${JOB}" run_jobs
        ;;

    "down" )
        cd ${UPLOAD_DIR}
        echo "Uninstalling deployment ${JOB}..."
        cfy executions start -d "${JOB}" uninstall
        echo "Deleting deployment ${JOB}..."
        cfy deployments delete "${JOB}"
        echo "Deleting blueprint ${JOB}..."
        cfy blueprints delete "${JOB}"
        ;;

    "pkg")
        cd ${SCRIPT_DIR}
        echo "Creating package..."
        export COPYFILE_DISABLE=1
        export COPYFILE_DISABLE=true 
        tar --transform s/^upload/${APP}/ -cvf "${APP}.tar" upload
        ;;

    "build")
        rm -rf build
        for ((i=0;i<${#toolbox[@]};++i));
        do
            mkdir -p build
            cp -r upload build/${toolbox[i]}
            sed -i "s/solid/fluid/g" build/${toolbox[i]}/blueprint.yaml
            sed -i "s#default:\s*'\"g.*#default: '${toolbox_default_cases[i]}'#g" build/${toolbox[i]}/blueprint.yaml
            echo "Generate blueprint build/${toolbox[i]}"

            echo "Creating package..."
            export COPYFILE_DISABLE=1
            export COPYFILE_DISABLE=true 
            tar -cvf "build/${toolbox[i]}.tar" -C build/${toolbox[i]} .
        done
        ;;
    *)
        usage
        ;;
esac
