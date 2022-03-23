#!/bin/bash
SCRIPT_DIR=$(dirname ${BASH_SOURCE[0]})
source $SCRIPT_DIR/../utils.sh

CAMPAIGN=RunIISummer20UL18
FRAGMENT=$1
GRIDPACK=$2
EVENTS=$3
SEED=$4
NORUN=$5

# == GEN,LHE =====================================
# Prepid: SMP-RunIISummer20UL18wmLHEGEN-00002
setup_cmssw CMSSW_10_6_17_patch1 slc7_amd64_gcc700 --no_scramb
FRAGMENT_CMSSW=$(inject_fragment $FRAGMENT $GRIDPACK $EVENTS)
scram b -j8
cd ../..

cmsDriver.py $FRAGMENT_CMSSW \
    --python_filename LHEGS_${CAMPAIGN}_cfg.py \
    --eventcontent RAWSIM,LHE \
    --customise Configuration/DataProcessing/Utils.addMonitoring \
    --datatier GEN,LHE \
    --fileout file:LHEGS_${CAMPAIGN}.root \
    --conditions 106X_upgrade2018_realistic_v4 \
    --beamspot Realistic25ns13TeVEarly2018Collision \
    --customise_commands process.source.numberEventsInLuminosityBlock="cms.untracked.uint32(100)" \
    --step LHE,GEN \
    --geometry DB:Extended \
    --era Run2_2018 \
    --no_exec \
    --mc \
    -n $EVENTS

cat >> LHEGS_${CAMPAIGN}_cfg.py << EOL
process.RandomNumberGeneratorService.externalLHEProducer.initialSeed = $SEED
process.source.firstLuminosityBlock = cms.untracked.uint32($SEED)
EOL

if [[ "$NORUN" != "true" ]]; then cmsRun LHEGS_${CAMPAIGN}_cfg.py; fi
# == GEN,LHE =====================================

# == SIM =========================================
# Prepid: SMP-RunIISummer20UL18SIM-00002
setup_cmssw CMSSW_10_6_17_patch1 slc7_amd64_gcc700
cmsDriver.py \
    --python_filename SIM_${CAMPAIGN}_cfg.py \
    --eventcontent RAWSIM \
    --customise Configuration/DataProcessing/Utils.addMonitoring \
    --datatier GEN-SIM \
    --fileout file:SIM_${CAMPAIGN}.root \
    --conditions 106X_upgrade2018_realistic_v11_L1v1 \
    --beamspot Realistic25ns13TeVEarly2018Collision \
    --step SIM \
    --geometry DB:Extended \
    --filein file:LHEGS_${CAMPAIGN}.root \
    --era Run2_2018 \
    --runUnscheduled \
    --no_exec \
    --mc \
    -n $EVENTS

if [[ "$NORUN" != "true" ]]; then cmsRun SIM_${CAMPAIGN}_cfg.py; fi
rm LHEGS_${CAMPAIGN}.root
# == SIM =========================================

# == DIGIPREMIX ==================================
# Prepid: SMP-RunIISummer20UL18DIGIPremix-00002 
# Pileup: /Neutrino_E-10_gun/RunIISummer20ULPrePremix-UL18_106X_upgrade2018_realistic_v11_L1v1-v2/PREMIX
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
    --conditions 106X_upgrade2018_realistic_v11_L1v1 \
    --step DIGI,DATAMIX,L1,DIGI2RAW \
    --procModifiers premix_stage2 \
    --geometry DB:Extended \
    --filein file:SIM_${CAMPAIGN}.root \
    --datamix PreMix \
    --era Run2_2018 \
    --runUnscheduled \
    --no_exec \
    --mc \
    -n $EVENTS

if [[ "$NORUN" != "true" ]]; then cmsRun DIGIPremix_${CAMPAIGN}_cfg.py; fi
rm SIM_${CAMPAIGN}.root
# == DIGIPREMIX ==================================

