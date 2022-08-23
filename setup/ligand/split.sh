#/usr/bin/bash

obabel -ipdbqt ligand_docking.pdbqt -opdb -O ligand_pose_.pdb -m
mkdir ligand_H 
obabel -ipdb *.pdb -opdb -O ./ligand_H/.pdb -m -p