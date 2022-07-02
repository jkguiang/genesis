#!/bin/bash
SCRIPT_DIR=$(dirname ${BASH_SOURCE[0]})
source $SCRIPT_DIR/../utils.sh

CAMPAIGN=RunIISummer20UL16APV
FRAGMENT=$1
GRIDPACK=$2
EVENTS=$3
SEED=$4
NORUN=$5

# == GEN,LHE =====================================
# Prepid: SMP-RunIISummer20UL16wmLHEGENAPV-00019
setup_cmssw CMSSW_10_6_18 slc7_amd64_gcc700 --no_scramb
FRAGMENT_CMSSW=$(inject_fragment $FRAGMENT $GRIDPACK $EVENTS)
scram b -j8
cd ../..

cmsDriver.py $FRAGMENT_CMSSW \
    --python_filename LHEGS_${CAMPAIGN}_cfg.py \
    --eventcontent RAWSIM,LHE \
    --customise Configuration/DataProcessing/Utils.addMonitoring \
    --datatier GEN,LHE \
    --fileout file:LHEGS_${CAMPAIGN}.root \
    --conditions 106X_mcRun2_asymptotic_preVFP_v8 \
    --beamspot Realistic25ns13TeV2016Collision \
    --customise_commands process.source.numberEventsInLuminosityBlock="cms.untracked.uint32(100)" \
    --step LHE,GEN \
    --geometry DB:Extended \
    --era Run2_2016_HIPM \
    --no_exec \
    --mc \
    -n $EVENTS

set_lhegs_seed LHEGS_${CAMPAIGN}_cfg.py $SEED

if [[ "$NORUN" != "true" ]]; then cmsRun LHEGS_${CAMPAIGN}_cfg.py; fi
# == GEN,LHE =====================================

# == SIM =========================================
# Prepid: SMP-RunIISummer20UL16SIMAPV-00020
setup_cmssw CMSSW_10_6_17_patch1 slc7_amd64_gcc700
cmsDriver.py \
    --python_filename SIM_${CAMPAIGN}_cfg.py \
    --eventcontent RAWSIM \
    --customise Configuration/DataProcessing/Utils.addMonitoring \
    --datatier GEN-SIM \
    --fileout file:SIM_${CAMPAIGN}.root \
    --conditions 106X_mcRun2_asymptotic_preVFP_v8 \
    --beamspot Realistic25ns13TeV2016Collision \
    --step SIM \
    --geometry DB:Extended \
    --filein file:LHEGS_${CAMPAIGN}.root \
    --era Run2_2016_HIPM \
    --runUnscheduled \
    --no_exec \
    --mc \
    -n $EVENTS

if [[ "$NORUN" != "true" ]]; then cmsRun SIM_${CAMPAIGN}_cfg.py; fi
rm LHEGS_${CAMPAIGN}.root
# == SIM =========================================

# == DIGIPREMIX ==================================
# Prepid: SMP-RunIISummer20UL16DIGIPremixAPV-00014
# Pileup: /Neutrino_E-10_gun/RunIISummer20ULPrePremix-UL16_106X_mcRun2_asymptotic_v13-v1/PREMIX
RANDOM_PILEUPFILES=$(shuf -n 5 $SCRIPT_DIR/pileup_files.txt | tr '\n' ',') 
RANDOM_PILEUPFILES=${RANDOM_PILEUPFILES::-1} # trim last comma

setup_cmssw CMSSW_10_6_17_patch1 slc7_amd64_gcc700
cmsDriver.py \
    --python_filename DIGIPremix_${CAMPAIGN}_cfg.py \
    --eventcontent PREMIXRAW \
    --customise Configuration/DataProcessing/Utils.addMonitoring \
    --datatier GEN-SIM-DIGI \
    --fileout file:DIGIPremix_${CAMPAIGN}.root \
    --pileup_input $RANDOM_PILEUPFILES \
    --conditions 106X_mcRun2_asymptotic_preVFP_v8 \
    --step DIGI,DATAMIX,L1,DIGI2RAW \
    --procModifiers premix_stage2 \
    --geometry DB:Extended \
    --filein file:SIM_${CAMPAIGN}.root \
    --datamix PreMix \
    --era Run2_2016_HIPM \
    --runUnscheduled \
    --no_exec \
    --mc \
    -n $EVENTS

if [[ "$NORUN" != "true" ]]; then cmsRun DIGIPremix_${CAMPAIGN}_cfg.py; fi
rm SIM_${CAMPAIGN}.root
# == DIGIPREMIX ==================================

