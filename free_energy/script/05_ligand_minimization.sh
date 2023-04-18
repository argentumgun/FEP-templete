#!/bin/sh

echo "SETING LIGAND ALCHEMICAL 0.0-1.0 20 WINDOW"

top=$(pwd)

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

  echo " $(date "+%Y-%m-%d %H:%M:%S") MINIMIZATION"
  mpirun -np 4 pmemd.MPI -i min.in -c ti.rst7 -ref ti.rst7 -p ti.parm7 -O -o min.out -inf min.info -r min.rst7 -l min.log

  cd ..
done
