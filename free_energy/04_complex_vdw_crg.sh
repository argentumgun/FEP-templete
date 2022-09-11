#!/bin/sh

mdrun="pmemd.cuda"

top=$(pwd)

# restraint force constant
k_dist=20
k_ang=200
k_rotate=200

complex_part="complex_1_${k_dist}_${k_ang}_${k_rotate}"
#complex_part="complex"

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

    for w in 0.0 0.01 0.025 0.05 0.075 0.1 0.15 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0; do
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

    for w in 0.7 0.8 0.9 1.0 0.0 0.01 0.025 0.05 ; do
      cd $w

      current_dir=$(pwd)

      echo "current working dir:  $current_dir"
      echo "  $(date "+%Y-%m-%d %H:%M:%S") MD MINIMIZATION"
      mpirun -np 8 pmemd.MPI -i min.in -c ti.rst7 -ref ti.rst7 -p ti.parm7 -O -o min.out -inf min.info  -r min.rst7 -l min.log
      echo "  $(date "+%Y-%m-%d %H:%M:%S") MD HEAT "
      $mdrun -i heat.in -c min.rst7 -ref ti.rst7 -p ti.parm7 -O -o heat.out -inf heat.info  -r heat.rst7 -x heat.nc -l heat.log
      echo "  $(date "+%Y-%m-%d %H:%M:%S") MD EQUILIBRATION "
      $mdrun -i prep.in -c heat.rst7 -p ti.parm7 -ref ti.rst7 -O -o prep.out -inf prep.info  -r prep.rst7 -x prep.nc -l prep.log
      echo "  $(date "+%Y-%m-%d %H:%M:%S") MD PRODUCTION "
      $mdrun -i ti.in -c prep.rst7 -p ti.parm7 -ref ti.rst7 -O -o ti001.out -inf ti001.info  -r ti001.rst7 -x ti001.nc -l ti001.log

      cd ..
    done

    cd ..
  done

  cd $top
done
