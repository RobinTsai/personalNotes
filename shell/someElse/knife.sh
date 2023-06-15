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
function downloadBak {
    local supported=" easy-deploy.tar etcd-chk.tar oss2mgr-linux.zip etcd-chk.tar ";
    local help="only support:$supported"
    if [ ${#1} -eq 0 ]; then
        echo $help
        return
    fi

    local filename="$1"
    if [ "${#filename}" -gt 0 ] && [[ $supported =~ " $filename " ]]; then
        curl "https://cti-paas-low.oss-cn-hangzhou.aliyuncs.com/ccps/robincai/bak/$filename" --output /tmp/webuser/robincai/bak_$filename
        return
    fi
    echo $help
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
# TODO：坐席状态变化的日志

TMP_TOML_FILE="/tmp/webuser/robincai/tmp.toml"

# format_cti_toml 格式化 toml 并复制到文件 $TMP_TOML_FILE
# input : toml_cnf_file output_file
function format_cti_toml {
    mkdir -p /tmp/webuser/robincai
    echo > $TMP_TOML_FILE

    local config_file=$1
    if [[ "$config_file" < "    " ]]; then
        config_file="/usr/local/kylin_cti/current/config/cti.toml"
    fi
    if ! [ -e "$config_file" ]; then
        echo "file not exists: $config_file"
        return
    fi

    # 删除行前空格
    # 移除注释（`#` 为行开头或 `#` 前后有空格的就当作注释符，可能不全，但不再进一步处理）
    # 删除行末空格
    # 删除空行
    # 移除 `=` 前后空格
    cat "$config_file" | sed 's/^ *//g; /^#.*/d; s/ #.*$//g; s/# .*//g; s/ *$//g; /^$/d; s/ *= */=/g' > "$TMP_TOML_FILE"
}

# input : toml_cfg_file section
# output: senction内容（不包含 section）
function read_toml_section {
    local confFile=$1
    local section=$2
    if [ "$#" = 1 ]; then
        confFile=""
        section=$1
    fi

    format_cti_toml $confFile
    sed "/^\[$section\]$/,/^\[.*\]$/p" "$TMP_TOML_FILE" -n # 只输出当前 section 中的内容（不包含 section）
}
function gen_sql_base {
    read_toml_section "mysql" | awk '
        { m[substr($0, 1, index($0, "=")-1)]=substr($0, index($0, "=")+1) }
        END { printf "mysql -h%s -p%d -u%s -p%s -D%s\n", m["host"], m["port"], m["user"], m["password"], m["db_name"] }
    '
}
function gen_sql_monitor {
    read_toml_section "udesk_monitor" | awk '
        { m[substr($0, 1, index($0, "=")-1)]=substr($0, index($0, "=")+1) }
        END { printf "mysql -h%s -p%d -u%s -p%s -D%s\n", m["mysql_host"], m["mysql_port"], m["mysql_user"], m["mysql_password"], m["mysql_db_name"] }
    '
}
function gen_redis_conn {
    local sec_conf=`read_toml_section "redis"`
    local template=`echo $sec_conf | awk '
        { m[substr($0, 1, index($0, "=")-1)]=substr($0, index($0, "=")+1) }
        END { printf "redis-cli -h %s -a %s --no-auth-warning\n", "HOSTPORT", m["password"] }
    '`
    # 生成连接 sentinels 命令
    sentinels=`echo $sec_conf | grep '^sentinel_addresses=' | grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}:[0-9]{4,5}' |
    awk -v tpl=$template '{ gsub(":", " -p " ,$0); gsub("HOSTPORT", $0 ,tpl); print tpl }'`
    echo -e "[sentinel conn]\n$sentinels"

    conn_cmd=`echo $sentinels | grep '' -m 1`
    info_sentinel_cmd="$conn_cmd info sentinel"
    # 连到 sentinel 并查到 master 连接命令（密码可能不对，因为用的 sentinel 的）
    eval $info_sentinel_cmd | grep -E '^master[0-9]' | grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}:[0-9]{4,5}' |
    awk -v tpl=$template 'BEGIN {print "[master conn]"} { gsub(":", " -p " ,$0); gsub("HOSTPORT", $0, tpl); print tpl }'
}
