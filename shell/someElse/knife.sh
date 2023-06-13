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
alias loadRecord=". /tmp/webuser/robincai/record"
alias clearRecord="echo > /tmp/webuser/robincai/record"
alias catRecord="cat /tmp/webuser/robincai/record"

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
    a=`uname -a | awk '{print $2 }'`; b=`ifconfig eth0| awk '/inet /{print $2 }' | grep -Eo "[0-9.]*"`; c=`curl cip.cc -s | awk '/IP/{print $3}'`
    echo -e "$a\t$b\t$c"
}

function whois {
    res=`curl -s "https://cti-paas-low.oss-cn-hangzhou.aliyuncs.com/ccps/robincai/bak/4.0_prod_host.md" | grep "$1"`
    if [[ ${res} > "  " ]]; then
        echo $res
        return
    fi
    curl -s "cip.cc/$1" | head -3
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
     sed -e '/acd.sendHttp.*sendHttp, method: .*:5001/{s/.*_time":"/acd.sendHttp/g;s/\+08:00.*method://g;s/, url://g;s/, params://g;s/\?.*$//g;s/, body.*$//g; /\/asr/d; s/acd.sendHttp//gp}' -n "$1" |
     awk '{ printf "%s\t%s\t%s\t%s\n",$1,$2,$3,$4}'
}
function grep_tower_call {
    grep 'Method' "$1" | sed -e 's/.*_time":"//g' -e 's/+08:00".*Method\\":\\"/ /g' -e 's/\\",.*//g' | awk '{printf "%s\t%s\n",$1, $2}'
}
function grep_cti_http {
    sed '/BasicAuthMiddleware.*URL Info/{s/.*_time\":\"//g; s/\+08:00.*URL Info: / /g; s/\?.*//g; s/\// \//; p}' "$1" -n |
    awk '{printf "%s\t%s\t%s\n",$1,$2,$3}'
}
function grep_cti_channel_id {
    grep -Eo 'channel_[0-9]_id":"[^"]*"' "$1" | sed '{s/.*://g;s/"//g}' | sort -u
}
function grep_cti_fs_event {
    sed '/Event\]\[Received/{s/.*_time\":\"//g; s/\+08:00.*\] / /g;s/\\n.*//g;p}' $callLog  -n  |
    awk '{printf "%s\t%s\n",$1,$2}'
}
function rec {
    echo "$@" >> /tmp/webuser/robincai/record
}
function gen_monitor_sql {
    config_file=$1
    if [[ $config_file < "    " ]]; then
        config_file="/usr/local/kylin_cti/current/config/cti.toml"
    fi

    if ! [ -e $config_file ]; then
        echo "file not exists: $config_file"
        return
    fi

    sed '/\[udesk_monitor\]/,/\[/{s/[ ]*=[ ]*/=/gp}' "$config_file" -n | awk '
        { m[substr($0, 0, index($0, "="))]=substr($0, index($0, "=")+1) }
        END { printf "mysql -h%s -p%d -u%s -p%s -D%s\n", m["mysql_host"], m["mysql_port"], m["mysql_user"], m["mysql_password"], m["mysql_db_name"] }
    '
}
# TODO：坐席状态变化的日志
