params.step = 0
params.zip = 'zip'


 process SAYHELLO {
    echo true
    """
    echo "Hello World!"
    """
 }

process SAYHELLO_PYTHON{
            debug true
            script:
            """
            #!/usr/bin/env python3
            print("Hello World!")
            """
}

process SAYHELLO_PARAM {
    input:
    val greeting_ch 

    echo true
    output: stdout

    script:
    """
    echo "$greeting_ch"
    """
}

process SAYHELLO_FILE{
    input:
    val greeting_ch 

    output:
    path "greeting.txt"

    script:
    """
    echo "$greeting_ch" > greeting.txt
    """
}

process UPPERCASE {
    publishDir 'results', mode: 'copy'

    input:
    val text

    output:
    path 'uppercase.txt'

    script:
    """
    echo "$text" | tr '[:lower:]' '[:upper:]' > uppercase.txt
    """
}


process PRINTUPPER {
    debug true
    input:
    path upper_file

    output:
    stdout

    script:
    """
    echo "Content of the uppercase file:"
    cat "$upper_file"
    """
}

process ZIPFILE {
    publishDir 'results', mode: 'copy'

    input:
    path file_to_zip
    val zip_format

    output:
    path '*.*', emit: zipped_file

    script:
    """
    if [ "$zip_format" = "zip" ]; then
        zip file.zip "$file_to_zip"
        echo "Zipped file path: \$(realpath file.zip)"
    elif [ "$zip_format" = "gzip" ]; then
        gzip -c "$file_to_zip" > file.gz
        echo "Gzip file path: \$(realpath file.gz)"
    elif [ "$zip_format" = "bzip2" ]; then
        bzip2 -c "$file_to_zip" > file.bz2
        echo "Bzip2 file path: \$(realpath file.bz2)"
    fi
    """
}

process ZIP_ALL {
    publishDir 'results', mode: 'copy'

    input:
    path file_to_zip

    output:
    path '*.*', emit: zipped_files  

    script:
    """
    # Create zip version
    zip "${file_to_zip}.zip" "$file_to_zip"

    # Create gzip version
    gzip -c "$file_to_zip" > "${file_to_zip}.gz"

    # Create bzip2 version
    bzip2 -c "$file_to_zip" > "${file_to_zip}.bz2"
    """
}

process WRITETOFILE {
    publishDir 'results', mode: 'copy'

    input:
    val in_ch

    output:
    path 'names.tsv'

    script:
    def content = in_ch.collect { "${it.name}\t${it.title}" }.join("\n")
    """
    echo -e "name\ttitle\n${content}" > names.tsv
    """
}

workflow {

    // Task 1 - create a process that says Hello World! (add debug true to the process right after initializing to be sable to print the output to the console)
    if (params.step == 1) {
        SAYHELLO()
    }

    // Task 2 - create a process that says Hello World! using Python
    if (params.step == 2) {
        SAYHELLO_PYTHON()
    }

    // Task 3 - create a process that reads in the string "Hello world!" from a channel and write it to command line
    if (params.step == 3) {
        greeting_ch = Channel.of("Hello world!")
        SAYHELLO_PARAM(greeting_ch)
    }

    // Task 4 - create a process that reads in the string "Hello world!" from a channel and write it to a file. WHERE CAN YOU FIND THE FILE?
    if (params.step == 4) {
        greeting_ch = Channel.of("Hello world!")
        SAYHELLO_FILE(greeting_ch)
    }

    // Task 5 - create a process that reads in a string and converts it to uppercase and saves it to a file as output. View the path to the file in the console
    if (params.step == 5) {
        greeting_ch = Channel.of("Hello world!")
        out_ch = UPPERCASE(greeting_ch)
        out_ch.view()
    }

    // Task 6 - add another process that reads in the resulting file from UPPERCASE and print the content to the console (debug true). WHAT CHANGED IN THE OUTPUT?
    if (params.step == 6) {
        greeting_ch = Channel.of("Hello world!")
        out_ch = UPPERCASE(greeting_ch)
        PRINTUPPER(out_ch)
    }

    
    // Task 7 - based on the paramater "zip" (see at the head of the file), create a process that zips the file created in the UPPERCASE process either in "zip", "gzip" OR "bzip2" format.
    //          Print out the path to the zipped file in the console
    if (params.step == 7) {
        greeting_ch = Channel.of("Hello world!")
        out_ch = UPPERCASE(greeting_ch)
        ZIPFILE(out_ch, params.zip)
        .view { "Zipped file created at: $it" }
    }

    // Task 8 - Create a process that zips the file created in the UPPERCASE process in "zip", "gzip" AND "bzip2" format. Print out the paths to the zipped files in the console

    if (params.step == 8) {
        greeting_ch = Channel.of("Hello world!")
        out_ch = UPPERCASE(greeting_ch)
        ZIP_ALL(out_ch)
        .view { "Zipped file created: $it" }
    }

    // Task 9 - Create a process that reads in a list of names and titles from a channel and writes them to a file.
    //          Store the file in the "results" directory under the name "names.tsv"

    if (params.step == 9) {
        in_ch = channel.of(
            ['name': 'Harry', 'title': 'student'],
            ['name': 'Ron', 'title': 'student'],
            ['name': 'Hermione', 'title': 'student'],
            ['name': 'Albus', 'title': 'headmaster'],
            ['name': 'Snape', 'title': 'teacher'],
            ['name': 'Hagrid', 'title': 'groundkeeper'],
            ['name': 'Dobby', 'title': 'hero'],
        ).toList()

        in_ch
            | WRITETOFILE
    }

}