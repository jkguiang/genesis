# Instructions
All of the code here is taken from the 2022 CMSDAS [example](https://github.com/agrohsje/genproductions/tree/cmsdas2020).
However, it has been consolidated for simplicity.
The following steps will produce a gridpack using MadGraph.

1. Create a new set of cards for a process called `PROCESS`
```
cd cards
mkdir PROCESS_4f_LO
cp WpToLNu_4f_LO/WpToLNu_4f_LO_run_card.dat PROCESS_4f_LO/PROCESS_4f_LO_run_card.dat
cp WpToLNu_4f_LO/WpToLNu_4f_LO_proc_card.dat PROCESS_4f_LO/PROCESS_4f_LO_proc_card.dat
```
2. Create a gridpack
```
./gridpack_generation.sh PROCESS_4f_LO cards/PROCESS_4f_LO local
```
3. Check that the gridpack is good
4. Clean up
```
rm -rf PROCESS_4f_LO
rm -rf PROCESS_4f_LO.log
```
