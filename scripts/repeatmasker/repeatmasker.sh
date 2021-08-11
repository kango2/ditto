#!/bin/bash

#This script runs RepeatMasker through an embarrassingly parallel approach

#PBS -P xl04
#PBS -q normal
#PBS -l walltime=12:00:00
#PBS -l mem=96GB
#PBS -l jobfs=400GB
#PBS -l ncpus=32
#PBS -j oe
#PBS -l storage=scratch/xl04+gdata/xl04

#Load modules
set -ex
source /g/data/xl04/rb9779/executecommand.sh
module load /g/data/xl04/rb9779/modules/RepeatMasker/4.1.2-p1 /g/data/xl04/rb9779/modules/utils/0.1

#variables set
#inputfile : input genome file
#sampleID  : unique sample ID
#logdir    : directory where logs are kept
#outputdir : directory to store all output

tmpdir=$PBS_JOBFS
mkdir -p $tmpdir/out.tmp.$sampleID
mkdir -p $tmpdir/out.tmp.RM.$sampleID/

#Filter contigs
if [[ $inputfile == *".gz" ]]; 
then 
  gunzip -c $inputfile > $tmpdir/out.tmp.$sampleID/$sampleID.fa
  else
  cat $inputfile > $tmpdir/out.tmp.$sampleID/$sampleID.fa
fi  

#Split fasta files
fastasplit \
--fasta $tmpdir/out.tmp.$sampleID/$sampleID.fa \
--output $tmpdir/out.tmp.$sampleID/ \
--chunk $((PBS_NCPUS * 10))

#Create chunks
ls -1 $tmpdir/out.tmp.$sampleID/*_chunk_* > $tmpdir/out.tmp.$sampleID/chunknames.txt

#Define RepeatMasker path
rmbin=`which RepeatMasker`

#Launch RepeatMasker and output to $PBS_JOBFS
parallel --compress --tmpdir $tmpdir/out.tmp.$sampleID/ --joblog $odir/$sampleID.parallel.log -j ${PBS_NCPUS} pbsdsh -n {%} -- bash $bp/ditto/misc/shift_dir.sh $tmpdir/out.tmp.RM.$sampleID/ $rmbin -pa 1 -species $species -xsmall -poly -gff {} :::: $tmpdir/out.tmp.$sampleID/chunknames.txt

cat $tmpdir/out.tmp.$sampleID/$sampleID.fa_chunk_*.out > $tmpdir/$sampleID.rm.out
cat $tmpdir/out.tmp.$sampleID/$sampleID.fa_chunk_*.gff > $tmpdir/$sampleID.rm.out.gff
cat $tmpdir/out.tmp.$sampleID/$sampleID.fa_chunk_*.polyout > $tmpdir/$sampleID.rm.polyout
cat $tmpdir/out.tmp.$sampleID/$sampleID.fa_chunk_*.cat > $tmpdir/$sampleID.rm.cat
cat $tmpdir/out.tmp.$sampleID/$sampleID.fa_chunk_*.tbl > $tmpdir/$sampleID.rm.tbl
cat $tmpdir/out.tmp.$sampleID/$sampleID.fa_chunk_*.masked > $tmpdir/$sampleID.rm.masked

rsync -avP $tmpdir/$sampleID.rm.out $odir
rsync -avP $tmpdir/$sampleID.rm.out.gff $odir
rsync -avP $tmpdir/$sampleID.rm.polyout $odir
rsync -avP $tmpdir/$sampleID.rm.cat $odir
rsync -avP $tmpdir/$sampleID.rm.tbl $odir
rsync -avP $tmpdir/$sampleID.rm.masked $odir

command=(\
qsub \
        -o $logdir \
        -v sampleID=$sampleID,inputfile=$inputfile,odir=$odir,logdir=$logdir \
        -N cat.$sampleID.RM.pbs \
        -P xl04 \
        -q normal \
        /g/data/xl04/ditto/scripts/repeatmasker/repeatmasker.output.gzip.sh\
        )
execute_command command[@] $sampleID.repeatmasker.qsub $odir/$sampleID.repeatmasker.qsub.done 0