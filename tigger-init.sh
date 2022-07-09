#!/bin/dash

if [[ ${#} != 0 ]]; then
    echo 'usage: tigger-init'
    exit
else
    if [[ -e '.tigger' ]]; then
        echo 'tigger-init: error: .tigger already exists'
        exit
    else
        mkdir '.tigger'
        echo 'Initialized empty tigger repository in .tigger'
    fi
fi
