# Instructions
After creating a gridpack for generating LHE files using MadGraph, we can follow the steps below to take LHE files all of the way to NanoAODv9.

## 1. Find a finished central sample
Find a centrally produced sample that has been completed processed. 
We want to produce a NanoAODv9 sample, so we will use DIS (or DAS) to locate a finished central NanoAODv9 sample. 
One such saample is the VBS WZ sample:
```
/WZJJ_EWK_InclusivePolarization_TuneCP5_13TeV_madgraph-madspin-pythia8/RunIISummer20UL16NanoAODAPVv9-106X_mcRun2_asymptotic_preVFP_v11-v1/NANOAODSIM
/WZJJ_EWK_InclusivePolarization_TuneCP5_13TeV_madgraph-madspin-pythia8/RunIISummer20UL16NanoAODv9-106X_mcRun2_asymptotic_v17-v1/NANOAODSIM
/WZJJ_EWK_InclusivePolarization_TuneCP5_13TeV_madgraph-madspin-pythia8/RunIISummer20UL17NanoAODv9-106X_mc2017_realistic_v9-v1/NANOAODSIM
/WZJJ_EWK_InclusivePolarization_TuneCP5_13TeV_madgraph-madspin-pythia8/RunIISummer20UL18NanoAODv9-106X_upgrade2018_realistic_v16_L1v1-v1/NANOAODSIM
```
*Disclaimer*: DIS has a ``chain" option that we can potentially use to skip McM alltogether. 
However, we will proceed with the central tool (McM) in case DIS has incomplete information--CMS does not always maintain perfect metadata, which DIS relies on.

