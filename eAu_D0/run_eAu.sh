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

#Make subdirectory and move there
INPUT=$(( 0 + $1 ))
echo $INPUT
DIR=`printf "%04d" $INPUT`
mkdir $DIR
cd $DIR

#Environmental Variables
#export BEAGLESYS="/gpfs/mnt/gpfs02/eic/mdbaker/BeAGLEdev/BeAGLE"
export "BEAGLE_SIF=/gpfs02/eic/veprbl2/beagle_v2.sif"
export "BIND=/gpfs02/eic:/gpfs02/eic"

#copy over necessary files
cp ${WDIR}/eAu_9x100.inp .
cp ${WDIR}/S3ALL003 .
cp ${WDIR}/nuclear.bin .
cp ${WDIR}/make_tree.C .
cp ${WDIR}/HF_filter.C .
cp ${WDIR}/bins.h .

#Run simulation
echo "start running in directory $PWD"

ls -lhrt

echo "Running Job Number $1"
singularity exec --bind "$BIND" "$BEAGLE_SIF" bash -c \
	    "BeAGLE < eAu_9x100.inp > eA.log"

echo "Completed Simulation!!!"

echo ""

/eic/u/rongrong/bin/eic-shell <<EOF
    root -b -q 'make_tree.C(\"eA.txt\")'
    root -b -q 'HF_filter.C(\"eA.root\")'
 
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
mv -v eA.filterD0.root $WDIR/outForPythiaMode/eAu_${INPUT}.filterD0.root
mv -v eA.log  $WDIR/outForPythiaMode/log/eAu_${INPUT}.log
echo "DONE!!!"