# == HLT =========================================
# Prepid: SMP-RunIISummer20UL18HLT-00002
setup_cmssw CMSSW_10_2_16_UL slc7_amd64_gcc700
cmsDriver.py \
    --python_filename HLT_${CAMPAIGN}_cfg.py \
    --eventcontent RAWSIM \
    --customise Configuration/DataProcessing/Utils.addMonitoring \
    --datatier GEN-SIM-RAW \
    --fileout file:HLT_${CAMPAIGN}.root \
    --conditions 102X_upgrade2018_realistic_v15 \
    --customise_commands 'process.source.bypassVersionCheck = cms.untracked.bool(True)' \
    --step HLT:2018v32 \
    --geometry DB:Extended \
    --filein file:DIGIPremix_${CAMPAIGN}.root \
    --era Run2_2018 \
    --no_exec \
    --mc \
    -n $EVENTS

if [[ "$NORUN" != "true" ]]; then cmsRun HLT_${CAMPAIGN}_cfg.py; fi
rm DIGIPremix_${CAMPAIGN}.root
# == HLT =========================================

# == RECO ========================================
# Prepid: SMP-RunIISummer20UL18RECO-00002
setup_cmssw CMSSW_10_6_17_patch1 slc7_amd64_gcc700
cmsDriver.py \
    --python_filename RECO_${CAMPAIGN}_cfg.py \
    --eventcontent AODSIM \
    --customise Configuration/DataProcessing/Utils.addMonitoring \
    --datatier AODSIM \
    --fileout file:RECO_${CAMPAIGN}.root \
    --conditions 106X_upgrade2018_realistic_v11_L1v1 \
    --step RAW2DIGI,L1Reco,RECO,RECOSIM,EI \
    --geometry DB:Extended \
    --filein file:HLT_${CAMPAIGN}.root \
    --era Run2_2018 \
    --runUnscheduled \
    --no_exec \
    --mc \
    -n $EVENTS

if [[ "$NORUN" != "true" ]]; then cmsRun RECO_${CAMPAIGN}_cfg.py; fi
rm HLT_${CAMPAIGN}.root
# == RECO ========================================

# == MiniAODv2 ===================================
# Prepid: SMP-RunIISummer20UL18MiniAODv2-00047
setup_cmssw CMSSW_10_6_20 slc7_amd64_gcc700
cmsDriver.py \
    --python_filename MiniAODv2_${CAMPAIGN}_cfg.py \
    --eventcontent MINIAODSIM \
    --customise Configuration/DataProcessing/Utils.addMonitoring \
    --datatier MINIAODSIM \
    --fileout file:MiniAODv2_${CAMPAIGN}.root \
    --conditions 106X_upgrade2018_realistic_v16_L1v1 \
    --step PAT \
    --procModifiers run2_miniAOD_UL \
    --geometry DB:Extended \
    --filein file:RECO_${CAMPAIGN}.root \
    --era Run2_2018 \
    --runUnscheduled \
    --no_exec \
    --mc \
    -n $EVENTS

if [[ "$NORUN" != "true" ]]; then cmsRun MiniAODv2_${CAMPAIGN}_cfg.py; fi
rm RECO_${CAMPAIGN}.root
# == MiniAODv2 ===================================


# == NanoAODv9 ===================================
# Prepid: SMP-RunIISummer20UL18NanoAODv9-00047
setup_cmssw CMSSW_10_6_26 slc7_amd64_gcc700
cmsDriver.py \
    --python_filename NanoAODv9_${CAMPAIGN}_cfg.py \
    --eventcontent NANOEDMAODSIM \
    --customise Configuration/DataProcessing/Utils.addMonitoring \
    --datatier NANOAODSIM \
    --fileout file:NanoAODv9_${CAMPAIGN}.root \
    --conditions 106X_upgrade2018_realistic_v16_L1v1 \
    --step NANO \
    --filein file:MiniAODv2_${CAMPAIGN}.root \
    --era Run2_2018,run2_nanoAOD_106Xv2 \
    --no_exec \
    --mc \
    -n $EVENTS

if [[ "$NORUN" != "true" ]]; then cmsRun NanoAODv9_${CAMPAIGN}_cfg.py; fi
# == NanoAODv9 ===================================
