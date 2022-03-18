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
