#!/bin/bash
# This shell is to auto-generate *.sublimt-project including files customized

BASE_PATH='/confidential_in_company'
CUSTOM_PATH='/confidential_in_company'
BACKEND_MODULE_PATH=${BASE_PATH}'/confidential_in_company'
FRONTEND_MODULE_PATH=${BASE_PATH}'/confidential_in_company'
PORTAL_MODULE_PATH=${BASE_PATH}'/confidential_in_company'

list_modules() {
    if test $1 && [ '-f' = $1 ]; then
        echo 'frontend >'
        modules_list=`ls $FRONTEND_MODULE_PATH | sort | tr -d '/'`
    elif test $1 && [ '-p' = $1 ]; then
        # portal modules
        echo 'portal >'
        modules_list=$(ls -p -F -1 ${PORTAL_MODULE_PATH} | sort | grep -E '[a-z]*/' | tr -d '/')
    else
        echo 'backend >'
        modules_list=`ls $BACKEND_MODULE_PATH | sort | tr -d '/'`
    fi
    echo -en "\e[1;32m"
    echo -e $modules_list | column -n
    echo -en "\e[0m"
}

check_modules() {
    rightModules=""
    for name in $*
    do
        if test -d ${BACKEND_MODULE_PATH}'/'${name} &&  test -d ${FRONTEND_MODULE_PATH}'/'${name}; then
            rightModules=$rightModules$name" "
        fi
    done

    echo $(echo $rightModules) # trim spaces
}

generate_project() {
    echo -e "\e[1;32m > gene module project \e[0m "
    avaliableModules=`check_modules $*`

    if test ! $avaliableModules; then
        echo -e "\e[1;31m x No avaliable modules \e[0m "
        return
    fi
    echo 'avaliableModules: \e[1;32m'$avaliableModules'\e[0m'
    template='{"file_exclude_patterns":["*.desktop"],"name":"custom-project","path":"'${CUSTOM_PATH}'"}'
    for moduleName in $(echo $avaliableModules)
    do
        MODULE_NAME=$moduleName
        backendTemplate='{"folder_exclude_patterns":["webapp","document","static"],"name":"'${MODULE_NAME}'-backend","path":"'${BACKEND_MODULE_PATH}'/'${MODULE_NAME}'"}'
        frontendTemplate='{"folder_exclude_patterns":["webapp","document","static"],"name":"'${MODULE_NAME}'-frontend","path":"'${FRONTEND_MODULE_PATH}'/'${MODULE_NAME}'"}'
        template=$template','$backendTemplate','$frontendTemplate
    done
    projectFullPath=$CUSTOM_PATH'/generated_project.sublime-project'
    echo '{"folders":['${template}']}' > $projectFullPath
    echo 'done'
}

extend_generate_project() {
    echo -e "\e[1;32m > gene module project \e[0m "
    template='{"file_exclude_patterns":["*.desktop"],"name":"custom-project","path":"'${CUSTOM_PATH}'"}'
    for name in $*
    do
        # backend
        if test -d ${BACKEND_MODULE_PATH}'/'${name}; then
            backendTemplate='{"folder_exclude_patterns":["webapp","document","static"],"name":"'${name}'-backend","path":"'${BACKEND_MODULE_PATH}'/'${name}'"}'
            template=$template','$backendTemplate
        fi
        # frontend
        if test -d ${FRONTEND_MODULE_PATH}'/'${name}; then
            frontendTemplate='{"folder_exclude_patterns":["webapp","document","static"],"name":"'${name}'-frontend","path":"'${FRONTEND_MODULE_PATH}'/'${name}'"}'
            template=$template','$frontendTemplate
        fi
        # portal
        if test -d ${PORTAL_MODULE_PATH}'/'${name} && test ! -L ${PORTAL_MODULE_PATH}'/'${name}; then
            portalTemplate='{"name":"'${name}'-portal","path":"'${PORTAL_MODULE_PATH}'/'${name}'"}'
            template=$template','$portalTemplate
        fi
    done
    projectFullPath=$CUSTOM_PATH'/generated_project.sublime-project'
    echo '{"folders":['${template}']}' > $projectFullPath
    echo 'done'
}
