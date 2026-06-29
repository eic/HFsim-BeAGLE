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
cp ${WDIR}/filter_Ds.C .
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
    root -b -q 'filter_Ds.C(\"eA.root\")'
 
EOF

#Move output files and cleanup
echo "Cleaning Up..."
mv -v eA.filterDs.root $WDIR/outForPythiaMode/eAu_${INPUT}.filterDs.root
mv -v eA.log  $WDIR/outForPythiaMode/log/eAu_${INPUT}.log
echo "DONE!!!"
