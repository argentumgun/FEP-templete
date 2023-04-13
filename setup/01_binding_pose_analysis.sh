#!/usr/bin/bash

export CUDA_VISIBLE_DEVICES='0'

mdrun=$AMBERHOME/bin/pmemd.MPI

# test mutil binding pose

top=$(pwd)

if [ \! -d ./init ]; then
    mkdir ./init
    echo 'making initial structure folder'
fi

if [ \! -d ./binding_pose_MD ]; then
    mkdir ./binding_pose_MD
    echo 'making unrestraint_MD folder'
fi

# only one pose is simulated now
for pose in 1; do
    
    cd ./init
    if [ \! -d ./$pose ]; then
        mkdir ./$pose
        echo "making binding_pose_${pose}_MD initial structure"
    fi
    cd $pose
    echo "current working folder:"
    pwd
    
    # ligand name
    ligand="mod3_2_gv"
    echo "binding ligand : $ligand"

    # retain ligand coordinate
    echo "$(date "+%Y-%m-%d %H:%M:%S") antechamber: convert ligand atom name to gcrt mode"
    antechamber -i $top/binding_pose_dir/$ligand.pdb -fi pdb -o lig.com -fo gcrt
    antechamber -i lig.com -fi gcrt -o lig.pdb -fo pdb

    echo "$(date "+%Y-%m-%d %H:%M:%S") GAUSS start"
    cp $top/binding_pose_dir/$ligand.gjf .
    g16 $ligand.gjf
    #antechamber -i $top/binding_pose_dir/$ligand -fi pdb -o lig.com -fo gcrt
    echo "$(date "+%Y-%m-%d %H:%M:%S") antechamber: ligang parameter"
    antechamber -i $ligand.log -fi gout -o lig.mol2 -fo mol2 -c bcc -at gaff2
    parmchk2 -i lig.mol2 -f mol2 -o lig.frcmod -s gaff2

    echo " $(date "+%Y-%m-%d %H:%M:%S") running tleap"
    tleap -f $top/run_protocol/leap.in > tleap.log
    
    cd $top/binding_pose_MD

    if [ \! -d ./$pose ]; then
        mkdir ./$pose
        echo "making md run folder for binding pose ${pose} "
    fi
    cd ./$pose

    cp $top/init/$pose/*.parm7 .
    cp $top/init/$pose/*.rst7 .

    echo "$(date "+%Y-%m-%d %H:%M:%S") MD MINIMIZATION "
    mpirun -np 16 $mdrun -O -i $top/run_protocol/01_minimization.mdin -p complex.parm7 -c complex.rst7 -ref complex.rst7 -o 01_minimization.mdout -r 01_minimization.rst7 -inf 01_minimization.mdinfo

    echo "$(date "+%Y-%m-%d %H:%M:%S") MD EQUILIBRATION "
    pmemd.cuda -O -i $top/run_protocol/02_equilibration.mdin -p complex.parm7 -c 01_minimization.rst7 -ref complex.rst7 -o 02_equilibration.mdout -r 02_equilibration.rst7 -inf 02_equilibration.mdinfo -x 02_equilibration.nc

    # echo "starting 1_min_1 at $(date "+%Y-%m-%d %H:%M:%S")"
    # mpirun -np 8 pmemd.MPI -O -i $top/run_protocol/new_md_protocol/1_min_1.in -o 1min.out -p complex.parm7 -c complex.rst7 -r 1_min_1.rst7 -inf 1_min_1.info -ref complex.rst7 -x 1_min_1.mdcrd
    # echo "ending 1_min_1 at $(date "+%Y-%m-%d %H:%M:%S")"

    # echo "starting 2_heat_1 at $(date "+%Y-%m-%d %H:%M:%S")"
    # pmemd.cuda -O -i $top/run_protocol/new_md_protocol/2_heat_1.in -o 2_heat_1.out -p complex.parm7 -c 1_min_1.rst7 -r 2_heat_1.rst7 -inf 2_heat_1.info -ref 1_min_1.rst7 -x 2_heat_1.mdcrd
    # echo "ending 2_heat_1 at $(date "+%Y-%m-%d %H:%M:%S")"

    # echo "starting 3_relex_1 at $(date "+%Y-%m-%d %H:%M:%S")"
    # pmemd.cuda -O -i $top/run_protocol/new_md_protocol/3_relex_1.in -o 3_relex_1.out -p complex.parm7 -c 2_heat_1.rst7 -r 3_relex_1.rst7 -inf 3_relex_1.info -ref 2_heat_1.rst7 -x 3_relex_1.mdcrd
    # echo "ending 3_relex_1 at $(date "+%Y-%m-%d %H:%M:%S")"

    # echo "starting 4_relex_2 at $(date "+%Y-%m-%d %H:%M:%S")"
    # pmemd.cuda -O -i $top/run_protocol/new_md_protocol/4_relex_2.in -o 4_relex_2.out -p complex.parm7 -c 3_relex_1.rst7 -r 4_relex_2.rst7 -inf 4_relex_2.info -ref 3_relex_1.rst7 -x 4_relex_2.mdcrd
    # echo "ending 4_relex_2 at $(date "+%Y-%m-%d %H:%M:%S")"

    # echo "starting 5_min_2.in at $(date "+%Y-%m-%d %H:%M:%S")"
    # mpirun -np 8 pmemd.MPI -O -i $top/run_protocol/new_md_protocol/5_min_2.in -o 5_min_2.out -p complex.parm7 -c 4_relex_2.rst7 -r 5_min_2.rst7 -inf 5_min_2.info -ref 4_relex_2.rst7 -x 5_min_2.mdcrd
    # echo "ending 5_min_2 at $(date "+%Y-%m-%d %H:%M:%S")"

    # echo "starting 6_relex_3 at $(date "+%Y-%m-%d %H:%M:%S")"
    # pmemd.cuda -O -i $top/run_protocol/new_md_protocol/6_relex_3.in -o 6_relex_3.out -p complex.parm7 -c 5_min_2.rst7 -r 6_relex_3.rst7 -inf 6_relex_3.info -ref 5_min_2.rst7 -x 6_relex_3.mdcrd
    # echo "ending 6_relex_3 at $(date "+%Y-%m-%d %H:%M:%S")"

    # echo "starting 7_relex_4 at $(date "+%Y-%m-%d %H:%M:%S")"
    # pmemd.cuda -O -i $top/run_protocol/new_md_protocol/7_relex_4.in -o 7_relex_4.out -p complex.parm7 -c 6_relex_3.rst7 -r 7_relex_4.rst7 -inf 7_relex_4.info -ref 6_relex_3.rst7 -x 7_relex_4.mdcrd
    # echo "ending 7_relex_4 at $(date "+%Y-%m-%d %H:%M:%S")"

    # echo "starting 8_relex_5 at $(date "+%Y-%m-%d %H:%M:%S")"
    # pmemd.cuda -O -i $top/run_protocol/new_md_protocol/8_relex_5.in -o 8_relex_5.out -p complex.parm7 -c 7_relex_4.rst7 -r 8_relex_5.rst7 -inf 8_relex_5.info -ref 7_relex_4.rst7 -x 8_relex_5.mdcrd
    # echo "ending 3_relex_1 at $(date "+%Y-%m-%d %H:%M:%S")"

    # echo "starting 9_relex_6 at $(date "+%Y-%m-%d %H:%M:%S")"
    # pmemd.cuda -O -i $top/run_protocol/new_md_protocol/9_relex_6.in -o 9_relex_6.out -p complex.parm7 -c 8_relex_5.rst7 -r 9_relex_6.rst7 -inf 9_relex_6.info -ref 8_relex_5.rst7 -x 9_relex_6.mdcrd
    # echo "ending 9_relex_6 at $(date "+%Y-%m-%d %H:%M:%S")"

    # 1 ns each step
    cnt=1
    cntmax=10
    prod_step='prod'

    while (($cnt <= $cntmax))
    do  
        let pcnt=$cnt-1;
        istep=${prod_step}_${cnt}
        pstep=${prod_step}_${pcnt}

        if (($cnt == 1)); then
            pstep='02_equilibration'
        fi
        
        echo "$(date "+%Y-%m-%d %H:%M:%S") MD PRODUCTION : $cnt  ${istep}"
        echo "set prod_run:::  pcnt =  $pcnt  istep =  $istep  psetp = $pstep"

        pmemd.cuda -O -i $top/run_protocol/03_production.mdin -p complex.parm7 -c ${pstep}.rst7 -ref complex.rst7 -o ${istep}.mdout -r ${istep}.rst7 -inf ${istep}.mdinfo -x ${istep}.nc

        let cnt+=1;
        
    done

    if [ \! -d ./analysis ]; then
        mkdir ./analysis
        echo "mkdir analysis"
    fi
    
    cd analysis

    cpptraj -i $top/run_protocol/RMSD.cpptraj > RMSD.log
    cpptraj -i $top/run_protocol/new_parm.cpptraj > new_parm.log
    cpptraj -i $top/run_protocol/save_space.cpptraj > traj_nowater.log

    cd $top
    
done