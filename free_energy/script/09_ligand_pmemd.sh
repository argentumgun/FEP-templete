#!/bin/sh

echo "ligand RUN 0.0-1.0 20 WINDOW"

export CUDA_VISIBLE_DEVICES='1'

top=$(pwd)
mdrun="pmemd.cuda"

# repate number
round_NO=1

# restraint force constant
k_dist=10
k_ang=100
k_rotate=100

complex_part="complex_${round_NO}_${k_dist}_${k_ang}_${k_rotate}"

cd $complex_part/ligand_one_step

for w in 0.0 0.01 0.025 0.05 0.075 0.1 0.15 0.2 0.3 0.4 0.5 0.6 0.65 0.7 0.75 0.8 0.85 0.9 0.95 1.0; do
  
  cd $w
  echo " $(date "+%Y-%m-%d %H:%M:%S") current working dir: $(pwd)"

  echo " $(date "+%Y-%m-%d %H:%M:%S") HEAT"
  $mdrun -i heat.in -c min.rst7 -ref ti.rst7 -p ti.parm7 -O -o heat.out -inf heat.info -r heat.rst7 -x heat.nc -l heat.log
  echo " $(date "+%Y-%m-%d %H:%M:%S") EQUILIBRATION"
  $mdrun -i prep.in -c heat.rst7 -p ti.parm7 -O -o prep.out -inf prep.info -r prep.rst7 -x prep.nc -l prep.log
  echo " $(date "+%Y-%m-%d %H:%M:%S") PRODUCTION"
  $mdrun -i ti.in -c prep.rst7 -p ti.parm7 -O -o ti001.out -inf ti001.info -r ti001.rst7 -x ti001.nc -l ti001.log

  cd ..
done
