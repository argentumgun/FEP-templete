#!/usr/bin/bash
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
    
    ligand="ligand_pose_$pose"
    echo "binding ligand : $ligand"

    echo "$(date "+%Y-%m-%d %H:%M:%S") GAUSS start"
    g16 $top/binding_pose_dir/$ligand.gjf
    #antechamber -i $top/binding_pose_dir/$ligand -fi pdb -o lig.com -fo gcrt
    echo "$(date "+%Y-%m-%d %H:%M:%S") antechamber start"
    antechamber -i $top/binding_pose_dir/$ligand.log -fi gout -o lig.mol2 -fo mol2 -c bcc -at gaff2
    parmchk2 -i lig.mol2 -f mol2 -o lig.frcmod -s gaff2

    echo "running tleap"
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

    # 1 ns each step
    cnt=1
    cntmax=5
    prod_step='prod'

    while (($cnt <= $cntmax))
    do  
        let pcnt=$cnt-1;
        istep=${prod_step}_${cnt}
        pstep=${prod_step}_${pcnt}

        if (($cnt == 1)); then
            pstep='02_equilibration'
        fi
        
        echo "$(date "+%Y-%m-%d %H:%M:%S") MD PRODUCTION : $cnt  ${istep} "
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
    cpptraj -i $top/run_protocol/new_parm.cpptraj
    cpptraj -i $top/run_protocol/save_space.cpptraj

    cd $top
    
done