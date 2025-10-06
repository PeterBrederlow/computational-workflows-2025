#!/bin/bash -ue
# Append header only if file does not exist
if [ ! -f names.tsv ]; then
    echo -e "name	title" > names.tsv
fi

# Append the data row
echo -e "Dobby	hero" >> names.tsv
