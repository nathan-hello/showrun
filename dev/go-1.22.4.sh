#/bin/bash

# Two ways to get go: get prebuilt binary and use that to compile future versions
#
# Or, more basedly, compile go1.4 because that was written in C, then use that to bootstrap
#
# https://go.dev/doc/install/source
# The minimum version of Go required depends on the target version of Go:
#   Go <= 1.4: a C toolchain.
#   1.5 <= Go <= 1.19: a Go 1.4 compiler.
#   1.20 <= Go <= 1.21: a Go 1.17 compiler.
#   1.22 <= Go <= 1.23: a Go 1.20 compiler.
# Going forward, Go version 1.N will require a Go 1.M compiler, where M is N-2 rounded down to an even number. Example: Go 1.24 and 1.25 require Go 1.22.
#
# For now, we just want a recent go version so gvm can pick up from there

curl -L https://go.dev/dl/go1.22.4.linux-amd64.tar.gz -o /tmp/go1.22.4.linux-amd64.tar.gz 

rm -rf /usr/local/go 

tar -C /usr/local -xzf /tmp/go1.22.4.linux-amd64.tar.gz

go version
