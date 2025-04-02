alias self="mkdir -p /home/webuser/robincai; cd /home/webuser/robincai; pwd"
alias selfTmp="mkdir -p /tmp/webuser/robincai_tmp; cd /tmp/webuser/robincai_tmp; pwd"
alias ccps="cd /usr/local/kylin_cti/current; pwd"
alias cdOpenresty="cd /usr/local/openresty"
alias cdFreeswitch="cd /usr/local/freeswitch/conf"
alias esl-py="cd /usr/local/esl-python"
alias ps-esl-py='ps -ef | grep recringing.py | grep -v grep  | awk '\''{ print $0 "\n\nPID: " $2 }'\'''

alias logCcps="cd /var/log/kylin_cti; pwd"
alias logFs="cd /usr/local/freeswitch/log; pwd"
alias logApigw="cd /var/log/udesk_api_gtw; pwd"
alias logOpenresty=logApigw

LOG_CCPS="/var/log/kylin_cti"
LOG_OPENRESTY="/var/log/udesk_api_gtw"
LOG_FS="/usr/local/freeswitch/log"
CONF_FS="/usr/local/freeswitch/conf"
CCPS="/usr/local/kylin_cti/current"
SELF_TMP="/tmp/webuser/robincai_tmp"

alias ll="ls -htrl"
alias l="ll"
alias psUdesk="ps -ef | grep -v grep | grep udesk"
alias pseo="ps -eo lstart,cmd"
alias psgrep="ps -ef | grep -v ' grep ' | grep "
alias cdOpenresty="cd /usr/local/openresty; pwd"
alias grepv="grep -v grep | grep "
alias tarx="tar -zxvf"

alias grep_tower_conns="grep -Eo 'conn_id[^,]*' "
alias grep_fs_applimit="grep mod_db.c:194 "

alias grep_fs_hangup="grep 'Hangup sofia/' "
alias grep_fs_new_channel="grep 'New Channel sofia/' "


# grep 'PubAgentState payload'  udesk_acd.log | grep -Eo '"_time":".*\+08:00' | grep -Eo '[^"]*$' | sed 's/+08:00//g'
function grep_acd_state_change {
    grep 'PubAgentState payload' "${1}" | while read line; do
        timestamp=`echo $line | grep -Eo '"_time":".*\+08:00' | grep -Eo '[^"]*$' | sed 's/+08:00//g'`
        agent_id=`echo $line | grep -Eo '"agent_id":"[0-9]*@.{36}","timestamp' | grep -Eo '[0-9]+@[0-9a-f-]*'`
        src_state=`echo $line | grep -Eo '\\"src_state\\":\\"[^"]*' | grep -Eo ':\\"[^"]*$' | grep -Eo '[a-zA-Z]*'`
        dst_state=`echo $line | grep -Eo '\\"state\\":\\"[^"]*' | grep -Eo ':\\"[^"]*$' | grep -Eo '[a-zA-Z]*'`
        src_sub_state_id=`echo $line | grep -Eo '\\"src_sub_state_id\\":[0-9]*' | grep -Eo '[0-9]*'`
        dst_sub_state_id=`echo $line | grep -Eo '\\"sub_state_id\\":[0-9]*' | grep -Eo '[0-9]*'`
        call_id=`echo $line | grep -Eo '\\"call_id\\":\\"[^"]*' | grep -Eo ':.*' | grep -Eo '[0-9a-z-]*'`
        if [[ ${call_id} < "  " ]]; then
            call_id="null"
        fi
        wrapup_dur=`echo $line | grep -Eo '\\"wrapup_duration\\":[0-9]*' | grep -Eo '[0-9]*'`
        echo "${agent_id} ${src_state} ${dst_state} ${src_sub_state_id} ${dst_sub_state_id} ${timestamp} ${call_id} ${wrapup_dur}" |
            awk '{ printf("%-029s %-44s, %7s -> %-7s, %3d -> %-3d,%3d, %s\n", $6, $1, $2, $3, $4, $5, $8, $7) }'
    done
}

