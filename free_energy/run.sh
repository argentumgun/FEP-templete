#!/bin/bash

# Run script1.sh
nohup sh ./script/01_set_up.sh > logs/01_set_up.log 2>&1 &

sleep 20

nohup sh ./script/02_restraint_minization.sh > logs/02_restraint_minization.log 2>&1 &
nohup sh ./script/03_complex_0.0_minimization.sh > logs/03_complex_0.0_minimization.log 2>&1 &
nohup sh ./script/04_complex_0.5_minimization.sh > logs/04_complex_0.5_minimization.log 2>&1 &
nohup sh ./script/05_ligand_minimization.sh > logs/05_ligand_minimization.log 2>&1 &

sleep 1000

nohup sh ./script/06_restraint_pmemd.sh > logs/06_restraint_pmemd.log 2>&1 &
nohup sh ./script/07_complex_0.0_pmemd.sh > logs/07_complex_0.0_pmemd.log 2>&1 &
nohup sh ./script/08_complex_0.5_pmemd.sh > logs/08_complex_0.5_pmemd.log 2>&1 &
nohup sh ./script/09_ligand_pmemd.sh > logs/09_ligand_pmemd.log 2>&1 &
