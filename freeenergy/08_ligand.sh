#!/bin/sh

top=$(pwd)
mdrun="pmemd.cuda"

if [ \! -d ligand ]; then
  mkdir ligand
fi

cd ligand

for step in vdw_crg; do
  if [ \! -d $step ]; then
    mkdir $step
  fi

  cd $step

  for w in 0.0 0.01 0.025 0.05 0.075 0.1 0.15 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0; do
    if [ \! -d $w ]; then
      mkdir $w
    fi

    sed -e "s/%L%/$w/"  $top/md_protocol/min_one_step_ligand.tmpl > $w/min.in
    sed -e "s/%L%/$w/"  $top/md_protocol/heat_one_step_ligands.tmpl > $w/heat.in
    sed -e "s/%L%/$w/"  $top/md_protocol/prep_one_step_ligands.tmpl > $w/prep.in
    sed -e "s/%L%/$w/"  $top/md_protocol/prod_one_step_ligands.tmpl > $w/ti.in

    (
      cd $w
      ln -sf $top/init_structure/lig.parm7 ti.parm7
      ln -sf $top/init_structure/lig.rst7  ti.rst7
    )
  done

  for w in 0.0 0.01 0.025 0.05 0.075 0.1 0.15 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0; do
    cd $w

    current_dir=$(pwd)

    echo " $(date "+%Y-%m-%d %H:%M:%S") current working dir:  $current_dir"

    mpirun -np 8 pmemd.MPI -i min.in -c ti.rst7 -ref ti.rst7 -p ti.parm7 -O -o min.out -inf min.info -r min.rst7 -l min.log

    $mdrun -i heat.in -c min.rst7 -ref ti.rst7 -p ti.parm7 -O -o heat.out -inf heat.info -r heat.rst7 -x heat.nc -l heat.log

    $mdrun -i prep.in -c heat.rst7 -p ti.parm7 -O -o prep.out -inf prep.info -r prep.rst7 -x prep.nc -l prep.log

    $mdrun -i ti.in -c prep.rst7 -p ti.parm7 -O -o ti001.out -inf ti001.info -r ti001.rst7 -x ti001.nc -l ti001.log

    cd ..
  done
  cd ..
done