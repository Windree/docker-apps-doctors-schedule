#!/bin/bash
<<EOF
apt update && apt install curl jq -y
bash /app/init.sh
EOF
set -euo pipefail

function main(){
    local affilate=2
    read_dates "$affilate" | while read date; do
        read_doctors "$affilate" "$date" | while read doctor; do
            local doctor_id=$(echo $doctor | jq --raw-output ".id")
            local last_name=$(echo $doctor | jq --raw-output ".lastName")
            local first_name=$(echo $doctor | jq --raw-output ".firstName")
            read_schedule  "$affilate" "$date" "$doctor_id" | while read schedule; do
                local time=$(echo $schedule | jq --raw-output ".time")
                local shortTime=$(echo $(echo $time | cut -d: -f1):$(echo $time | cut -d: -f2))
                echo "$date $first_name $last_name $shortTime"
            done
        done
    done
}


function read_dates(){
    curl -s "http://reg.npcpn.ru/api/appointment/appointableDates?affilateId=$1" | jq --raw-output '.[]' | while read str; do
        local year=$(echo $str | cut -d- -f1)
        local month=$(echo $str | cut -d- -f2)
        local date=$(echo $str | cut -d- -f3)
        echo "$month/$date/$year"
    done
}

function read_doctors(){
    curl -s "http://reg.npcpn.ru/api/appointment/appointableDoctors?affilateId=$1&date=$2" | jq -c '.[]' 
}

function read_schedule(){
    curl -s "http://reg.npcpn.ru/api/appointment/appointableSeances?affilateId=$1&date=$2&doctorId=$3" | jq -c '.[]' 
}

main
