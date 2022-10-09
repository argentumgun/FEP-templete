#!/bin/sh
mdrun="pmemd.cuda"
mpirun="mpirun -np 16"
sander="sander.MPI"
top=$(pwd)

# restraint force constant
k_dist=20
k_ang=200
k_rotate=200

restraint_wt=0.01

complex_part="complex_6_${k_dist}_${k_ang}_${k_rotate}_restraint_loop_no_DI-PHE_0.01"

loop_restraint_off="loop_restraint_off_04_sir_this_way"

cd $complex_part/$loop_restraint_off

if [ \! -d post_processing ]; then
    mkdir post_processing
fi

cd post_processing

for w in 0.0 0.2 0.4 0.6 0.8 1.0; do

    if [ \! -d $w ]; then
        mkdir $w
    fi
    
    # same boresch restraint state
    sed -e "s/%D%/${k_dist}/g" -e "s/%A%/${k_ang}/g" -e "s/%T%/${k_rotate}/g"  $top/init_structure/Boresch_restraint.tmpl > $w/dist_angel_dihedral.RST

    # ntr restraint_wt state
    R=`echo "scale=3; ${restraint_wt} * $w"|bc`

    (
        cd $w
            ln -sf $top/init_structure/complex.parm7 ti.parm7
            ln -sf $top/init_structure/restraint_reference.rst7 restraint_reference.rst7
            # different ntr restraint weight
            sed -e "s/%RESTR%/$R/" $top/md_protocol/protein/mbar_loop_restraint_off.tmpl > mbar.in
    )

done

# calculate MBAR state
for w in 0.2 0.4 0.6 0.8 1.0 0.0; do
  cd $w 

    echo "$(date "+%Y-%m-%d %H:%M:%S") current MBAR state : ${w} "

    for s in 0.0 0.2 0.4 0.6 0.8 1.0; do
 
      echo "  processing sample state $s mdcrd:  ${top}/${complex_part}/$loop_restraint_off/${s}/ti001.nc"

      #$mpirun $sander -i mbar.in -O -o mbar_${w}_${s}.out -p ti.parm7 -c restraint_reference.rst7 -ref restraint_reference.rst7 -y ${top}/${complex_part}/$loop_restraint_off/$s/ti001.nc
      
      $mpirun $sander -i mbar.in -O -o mbar_${w}_${s}.out -p ti.parm7 -c ${top}/${complex_part}/$loop_restraint_off/$s/prep.rst7 -ref restraint_reference.rst7 -y ${top}/${complex_part}/$loop_restraint_off/$s/ti001.nc
      
      #$mpirun $sander -i mbar.in -O -o mbar_${w}_${s}.out -p ti.parm7 -c ${top}/${complex_part}/$loop_restraint_off/$s/prep.rst7 -ref $top/$complex_part/loop_restraint_off/$w/ti001.rst7 -y ${top}/${complex_part}/$loop_restraint_off/$s/ti001.nc

    done
  cd ..
done