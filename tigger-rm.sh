#!/bin/dash

function trigger_add
{
    if ! [[ -e '.tigger/.add' ]]; then
        touch '.tigger/.add'
    fi
    echo 1 > '.tigger/.add'
}

function rm_current
{
    if [[ -e "${1}" ]]; then
        rm "${1}"
        trigger_add
    fi
}

function rm_index
{
    if [[ -e ".tigger/index/${1}" ]]; then
        rm ".tigger/index/${1}"
        trigger_add
    fi
}

function check_diff
{
    if ! [[ -e "${2}" ]]; then
        return 1
    else
        if diff "${1}" "${2}" > /dev/null; then
            return 0
        else
            return 1
        fi
    fi
}

function not_in_tigger
{
    if ! [[ -e "${1}" ]]; then
        return
    fi
    if ! [[ -s '.tigger/.log' ]]; then
        num='-1'
    else
        num=$(cat '.tigger/.log' | tail -1 | cut -d ' ' -f 1)
    fi
    if ! check_diff "${1}" ".tigger/index/${1}"; then
        if ! check_diff "${1}" ".tigger/${num}/${1}"; then
            if [[ -e ".tigger/index/${1}" ]]; then
                if ! check_diff ".tigger/index/${1}" ".tigger/${num}/${1}"; then
                    return
                fi
            else
                echo "tigger-rm: error: '${1}' is not in the tigger repository"
                exit
            fi
        fi
    fi
}

function changes_staged_index
{
    if ! [[ -e "${1}" ]]; then
        return
    fi
    if ! [[ -s '.tigger/.log' ]]; then
        num='-1'
    else
        num=$(cat '.tigger/.log' | tail -1 | cut -d ' ' -f 1)
    fi
    if check_diff "${1}" ".tigger/index/${1}"; then
        if ! check_diff "${1}" ".tigger/${num}/${1}"; then
            echo "tigger-rm: error: '${file}' has staged changes in the index"
            exit
        fi
    fi
}

function diffto_workngfile
{
    if ! [[ -e ".tigger/index/${1}" ]]; then
        return
    fi
    if ! [[ -s '.tigger/.log' ]]; then
        num='-1'
    else
        num=$(cat '.tigger/.log' | tail -1 | cut -d ' ' -f 1)
    fi
    if check_diff ".tigger/index/${1}" ".tigger/${num}/${1}"; then
        if ! check_diff ".tigger/index/${1}" "${1}"; then
            echo "tigger-rm: error: '${1}' in the repository is different to the working file"
            exit
        fi
    fi
}

function diff_to_both
{
    if ! [[ -e ".tigger/index/${1}" ]]; then
        return
    fi
    if ! [[ -s '.tigger/.log' ]]; then
        num='-1'
    else
        num=$(cat '.tigger/.log' | tail -1 | cut -d ' ' -f 1)
    fi
    if ! check_diff ".tigger/index/${1}" "${1}"; then
        if ! check_diff ".tigger/index/${1}" ".tigger/${num}/${1}"; then
            echo "tigger-rm: error: '${1}' in index is different to both the working file and the repository"
            exit
        fi
    fi
}

function check_force
{
    if ! [[ -e "${1}" ]]; then
        return
    fi
    if ! [[ -s '.tigger/.log' ]]; then
        num='-1'
    else
        num=$(cat '.tigger/.log' | tail -1 | cut -d ' ' -f 1)
    fi
    if ! [[ -e ".tigger/index/${1}" ]]; then
        if ! check_diff "${1}" ".tigger/${num}/${1}"; then
            echo "tigger-rm: error: '${1}' is not in the tigger repository"
            exit
        fi
    fi
}

if [[ ${1} != '--cached' && ${1} != '--force' ]]; then
    for file in ${@}; do
        not_in_tigger "${file}"
        changes_staged_index "${file}"
        diffto_workngfile "${file}"
        diff_to_both "${file}"
    done
    rm_current "${file}"
    rm_index "${file}"
elif [[ "${1}" = '--cached' ]]; then
    for file in ${@}; do
        if [[ "${file}" != '--cached' ]]; then
            not_in_tigger "${file}"
            diff_to_both "${file}"
        fi
        rm_index ${file}
    done
elif [[ "${1}" = '--force' ]]; then
    if [[ "$2" = '--cached' ]]; then
        for file in ${@}; do
            if [[ "${file}" != '--force' && "${file}" != '--cached' ]]; then
                rm_index "${file}"
                exit
            fi
        done
    fi
    for file in ${@}; do
        if [[ "${file}" != '--force' ]]; then
            check_force "${file}"
            rm_current "${file}"
            rm_index "${file}"
        fi
    done
fi