alias sed_join_line='sed ":a;N;\$!ba;s/\n/|/g"'
alias fs_status="fs_cli -x 'status'"
alias fs_sofia_status="fs_cli -x 'sofia status'"
alias fs_sofia_reg="fs_cli -x 'sofia status profile internal reg'"
alias fs_calls_count="fs_cli -x 'show calls count'"
alias fs_show_calls="fs_cli -x 'show calls'"

alias tail_openresty_acc_err="tail -f access.log | grep -v 'HTTP/1.0' | grep -v ' HTTP/1.1\" 200 '"
alias tail_openresty_acc_errcodes="tail_openresty_acc_err | grep -Eo 'HTTP/1.1\"[^\"]*'"

ossBin="echo" # as default
for name in "oss2mgr-linux" "oss2mgr"
do
    res=`whereis ${name}`
    if [[ ${res##*:} > "   " ]]; then
        ossBin=`expr match "$res" ".*: \(\/[^ ]*${name}\)"`
        break
    fi
    md5=`md5sum ${ossBin}`
    if [[ ${md5} != "c9d373995127b886a4a73ea676fa342f" ]]; then
        echo "oss2mgr-linux is not updated, ossDownload oss2mgr.tar to update."
        return
    fi
done

echo "oss bin is ${ossBin}"

function setIP {
    IP=`ifconfig eth0 2>&1 | grep inet | grep -v inet6 | awk '{ print $2 }'`
}
setIP

function monitor_is_main {
    if [[ ${IP} < "  " ]]; then
        setIP
    fi
    curl "http://${IP}:4041/event_listen_status"; echo '';
}
function monitor_is_chan_overflow {
    local result=`grep 'output redis channel blocked msg from redis' /var/log/kylin_cti/udesk_cc_monitor.log -m 1`
    if [[ "${result}" < "  " ]]; then
        echo "no.";
    else
        echo "overflowed.";
    fi
}
function monitor_is_evt_delay {
    timespan=`date "+%Y-%m-%dT%H:%M"`
    grep "\"_time\":\"${timespan}" udesk_cc_monitor.log | grep ',attime=' |
        sed 's/.*","_time":"//g; s/+08:00",".* Timestame:/,/g; s/ .*//g; s/\.[^,]*,/ /g' |
        while read line; do
        t=`echo $line |awk '{print $1}'`;
        t2=`echo $line | awk '{print $2}'`;
        t2=${t2:0:10}; t1=`date +%s -d "${t}"`; d=$[t1 - t2];
        if ! [ $d -eq 0 ]; then echo $t1 ${t2} $d $t; fi; done
}

function grep_cti_call_log {
    call_id=$1
    if [[ ${call_id} < "  " ]]; then
        return
    fi
    log_file=$2
    if [[ ${log_file} < "  " ]]; then
        log_file=/var/log/kylin_cti/udesk_cti.log
    fi
    cmd="grep $call_id $log_file > /tmp/webuser/robincai_tmp/cti-${call_id:0:3}.log"
    echo "run: $cmd"
    sh -c "${cmd}"
}

function grep_fs_channel_log {
    channels=$1
    if [[ ${channels} < "  " ]]; then
        return
    fi

    cmd="grep -E $channels $2 $3 > /tmp/webuser/robincai_tmp/fs-${channels:0:3}.log"
    echo "run: $cmd"
    sh -c "${cmd}"
}

function grep_record_by_call {
    call_id=$1
    log_file=$2
    if [[ ${call_id} < "  " ]]; then
        return
    fi
    grep "${call_id}" "${log_file}" | grep upload_worker | grep -Eno 'https:[^,]*'
}

function whoAmi {
    a=`uname -a | awk '{print $2 }'`; b=`ifconfig eth0| awk '/inet /{print $2 }' | grep -Eo "[0-9.]*"`; c=`curl ip.sb -s`
    echo -e "$a\t$b\t$c"
}

function whois {
    res=`curl -s "https://cti-paas-low.oss-cn-hangzhou.aliyuncs.com/ccps/robincai/bak/4.0_prod_host.md" | grep "$1"`
    if [[ ${res} > "  " ]]; then
        echo "$res"
        return
    fi
}

function whoisTenent {
    filename="${SELF_TMP}/tenents_info.csv"
    if ! [ -e "${filename}" ]; then
        echo "download to ${filename}"
        curl -s "https://cti-paas-low.oss-cn-hangzhou.aliyuncs.com/ccps/robincai/bak/tenents_info.csv" -o ${filename}
    fi

    res=`grep "$1" "${filename}" | sed 's/,/ , /g'`
    echo "$res"
    return
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

function ossDownloads {
    for name in $@
    do
        ossDownload ${name}
    done
}

function ossUploads {
    for name in $@
    do
        ossUpload ${name}
    done
}


function ossDownloadBak {
    local supported=" easy-deploy etcd-chk oss2mgr etcd-chk ";
    local help="only support:$supported"
    if [ ${#1} -eq 0 ]; then
        echo $help
        return
    fi

    local filename="$1"
    if [ "${#filename}" -gt 0 ] && [[ $supported =~ " $filename " ]]; then
        curl "https://cti-paas-low.oss-cn-hangzhou.aliyuncs.com/ccps/robincai/bak/$filename.tar" --output /tmp/webuser/robincai_tmp/bak_$filename.tar
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
    exists=`grep -E "robincai=[\"\']\. \/home/webuser/robincai/knife.sh" "$shrc" | wc | awk '{print $1}'`
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

    echo "alias robincai='. /home/webuser/robincai/knife.sh'" >> $shrc
    . $shrc && echo "enabled at $shrc"
}

function updateSelf {
    cmd='curl "https://cti-paas-low.oss-cn-hangzhou.aliyuncs.com/ccps/robincai/bak/knife.tar" --output /home/webuser/robincai/knife.tar'
    if [ "$1" = "wget" ]; then
        cmd='wget "https://cti-paas-low.oss-cn-hangzhou.aliyuncs.com/ccps/robincai/bak/knife.tar" -O /home/webuser/robincai/knife.tar '
    fi
    mkdir -p /home/webuser/robincai && cd /home/webuser/robincai && eval "${cmd}" &&
    mv ./knife{,.bak}.sh 2>/dev/null
    tar -zxvf knife.tar &&
    rm -f ./knife.tar
    . /home/webuser/robincai/knife.sh && echo "Done"
    enableSelf
}

function ossPushSelf {
    echo "do nothing"
    return
    cur=`pwd`
    cd /tmp/webuser/robincai_tmp/ && tar -zcf knife.tar knife.sh && echo "tar done"
    cmdStr="${ossBin} -cmd up -obj ccps/robincai/bak/knife.tar -file knife.tar"
    echo ">>> run ${cmdStr}"
    sh -c "${cmdStr}"
    cd $cur
}

# ------------- tower 日志相关 -------------
function grep_tower_events {
    grep 'Method' "$1" | sed -e 's/.*_time":"//g' -e '/SignalHub-msgMap/d' -e '/Inbox/d' -e '/GetAgentStatusOptions/d' -e '/+++Read/d' -e 's/+08:00".*Method\\":\\"/ /g' -e 's/\\":\\"/:/g' -e 's/\\",\\"/ /' -e 's/\\",\\"/,/g' -e 's/StartTime:[^,]*,//g' |
    awk 'function get(raw, start, end){
            startIdx=index(raw, start)
            len=index(substr(raw, startIdx), end)
            if (len > 0) {
                result=substr(raw, startIdx, len-length(end))
            } else {
                result=substr(raw, startIdx)
            }
            return result
        }
    {
        if ($2 ~ /GetState/) {
            state=get($3, "CurState:", ",")
            mode=get($3, "CurMode:", ",")
            printf "%-29s\t%-20s\t%s,%s\n", $1, $2, state, mode
        } else if ($2 ~ /AgentCallModeChange/) {
            modeTmp=get($3, "CurContact:", ",");   mode=substr(get(modeTmp, ":", ","), 2)
            num=get($3, "CurNumber:", ",");        num=substr(get(num, ":", ","), 2)
            extState=get($3, "CurExtState:", ","); extState=get(extState, "CurExtState:", "\\");
            printf "%-29s\t%-20s\t%s:%s, %s\n", $1, $2, mode, num, extState
        } else if ($2 ~ /AgentStateChange/) {
            from=get($3, "OldState:", ",")
            to=get($3, "CurState:", ",")
            printf "%-29s\t%-20s\t%s, %s\n", $1, $2, from, to
        } else if ($2 ~ /ExtensionStateChange/) {
            cur=get($3, "CurState:", ",")
            printf "%-29s\t%-20s\t%s\n", $1, $2, cur
        # } else if ($2 ~ /Originated/) {
        # } else if ($2 ~ /SetCallMode/) {
        # } else if ($2 ~ /TransferQueue/) {
        # } else if ($2 ~ /UserAnswered/) {
        } else {
            printf "%-29s\t%-20s\n", $1, $2
        }
    }'
}
# ------------- cti 日志相关 ------------
function grep_cti_ivr {
    sed -n '/callworker\.(\*ReportSend)\.post/{
        s/.*","_time":"/post_app\t/g;
        s/+08:00.*v1\/call/\tv1\/call/g;
        s/\?app_id.*\\"type\\":\\"/\t/g;
        s/\\".*//g;
        p};
	/appRespProcess/{s/.*","_time":"/app_resp\t/g;
        s/+08:00.*\\"order\\":\\"/\t/g;
        s/\\".*//g;
        p}' "$1" | grep -v '"'
}
grep_cti_ivr_kcc () {
        sed -n '/callworker\.(\*ReportSend)\.post/{
        s/.*","_time":"/post_app\t/g;
        s/+08:00.*\\"type\\":\\"/\t/g;
        s/\\".*//g;
        p};
        /appRespProcess/{s/.*","_time":"/app_resp\t/g;
        s/+08:00.*\\"order\\":\\"/\t/g;
        s/\\".*//g;
        p}' "$1"
}
function grep_cti_app_resp {
    grep 'appRespProcess' "$1" | sed 's/.*"_time":"//g; s/+08:00.*orders/+08:00/g; s/+08:00.*order\\":\\"/\t/g; s/\\".*//g'
}
function grep_cti_ivr_pub { # 过滤 ivr 相关消息
    grep 'callworker.publishAppMsg' "$1"  | sed 's/.*"_time":"//g' | sed 's/","msg":"publishAppMsg success:/\t/g' | sed 's/appID.*//g'
}
function grep_cti_acd { # 过滤和 acd 的交互
     sed -e '/acd.sendHttp.*sendHttp, method: .*:5001/{s/.*_time":"/acd.sendHttp/g;s/\+08:00.*method://g;s/, url://g;s/, params://g;s/\?.*$//g;s/, body.*$//g; /\/asr/d; s/acd.sendHttp//gp};
        /BasicAuthMiddleware.*URL Info/{s/.*_time\":\"//g; s/\+08:00.*URL Info: / /g; s/\?.*//g; s/\// \//; p}' -n "$1" |
     awk '{ printf "%s\t%s\t%s\t%s\n",$1,$2,$3,$4}'
}
function grep_cti_events {
    grep generalPublish "$1" | sed 's/.*_time":"//g; s/+08:00.*payload {\\"type\\":\\"/ /g; s/\\",\\".*\\"call_event\\":\\"/ /g; s/\\".*//g; s/ /\t/g'
}
function grep_cti_http {
    sed '/BasicAuthMiddleware.*URL Info/{s/.*_time\":\"//g; s/\+08:00.*URL Info: / /g; s/\?.*//g; s/\// \//; p}' "$1" -n |
    awk '{printf "%s\t%s\t%s\n",$1,$2,$3}'
}
function grep_cti_channels { # 查看 channelIDs
    grep -Eo 'channel_[0-9]_[a-z]+":"[^"]*"' "$1" | sed '{s/.*://g;s/"//g}' | sort -u
}
function grep_cti_fs_event { # 过滤 fs 事件
    sed '/Event\]\[Received/{s/.*_time\":\"//g; s/\+08:00.*\] / /g;s/\\n.*//g;p}' "$1"  -n  |
    awk '{printf "%s\t%s\n",$1,$2}'
}
function grep_cti_esl { # 过滤和 esl 交互
    sed '/cti\/esl.(\*Client)/{s/.*_time\":\"//g; s/+08:00.*api\]\[/\t/g; s/\]/\t/; s/"\}$//g p}' "$1" -n | sed -E 's/[^\t ]{50,}//g'
}
function rec {
    echo "$@" >> /home/webuser/robincai/record
}
# TODO：坐席状态变化的日志

TMP_TOML_FILE="/home/webuser/robincai/tmp.toml"

# toml_format 格式化 toml 并复制到文件 $TMP_TOML_FILE
# input : toml_cnf_file output_file
function toml_format {
    mkdir -p /home/webuser/robincai
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
    # 用 sed ""s/\r//g"" 可以替换了 \r 符号
}

function toml_list_sections {
    grep -Eo '^\[.*\]$' "$TMP_TOML_FILE"
}

# input : toml_cfg_file section
# output: senction内容（不包含 section）
function toml_read_section {
    local confFile=$1
    local section=$2
    if [ "$#" = 1 ]; then
        confFile=""
        section=$1
    fi

    if ! [ -e "$config_file" ]; then
        toml_format "$config_file"
    fi
    sed "/^\[$section\]$/,/^\[.*\]$/p" "$TMP_TOML_FILE" -n # 只输出当前 section 中的内容（不包含 section）
}
function gen_sql_base {
    toml_read_section "mysql" | awk '
        { m[substr($0, 1, index($0, "=")-1)]=substr($0, index($0, "=")+1) }
        END { printf "mysql -h%s -P%d -u%s -p%s -D%s\n", m["host"], m["port"], m["user"], m["password"], m["db_name"] }
    '
}
function gen_sql_monitor {
    toml_read_section "udesk_monitor" | awk '
        { m[substr($0, 1, index($0, "=")-1)]=substr($0, index($0, "=")+1) }
        END { printf "mysql -h%s -P%d -u%s -p%s -D%s\n", m["mysql_host"], m["mysql_port"], m["mysql_user"], m["mysql_password"], m["mysql_db_name"] }
    '
}
function gen_redis_conn {
    local sec_conf=`toml_read_section "redis"`
    local template=`echo "$sec_conf" | awk '
        { m[substr($0, 1, index($0, "=")-1)]=substr($0, index($0, "=")+1) }
        END { printf "redis-cli -h %s -a %s\n", "HOSTPORT", m["password"] }
    '`
    # 生成连接 sentinels 命令
    sentinels=`echo "$sec_conf" | grep '^sentinel_addresses=' | grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}:[0-9]{4,5}' |
        awk -v tpl="$template" '{ gsub(":", " -p ", $0); tmp=tpl; gsub("HOSTPORT", $0, tmp); print tmp }'`
    echo -e "[sentinel conn]\n$sentinels"

    conn_cmd=`echo "$sentinels" | grep '' -m 1`
    info_sentinel_cmd="$conn_cmd info sentinel"
    # 连到 sentinel 并查到 master 连接命令（密码可能不对，因为用的 sentinel 的）
    eval "$info_sentinel_cmd" | grep -E '^master[0-9]' | grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}:[0-9]{4,5}' |
    awk -v tpl="$template" 'BEGIN {print "[master conn]"} { gsub(":", " -p " ,$0); gsub("HOSTPORT", $0, tpl); print tpl }'
}

function cat_fs_log {
    sed -E 's/^freeswitch.log(.[0-9]*:)?//;/Dialplan: /d; / EXPORT /d; / SET /d;
    s/EXECUTE \[depth=0\] [^ ]*/EXECUTE/g; /Running State Change (CS_EXECUTE)|(CS_ROUTING)/d' "$1" | gawk 'BEGIN {
        RED="\033[31m";  GREEN="\033[32m";  YELLOW="\033[33m";  BLUE="\033[34m";  CYAN="\033[36m";  CLEAR="\033[0m";
        COLOR[1]=RED;    COLOR[2]=GREEN;    COLOR[3]=YELLOW;    COLOR[4]=BLUE;    COLOR[5]=CYAN;    COLOR[0]=CLEAR;
        used_color=0;
    } {
        ori_call_id=$1

        # set color on ori_call_id
        if (!color_group[ori_call_id]) {
            used_color++;
            cur_color = used_color
            color_group[ori_call_id] = cur_color
        } else {
            cur_color = color_group[ori_call_id]
        }
        call_id=COLOR[cur_color]""ori_call_id""COLOR[0]

        # store to username_info
        if (!username_group[call_id] && match($0, "sofia/[^ ]*")) {
            username = substr($0, RSTART, RLENGTH)
            username_group[call_id] = username
            username_info = (username_info?username_info "\n":"") call_id " " username
        }

        # if in SDP state
        if ($0 ~ / Local SDP/) { state="LOCAL_SDP" }
        else if ($0 ~ / Remote SDP:/) { state="REMOTE_SDP" }

        # collect SDP info
        if (state == "LOCAL_SDP" || state == "REMOTE_SDP") {
            if (!$2) { sdp_group[call_id][state]=sdp; sdp = ""; state = ""; }
            if (match($0, "c=IN IP.*")) { sdp = substr($0, RSTART+5, RLENGTH-6); }
            if (match($0, " m=audio [0-9]*")) { sdp=sdp":"substr($0, RSTART+9, RLENGTH-9); }
        }
        gsub("\[[A-Z]*\] [a-z_]*.c:[0-9]* ", "", $0)

        # collect state
        if (match($0, "entering state \[[a-z]*\]\[[0-9]*\]")) {
            fs_state = substr($0, RSTART, RLENGTH)
            fs_state_info = (fs_state_info?fs_state_info"\n":"")call_id" "$2" "$3" "fs_state
        }
        if (match($0, "hanging up, cause: [A-Z_]*")) {
            fs_state = substr($0, RSTART, RLENGTH)
            fs_state_info = (fs_state_info?fs_state_info"\n":"")call_id" "$2" "$3" "fs_state
        }

        print COLOR[cur_color]""$0""COLOR[0]
    }
    END {
        print "---- channels ----:"
        print username_info;
        print "---- sdp info ----:"
        for (call_id in sdp_group) {
            printf("%s [local]%s <-> [remote]%s\n",
                call_id, sdp_group[call_id]["LOCAL_SDP"], sdp_group[call_id]["REMOTE_SDP"] ? sdp_group[call_id]["REMOTE_SDP"]:"x");
        }
        print "---- fs state info ----:"
        print fs_state_info;
    }'
}

function get_callID_by_channelID {
    channel_id=$1
    if [[ ${channel_id} < "  " ]]; then
        return
    fi
    log_file=$2
    if [[ ${log_file} < "  " ]]; then
        log_file=/var/log/kylin_cti/udesk_cti.log
    fi

    grep "$channel_id" "$log_file" | grep call_id -m 1
}
