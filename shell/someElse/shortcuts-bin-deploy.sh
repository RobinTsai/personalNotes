alias self="mkdir -p /tmp/webuser/ccps; cd /tmp/webuser/ccps; pwd"

alias ccps="cd /usr/local/kylin_cti/current; pwd"
alias cdOpenresty="cd /usr/local/openresty"
alias cdFreeswitch="cd /usr/local/freeswitch/conf"

alias logCcps="cd /var/log/kylin_cti; pwd"
alias logFs="cd /usr/local/freeswitch/log; pwd"
alias logApigw="cd /var/log/udesk_api_gtw; pwd"
alias logOpenresty=logApigw

alias ll="ls -htrl"
alias l="ll"
alias grepv="grep -v grep | grep "

alias grep_tower_conns="grep -Eo 'conn_id[^,]*' "
alias grep_fs_hangup="grep 'Hangup sofia/' "
alias grep_fs_new_channel="grep 'New Channel sofia/' "

# ------------- tower 日志相关 -------------
function grep_tower_events {
    grep 'Method' "$1" | sed -e 's/.*_time":"//g' -e '/SignalHub-msgMap/d' -e '/Inbox/d' -e '/GetAgentStatusOptions/d' -e '/+++Read/d' -e 's/+08:00".*Method\\":\\"/ /g' -e 's/\\":\\"/:/g' -e 's/\\",\\"/ /' -e 's/\\",\\"/,/g' |
    awk 'function get(raw, start, end){
            startIdx=index(raw, start)
            len=index(substr(raw, startIdx), end)
            result=substr(raw, startIdx, len-length(end))
            return result
        }
    {
        if ($2 ~ /GetState/) {
            state=get($3, "CurState:", ",")
            mode=get($3, "CurMode:", ",")
            printf "%-29s\t%-20s\t%s,%s\n", $1, $2, state, mode
        } else if ($2 ~ /AgentCallModeChange/) {
            mode=get($3, "CurContact:", ",")
            extState=get($3, "CurExtState:", ",")
            printf "%-29s\t%-20s\t%s,%s\n", $1, $2, mode, extState
        # } else if ($2 ~ /Delivered/) {
        # } else if ($2 ~ /AgentStateChange/) {
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
        p}' "$1"
}
function grep_cti_app_resp {
    grep 'appRespProcess' "$1" | sed 's/.*"_time":"//g; s/+08:00.*orders/+08:00/g; s/+08:00.*order\\":\\"/\t/g; s/\\".*//g'
}
function grep_cti_app_msg { # 过滤 ivr 相关消息
    grep 'callworker.publishAppMsg' "$1"  | sed 's/.*"_time":"//g' | sed 's/","msg":"publishAppMsg success:/\t/g' | sed 's/appID.*//g'
}
function grep_cti_acd { # 过滤和 acd 的交互
     sed -e '/acd.sendHttp.*sendHttp, method: .*:5001/{s/.*_time":"/acd.sendHttp/g;s/\+08:00.*method://g;s/, url://g;s/, params://g;s/\?.*$//g;s/, body.*$//g; /\/asr/d; s/acd.sendHttp//gp}' -n "$1" |
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
    grep -Eo 'channel_[0-9]_id":"[^"]*"' "$1" | sed '{s/.*://g;s/"//g}' | sort -u
}
function grep_cti_fs_event { # 过滤 fs 事件
    sed '/Event\]\[Received/{s/.*_time\":\"//g; s/\+08:00.*\] / /g;s/\\n.*//g;p}' "$1"  -n  |
    awk '{printf "%s\t%s\n",$1,$2}'
}
function grep_cti_esl { # 过滤和 esl 交互
    sed '/cti\/esl.(\*Client)/{s/.*_time\":\"//g; s/+08:00.*api\]\[/\t/g; s/\]/\t/; s/"\}$//g p}' "$1" -n | sed -E 's/[^\t ]{50,}//g'
}

TMP_TOML_FILE="/tmp/webuser/ccps/tmp.toml"

# toml_format 格式化 toml 并复制到文件 $TMP_TOML_FILE
# input : toml_cnf_file output_file
function toml_format {
    mkdir -p /tmp/webuser/ccps
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
    local template=`echo $sec_conf | awk '
        { m[substr($0, 1, index($0, "=")-1)]=substr($0, index($0, "=")+1) }
        END { printf "redis-cli -h %s -a %s\n", "HOSTPORT", m["password"] }
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
