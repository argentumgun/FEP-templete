top=$(pwd)

# binding pose number
pose=1

# restraint group number
set_No=1

system_restraint="restraint_set_${set_No}"

# anchor atom set
ATOM_C=':48@C'
ATOM_B=':48@CA'
ATOM_A=':48@CB' 
ATOM_a=':1@C21'
ATOM_b=':1@N7'
ATOM_c=':1@C7'

if [ \! -d ${top}/binding_pose_MD/${pose}/analysis/$system_restraint ]; then
    mkdir ${top}/binding_pose_MD/${pose}/analysis/$system_restraint
fi

cd ${top}/binding_pose_MD/${pose}/analysis/$system_restraint

sed  -e "s/%A%/$ATOM_A/g" -e "s/%B%/$ATOM_B/g" -e "s/%C%/$ATOM_C/g" -e "s/%a%/$ATOM_a/g" -e "s/%b%/$ATOM_b/g" -e "s/%c%/$ATOM_c/g" $top/run_protocol/restraint_analysis.tmpl > $system_restraint.in

sed -e "s/%PA%/$ATOM_A/g" -e "s/%PB%/$ATOM_B/g" -e "s/%PC%/$ATOM_C/g" -e "s/%La%/$ATOM_a/g" -e "s/%Lb%/$ATOM_b/g" -e "s/%Lc%/$ATOM_c/g" $top/run_protocol/05_set_boresch_restraint.sh.tmpl > 05_set_boresch_restraint.sh

sed -e "s/%PA%/$ATOM_A/g" -e "s/%PB%/$ATOM_B/g" -e "s/%PC%/$ATOM_C/g" -e "s/%La%/$ATOM_a/g" -e "s/%Lb%/$ATOM_b/g" -e "s/%Lc%/$ATOM_c/g" ../free_energy/script/06_restraint_pmemd.sh.tmpl > ../free_energy/script/06_restraint_pmemd.sh


cpptraj -i $system_restraint.in > $system_restraint.log