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
    singularity exec --bind "$BIND" "$BEAGLE_SIF" bash -c BeAGLE < eAg_9x115_Q2_100_10000.inp

    /eic/u/rongrong/bin/eic-shell <<EOF
    root -b -q 'make_tree.C(\"eAg_9x115.txt\")'
    echo 'TreeToHepMC("eAg_9x115.root")' | eic-smear
EOF
    
    exit
fi



###############################################################
### Batch prodcution for real data using file list          ###
###############################################################

if [ $submit -eq 1 ]; then
    #odir=/gpfs/mnt/gpfs02/eic/rongrong/BeAGLE/D0/eAu_10x100_Q2min1_largesample
    #odir=/gpfs/mnt/gpfs02/eic/rongrong/BeAGLE/D0/eAu_5x41_Q2min1_largesample
    #odir=/gpfs/mnt/gpfs02/eic/rongrong/BeAGLE/DIS/eAu_10x100_Q2min1

    config=9x115
    generator=BeAGLE_1.03.02
    minQ2=(1 10 100)
    maxQ2=(10 100 10000)

    for i in `seq 0 2`; do
	minq2=${minQ2[$i]}
	maxq2=${maxQ2[$i]}
	echo "[i] Process Q2 = $minq2 - $maxq2"
		
	odir=/gpfs/mnt/gpfs02/eic/rongrong/SC_requests/${generator}/DIS/eAg_${config}_Q2_${minq2}_${maxq2}
	logdir=$odir/outForPythiaMode/log
	if [ ! -d $logdir ]; then
	    mkdir -pv $logdir
	fi
	rm -rf $logdir/*

	executable=run_eAg.sh
	cp -v ${executable} $odir/.
	cp -v eAg_9x115_Q2_${minq2}_${maxq2}.inp $odir/.
	cp -v S3ALL003 $odir/.
	cp -v nuclear.bin $odir/.
	cp -v make_tree.C $odir/.
	chmod a+x $odir/${executable}
    
	echo $odir/$executable
	#Initializing Condor File
	condor_file=CondorFile_gen_eAg_9x115_Q2_${minq2}_${maxq2}
	echo "" > ${condor_file}
	echo "Universe    = vanilla" >> ${condor_file}
	echo "Executable  = ${odir}/${executable}" >> ${condor_file}
	echo "GetEnv  =  True" >> ${condor_file}
	#echo '+SingularityImage="/cvmfs/singularity.opensciencegrid.org/eicweb/jug_xl:nightly"' >> ${condor_file}

	for ifile in `seq 1 9`; do
	    LogFile=${logdir}/eAgjob.${ifile}.out
	    ErrFile=${logdir}/eAgjob.${ifile}.err
	    
	    echo "" >> CondorFile_gen
	    echo "Output    = ${LogFile}" >> ${condor_file}
	    echo "Error     = ${ErrFile}" >> ${condor_file}
	    echo "Arguments = ${ifile} ${odir} ${minq2} ${maxq2}" >> ${condor_file}
	    echo "Queue" >> ${condor_file}
	done
	cp ${condor_file} $odir/.
    done
fi

