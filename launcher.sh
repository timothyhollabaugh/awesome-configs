#!/bin/bash

CONFIG=/home/tim/.config/xlunch/xlunch
ENTRIES_FILE=/etc/xlunch/entries.dsv
TOP_ENTRIES_FILE=/home/tim/.config/xlunch/entries.dsv

RESULT=""

case "$1" in
    a)
        RESULT=$(cat $TOP_ENTRIES_FILE $ENTRIES_FILE | awk 'BEGIN {FS=";"} $0 == ";;" {next} $2 == "" {print $0; next} !a[$1]++ {print $0}' | xlunch --config $CONFIG)
        ;;
    *)
        exit 1
esac

echo $1$RESULT


