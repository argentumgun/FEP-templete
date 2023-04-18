#!/bin/sh

echo "SETING COMPELX ALCHEMICAL SETP AND RUN 0.0-0.4 10 WINDOW"

export CUDA_VISIBLE_DEVICES='1'

mdrun="pmemd.cuda"

top=$(pwd)

# repate number
round_NO=1
repeat_NO="001"

# restraint force constant
k_dist=10
k_ang=100
k_rotate=100

complex_part="complex_${round_NO}_${k_dist}_${k_ang}_${k_rotate}"

for system in $complex_part; do

  if [ \! -d $system ]; then
    mkdir $system
  fi

  cd $system
  
  for step in vdw_crg_one_step; do
    if [ \! -d $step ]; then
      mkdir $step
    fi

    cd $step

    for w in 0.0 0.01 0.025 0.05 0.075 0.1 0.15 0.2 0.3 0.4 0.5 0.6 0.65 0.7 0.75 0.8 0.85 0.9 0.95 1.0; do
      if [ \! -d $w ]; then
        mkdir $w
      fi

      sed -e "s/%L%/$w/"  $top/md_protocol/min_one_step_complex.tmpl > $w/min.in
      sed -e "s/%L%/$w/"  $top/md_protocol/heat_one_step_complex.tmpl > $w/heat.in
      sed -e "s/%L%/$w/"  $top/md_protocol/prep_one_step_complex.tmpl > $w/prep.in
      sed -e "s/%L%/$w/"  $top/md_protocol/prod_one_step_complex.tmpl > $w/ti.in
      sed -e "s/%D%/${k_dist}/g" -e "s/%A%/${k_ang}/g" -e "s/%T%/${k_rotate}/g" $top/init_structure/Boresch_restraint.tmpl > $w/dist_angel_dihedral.RST

      (
        cd $w
        ln -sf $top/init_structure/complex.parm7 ti.parm7
        ln -sf $top/init_structure/restraint_reference.rst7 ti.rst7
      )
    done

    for w in 0.0 0.01 0.025 0.05 0.075 0.1 0.15 0.2 0.3 0.4 ; do
      
      cd $w

      echo "current working dir: $(pwd)"
      echo "  $(date "+%Y-%m-%d %H:%M:%S") MD MINIMIZATION"
      mpirun -np 8 pmemd.MPI -i min.in -c ti.rst7 -ref ti.rst7 -p ti.parm7 -O -o min.out -inf min.info  -r min.rst7 -l min.log
      echo "  $(date "+%Y-%m-%d %H:%M:%S") MD HEAT "
      $mdrun -i heat.in -c min.rst7 -ref ti.rst7 -p ti.parm7 -O -o heat${repeat_NO}.out -inf heat${repeat_NO}.info  -r heat${repeat_NO}.rst7 -x heat${repeat_NO}.nc -l heat${repeat_NO}.log
      echo "  $(date "+%Y-%m-%d %H:%M:%S") MD EQUILIBRATION "
      $mdrun -i prep.in -c heat${repeat_NO}.rst7 -p ti.parm7 -ref heat${repeat_NO}.rst7 -O -o prep${repeat_NO}.out -inf prep${repeat_NO}.info  -r prep${repeat_NO}.rst7 -x prep${repeat_NO}.nc -l prep${repeat_NO}.log
      echo "  $(date "+%Y-%m-%d %H:%M:%S") MD PRODUCTION "
      $mdrun -i ti.in -c prep${repeat_NO}.rst7 -p ti.parm7 -ref prep${repeat_NO}.rst7 -O -o ti${repeat_NO}.out -inf ti${repeat_NO}.info  -r ti${repeat_NO}.rst7 -x ti${repeat_NO}.nc -l ti${repeat_NO}.log

      cd ..
    done

    cd ..
  done

  cd $top
done
