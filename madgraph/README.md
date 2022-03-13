# Instructions
As an exercise, we will try to reproduce the central WWZTo4L2Nu\_NLO sample.

1. [Find](https://github.com/cms-sw/genproductions/blob/master/bin/MadGraph5_aMCatNLO/cards/production/2017/13TeV/WWZJets/WWZTo4L_4f_NLO/WWZTo4L_4f_NLO_madspin_card.dat) or write `WWZTo4L_4f_NLO_proc_card.dat`, which specifies the basic parameters of generating this process
```
import model loop_sm
define w = w+ w-
define lep+ = e+ mu+ ta+
define lep- = e- mu- ta-
generate p p > w w lep+ lep- $$ h [QCD] 
output WWZTo4L_4f_NLO -nojpeg
```
2. Run the first Madgraph step, best to do this in a screen; this will make a directory called `WWZTo4L_4f_NLO`
```
$ screen -S genesis
[genesis] $ mg5_aMC proc_cards/WWZTo4L_4f_NLO_proc_card.dat
ctrl+A+D
```
3. [Find](http://uaf-10.t2.ucsd.edu/~jguiang/dis/?query=%2FWWZJetsTo4L2Nu_4F_TuneCP5_13TeV-amcatnlo-pythia8%2FRunIISummer20UL18NanoAODv9-106X_upgrade2018_realistic_v16_L1v1-v2%2FNANOAODSIM&type=chain&short=short) a the central gridpack, and untar it
```
$ mkdir temp
$ cd temp
temp $ cp /cvmfs/path/to/gridpack.tar.xz .
temp $ tar -xf gridpack.tar.xz
```
4. There should be a directory called `process/Cards` with the cards we need inside
```
temp $ ls process/Cards
.plot_card.dat               README                       madspin_card_default.dat     pgs_card_default.dat
.shower_card.dat             amcatnlo_configuration.txt   param_card.dat               plot_card_default.dat
FKS_params.dat               delphes_card_ATLAS.dat       param_card_default.dat       proc_card_mg5.dat
FO_analyse_card.dat          delphes_card_CMS.dat         pgs_card_ATLAS.dat           reweight_card_default.dat
FO_analyse_card_default.dat  delphes_card_default.dat     pgs_card_CMS.dat             run_card.dat
MadLoopParams.dat            ident_card.dat               pgs_card_LHC.dat             run_card_default.dat
MadLoopParams_default.dat    madspin_card.dat             pgs_card_TEV.dat             shower_card_default.dat
```
5. Copy the cards we need and clean up
```
temp $ cp process/Cards/run_card.dat ../WWZTo4L_4f_NLO/Cards/run_card.dat
temp $ cp process/Cards/run_card.dat ../run_cards/WWZTo4L_4f_NLO_run_card.dat # save for posterity
temp $ cp process/Cards/madspin_card.dat ../WWZTo4L_4f_NLO/Cards/madspin_card.dat
temp $ cp process/Cards/madspin_card.dat ../madspin_cards/WWZTo4L_4f_NLO_madspin_card.dat # save for posterity
temp $ cd ..
$ rm -rf temp
```
6. Run the last Madgraph step; again, best to do this in a screen
```
$ screen -S genesis
[genesis] $ mg5_aMC
MG5_aMC>launch WWZTo4L_4f_NLO
************************************************************
*                                                          *
*           W E L C O M E  to  M A D G R A P H 5           *
*                       a M C @ N L O                      *
*                                                          *
*                 *                       *                *
*                   *        * *        *                  *
*                     * * * * 5 * * * *                    *
*                   *        * *        *                  *
*                 *                       *                *
*                                                          *
*         VERSION 3.3.1                 2021-12-04         *
*                                                          *
*    The MadGraph5_aMC@NLO Development Team - Find us at   *
*                 http://amcatnlo.cern.ch                  *
*                                                          *
*               Type 'help' for in-line help.              *
*                                                          *
************************************************************
INFO: load configuration from /home/users/jguiang/projects/genesis/madgraph/WWZTo4L_4f_NLO/Cards/amcatnlo_configuration.txt
INFO: load configuration from /home/users/jguiang/apps/MG5_aMC_v3_3_1/input/mg5_configuration.txt
INFO: load configuration from /home/users/jguiang/projects/genesis/madgraph/WWZTo4L_4f_NLO/Cards/amcatnlo_configuration.txt
No valid eps viewer found. Please set in ./input/mg5_configuration.txt
launch auto
...
```
7. Hit enter a few times until it starts running, then detach from the screen and let Madgraph do its thing
