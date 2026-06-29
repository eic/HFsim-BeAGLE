#!/bin/bash

submit=$1

if [ -z $submit ]; then
    echo "[i] Set it to submit = 0 for local test"
    submit=0
fi

##################################################
### Local test ###
##################################################
if [ $submit -eq 0 ]; then
    echo "[i] Running local tests"
    export "BEAGLE_SIF=/gpfs02/eic/veprbl2/beagle_v2.sif"
    export "BIND=/gpfs02/eic:/gpfs02/eic"
    singularity exec --bind "$BIND" "$BEAGLE_SIF" bash -c BeAGLE < eAu_9x100.inp

    /eic/u/rongrong/bin/eic-shell <<EOF
    root -b -q 'make_tree.C(\"eA.txt\")'
    root -b -q 'filter_Lc.C(\"eA.root\")'
 
EOF
    
    exit
fi



###############################################################
### Batch prodcution for real data using file list          ###
###############################################################

if [ $submit -eq 1 ]; then
    config=9x100
    generator=BeAGLE_1.03.02
    odir=/gpfs/mnt/gpfs02/eic/rongrong/SC_requests/${generator}/Lc/eAu_${config}_Q2min1
    logdir=$odir/outForPythiaMode/log
    if [ ! -d $logdir ]; then
	mkdir -pv $logdir
    fi
    rm -rf $logdir/*

    executable=run_eAu.sh
    cp -v ${executable} $odir/.
    cp -v eAu_9x100.inp $odir/.
    cp -v S3ALL003 $odir/.
    cp -v nuclear.bin $odir/.
    cp -v make_tree.C $odir/.
    cp -v filter_Lc.C $odir/.
    cp -v bins.h $odir/.
    chmod a+x $odir/${executable}
    
    echo $odir/$executable
    #Initialising Condor File
    condor_file=CondorFile_gen
    echo "" > ${condor_file}
    echo "Universe    = vanilla" >> ${condor_file}
    echo "Executable  = ${odir}/${executable}" >> ${condor_file}
    echo "GetEnv  =  True" >> ${condor_file}
    echo "Arguments = \$(number) \$(oodir) "  >> ${condor_file}

    echo "log = ${logdir}/eAujob.\$(number).log"  >> ${condor_file}
    echo "error = ${logdir}/eAujob.\$(number).err"  >> ${condor_file}
    echo "output = ${logdir}/eAujob.\$(number).out"  >> ${condor_file}

    echo "" >> ${condor_file}
    echo "queue number, oodir from (" >> ${condor_file}

    for ifile in `seq 1 10000`; do
	echo ${ifile}, ${odir} >> ${condor_file}
    done
    echo ")" >> ${condor_file}
    cp ${condor_file} $odir/.
fi

