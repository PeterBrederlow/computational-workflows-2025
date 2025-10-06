params.step = 0


workflow{

    // Task 1 - Read in the samplesheet.

    if (params.step == 1) {
        channel.fromPath('samplesheet.csv')
            .set { samplesheet_ch }
        
        samplesheet_ch.view() 
    }

    // Task 2 - Read in the samplesheet and create a meta-map with all metadata and another list with the filenames ([[metadata_1 : metadata_1, ...], [fastq_1, fastq_2]]).
    //          Set the output to a new channel "in_ch" and view the channel. YOU WILL NEED TO COPY AND PASTE THIS CODE INTO SOME OF THE FOLLOWING TASKS (sorry for that).

    if (params.step == 2) {
        samplesheet_ch = channel.fromPath('samplesheet.csv').splitCsv(header:true)
        in_ch = samplesheet_ch
            .map { row ->
                def meta = row.clone()
                def files = [ meta.remove('fastq_1'), meta.remove('fastq_2') ]
                [meta, files]
            }
        in_ch.view()
    }

    // Task 3 - Now we assume that we want to handle different "strandedness" values differently. 
    //          Split the channel into the right amount of channels and write them all to stdout so that we can understand which is which.

    if (params.step == 3) {
        samplesheet_ch = channel.fromPath('samplesheet.csv').splitCsv(header:true)
        in_ch = samplesheet_ch
            .map { row ->
                def meta = row.clone()
                def files = [ meta.remove('fastq_1'), meta.remove('fastq_2') ]
                [meta, files]
            }
        forward_ch = in_ch.filter { it[0].'strandedness' == 'forward' }
        reverse_ch = in_ch.filter { it[0].'strandedness' == 'reverse' }
        auto_ch = in_ch.filter { it[0]['strandedness'] == 'auto' }

        forward_ch.view()
        reverse_ch.view()
    }

    // Task 4 - Group together all files with the same sample-id and strandedness value.

    if (params.step == 4) {
        samplesheet_ch = channel.fromPath('samplesheet.csv').splitCsv(header:true)
        in_ch = samplesheet_ch
            .map { row ->
                def meta = row.clone()
                def files = [ meta.remove('fastq_1'), meta.remove('fastq_2') ]
                [meta, files]
            }
        grouped_ch = in_ch.groupTuple(
            by: { meta, files -> [meta.sample, meta.strandedness] },
            value: { meta, files -> files }
            )
        grouped_ch.view()
    }



}