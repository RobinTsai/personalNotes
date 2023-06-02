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
alias pseo="ps -eo lstart,cmd"
alias cdOpenresty="cd /usr/local/openresty; pwd"
alias grepv="grep -v grep | grep "
alias tarx="tar -zxvf"

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

function whoAmi {
    1=`uname -a | awk '{print $2 }'`; 2=`ifconfig eth0| awk '/inet /{print $2 }'`; 3=`curl cip.cc -s | awk '/IP/{print $3}'`
    echo $1 $2 $3
}

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

function enableSelf {
    curShell=`echo $SHELL`
    curShell=${curShell##*\/}
    if [ $curShell = "zsh" ]; then
        shrc="$HOME/.zshrc";
    elif [ $curShell = "bash" ]; then
        shrc="$HOME/.bashrc";
    else
        return
    fi
    exists=`grep -E "robincai=[\"\']\. \/tmp/webuser/robincai/knife.sh" $shrc | wc | awk '{print $1}'`
    if [ $exists -ge 1 ]; then
        . $shrc && echo "enabled at $shrc"
        return
    fi

    bak=$shrc.bak-`date +%Y%m%d`
    cp $shrc $bak && echo "backed up at $bak" # backup
    if [ $? -ne 0 ]; then
        echo "back up $shrc failed, return enableSelf"
        return
    fi
    sed '/alias\ robincai=/d' $shrc > $shrc.swp # edit and output to $shrc.swp
    mv $shrc{.swp,}                             # replace

    echo "alias robincai='. /tmp/webuser/robincai/knife.sh'" >> $shrc
    . $shrc && echo "enabled at $shrc"
}

function updateSelf {
    mkdir -p /tmp/webuser/robincai && cd /tmp/webuser/robincai &&
    curl "https://cti-paas-low.oss-cn-hangzhou.aliyuncs.com/ccps/robincai/bak/knife.tar" --output /tmp/webuser/robincai/knife.tar &&
    mv ./knife{,.bak}.sh 2>/dev/null
    tar -zxvf knife.tar &&
    rm -f ./knife.tar
    . /tmp/webuser/robincai/knife.sh && echo "Done"
    enableSelf
}

function ossPushSelf {
    cur=`pwd`
    cd /tmp/webuser/robincai/ && tar -zcf knife.tar knife.sh && echo "tar done"
    cmdStr="${ossBin} -cmd up -obj ccps/robincai/bak/knife.tar -file knife.tar"
    echo ">>> run ${cmdStr}"
    sh -c "${cmdStr}"
    cd $cur
}

# ------------- cti 日志相关 ------------

function grep_cti_ivr { # 过滤 ivr 相关消息
    grep 'callworker.publishAppMsg' "$1"  | sed 's/.*"_time":"//g' | sed 's/","msg":"publishAppMsg success://g' | sed 's/appID.*//g'
}
function grep_cti_acd { # 过滤和 acd 的交互
    sed '/acd.sendHttp/{s/.*_time":"//g;s/\+08:00.*method://g;s/, url://g;s/, params://g;s/\?.*$//g;s/, body.*$//gp}' -n "$1"
}
function grep_tower_call {
    grep 'Method' "$1" | sed -e 's/.*_time":"//g' -e 's/+08:00".*Method\\":\\"/ /g' -e 's/\\",.*//g' | awk '{printf "%s\t%s\n",$1, $2}'
}
