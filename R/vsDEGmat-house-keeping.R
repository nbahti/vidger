#-----------------------------------------------------#
# Title:  ggviseq - House Keeping - DEG Matrix        #
# Author: Brandon Monier (brandon.monier@sdstate.edu) #
# Date:   04.04.17                                    #
#-----------------------------------------------------#

.getEdgeDEGMat <- function(data, padj) {
    dat1 <- as.vector(unique(data$sample$group))
    dat2 <- t(combn(dat1, 2))
    l.dat <- split(dat2, row(dat2))
    ls1 <- lapply(l.dat, function(i) {
        exactTest(data, pair = i) 
    })
    ls2 <- lapply(seq_along(ls1), function(i) {
        topTags(ls1[[i]], n = nrow(ls1[[i]]$table))
    })
    ls3 <- lapply(seq_along(ls1), function(i) {
        tab <- ls2[[i]]$table[order(as.numeric(rownames(ls2[[i]]$table))),]
        tab$x <- ls2[[i]]$comparison[1]
        tab$y <- ls2[[i]]$comparison[2]
        tab
    })
    dat3 <- do.call("rbind", ls3)
    dat3 <- dat3[, c('x', 'y', 'PValue','FDR')]
    names(dat3)[names(dat3) == 'FDR'] <- 'padj'
    names(dat3)[names(dat3) == 'PValue'] <- 'pval'
    dat3$x <- as.factor(dat3$x)
    dat3$y <- as.factor(dat3$y)
    dat3 <- dat3[which(dat3$padj <= padj), ]
    return(dat3)
}



.getCuffDEGMat <- function(data, padj) {
    dat1 <- data
    dat1 <- dat1[, c('sample_1', 'sample_2', 'p_value', 'q_value')]
    names(dat1) <- c('x', 'y', 'pval', 'padj')
    dat1$x <- as.factor(dat1$x)
    dat1$y <- as.factor(dat1$y)
    dat1 <- dat1[which(dat1$padj <= padj), ]
    return(dat1)
}



.getDeseqDEGMat <- function(data, d.factor, padj) {
    if(is.null(d.factor)) {
        stop(
            'This appears to be a DESeq object.
            Please enter d.factor variable.'
        )
    }
    dat1 <- as.data.frame(colData(data))
    tmp1 <- as.vector(unique(dat1[[d.factor]]))
    dat2 <- t(combn(tmp1, 2))
    dat2 <- cbind(d.factor, dat2)
    l.dat <- split(dat2, row(dat2))
    ls1 <- lapply(seq_along(l.dat), function(i) {
        as.data.frame(results(data, contrast = l.dat[[i]]))
    })
    ls2 <- lapply(seq_along(l.dat), function(i) {
        tab <- ls1[[i]][, c("pvalue", "padj")]
        tab$x <- l.dat[[i]][2]
        tab$y <- l.dat[[i]][3]
        tab
    })
    dat3 <- do.call('rbind', ls2)
    dat3 <- dat3[, c('x', 'y', 'pvalue', 'padj')]
    names(dat3)[names(dat3) == 'pvalue'] <- 'pval'
    dat3$x <- as.factor(dat3$x)
    dat3$y <- as.factor(dat3$y)
    dat3 <- dat3[which(dat3$padj <= padj), ]
    return(dat3)
}
