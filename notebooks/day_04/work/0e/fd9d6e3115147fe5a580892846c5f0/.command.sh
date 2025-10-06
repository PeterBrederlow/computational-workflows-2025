#!/bin/bash -ue
if [ "zip" = "zip" ]; then
    zip file.zip "uppercase.txt"
    echo "Zipped file path: $(realpath file.zip)"
elif [ "zip" = "gzip" ]; then
    gzip -c "uppercase.txt" > file.gz
    echo "Gzip file path: $(realpath file.gz)"
elif [ "zip" = "bzip2" ]; then
    bzip2 -c "uppercase.txt" > file.bz2
    echo "Bzip2 file path: $(realpath file.bz2)"
fi
