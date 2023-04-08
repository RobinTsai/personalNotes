alias self="mkdir -p /tmp/webuser/robincai; cd /tmp/webuser/robincai; pwd"
alias ccps="cd /usr/local/kylin_cti/current; pwd"
alias cdOpenresty="cd /usr/local/openresty"
alias cdFreeswitch="cd /usr/local/freeswitch/conf"

alias logCcps="cd /var/log/kylin_cti; pwd"
alias logFs="cd /usr/local/freeswitch/log; pwd"
alias logApigw="cd /var/log/udesk_api_gtw; pwd"
alias logOpenresty=logApigw

alias ll="ls -htrl"
alias l="ll"
alias psUdesk="ps -ef | grep -v grep | grep udesk"
alias cdOpenresty="cd /usr/local/openresty; pwd"
alias grepv="| grep -v grep | grep "

ossBin="echo" # as default
for name in "oss2mgr-linux" "oss2mgr"
do
    res=`whereis ${name}`
    if [[ ${res##*:} > "   " ]]; then
        ossBin=`expr match "$res" ".*: \(\/[^ ]*${name}\)"`
        break
    fi
done

echo "oss bin is ${ossBin}"

function ossUpload {
    filename=${1##*\/}
    cmdStr="${ossBin} -cmd up -obj ccps/robincai/${filename} -file ${1}"
    echo ">>> run ${cmdStr}"
    sh -c "${cmdStr}"
}

function ossDownload {
    filename=${1##*\/}
    cmdStr="${ossBin} -cmd down -obj ccps/robincai/${1} -file ${filename}"
    echo ">>> run ${cmdStr}"
    sh -c "${cmdStr}"
}

function updateSelf {
    mkdir -p /tmp/webuser/robincai && cd /tmp/webuser/robincai &&
    curl "https://cti-paas-low.oss-cn-hangzhou.aliyuncs.com/ccps/robincai/bak/knife.tar" --output /tmp/webuser/robincai/knife.tar &&
    rm -f ./knife.sh 2>/dev/null
    tar -zxvf knife.tar &&
    rm -f ./knife.tar
    . ./knife.sh && echo "Done"
}

function tarSelf {
    cur=`pwd`
    cd /tmp/webuser/robincai/ && tar -zcf knife.tar knife.sh && echo "Done"
    cd $cur
}
