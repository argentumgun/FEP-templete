#!/bin/bash

# Run script1.sh
nohup sh ./01_restraint.sh > logs/restraint.log 2>&1 &
# Wait for 5 seconds
sleep 10

nohup sh ./03_complex_vdw_crg.sh > logs/complex_01.log 2>&1 &
nohup sh ./04_complex_0.5.sh > logs/complex_02.log 2>&1 &
nohup sh ./08_ligand.sh > logs/ligands.log 2>&1 &
