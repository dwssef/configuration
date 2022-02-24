#!/bin/bash

VERSION="1.17.1"

source .bashrc
wget https://studygolang.com/dl/golang/go$VERSION.linux-amd64.tar.gz
tar xvfz go$VERSION.linux-amd64.tar.gz
rm -rf /usr/local/go
mv go /usr/local/

# go get golang.org/x/tools/cmd/goimports
# go get github.com/nsf/gocode

rm go$VERSION.linux-amd64.tar.gz -rf


tee -a $HOME/.bashrc <<'EOF'
export GOPROXY=https://goproxy.cn,direct
export GOROOT=/usr/local/go
export GOPATH=$HOME/go
export PATH=$GOPATH/bin:$GOROOT/bin:$PATH
EOF
