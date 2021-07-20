getGenBankSeqs <- function(id) {
    # get the raw record
    raw <- rentrez::entrez_fetch(db = 'nuccore', id = id,
                                 rettype = 'gbc', retmode = 'xml')

    # convert XML to list
    rawList <- XML::xmlToList(raw)

    # get easy to retrieve data
    dat <- data.frame(
        accession = rawList$INSDSeq$`INSDSeq_accession-version`,
        species = rawList$INSDSeq$INSDSeq_organism,
        date = rawList$INSDSeq$`INSDSeq_create-date`,
        pubmed = rawList$INSDSeq$INSDSeq_references$INSDReference$
            INSDReference_pubmed
    )

    # get taxonomy
    tax <- data.frame(taxonomy = rawList$INSDSeq$INSDSeq_taxonomy)

    # extract feature table
    featTab <- rawList$INSDSeq$`INSDSeq_feature-table`

    # add data from feature table
    dat <- cbind(dat, parseFeatTab(featTab))

    # extract sequence and format it as FASTA
    dnaFASTA <- formatFASTA(dat$accession,
                            rawList$INSDSeq$INSDSeq_sequence)

    return(list(data = dat, taxonmy = tax, dna = dnaFASTA))
}



parseFeatTab <- function(featTab) {
    featTab <- unlist(featTab)

    # gather info into data.frame
    info <- data.frame(
        # info about genomic region
        # regionType = featTab['INSDFeature.INSDFeature_key'],
        region = extractFeatByName('gene', featTab),
        product = extractFeatByName('product', featTab),
        organelle = extractFeatByName('organelle', featTab),
        region_note = extractFeatByName('note', featTab),

        # info about geographic location
        latlon = extractFeatByName('lat_lon', featTab),
        locality = extractFeatByName('country', featTab),

        # info about specimen
        coll_date = extractFeatByName('collection_date', featTab),
        coll_by = extractFeatByName('collected_by', featTab),
        specimen_id = extractFeatByName('specimen_voucher', featTab)
    )

    return(info)
}

extractFeatByName <- function(name, featTab) {
    index <- which(grepl('INSDQualifier_name', names(featTab)) &
                       featTab == name) + 1

    if(length(index) == 0) {
        out <- NA
    } else {
        out <- as.character(featTab[index])
        out <- unique(out)

        if(out == '') out <- NA
    }

    return(out)
}

formatFASTA <- function(dbID, dnaSeq) {
    paste0('>', dbID, '\n', dnaSeq)
}


getGenBankSeqs('1331395866')
getGenBankSeqs('1679378317')