## 2. Use McM
We proceed to [McM](https://cms-pdmv.cern.ch/mcm/), enter the dataset name (`WZJJ_EWK_InclusivePolarization_TuneCP5_13TeV_madgraph-madspin-pythia8`) into the "...by dataset name" field, and click the "Search" button.
The interface is... less than perfect, but we must proceed with courage. 

![McM Landing Page](/path/to/img)

We first note that we are only seeing the first 20 results. 
We would like to see _all_ of them, and we can click the "All" button by the result counter to do so; loading them will take some time.

![McM Paginated Results](/path/to/img)

We are also not seeing some useful information. 
By clicking "Select View," we will see a wealth of additional columns to render. 
We will select the "Input dataset" and "Output dataset" options; we will also _deselect_ the "Tag" option because that column is consuming valuable screen real estate.
We can then click the "Save selection" button to update the table. 
Two new columns should appear corresponding to the additional options we selected.
We can click "Select View" again to tuck that menu away--we will not need it again.

![McM Select Views Results](/path/to/img)

Once all of the results are loaded, we can use `ctrl+F` to search for the each of the production campaigns we would like to follow.
We will start with 2018: `Summer20UL18NanoAODv9`.
Nicely, there is only one row with this substring in it, and it corresponds to the NanoAODv9 sample we were looking for!

![McM Search Results](/path/to/img)

We can now follow the production chain down the line. We see that our NanoAODv9 sample was produced from a MiniAODv2 sample. 
We can search for `Summer20UL18MiniAODv2` to find it amongst our page of results.
Again, only one row corresponds to the 2018 MiniAODv2 production.
Repeating this process, we find that the MiniAODv2 sample was produced from a RECO sample.
However, if we try to find what the RECO sample was produced from, we come across a convenient dead end: the "Input dataset" column for the RECO sample is empty!
We can instead search for just the campaign tag `RunIISummer20UL18` to find the rest of the samples in the production chain.
We see now that the metadata is incomplete: the DIGIPremix, HLT, SIM, and wmLHEGEN steps are all missing values in the "Input dataset" and "Output dataset" columns.
Using previous experience (or asking someone with previous experience), we can deduce the order of the full production chain:

| Step       | Prepid (`PAG-CampaignStep-index`)       | Description                                                        | Data Tier  |
| ---------- | --------------------------------------- | ------------------------------------------------------------------ | ---------- |
| wmLHEGEN   | `SMP-RunIISummer20UL18wmLHEGEN-00002`   | LHE simulation data                                                | LHEGENSIM  |
| SIM        | `SMP-RunIISummer20UL18SIM-00002`        | simulation data                                                    | GENSIM     |
| DIGIPremix | `SMP-RunIISummer20UL18DIGIPremix-00002` | "digitized" simulation data                                        | GENSIMDIGI |
| HLT        | `SMP-RunIISummer20UL18HLT-00002`        | simulation data that passes the HLT                                | GENSIMRAW  |
| RECO       | `SMP-RunIISummer20UL18RECO-00002`       | reconstructed simulation data                                      | AODSIM     |
| MiniAODv2  | `SMP-RunIISummer20UL18MiniAODv2-00047`  | semi-slim data tier                                                | MINIAODSIM |
| NanoAODv9  | `SMP-RunIISummer20UL18NanoAODv9-00047`  | ultra-slim data tier that we want to use                           | NANOAODSIM |

We can now click the third button from the left (a :heavy_check_mark: in a circle) to get the setup shell script for each step.
These scripts can also be used to deduce the order of the steps in the production chain.
Even better, however, these scripts can be used to create all of the CMSSW "psets" needed to actually _run_ the production chain ourselves!

## 3. Build the production chain
Our goal is to construct a shell script that runs `cmsDriver.py` for each step in the production chain; this will produce the psets we are after.
We must start with the wmLHEGEN step. 
Somewhere in the setup shell script for this step that we found earlier, we should see something like the following line:
```bash
# Download fragment from McM
curl -s -k https://cms-pdmv.cern.ch/mcm/public/restapi/requests/get_fragment/SMP-RunIISummer20UL18wmLHEGEN-00002 --retry 3 --create-dirs -o Configuration/GenProduction/python/SMP-RunIISummer20UL18wmLHEGEN-00002-fragment.py
[ -s Configuration/GenProduction/python/SMP-RunIISummer20UL18wmLHEGEN-00002-fragment.py ] || exit $?;
```
We can run something like this line ourselves to retrieve this "fragment" (a CMSSW python script) for each campaign:
```
curl -s -k https://cms-pdmv.cern.ch/mcm/public/restapi/requests/get_fragment/SMP-RunIISummer20UL18wmLHEGEN-00002 -o wmLHEGS_RunIISummer20UL18.py
curl -s -k https://cms-pdmv.cern.ch/mcm/public/restapi/requests/get_fragment/SMP-RunIISummer20UL17wmLHEGEN-00001 -o wmLHEGS_RunIISummer20UL17.py
curl -s -k https://cms-pdmv.cern.ch/mcm/public/restapi/requests/get_fragment/SMP-RunIISummer20UL16wmLHEGENAPV-00019 -o wmLHEGS_RunIISummer20UL16APV.py
curl -s -k https://cms-pdmv.cern.ch/mcm/public/restapi/requests/get_fragment/SMP-RunIISummer20UL16wmLHEGEN-00002 -o wmLHEGS_RunIISummer20UL16.py
```
We should then check these fragments against each other: they should be identical.
If this is true, we can then check any one of them against the generic fragment `fragment.py` in this repository.
The only difference should be in the `sed` "placeholder" strings `VARIABLE_SED_PLACEHOLDER`.
If this is true, we can proceed.
Otherwise, we will have to make a new generic fragment, taking care to place `sed` placeholders where appropriate.
In the example case we have been using, `fragment.py` is sufficient.
Now, we want to selectively copy the parts of this shell script that we need.
By stringing these together, we can create and run all of the psets that we need for a given production campaign.
Then, we can submit Condor jobs to ultimately run everything.
We can look at the scripts in the `scripts/RunIISummer20UL18` directory as an example.

When we reach the DIGIPremix step, we notice this `cmsDriver.py` parameter:
```
--pileup_input "dbs:/Neutrino_E-10_gun/RunIISummer20ULPrePremix-UL18_106X_upgrade2018_realistic_v11_L1v1-v2/PREMIX"
```
This points to a dataset of around 50,000 files of pre-generated pileup events.
However, it is sufficient to just pass in a randomly selected handful of these files instead.
To do this, we first need to get the list of these files:
```
dasgoclient -query="file dataset=/Neutrino_E-10_gun/RunIISummer20ULPrePremix-UL18_106X_upgrade2018_realistic_v11_L1v1-v2/PREMIX" > pileup_files.txt
```
Then, we can select 5 random files using the following lines:
```
# Grab 5 random files, exchanging '\n' characters for ','
RANDOM_PILEUPFILES=$(shuf -n 5 pileup_files | tr '\n' ',') 
RANDOM_PILEUPFILES=${RANDOM_PILEUPFILES::-1} # trim last comma
```
Again, see the examples in the `scripts` directory for how to include this in the pset generation.

## 4. Run Condor jobs
Once we have finished writing the equivalent scripts to those found in one of the campaigns in the `scripts` directory, we can start running our Condor jobs.
First, we can tar up everything we need with a handy script included in this repository:
```
$ ./mkpkg RunIISummer20UL18
Tarring up the following files into RunIISummer20UL18.tar.xz...
fragment.py
scripts/utils.sh
scripts/RunIISummer20UL18/mkall.sh
scripts/RunIISummer20UL18/pileup_files.txt
Done
```
Then, we can simply run our [ProjectMetis](https://github.com/aminnj/ProjectMetis) script:
```
$ ./metis -h
usage: metis [-h] [--debug] --tag TAG --nevents NEVENTS --njobs NJOBS
             --gridpack GRIDPACK --campaign CAMPAIGN
             [--sites [SITES [SITES ...]]] [--n_monit_hrs N_MONIT_HRS]

Submit NanoAOD-skimming condor jobs

optional arguments:
  -h, --help            show this help message and exit
  --debug               Run in debug mode
  --tag TAG             Unique tag for submissions
  --nevents NEVENTS     Number of events to generate per job
  --njobs NJOBS         Number of jobs to run
  --gridpack GRIDPACK   /path/to/gridpack.tar.gz
  --campaign CAMPAIGN   Reconstruction campaign to generate
  --sites [SITES [SITES ...]]
                        Space-separated list of T2 sites
  --n_monit_hrs N_MONIT_HRS
                        Number of hours to run Metis for
```
