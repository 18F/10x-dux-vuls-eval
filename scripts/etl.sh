#!/usr/bin/env sh

echo Load go-cve-dictionary data ...

for i in `seq 2002 $(date +"%Y")`; do \
    echo Starting year $i ...
    go-cve-dictionary fetchnvd ${@} -years $i; \
done

echo Load go-cve-dictionary-data ...
go-exploitdb ${@} fetch exploitdb

echo Load gost data ...
gost fetch ${@} debian
gost fetch ${@} redhat

echo Load go-msfdb data ...
go-msfdb ${@} fetch msfdb

echo Load goval-dictionary data ...
goval-dictionary fetch-redhat ${@} 6 7 8 
goval-dictionary fetch-amazon ${@}
goval-dictionary fetch-debian ${@} 8 9 10
goval-dictionary fetch-ubuntu ${@} 16 18 20
goval-dictionary fetch-alpine ${@} 3.3 3.4 3.5 3.6 3.7 3.8 3.9 3.10