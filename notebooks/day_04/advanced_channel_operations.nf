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
        samplesheet_ch = channel.fromPath('samplesheet.csv').splitCsv(header:true, sep: ',')
        in_ch = samplesheet_ch
            .map { row ->
                def meta  = [:]
                def files  = []
            
            // Extract metadata (everything except file paths)
                meta.id = row.sample
                meta.strandedness = row.strandedness
                
                // Extract file paths
                files = [row.fastq_1, row.fastq_2]
                
                return [meta, files]
            }
        
        in_ch.view()
    }

    // Task 3 - Now we assume that we want to handle different "strandedness" values differently. 
    //          Split the channel into the right amount of channels and write them all to stdout so that we can understand which is which.

     if (params.step == 3) {
        samplesheet_ch = channel.fromPath('samplesheet.csv').splitCsv(header:true, sep: ',')
        in_ch = samplesheet_ch
            .map { row ->
                def meta  = [:]
                def files  = []
            
            // Extract metadata (everything except file paths)
                meta.id = row.sample
                meta.strandedness = row.strandedness
                
                // Extract file paths
                files = [row.fastq_1, row.fastq_2]
                
                return [meta, files]
            }
        
        // Branch based on strandedness
        branched = in_ch.branch {
            forward: it[0].strandedness == 'forward'
            reverse: it[0].strandedness == 'reverse'
            unstranded: it[0].strandedness == 'unstranded'
            auto: it[0].strandedness == 'auto'
        }
        
        // Display each branch with labels
        branched.forward.view { "FORWARD: $it" }
        branched.reverse.view { "REVERSE: $it" }
        branched.unstranded.view { "UNSTRANDED: $it" }
        branched.auto.view { "AUTO: $it" }
    }
    // if (params.step == 3) {
    //     samplesheet_ch = channel.fromPath('samplesheet.csv').splitCsv(header:true)
    //     in_ch = samplesheet_ch
    //         .map { row ->
    //             def meta = row.clone()
    //             def files = [ meta.remove('fastq_1'), meta.remove('fastq_2') ]
    //             [meta, files]
    //         }
    //     forward_ch = in_ch.filter { it[0].'strandedness' == 'forward' }
    //     reverse_ch = in_ch.filter { it[0].'strandedness' == 'reverse' }
    //     auto_ch = in_ch.filter { it[0]['strandedness'] == 'auto' }

    //     forward_ch.view()
    //     reverse_ch.view()
    // }

    // Task 4 - Group together all files with the same sample-id and strandedness value.
    if (params.step == 4) {
        samplesheet_ch = channel.fromPath('samplesheet.csv').splitCsv(header:true, sep: ',')
        in_ch = samplesheet_ch
            .map { row ->
                def meta  = [:]
                def files  = []
            
            // Extract metadata (everything except file paths)
                meta.id = row.sample
                meta.strandedness = row.strandedness
                
                // Extract file paths
                files = [row.fastq_1, row.fastq_2]
                
                return [meta, files]
            }
        
        // Group by sample ID and strandedness combination
        grouped = in_ch.groupTuple(by: [0])  // Group by the first element (meta map)
        grouped.view { meta, filesList ->
            "SAMPLE: ${meta.id}, STRANDEDNESS: ${meta.strandedness} -> FILES: ${filesList}"
        }
    }
    // if (params.step == 4) {
    //     samplesheet_ch = channel.fromPath('samplesheet.csv').splitCsv(header:true)
    //     in_ch = samplesheet_ch
    //         .map { row ->
    //             def meta = row.clone()
    //             def files = [ meta.remove('fastq_1'), meta.remove('fastq_2') ]
    //             tuple(meta, files)
    //         }
    //     grouped_ch = in_ch
    //     grouped_ch = grouped_ch.groupTuple(by: { it[0]['sample-id'] + '_' + it[0]['strandedness'] }, flatten: true)
    //     grouped_ch.view()
    // }



}