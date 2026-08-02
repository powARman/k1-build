#!/bin/sh

LOG_FILE=/tmp/mcu_update.log
FW_DIR=/home/printer/mcu_fw

MCU0_SERIAL=/dev/ttyS7
BED0_SERIAL=/dev/ttyS9
NOZ0_SERIAL=/dev/ttyS1

MCU0_FORCE_UPDATE=false
BED0_FORCE_UPDATE=false
NOZ0_FORCE_UPDATE=false

write_log()
{
    [ -e $LOG_FILE ] || touch $LOG_FILE
    echo "[$(date "+%Y-%m-%d %H:%M:%S")] $1" >> $LOG_FILE
}

mcu_handshake()
{
    local ret
    local output
    local tty_path=$1

    output=$(mcu_util.py -i $tty_path -c)
    ret=$?
    if [ $ret -ne 0 ]; then
        write_log "$output"
        write_log "handshake $tty_path fail, ret=$ret"
    else
        write_log "handshake $tty_path success"
    fi

    echo $ret
}

get_version()
{
    local version
    local ret
    local tty_path=$1

    version=$(mcu_util.py -i $tty_path -g)
    ret=$?
    if [ $ret != 0 ]; then
        write_log "$version"
        write_log "get_version $tty_path fail, ret=$ret"
        echo "unknown"
    else
        write_log "get_version $version"
        echo "$version"
    fi
}

is_invalid_fw_version()
{
    local version=$1
    local fw_version=
    local fw_check1=
    local fw_check2=

    fw_version=$(echo $version | awk 'BEGIN{FS="-"} {print $2} END{}')
    fw_check1=$(echo $fw_version | awk '{ string=substr($0, 5, 1); print string; }')
    fw_check2=$(echo $fw_version | awk '{ string=substr($0, 9, 1); print string; }')

    if [ "$fw_check1" != "_" -o "$fw_check2" != "_" ]; then
        echo "true"
    else
        echo "false"
    fi
}

compare_version()
{
    local version=$1
    local fw_dir=$2
    local force_update=$3
    local ret_fw_bin=
    local fw_bin=
    local hw_version=
    local fw_version=
    local orig_fw_version=
    local target_fw_version=
    local invalid_fw_version=false
    local tmp=

    # version example: mcu0_110_G32-mcu0_000_000
    hw_version=$(echo $version | awk 'BEGIN{FS="-"} {print $1} END{}')
    fw_version=$(echo $version | awk 'BEGIN{FS="-"} {print $2} END{}')

    invalid_fw_version=$(is_invalid_fw_version $version)
    if [ "$invalid_fw_version" = "true" ]; then
        write_log "invalid fw version $version"
    fi

    cd $fw_dir
    if [ $(ls "$hw_version"*.bin | wc -l) -eq 1 ]; then
        fw_bin=$(ls "$hw_version"*.bin)
        tmp=${fw_bin%.*}
        orig_fw_version=$(echo $version | awk '{ string=substr($0, 19, 3); print string; }')
        target_fw_version=$(echo $tmp | awk '{ string=substr($0, 19, 3); print string; }')
        if [ "$invalid_fw_version" = "true" -o $force_update = "true" -o "$target_fw_version" != "$orig_fw_version" ]; then
            ret_fw_bin=$fw_dir/$fw_bin
            write_log "old version: $version, will update: $ret_fw_bin"
        fi
    elif [ $(ls "$hw_version"*.bin | wc -l) -eq 0 ]; then
        write_log "No firmware file for $hw_version board found!"
    else
        write_log "There should only be one firmware file for $hw_version board!"
    fi

    echo "$ret_fw_bin"
}

startup_app()
{
    local ret
    local output
    local tty_path=$1

    output=$(mcu_util.py -i $tty_path -s)
    ret=$?
    if [ $ret -ne 0 ]; then
        write_log "$output"
        write_log "startup $tty_path fail, ret=$ret"
    else
        write_log "startup app success"
    fi

    echo $ret
}

fw_update()
{
    local ret
    local output
    local tty_path=$1
    local fw_path=$2

    output=$(mcu_util.py -i $tty_path -u -f $fw_path)
    ret=$?
    if [ $ret -ne 0 ]; then
        write_log "$output"
        write_log "fw_update $tty_path fail, $fw_path, ret=$ret"
    else
        write_log "fw_update success"
    fi

    echo $ret
}


MCU0_READY=0
BED0_READY=0
NOZ0_READY=0

if [ $(mcu_handshake $MCU0_SERIAL) -eq 0 ]; then
    MCU0_READY=1
    write_log "mcu0 ready"
fi

if [ $(mcu_handshake $BED0_SERIAL) -eq 0 ]; then
    BED0_READY=1
    write_log "bed0 ready"
fi

if [ $(mcu_handshake $NOZ0_SERIAL) -eq 0 ]; then
    NOZ0_READY=1
    write_log "noz0 ready"
fi

if [ $MCU0_READY = "1" ]; then
    MCU0_VERSION=$(get_version $MCU0_SERIAL)
    if [ "$MCU0_VERSION" != "unknown" ]; then
        write_log "mcu0_version: $MCU0_VERSION"
        FW_BIN=$(compare_version $MCU0_VERSION $FW_DIR $MCU0_FORCE_UPDATE)
        if [ "x$FW_BIN" != "x" ]; then
            write_log "updating mcu0: $FW_BIN"
            $(fw_update $MCU0_SERIAL $FW_BIN)
        else
            $(startup_app $MCU0_SERIAL)
        fi
    fi
fi

if [ $BED0_READY = "1" ]; then
    BED0_VERSION=$(get_version $BED0_SERIAL)
    if [ "$BED0_VERSION" != "unknown" ]; then
        write_log "bed0_version: $BED0_VERSION"
        FW_BIN=$(compare_version $BED0_VERSION $FW_DIR $BED0_FORCE_UPDATE)
        if [ "x$FW_BIN" != "x" ]; then
            write_log "updating bed0: $FW_BIN"
            $(fw_update $BED0_SERIAL $FW_BIN)
        else
            $(startup_app $BED0_SERIAL)
        fi
    fi
fi

if [ $NOZ0_READY = "1" ]; then
    NOZ0_VERSION=$(get_version $NOZ0_SERIAL)
    if [ "$NOZ0_VERSION" != "unknown" ]; then
        write_log "mcu0_version: $NOZ0_VERSION"
        FW_BIN=$(compare_version $NOZ0_VERSION $FW_DIR $NOZ0_FORCE_UPDATE)
        if [ "x$FW_BIN" != "x" ]; then
            write_log "updating noz0: $FW_BIN"
            $(fw_update $NOZ0_SERIAL $FW_BIN)
        else
            $(startup_app $NOZ0_SERIAL)
        fi
    fi
fi

