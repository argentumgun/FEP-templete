#!/bin/sh

mdrun="pmemd.cuda"
mpirun="mpirun -np 16"
sander="sander.MPI"
top=$(pwd)

# restraint force constant
k_dist=20
k_ang=200
k_rotate=200

complex_part="complex_1_${k_dist}_${k_ang}_${k_rotate}"

if [ \! -d $complex_part ]; then
  mkdir $complex_part
fi

cd $complex_part

if [ \! -d restraint ]; then
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

# run MD (apply restraint)
for w in 0.0 0.01 0.025 0.05 0.075 0.1 0.15 0.2 0.35 0.5 0.75 1.0; do
  cd $w
  
  echo "Current Working Window: adding restriant $w"
  echo " $(date "+%Y-%m-%d %H:%M:%S") minimization"
  $mpirun pmemd.MPI -i min.in -c ti.rst7 -ref ti.rst7 -p ti.parm7 -O -o min.out -inf min.info -r min.rst7 -l min.log
  echo " $(date "+%Y-%m-%d %H:%M:%S") heating"
  pmemd.cuda -i heat.in -c min.rst7 -ref min.rst7 -p ti.parm7 -O -o heat.out -inf heat.info -r heat.rst7 -x heat.nc -l heat.log
  echo " $(date "+%Y-%m-%d %H:%M:%S") prep"
  pmemd.cuda -i prep.in -c heat.rst7 -ref heat.rst7 -p ti.parm7 -O -o prep.out -inf prep.info -r prep.rst7 -x prep.nc -l prep.log
  echo " $(date "+%Y-%m-%d %H:%M:%S") production"
  pmemd.cuda -i ti.in -c prep.rst7 -p ti.parm7 -O -o ti001.out -inf ti001.info -r ti001.rst7 -x ti001.nc -l ti001.log

  cd ..
done

cd ..
# create_postprocessing

if [ \! -d post_processing ]; then
    mkdir post_processing
fi

cd post_processing

for w in 0.0 0.01 0.025 0.05 0.075 0.1 0.15 0.2 0.35 0.5 0.75 1.0; do
  if [ \! -d $w ]; then
    mkdir $w
  fi

  # change weight
  Distance=`echo "scale=3; ${k_dist} * $w"|bc`
  Angel=`echo "scale=3; ${k_ang} * $w"|bc`
  Torsion=`echo "scale=3; ${k_rotate} * $w"|bc`
  
  # restraint weight state w
  sed -e "s/%D%/$Distance/g" -e "s/%A%/$Angel/g" -e "s/%T%/$Torsion/g"  $top/init_structure/Boresch_restraint.tmpl > $w/dist_angel_dihedral.RST
  
  (
    cd $w
    ln -sf $top/init_structure/complex.parm7 ti.parm7
    ln -sf $top/init_structure/restraint_reference.rst7 restraint_reference.rst7
    ln -sf $top/md_protocol/restraint_mbar_in.tmpl mbar.in
  )

done

# calculate MBAR state
for w in 0.0 0.01 0.025 0.05 0.075 0.1 0.15 0.2 0.35 0.5 0.75 1.0; do
  cd $w 

    echo " $(date "+%Y-%m-%d %H:%M:%S") current MBAR state : ${w} "

    for s in 0.0 0.01 0.025 0.05 0.075 0.1 0.15 0.2 0.35 0.5 0.75 1.0; do

      echo " $(date "+%Y-%m-%d %H:%M:%S") current working dir: postprocessing restriant ${w} - ${s}"
      echo "   processing  mdcrd:  ${top}/${complex_part}/restraint/${s}/ti001.nc"

      $mpirun $sander -i mbar.in -O -o mbar_${w}_${s}.out -p ti.parm7 -c restraint_reference.rst7 -y ${top}/${complex_part}/restraint/$s/ti001.nc

    done
  cd ..
done