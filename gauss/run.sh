# /usr/bin/bash

g16 ligand_1.gjf
antechamber -i ligand_1.log -fi gout -fo mol2 -o lig.mol2 -c bcc -at gaff2
parmchk2 -i lig.mol2 -f mol2 -o lig.frcmod -s gaff2