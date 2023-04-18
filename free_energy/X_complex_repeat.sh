#!/bin/sh

echo "COMPELX ALCHEMICAL SETP AND RUN 0.0-1.0 10 WINDOW"

export CUDA_VISIBLE_DEVICES='1'

mdrun="pmemd.cuda"

top=$(pwd)

# repate number
round_NO=1
repeat_NO="003"

# restraint force constant
k_dist=10
k_ang=100
k_rotate=100

complex_part="complex_${round_NO}_${k_dist}_${k_ang}_${k_rotate}"

for system in $complex_part; do

  cd $system
  
  for step in vdw_crg_one_step; do

    cd $step

    for w in 0.0 0.01 0.025 0.05 0.075 0.1 0.15 0.2 0.3 0.4 0.5 0.6 0.65 0.7 0.75 0.8 0.85 0.9 0.95 1.0; do
    
      cd $w

      echo "current working dir:  $(pwd)"
      # echo "  $(date "+%Y-%m-%d %H:%M:%S") MD MINIMIZATION"
      # mpirun -np 8 pmemd.MPI -i min.in -c ti.rst7 -ref ti.rst7 -p ti.parm7 -O -o min.out -inf min.info  -r min.rst7 -l min.log
      # echo "  $(date "+%Y-%m-%d %H:%M:%S") MD HEAT "
      # $mdrun -i heat.in -c min.rst7 -ref ti.rst7 -p ti.parm7 -O -o heat.out -inf heat.info  -r heat.rst7 -x heat.nc -l heat.log
      # echo "  $(date "+%Y-%m-%d %H:%M:%S") MD EQUILIBRATION "
      # $mdrun -i prep.in -c heat.rst7 -p ti.parm7 -ref heat.rst7 -O -o prep.out -inf prep.info  -r prep.rst7 -x prep.nc -l prep.log
      echo "  $(date "+%Y-%m-%d %H:%M:%S") MD PRODUCTION "
      $mdrun -i ti.in -c prep.rst7 -p ti.parm7 -ref prep.rst7 -O -o ti${repeat_NO}.out -inf ti${repeat_NO}.info  -r ti${repeat_NO}.rst7 -x ti${repeat_NO}.nc -l ti${repeat_NO}.log

      cd ..
    done

    cd ..
  done

  cd $top
done
