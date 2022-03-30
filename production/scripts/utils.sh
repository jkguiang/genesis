function setup_cmssw {
    export SCRAM_ARCH=$2
    source /cvmfs/cms.cern.ch/cmsset_default.sh
    if [ -r $1/src ] ; then
      echo release $1 already exists
    else
      scram p CMSSW $1
    fi
    cd $1/src
    echo "moved to $PWD"
    eval `scram runtime -sh`

    if [[ "$3" == "--no_scramb" ]]; then
        return
    else
        scram b -j8
        cd ../..
        return
    fi
}

function inject_fragment {
    FRAGMENT=$1
    GRIDPACK=$2
    EVENTS=$3
    # Copy fragment to the appropriate area
    mkdir -p Configuration/GenProduction/python/
    FRAGMENT_CMSSW=Configuration/GenProduction/python/$(basename $FRAGMENT)
    cp $FRAGMENT $FRAGMENT_CMSSW
    # Insert gridpack path info fragment
    GRIDPACK_ESC=$(echo $GRIDPACK | sed 's_/_\\/_g') # escape slashes in gridpack path
    sed -i "s/GRIDPACK_SED_PLACEHOLDER/$GRIDPACK_ESC/g" $FRAGMENT_CMSSW
    sed -i "s/NEVENTS_SED_PLACEHOLDER/$EVENTS/g" $FRAGMENT_CMSSW
    echo "$FRAGMENT_CMSSW"
}

function set_lhegs_seed {
    LHEGS_PSET=$1
    SEED=$2
    echo "process.RandomNumberGeneratorService.externalLHEProducer.initialSeed = $SEED" >> $LHEGS_PSET
    echo "process.source.firstLuminosityBlock = cms.untracked.uint32($SEED)" >> $LHEGS_PSET
}
