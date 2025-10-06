#!/bin/bash -ue
# Create zip version
zip "uppercase.txt.zip" "uppercase.txt"

# Create gzip version
gzip -c "uppercase.txt" > "uppercase.txt.gz"

# Create bzip2 version
bzip2 -c "uppercase.txt" > "uppercase.txt.bz2"
