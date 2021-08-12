#!/bin/bash

##Run RepeatMasker
for i in `cat /g/data/xl04/rb9779/ditto/misc/genomepaths.txt | head -n2 | tail -n1`
    do
    sampleID=`basename $i .fa`
    odir=/g/data/xl04/rb9779/repeatmasker/output
    tmpdir=/g/data/xl04/rb9779/repeatmasker/tmp
    inputfile=$i
    bp=/g/data/xl04/rb9779
    logdir=/g/data/xl04/rb9779/repeatmasker/logs
    species="amniota"

#Check if there are done files with EXIT_STATUS:0 for the last step/ removal of tmp directories (indicating that the script has gone to completion)
    if [[ $(grep 'EXIT_STATUS:0' $odir/$sampleID.repeatmasker.rmtmp.done) ]]; then
        echo "RepeatMasker has run for $sampleID"
    else
        echo $sampleID
        qsub \
        -o $logdir \
        -q normal \
        -l ncpus=16 \
        -l mem=32GB \
        -l jobfs=400GB \
        -l walltime=24:00:00 \
        -v bp=$bp,species=$species,sampleID=$sampleID,odir=$odir,tmpdir=$tmpdir,inputfile=$inputfile,len=$len,basepath=$basepath,logdir=$logdir \
        -N RM.$sampleID.pbs \
        -P xl04 \
        /g/data/xl04/rb9779/ditto/scripts/repeatmasker/repeatmasker.sh
    fi
done