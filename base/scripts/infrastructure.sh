#!/bin/bash



function fun_update(){
    cd ../../environments/$1
    rm -rf .terraform
    terraform init
    terraform apply -auto-approve
}




case "$1" in
prod)
    fun_update $1
    ;;
nonprod)
    fun_update $1
    ;;
int)
    fun_update $1
    ;;
stage)
    fun_update $1
    ;;
test)
    fun_update $1
    ;;
admin)
    fun_update $1
    ;;
    *)
    echo "Usage: $0 update {prod|nonprod|int|stage|test|admin}"
    ;;
esac