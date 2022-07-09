#!/bin/dash

rm .tigger/.status > /dev/null 2>&1

#check 2 file different (think file 1 always exists by default)
function check_diff
{
    #1 exist 2 not exist || 1 exist 2 exist but diff
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

current_branch=$(cat '.tigger/.current')
num=branch/${current_branch}

for file in .tigger/${num}/*
do
    file_working=$(echo "${file}" | cut -d '/' -f 4)
    if ! [[ -e "${file_working}" ]]; then
        if ! [[ -e ".tigger/index/${file_working}" ]]; then
            echo "${file_working} - deleted" >> '.tigger/.status'
        else
            echo "${file_working} - file deleted" >> '.tigger/.status'
        fi
    fi
done

for file in *; do
    if [[ -e ".tigger/${num}/${file}" ]]; then
        if check_diff "${file}" ".tigger/${num}/${file}"; then
            echo "${file} - same as repo" >> '.tigger/.status'
            continue
        fi
    fi
    if ! [[ -e ".tigger/index/${file}" ]]; then
        echo "${file} - untracked" >> '.tigger/.status'
        continue
    fi
    if [[ -e ".tigger/index/${file}" && ! -e ".tigger/${num}/${file}" ]]; then
        if check_diff "${file}" ".tigger/index/${file}"; then
            echo "${file} - added to index" >> '.tigger/.status'
            continue
        fi
    fi
    if [[ -e ".tigger/index/${file}" && -e ".tigger/${num}/${file}" ]]; then
        if ! check_diff "${file}" ".tigger/index/${file}"; then
            if check_diff ".tigger/index/${file}" ".tigger/${num}/${file}"; then
                echo "${file} - file changed, changes not staged for commit" >> '.tigger/.status'
                continue
            else
                echo "${file} - file changed, different changes staged for commit" >> '.tigger/.status'
                continue
            fi
        else
            if ! check_diff ".tigger/index/${file}" ".tigger/${num}/${file}"
            then
                echo "${file} - file changed, changes staged for commit" >> '.tigger/.status'
                continue
            fi
        fi
    fi
done

cat '.tigger/.status' | grep -Ev '\*' | sort
