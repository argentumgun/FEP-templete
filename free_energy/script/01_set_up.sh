#!/bin/sh

echo "SET UP AND RUN ADDING RESTRAINT STEP"

top=$(pwd)

# repate number
round_NO=1

# restraint force constant
k_dist=10
k_ang=100
k_rotate=100

complex_part="complex_${round_NO}_${k_dist}_${k_ang}_${k_rotate}"

if [ \! -d $complex_part ]; then
  mkdir $complex_part
fi

cd $complex_part

# restraint set up
if [ \! -d restraint ]; then
  echo "mkdir restraint"
  mkdir restraint
fi

cd restraint

for w in 0.0 0.01 0.025 0.05 0.075 0.1 0.15 0.2 0.35 0.5 0.75 1.0; do

  if [ \! -d $w ]; then
    mkdir $w
  fi

  # restriant force
  Distance=`echo "scale=3; ${k_dist} * $w"|bc`
  Angel=`echo "scale=3; ${k_ang} * $w"|bc`
  Torsion=`echo "scale=3; ${k_rotate} * $w"|bc`
  
  # restriant templete
  sed -e "s/%D%/$Distance/g" -e "s/%A%/$Angel/g" -e "s/%T%/$Torsion/g" $top/init_structure/Boresch_restraint.tmpl > $w/dist_angel_dihedral.RST
  
  # MD templete
  sed -e "s/%L%/$w/" $top/md_protocol/min_restraint.tmpl > $w/min.in
  sed -e "s/%L%/$w/" $top/md_protocol/heat_restraint.tmpl > $w/heat.in
  sed -e "s/%L%/$w/" $top/md_protocol/prep_restraint.tmpl > $w/prep.in
  sed -e "s/%L%/$w/" $top/md_protocol/prod_restraint.tmpl > $w/ti.in

  (
    cd $w
    ln -sf $top/init_structure/complex.parm7 ti.parm7
    ln -sf $top/init_structure/restraint_reference.rst7  ti.rst7
  )
done

cd ..

# decouple in complex set up
if [ \! -d vdw_crg_one_step ]; then
  echo "mkdir vdw_crg_one_step"
  mkdir vdw_crg_one_step
fi
cd vdw_crg_one_step

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

cd ..

if [ \! -d ligand_one_step ]; then
  echo "mkdir ligand_one_step"
  mkdir ligand_one_step
fi

# ligand set up

cd ligand_one_step

for w in 0.0 0.01 0.025 0.05 0.075 0.1 0.15 0.2 0.3 0.4 0.5 0.6 0.65 0.7 0.75 0.8 0.85 0.9 0.95 1.0; do
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