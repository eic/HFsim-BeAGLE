# BeAGLE Heavy Flavor Production

The running cards and filtering macros for generating heavy flavor events in eAu
collisions can be found in this repository. Here is the procedure:

1) Run BeAGLE simulation for DIS events. Instructions can be found here:
https://eic.github.io/software/beagle.html

Current simulations use version BeAGLE_1.03.01

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
4) Convert root file to HEPMC format using eic-smear (https://github.com/eic/eic-smear, v1.1.14)

5) Apply beam effects with afterbuner (https://github.com/eic/afterburner, v0.1.1)
   
For more details on the runing procedure, refer to "run_eAu.sh" in subdirectories
