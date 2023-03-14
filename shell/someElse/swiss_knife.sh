alias self="mkdir -p /tmp/webuser/robincai; cd /tmp/webuser/robincai; pwd"
alias logCcps="cd /var/log/kylin_cti; pwd"
alias logFs="cd /usr/local/freeswitch/log; pwd"

ossBin="echo" # as default
res=`whereis oss2mgr-linux`
res=${res##*:}
if [[ $res > "   " ]]; then
    ossBin=oss2mgr-linux
else
    res=`whereis oss2mgr`
    res=${res##*:}
    if [[ $res > "   " ]]; then
        ossBin=oss2mgr
    fi
fi

echo "oss bin is ${ossBin}"

function ossUpload {
    filename=${1##*\/}
    cmdStr="${ossBin} -cmd up -obj ccps/robincai/${filename} -file ${1}"
    echo ">>> run ${cmdStr}"
    ${cmdStr}
}

function ossDownload {
    filename=${1##*\/}
    cmdStr=${ossBin} -cmd down -obj ccps/robincai/${filename} -file ${1}
    echo ">>> run ${cmdStr}"
    ${cmdStr}
}
