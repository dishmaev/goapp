#!/bin/sh

###header

readonly VAR_PARAMETERS='$1 script name without extenstion, $2 suite, $3 make output, $4 source tar.gz file name, $5 build tar.gz file name'

if [ -r ${1}.ok ]; then rm ${1}.ok; fi
exec 1>${1}.log
exec 2>${1}.err
exec 3>${1}.tst
if [ "$#" != "5" ]; then echo "Call syntax: $(basename "$0") $VAR_PARAMETERS"; exit 1; fi

###function

checkRetValOK(){
  if [ "$?" != "0" ]; then exit 1; fi
}

#$1 suite
getConfigName(){
    if [ "$1" = "dev" ] || [ "$1" = "tst" ]; then
      echo 'Debug'
    elif [ "$1" = "rel" ]; then
      echo 'Release'
    else #error
      exit 1
    fi
}

###body

echo "Current build suite: $2"

uname -a

readonly CONST_PACKAGE_SPEC=package-spec.cfg
readonly CONST_PACKAGE_HEADER=version/package-spec.go
readonly CONST_FIELD_SPEC_VERSION=CONST_PACKAGE_VERSION

VAR_CONFIG=$(getConfigName "$2") || exit 1

mkdir build
checkRetValOK
tar -xvf $4 -C build/
checkRetValOK
cd build
if [ -r "$CONST_PACKAGE_HEADER" ]; then
  echo "Upgrade $PWD/$CONST_PACKAGE_HEADER from $PWD/$CONST_PACKAGE_SPEC"
  VAR_VERSION=$(cat $CONST_PACKAGE_SPEC | grep $CONST_FIELD_SPEC_VERSION | cut -d ' ' -f 2)
  checkRetValOK
  sed -i "/$CONST_FIELD_SPEC_VERSION/c const CONST_PACKAGE_VERSION = \"$VAR_VERSION\"" $CONST_PACKAGE_HEADER
  checkRetValOK
fi
go build -o dist/${VAR_CONFIG}_APT/GNU-Linux/hello hello.go package-spec.go
checkRetValOK
bash -x package-apt.bash dist/${VAR_CONFIG}_APT/GNU-Linux $3 QMAKE=/usr/bin/qmake
checkRetValOK
tar -cvf $HOME/$5 -C dist/${VAR_CONFIG}_APT/GNU-Linux/package .
checkRetValOK

cd $HOME

##test

if [ ! -f "$5" ]; then echo "Build file $5 not found"; exit 1; fi

for VAR_CUR_PACKAGE in $HOME/build/dist/${VAR_CONFIG}_APT/GNU-Linux/package/*.deb; do
  if [ ! -r "$VAR_CUR_PACKAGE" ]; then continue; fi
  dpkg-deb -I $VAR_CUR_PACKAGE >&3
  checkRetValOK
done

###finish

echo 1 > ${1}.ok
exit 0