# == HLT =========================================
# Prepid: SMP-RunIISummer20UL16HLTAPV-00021
setup_cmssw CMSSW_8_0_33_UL slc7_amd64_gcc530
cmsDriver.py \
    --python_filename HLT_${CAMPAIGN}_cfg.py \
    --eventcontent RAWSIM \
    --outputCommand "keep *_mix_*_*,keep *_genPUProtons_*_*" \
    --customise Configuration/DataProcessing/Utils.addMonitoring \
    --datatier GEN-SIM-RAW \
    --inputCommands "keep *","drop *_*_BMTF_*","drop *PixelFEDChannel*_*_*_*" \
    --fileout file:HLT_${CAMPAIGN}.root \
    --conditions 80X_mcRun2_asymptotic_2016_TrancheIV_v6 \
    --customise_commands 'process.source.bypassVersionCheck = cms.untracked.bool(True)' \
    --step HLT:25ns15e33_v4 \
    --geometry DB:Extended \
    --filein file:DIGIPremix_${CAMPAIGN}.root \
    --era Run2_2016 \
    --no_exec \
    --mc \
    -n $EVENTS

if [[ "$NORUN" != "true" ]]; then cmsRun HLT_${CAMPAIGN}_cfg.py; fi
rm DIGIPremix_${CAMPAIGN}.root
# == HLT =========================================

# == RECO ========================================
# Prepid: SMP-RunIISummer20UL16RECOAPV-00021
setup_cmssw CMSSW_10_6_17_patch1 slc7_amd64_gcc700
cmsDriver.py \
    --python_filename RECO_${CAMPAIGN}_cfg.py \
    --eventcontent AODSIM \
    --customise Configuration/DataProcessing/Utils.addMonitoring \
    --datatier AODSIM \
    --fileout file:RECO_${CAMPAIGN}.root \
    --conditions 106X_mcRun2_asymptotic_preVFP_v8 \
    --step RAW2DIGI,L1Reco,RECO,RECOSIM \
    --geometry DB:Extended \
    --filein file:HLT_${CAMPAIGN}.root \
    --era Run2_2016_HIPM \
    --runUnscheduled \
    --no_exec \
    --mc \
    -n $EVENTS

if [[ "$NORUN" != "true" ]]; then cmsRun RECO_${CAMPAIGN}_cfg.py; fi
rm HLT_${CAMPAIGN}.root
# == RECO ========================================

# == MiniAODv2 ===================================
# Prepid: SMP-RunIISummer20UL16MiniAODAPVv2-00034
setup_cmssw CMSSW_10_6_25 slc7_amd64_gcc700
cmsDriver.py \
    --python_filename MiniAODv2_${CAMPAIGN}_cfg.py \
    --eventcontent MINIAODSIM \
    --customise Configuration/DataProcessing/Utils.addMonitoring \
    --datatier MINIAODSIM \
    --fileout file:MiniAODv2_${CAMPAIGN}.root \
    --conditions 106X_mcRun2_asymptotic_preVFP_v11 \
    --step PAT \
    --procModifiers run2_miniAOD_UL \
    --geometry DB:Extended \
    --filein file:RECO_${CAMPAIGN}.root \
    --era Run2_2016_HIPM \
    --runUnscheduled \
    --no_exec \
    --mc \
    -n $EVENTS

if [[ "$NORUN" != "true" ]]; then cmsRun MiniAODv2_${CAMPAIGN}_cfg.py; fi
rm RECO_${CAMPAIGN}.root
# == MiniAODv2 ===================================

# == NanoAODv9 ===================================
# Prepid: SMP-RunIISummer20UL16NanoAODAPVv9-00034
setup_cmssw CMSSW_10_6_26 slc7_amd64_gcc700

git cms-init --upstream-only
git cms-addpkg PhysicsTools/NanoAOD

cat > CMSSW_10_6_26_PhysicsTools_NanoAOD_plugins.patch << EOL
844c844,845
<             if (groupname == "mg_reweighting") {
---
>             //if (groupname == "mg_reweighting") {
>             if (groupname.find("mg_reweighting") != std::string::npos) {
EOL
patch PhysicsTools/NanoAOD/plugins/GenWeightsTableProducer.cc < CMSSW_10_6_26_PhysicsTools_NanoAOD_plugins.patch

scram b -j8
cd ../..

cmsDriver.py \
    --python_filename NanoAODv9_${CAMPAIGN}_cfg.py \
    --eventcontent NANOAODSIM \
    --customise Configuration/DataProcessing/Utils.addMonitoring \
    --datatier NANOAODSIM \
    --fileout file:NanoAODv9_${CAMPAIGN}.root \
    --conditions 106X_mcRun2_asymptotic_preVFP_v11 \
    --step NANO \
    --filein file:MiniAODv2_${CAMPAIGN}.root \
    --era Run2_2016_HIPM,run2_nanoAOD_106Xv2 \
    --no_exec \
    --mc \
    -n $EVENTS

if [[ "$NORUN" != "true" ]]; then cmsRun NanoAODv9_${CAMPAIGN}_cfg.py; fi
# == NanoAODv9 ===================================
