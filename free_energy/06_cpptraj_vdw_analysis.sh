#!/bin/sh

top=$(pwd)

analysis_target="complex_1_10_100_100"

cd $analysis_target

if [ \! -d analysis ]; then
    mkdir analysis
    echo "making dir analysis"
fi

cd analysis

if [ \! -d residue_analysis ]; then
    mkdir residue_analysis
    echo "making dir analysis residue_analysis"
fi

cd residue_analysis

if [ \! -d complex ]; then
    mkdir complex
    echo "making dir analysis residue_analysis complex"
fi

if [ \! -d restraint ]; then
    mkdir restraint
    echo "making dir analysis residue_analysis restraint"
fi

cd complex
cpptraj -i $top/cpptraj_protocol/cpptraj_PHE_complex.in > cpptraj_complex.log
cd ..

cd restraint
cpptraj -i $top/cpptraj_protocol/cpptraj_PHE_restraint.in > cpptraj_PHE_restraint.log

