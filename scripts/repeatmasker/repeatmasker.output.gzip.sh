#!/bin/bash

#PBS -P xl04
#PBS -q normal
#PBS -l walltime=04:00:00
#PBS -l mem=16GB
#PBS -l jobfs=32GB
#PBS -l ncpus=1
#PBS -j oe
#PBS -l storage=scratch/xl04+gdata/xl04

#Load modules
set -ex
source  /g/data/xl04/rb9779/ditto/misc/executecommand.sh
module load /g/data/xl04/rb9779/modules/RepeatMasker/4.1.2-p1 /g/data/xl04/rb9779/modules/utils/0.1

gzip -c $odir/$sampleID.rm.out > $odir/$sampleID.rm.out.gz
gzip -c $odir/$sampleID.rm.out.gff > $odir/$sampleID.rm.out.gff.gz
gzip -c $odir/$sampleID.rm.polyout > $odir/$sampleID.rm.polyout.gz
gzip -c $odir/$sampleID.rm.cat > $odir/$sampleID.rm.cat.gz
gzip -c $odir/$sampleID.rm.masked > $odir/$sampleID.rm.masked.gz

command=(\
gzip -c $odir/$sampleID.rm.tbl
)
execute_command command[@] $sampleID.repeatmasker.gzipcat $odir/$sampleID.repeatmasker.gzipcat.done 0 $odir/$sampleID.rm.tbl.gz

gzip -c $odir/$sampleID.parallel.log > $odir/$sampleID.parallel.log.gz

#Clean up
rm -f $odir/$sampleID.rm.out
rm -f $odir/$sampleID.rm.out.gff
rm -f $odir/$sampleID.rm.polyout
rm -f $odir/$sampleID.rm.cat
rm -f $odir/$sampleID.parallel.log
rm -f $odir/$sampleID.rm.masked

#Logic behind here is that the script will fail if there is no output, therefore, tmp directories being removed will only pass if the script runs successfully to this point.
command=(\
rm $odir/$sampleID.rm.tbl
)
execute_command command[@] $sampleID.repeatmasker.rmtmp $odir/$sampleID.repeatmasker.rmtmp.done 0
