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

## 2. Using McM
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
We can instead, however, search for just the campaign tag `RunIISummer20UL18` to find the rest of the samples in the production chain.
We see here that the metadata is incomplete: the DIGIPremix, HLT, SIM, and wmLHEGEN steps are all missing values in the "Input dataset" and "Output dataset" columns.
Using previous experience (or asking someone with previous experience), however, we can deduce the order of the full production chain:

| Prepid (`PAG-DataTier-index`)           | Description                                                        |
| --------------------------------------- | ------------------------------------------------------------------ |
| `SMP-RunIISummer20UL18NanoAODv9-00047`  | ultra-slim NanoAOD data tier that we want to use                   |
| `SMP-RunIISummer20UL18MiniAODv2-00047`  | semi-slim MiniAOD data tier (closer to "raw" detector information) |
| `SMP-RunIISummer20UL18RECO-00002`       | reconstructed simulation data                                      |
| `SMP-RunIISummer20UL18DIGIPremix-00002` | "digitized" simulation data                                        |
| `SMP-RunIISummer20UL18HLT-00002`        | simulation data that passes the HLT                                |
| `SMP-RunIISummer20UL18SIM-00002`        | simulation data                                                    |
| `SMP-RunIISummer20UL18wmLHEGEN-00002`   | LHE simulation data                                                |

We can now click the second button from the left (a circle with a downward-pointing arrow) to get the setup shell script for each step.
