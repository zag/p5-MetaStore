#!/bin/sh
files_path=$2;
files=`ls ${files_path}`
gallery=$1
 mkdir -p ${gallery} 
 gallery_id=`metastore.pl -c -d ${gallery}` || exit 1
 tempfoo=`basename $0`
 for _file in ${files}; do
#  TMPFILE=`mktemp /tmp/${_file}.${tempfoo}.XXXXXX.${_file}` || exit 1
  TMPFILE=`mktemp /tmp/${_file}.preview.XXXX.jpg` || exit 1
     image_file=${files_path}/${_file}
     echo  ${files_path}/${_file}
     convert -resize 200x150 -quality 85  -sharpen 2 ${image_file} ${TMPFILE}
     metastore.pl -a -id ${gallery_id} -d ${gallery} -preview ${TMPFILE} ${image_file} 
     unlink ${TMPFILE}
 done
#echo ${files} 