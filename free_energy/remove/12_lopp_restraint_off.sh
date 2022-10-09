#!/bin/sh
mdrun="pmemd.cuda"
top=$(pwd)

# restraint force constant
k_dist=20
k_ang=200
k_rotate=200

restraint_wt=0.01

# simulation_dir
complex_part="complex_6_${k_dist}_${k_ang}_${k_rotate}_restraint_loop_no_DI-PHE_0.01"

loop_restraint_off="loop_restraint_off_04_sir_this_way"

cd $complex_part

# adding restraint off loop
if [ \! -d $loop_restraint_off ]; then
    mkdir $loop_restraint_off
fi

cd $loop_restraint_off

for w in 0.0 0.2 0.4 0.6 0.8 1.0; do
    if [ \! -d $w ]; then
        mkdir $w
    fi
    
    #restraint_wt
    R=`echo "scale=3; ${restraint_wt} * $w"|bc`

    sed -e "s/%L%/$w/" $top/md_protocol/protein/min_restraint_off.tmpl > $w/min.in
    sed -e "s/%L%/$w/" $top/md_protocol/protein/heat_restraint_off.tmpl > $w/heat.in
    sed -e "s/%L%/$w/" $top/md_protocol/protein/prep_restraint_off.tmpl > $w/prep.in
    sed -e "s/%RESTR%/$R/" $top/md_protocol/protein/prod_loop_restraint_off.tmpl > $w/ti.in

    sed -e "s/%D%/${k_dist}/g" -e "s/%A%/${k_ang}/g" -e "s/%T%/${k_rotate}/g" $top/init_structure/Boresch_restraint.tmpl > $w/dist_angel_dihedral.RST

    (
        cd $w
        ln -sf $top/init_structure/complex.parm7 ti.parm7
        ln -sf $top/init_structure/restraint_reference.rst7 ti.rst7
    )
done

for w in 0.0 0.2 0.4 0.6 0.8 1.0; do
    cd $w

    echo "current working dir: $(pwd)"
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