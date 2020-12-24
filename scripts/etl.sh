#!/usr/bin/env sh

export PATH=/usr/local/bin:${PATH}
export NVD_START_YEAR=${NVD_START_YEAR:-2002}
export GOST_LINUX_DISTROS="debian redhat"
export OVAL_ALPINE_VERSIONS=${OVAL_ALPINE_VERSIONS:-"3.3 3.4 3.5 3.6 3.7 3.8 3.9 3.10"}
export OVAL_AMAZON_VERSIONS=${OVAL_AMAZON_VERSIONS:-""}
export OVAL_DEBIAN_VERSIONS=${OVAL_DEBIAN_VERSIONS:-"8 9 10"}
export OVAL_REDHAT_VERSIONS=${OVAL_REDHAT_VERSIONS:-"6 7 8"}
export OVAL_UBUNTU_VERSIONS=${OVAL_UBUNTU_VERSIONS:-"16 18 20"}

for y in `seq $NVD_START_YEAR $(date +"%Y")`; do \
    echo Load go-cve-dictionary data for year $y...
    go-cve-dictionary fetchnvd -years $y ${@}; \
done

echo Load go-cve-dictionary-data ...
go-exploitdb ${@} fetch exploitdb

for d in GOST_LINUX_DISTROS; do \
    echo Load gost data for distro $d ...
    gost fetch ${@} $d; \
done

echo Load go-msfdb data ...
go-msfdb ${@} fetch msfdb

echo Load goval-dictionary data for Alpine Linux ...
goval-dictionary fetch-alpine ${@} $OVAL_ALPINE_VERSIONS  #3.3 3.4 3.5 3.6 3.7 3.8 3.9 3.10
echo Load goval-dictionary data for Amazon Linux ...
goval-dictionary fetch-amazon ${@} $OVAL_AMAZON_VERSIONS  #
echo Load goval-dictionary data for Debian Linux ...
goval-dictionary fetch-debian ${@} $OVAL_DEBIAN_VERSIONS  #8 9 10
echo Load goval-dictionary data for RedHat Linux ...
goval-dictionary fetch-redhat ${@} $OVAL_REDHAT_VEERSIONS #6 7 8 
echo Load goval-dictionary data for Ubuntu Linux ...
goval-dictionary fetch-ubuntu ${@} $OVAL_UBUNTU_VERSIONS  #16 18 20