#!/bin/bash
set -ex

# log infos about Linux kernel, OS system release and gcc version
uname -a
cat /etc/*release
gcc --version

# we need this env var for the Go 1.5.x bootstrap build process
GOROOT_BOOTSTRAP=$HOME/go1.4 

# install a pre-compiled Go 1.4.x tarball to bootstrap
GO_BOOTSTRAP_GOARM=${GO_BOOTSTRAP_GOARM:-7}
GO_BOOTSTRAP_VERSION=${GO_BOOTSTRAP_VERSION:-1.4.3}
rm -fr "$GOROOT_BOOTSTRAP"
mkdir -p "$GOROOT_BOOTSTRAP"
curl -sSL "https://github.com/hypriot/golang-armbuilds/releases/download/v${GO_BOOTSTRAP_VERSION}/go${GO_BOOTSTRAP_VERSION}.linux-armv${GO_BOOTSTRAP_GOARM}.tar.gz" | tar xz -C "$GOROOT_BOOTSTRAP" --strip-components=1

# fetch Go 1.5.x source tarball
GOARM=${GOARM:-7}
GO_VERSION=${GO_VERSION:-1.5.1}
rm -fr /usr/local/go
curl -sSL "https://storage.googleapis.com/golang/go${GO_VERSION}.src.tar.gz" | tar xz -C /usr/local

# now compile Go 1.5.x and package it as a tarball
pushd /usr/local/go/src
if [ "x${SKIP_TESTS}" != "x" ]; then
  echo "Compile Go, skip tests."
  time ./make.bash 2>&1
else
  echo "Compile Go, run tests."
  time ./all.bash 2>&1
fi
cd ../..
tar --numeric-owner -czf "go${GO_VERSION}.linux-armv${GOARM}.tar.gz" go
popd
mv "/usr/local/go${GO_VERSION}.linux-armv${GOARM}.tar.gz" .

# cleanup
rm -fr "$GOROOT_BOOTSTRAP"
rm -fr /usr/local/go
