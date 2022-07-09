#!/bin/dash

function trigger_add
{
    if ! [[ -e '.tigger/.add' ]]; then
        touch '.tigger/.add'
    fi
    echo 1 > '.tigger/.add'
}

if ! [[ -e '.tigger' ]]; then
    echo "${0}: error: tigger repository directory .tigger not found"
    exit
fi

if ! [[ -e '.tigger/index' ]]; then
    mkdir '.tigger/index'
fi

for file in ${@}; do
    if ! [[ -e "${file}" ]]; then
        if ! [[ -e ".tigger/index/${file}" ]]; then
            echo "${0}: error: can not open '${file}'"
            exit
        fi
    fi
done

for file in ${@}; do
    if [[ -e "${file}" ]]; then
        if ! [[ -e ".tigger/index/${file}" ]]; then
            cp -rf "${file}" '.tigger/index'
            trigger_add
        elif [[ -e ".tigger/index/${file}" ]]; then
            if ! diff "${file}" ".tigger/index/${file}" > /dev/null; then
                cp -rf "${file}" '.tigger/index'
                trigger_add
            fi
        fi
    fi
    if ! [[ -e "${file}" ]]; then
        if [[ -e ".tigger/index/${file}" ]]; then
            trigger_add
        fi
    fi
done
