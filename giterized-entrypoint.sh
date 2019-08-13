#!/usr/bin/env sh

# This allows to set the VERBOSE environment variable to be able to peek
# at the entrypoint execution for easy debugging
${VERBOSE} && set -x

###############################################################################
# get_value (variable)
#
# Get the value of a variable passed, preserving any spaces
###############################################################################
get_value ()
{
    # the following will preserve spaces in the printf
    IFS="%%"
    eval printf '%s' "\${${1}}"
    unset IFS
}

########################################################################################
# performs a git clone on the server profile passed
########################################################################################
applyLayer ()
{
    gitUrl=$( get_value "${1}_URL" )
    gitBranch=$( get_value "${1}_BRANCH" )
    gitPath=$( get_value "${1}_PATH" )

    # this is a precaution because git clone needs an empty target
    rm -rf "${gitTempDir}"
    if test -n "${gitUrl}" ; then
        # deploy configuration if provided
        echo "Getting ${1}"
        echo "  git url: ${gitUrl}"
        test -n "${gitBranch}" && echo "  branch: ${gitBranch}"
        test -n "${gitPath}" && echo "  path: ${gitPath}"
  
        git clone --depth 1 ${gitBranch:+--branch} ${gitBranch} "${gitUrl}" "${gitTempDir}"
        die_on_error 141 "Git clone failure"  || exit ${?}
        
        # shellcheck disable=SC2086
        cp -af ${gitTempDir}/* "${gitStagingDir}"
        die_on_error 142 "Copy to staging failure"  || exit ${?}
    fi    
}

########################################################################################
# takes the current server profile name and appends _PARENT to the end
#   Example: SERVER_PROFILE          returns SERVER_PROFILE_PARENT
#            SERVER_PROFILE_LICENSE  returns SERVER_PROFILE_LICENSE_PARENT
########################################################################################
getParent ()
{
    echo ${1}${2:+_}${2}"_PARENT"
}

applyLayers ()
{

    # Below is the current layer, which by default is empty but is used to walk up the heap of git repos to layer over each other
    gitLayer=""

    # Below is the variable that stores a list of all the git layers
    gitLayerList=""

    # below is the variable for storing the parent of the current layer
    gitParent=$( getParent ${gitPrefix} ${gitLayer} )

    # creates a spaced separated list of server profiles starting with the parent most
    # profile and moving down.
    while test -n "$( get_value ${gitParent} )" ; do
        # get the parent layer
        gitLayer=$( get_value ${gitParent} )
        # prepend the layer to the list
        gitLayerList="${gitLayer}${gitLayerList:+ }${gitLayerList}"
        # update the current parent
        gitParent=$( getParent ${gitPrefix} ${gitLayer} )
    done

    # now, take that spaced separated list of servers and get the profiles for each
    # one until exhausted.  
    for gitLayer in ${gitLayerList} ; do
        applyLayer "${gitPrefix}_${gitLayer}"
    done

    #Finally after all are processed, get the final top level SERVER_PROFILE
    applyLayer "${gitPrefix}"
}

expandFiles()
{
    # shellcheck disable=SC2044
    for template in $( find "${gitStagingDir}" -type f -iname \*.subst ) ; do
        ${VERBOSE} && echo "  - ${template}"
        envsubst < "${template}" > "${template%.subst}"
    done
}

deployLayers()
{
    echo "merging Git content to container"
    cp -af "${gitStagingDir}"/* /
}

# Below is the prefix for the environment variable for all things GIT
gitPrefix="GIT"

if test -n "$( getValue ${gitPrefix}_URL )" ; then
    baseDir=/tmp/git
    gitTempDir=${baseDir}/tmp
    gitStagingDir=${baseDir}/staging
    mkdir -p "${gitStagingDir}"
    applyLayers
    expandFiles
    deployLayers
fi

exec "${ORIGINAL_ENTRYPOINT}" "$@"