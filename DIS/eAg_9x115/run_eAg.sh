#!/usr/bin/bash
#-----#-----#----#----#----#----#----#----#----#

if [ -z "$1" ]
then
        echo "No job number set."
        echo "Please run as ./run_eAu.sh jobnumber"
        echo "Exiting..."
        exit 1
fi

#Go into scratch directory
chmod g+rx ${_CONDOR_SCRATCH_DIR}
cd ${_CONDOR_SCRATCH_DIR}

#Working directory
WDIR=${2}
minq2=${3}
maxq2=${4}

#Make subdirectory and move there
INPUT=$(( 0 + $1 ))
echo $INPUT
DIR=`printf "%04d" $INPUT`
DIR=Q2_${minq2}_${maxq2}_$DIR
mkdir $DIR
cd $DIR

#Environmental Variables
#export BEAGLESYS="/gpfs/mnt/gpfs02/eic/mdbaker/BeAGLEdev/BeAGLE"
export "BEAGLE_SIF=/gpfs02/eic/veprbl2/beagle_v2.sif"
export "BIND=/gpfs02/eic:/gpfs02/eic"

#copy over necessary files
cp ${WDIR}/eAg_9x115_Q2_${minq2}_${maxq2}.inp eAg_9x115.inp
cp ${WDIR}/S3ALL003 .
cp ${WDIR}/nuclear.bin .
cp ${WDIR}/make_tree.C .

#Run simulation
echo "start running in directory $PWD"

ls -lhrt

echo "Running Job Number $1"
singularity exec --bind "$BIND" "$BEAGLE_SIF" bash -c \
	    "BeAGLE < eAg_9x115.inp > eAg.log"

echo "Completed Simulation!!!"

echo ""

/eic/u/rongrong/bin/eic-shell <<EOF
    root -b -q 'make_tree.C(\"eAg_9x115.txt\")'
    echo 'TreeToHepMC("eAg_9x115.root")' | eic-smear
 
EOF

#echo "Making Output ROOT File..."
#root -l -b -q "make_tree.C(\"eA.txt\")"
#echo "Done!!!"
#echo ""

#echo "Filter ROOT File..."
#root -l -b -q "HF_filter.C(\"eA.root\")"
#echo "Done!!!"
#echo ""

#Move output files and cleanup
echo "Cleaning Up..."
#mv -v eA.txt  $WDIR/outForPythiaMode/eAu_${INPUT}.txt
#mv -v eA.root $WDIR/outForPythiaMode/eAu_${INPUT}.root
mv -v eAg_9x115.root  $WDIR/outForPythiaMode/eAg_Q2_${minq2}_${maxq2}.${INPUT}.root
mv -v eAg_9x115.hepmc $WDIR/outForPythiaMode/eAg_Q2_${minq2}_${maxq2}.${INPUT}.hepmc
mv -v eAg.log $WDIR/outForPythiaMode/log/eAg_${INPUT}.log
echo "DONE!!!"
