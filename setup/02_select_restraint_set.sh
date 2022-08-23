top=$(pwd)

# binding pose number
pose=1

# restraint group number
set_No=7

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

cpptraj -i $system_restraint.in > $system_restraint.log