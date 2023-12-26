#!/bin/bash

VERSION="1.21.5"

wget -4 https://go.dev/dl/go$VERSION.linux-amd64.tar.gz
sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf go$VERSION.linux-amd64.tar.gz

tee -a $HOME/.zshrc <<'EOF'
export GOPROXY=https://goproxy.cn,direct
export GOROOT=/usr/local/go
export PATH=$PATH:/usr/local/go/bin
EOF
