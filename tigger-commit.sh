#!/bin/dash

if ! [[ -e '.tigger/.add' ]]; then
    echo 0 > '.tigger/.add'
fi

#judge command = -m
if [[ ${1} = '-m' ]]; then
    if [[ ${#} != 2 ]]; then
        echo '2 arguments needed'
        exit
    fi
fi

#judge command = -a -m
if [[ ${1} = '-a' ]]; then
    if [[ ${#} != 3 ]]; then
        echo '3 arguments needed'
        exit
    fi
    #add new version into index advancely
    for file in .tigger/index/*
    do
        file=$(echo "${file}" | cut -d '/' -f 3)
        $(tigger-add "${file}")
    done
fi

#judge add
if [[ $(cat '.tigger/.add') = 0 ]]; then
    echo 'nothing to commit'
    exit
fi
echo 0 > '.tigger/.add'

#create .log
if ! [[ -e '.tigger/.log' ]]; then
    #create .log.txt to record commit
    touch '.tigger/.log'
fi

#num of new log/repository
if ! [[ -s '.tigger/.log' ]]; then
    num='-1'
else
    num=$(cat '.tigger/.log' | tail -1 | cut -d ' ' -f 1)
fi

current='master'
if [[ -e '.tigger/.current' ]]; then
    current=$(cat '.tigger/.current')
else
    echo 'master' > '.tigger/.current'
    current='master'
fi

if ! [[ -e '.tigger/branch' ]]; then
    mkdir '.tigger/branch'
fi

if ! [[ -e '.tigger/branch/master' ]]; then
    mkdir '.tigger/branch/master'
fi

num=$((num + 1))
mkdir ".tigger/${num}"
record="${num} ${2}"
echo "${record}" >> '.tigger/.log'
echo "Committed as commit ${num}"
if [[ "$(ls -A .tigger/index)" != '' ]]; then
    cp .tigger/index/* .tigger/${num}/
    if [[ "$(ls -A .tigger/branch/${current})" != '' ]]; then
        rm .tigger/branch/${current}/*
    fi
    cp .tigger/index/* .tigger/branch/${current}/
fi
