set -ex
execute_command () {
  command=("${!1}")
  taskname="$2"
  donefile="$3"
  force="$4"
  outputfile="$5"

  JOBID=$PBS_JOBID
  ###alter this to suit the job scheduler

  if [ "$force" -eq 1 ] || [ ! -e $donefile ] || [ ! -s $donefile ] || [ "`tail -n1 $donefile | cut -f3 -d','`" != " EXIT_STATUS:0" ]
  then
    echo COMMAND: "${command[@]}" >> $donefile
		echo JOBID: "$JOBID" >> $donefile
		
    if [ -z "$outputfile" ]
    then
      /usr/bin/time --format='RESOURCEUSAGE: ELAPSED=%e, CPU=%S, USER=%U, CPUPERCENT=%P, MAXRM=%M Kb, AVGRM=%t Kb, AVGTOTRM=%K Kb, PAGEFAULTS=%F, RPAGEFAULTS=%R, SWAP=%W, WAIT=%w, FSI=%I, FSO=%O, SMI=%r, SMO=%s EXITSTATUS:%x' -o $donefile -a -- "${command[@]}"
      ret=$?
    else
      /usr/bin/time --format='RESOURCEUSAGE: ELAPSED=%e, CPU=%S, USER=%U, CPUPERCENT=%P, MAXRM=%M Kb, AVGRM=%t Kb, AVGTOTRM=%K Kb, PAGEFAULTS=%F, RPAGEFAULTS=%R, SWAP=%W, WAIT=%w, FSI=%I, FSO=%O, SMI=%r, SMO=%s EXITSTATUS:%x' -o $donefile -a -- "${command[@]}" >$outputfile
      ret=$?
    fi
    echo JOBID:$JOBID, TASKNAME:$taskname, EXIT_STATUS:$ret,  TIME:`date +%s`>>$donefile
    if [ "$ret" -ne 0 ]
    then
      echo ERROR_command: "${command[@]}"
      echo ERROR_exitcode: $taskname failed with $ret exit code.
      exit $ret
    fi
  else
    echo SUCCESS_command: "${command[@]}"
  fi
}

