#!/bin/dash

if [[ ${#} != 1 ]]; then
    echo 'error: 2 arguments needed.'
    exit
fi

if [[ $(echo ${1} | grep -E '[0-9]*:[a-zA-Z0-9.-_]+') = '' ]]; then
    echo 'error'
    exit
fi

version=$(echo ${1} | cut -d ':' -f 1)
file=$(echo ${1} | cut -d ':' -f 2)

if [[ ${version} = '' ]]; then
    if ! [[ -e ".tigger/index/${file}" ]]; then
        echo "tigger-show: error: '${file}' not found in index"
        exit
    else
        cat ".tigger/index/${file}"
        exit
    fi
fi

if ! [[ -e ".tigger/${version}" ]]; then
    echo "tigger-show: error: unknown commit '${version}'"
    exit
fi

if ! [[ -e .tigger/"$version"/"$file" ]]; then
    echo "tigger-show: error: '${file}' not found in commit '${version}'"
    exit
fi

cat ".tigger/${version}/${file}"
