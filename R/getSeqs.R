getGenBankSeqs <- function(id) {
    # get the raw record
    raw <- rentrez::entrez_fetch(db = 'nuccore', id = id,
                                 rettype = 'gbc', retmode = 'xml')

    # convert XML to list
    rawList <- XML::xmlToList(raw)

    # loop over list and extract needed info
    out <- lapply(rawList, function(l) {
        # get easy to retrieve data
        dat <- data.frame(
            accession = l$`INSDSeq_accession-version`,
            species = l$INSDSeq_organism,
            date = l$`INSDSeq_create-date`,
            pubmed = l$INSDSeq_references$INSDReference$INSDReference_pubmed
        )

        # extract feature table
        featTab <- l$`INSDSeq_feature-table`

        # browser()
        # add data from feature table
        dat <- cbind(dat, parseFeatTab(featTab))

        # add sequence to data.frame (will be sepparated after loop)
        dat$dna <- l$INSDSeq_sequence

        return(dat)
    })


    out <- do.call(rbind, out)
    dna <- formatFASTA(out$accession, out$dna)
    out <- out[, names(out) != 'dna']

    return(list(data = out, dna = dna))
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


# test
# foo <- getGenBankSeqs(c('1331395866', '1679378317'))

