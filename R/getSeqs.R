getWhatWeWant <- function(entrezOut) {
    # linearize the XML mess
    entrezOut <- unlist(XML::xmlToList(entrezOut))

    # keywords in XML hierarchy to find wanted info
    weWantDirect <- list(
        'taxon_name' = 'Org-ref_taxname',
        'date' = 'Seqdesc_create-date.Date.Date_std.Date-std.Date-std_year',
        'seq' = 'Seq-data_ncbi2na.NCBI2na',
        'pub' = c('ArticleId_pubmed.PubMedId', 'ArticleId_doi.DOI'),
        'accession' = 'Textseq-id_accession', # this could have multiple matches, we want the first only
        'genomic_region' = c(
            'SeqFeatData_prot.Prot-ref.Prot-ref_name.Prot-ref_name_E',
            'SeqFeatData_rna.RNA-ref.RNA-ref_type.value',
            'Seq-feat_comment'
        ),
        'primer_forward' = 'PCRReaction.PCRReaction_forward.PCRPrimerSet.PCRPrimer.PCRPrimer_seq.PCRPrimerSeq',
        'primer_reverse' = 'PCRReaction.PCRReaction_reverse.PCRPrimerSet.PCRPrimer.PCRPrimer_seq.PCRPrimerSeq')

    # keyword `attrs.value` in XML; the wanted info will be at the index + 1
    # (thus `PP` aka `++` aka `index + 1`)
    weWantPP <- list(
        'latlon' = 'lat-lon',
        'location' = 'country',
        'specimen_id' = 'specimen-voucher'
    )

    # loop over keywords and extract info
    info1 <- lapgrep(weWantDirect, crazyGREP, entrezOut)
    info2 <- lapgrep(weWantPP, grepPP, entrezOut)

    return(rbind(info1, info2))
}

crazyGREP <- function(p, x) {
    grep(paste(p, collapse = '|'), names(x))
}

grepPP <- function(p, x) {
    grep(paste(p,  collapse = '|'), x) + 1
}

lapgrep <- function(x, gfun, dat) {
    ii <- 1:length(x)

    out <- lapply(ii, function(i) {
        p <- x[[i]]
        jj <- gfun(p, dat)
        val <- dat[jj]
        if(length(val) == 0) val <- NA

        o <- try(data.frame(field = names(x)[i],
                            # match_term = paste(p, collapse = '|'),
                            value = val))
        if('try-error' %in% class(o)) browser()

        return(o)
    })

    out <- do.call(rbind, out)
    rownames(out) <- NULL

    return(out)
}


#
# new <- rentrez::entrez_fetch(db = 'nuccore', id = '1490508',
#                              rettype = 'native', retmode = 'xml',
#                              parsed = TRUE)
#
#
old <- rentrez::entrez_fetch(db = 'nuccore', id = '1331395866',
                             rettype = 'acc', retmode = 'text')

foo <- entrez_summary('nuccore', '1679378317')
names(foo)

for(i in names(foo)) {
    print(extract_from_esummary(foo, i))
}

entrez_fetch

x <- getWhatWeWant(boo)


sort(unique(x$value[x$field == 'accession']))


library(rentrez)
library(XML)

foo <- rentrez::entrez_search(db = 'nuccore', term = 'Drosophila murphyi[ORGN]',
                              retmax = 1000)
foo$ids



raw <- rentrez::entrez_fetch(db = 'nuccore', id = '1679378317',
                             rettype = 'gbc', retmode = 'xml')
raw <- readLines('~/Desktop/sequence.gbc.xml')
rawList <- unlist(XML::xmlToList(raw))
allTax <- rawList[grep('Org-ref_taxname', names(rawList))]
names(allTax) <- NULL
length(unique(allTax))
head(allTax)

rawFASTA <- rentrez::entrez_fetch(db = 'nuccore', id = '403062956',
                             rettype = 'fasta')
cat(rawFASTA)


boo <- cbind(names(rawList), as.character(rawList))
x <- strsplit(boo[, 1], '\\.')
n <- max(sapply(x, length))
x <- lapply(x, function(y) {
    y <- c(y, rep('', n - length(y)))
    return(y)
})

boo <- cbind(do.call(rbind, x), boo[, 2])
write.csv(boo, 'boo2.csv', row.names = FALSE)

z <- list(a = list(a1 = 1, a2 = 2), b = 3, c = list(c1 = 4, c2 = 5))
unlist(z)

