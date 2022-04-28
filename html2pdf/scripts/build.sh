#!/usr/bin/env bash

set -x
GOOS=linux GOARCH=amd64 go build -o build/html2pdf
cd build && upx html2pdf
