#!/bin/bash

if [ ! -f "gvm/conf" ]; then
    echo "ERROR : gvm/conf is missing!!!"
    exit
fi

for line in `cat gvm/conf`
do
    if [ -n "$1" ];then
        product=$1
    else 
        if [[ $line == [product:* ]];then 
            product=${line##*[product:}
            product=${product%%]*}
        fi
    fi
done

if [ -z "${product}" ]; then
   echo "product is empty!!!"
   exit
fi


ver=$(git tag --contains)
echo ------------------------------
echo HEAD:
echo $(git log -n 1)
echo -------------------------------
if [ -z "${ver}" ]; then
   echo "need git tag !!!!!"
   exit
fi

build=$(git log -n 1 --pretty=format:"%h")
version=${ver}-${build}

echo ''
echo "* product: ${product}"
echo "* version: ${version}"
echo -------------------------------

tar=${product}-${version}.tar.gz
rd=releasenotes.md

if [ ! -f "${rd}" ]; then
    echo '' > ${rd}
fi

echo '# '${ver} >> ${rd}

echo '## Manifest' >> ${rd}

# rename file
if [ -f "gvm/${product}.tar.gz" ]; then
	echo move gvm/${product}.tar.gz to gvm/${tar}
	mv gvm/${product}.tar.gz gvm/${tar}
fi


# generate md5
if [ -f "gvm/${tar}" ]; then
    md5info=`md5sum gvm/${tar}`
    md5=${md5info:0:32}
	echo file: ${tar} >> ${rd}
	echo md5: ${md5} >> ${rd}
fi

# release notes
echo '' >> ${rd}
echo '## Release Notes' >> ${rd}
echo '' >> ${rd}
headcommit_ver=$(git for-each-ref --sort=taggerdate --format '%(tag)' refs/tags | tail -n -1)
precommit_ver=$(git for-each-ref --sort=taggerdate --format '%(tag)' refs/tags | tail -n -2 | head -n 1)
releaseNotes=$(git log  ${headcommit_ver}...${precommit_ver} | grep -v commit | grep -v Author | grep -v Date)
echo ${releaseNotes} >> ${rd}
