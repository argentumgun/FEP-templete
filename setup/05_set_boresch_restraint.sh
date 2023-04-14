top=$(pwd)

# binding pose number
pose=1

system_restraint='Boresch_restraint_frame_'

# anchor atom
ATOM_C=':48@C'
ATOM_B=':48@CA'
ATOM_A=':48@CB' 
ATOM_a=':1@C21'
ATOM_b=':1@N7'
ATOM_c=':1@C7'

if [ \! -d ${top}/binding_pose_MD/${pose}/analysis/Select_Reference_Frame ]; then
    mkdir ${top}/binding_pose_MD/${pose}/analysis/Select_Reference_Frame
fi

cd ${top}/binding_pose_MD/${pose}/analysis/Select_Reference_Frame

for Frame in 1 2 3 4 5 6 7 8 9 10; do
    
    if [ \! -d $system_restraint$Frame ]; then
        mkdir $system_restraint$Frame
    fi

    cd $system_restraint$Frame

    # different reference frames
    sed  -e "s/%Frame%/$Frame/g" -e "s/%A%/$ATOM_A/g" -e "s/%B%/$ATOM_B/g" -e "s/%C%/$ATOM_C/g" -e "s/%a%/$ATOM_a/g" -e "s/%b%/$ATOM_b/g" -e "s/%c%/$ATOM_c/g" $top/run_protocol/set_boresch_restraint.tmpl > $system_restraint$Frame.in

    cpptraj -i $system_restraint$Frame.in > $system_restraint$Frame.log

    # output a restraint templete file
    sed -e "s/10.000000/%D%/g" -e "s/11.000000/%A%/g" -e "s/12.000000/%T%/g" middle.tmpl > Boresch_restraint.tmpl

    cd ..

done