# BeAGLE Heavy Flavor Production

The running cards and filtering macros for generating heavy flavor events in eAu
collisions can be found in this repository. Here is the procedure:

1) Run BeAGLE simulation for DIS events.

General instruction: https://eic.github.io/software/beagle.htm

Run through container on Alma9:
```
export "BEAGLE_SIF=/gpfs02/eic/veprbl2/beagle_v2.sif"
export "BIND=/gpfs02/eic:/gpfs02/eic"
singularity exec --bind "$BIND" "$BEAGLE_SIF" bash -c \
	    "BeAGLE < eAu_9x100.inp > eA.log"
```

Current simulations use version BeAGLE_1.03.02

2) Convert output txt file into root file using 
```
root -l -b -q 'make_tree.C("eA.txt")'
```

3) Filter out events containing heavy flavor hadrons
* To filter out D0 events, use
```
root -l -b -q 'HF_filter.C("eA.root")'
```
* To filter out Lc events, use
```
root -l -b -q 'filter_Lc.C("eA.root")'
```
* To filter out Ds events, use
```
root -l -b -q 'filter_Ds.C("eA.root")'
```
4) Convert root file to HEPMC format using eic-smear (https://github.com/eic/eic-smear, v1.1.14 and above)

5) Apply beam effects with afterbuner (https://github.com/eic/afterburner)
   
For more details on the runing procedure, refer to "run_eAu.sh" in subdirectories
