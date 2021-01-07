#!/bin/bash

echo -e "\n\n\n\nWorking on branch: ${BRANCH_NAME}\n\n\n\n"

# set -x

# Eclipse update site repository publisher
# This script rebuilds
#   atrifacts.jar
#   content.jar
# of our eclipse update site. With these two files, checking the content of the
# update site is much quicker than with just using site.xml file. This especially
# applies to http-based access of the update site. An access via nfs is much quicker
# anyways.

rootdir=$(dirname $0)
if [[ "${rootdir}" = "." ]] ; then
  rootdir=$PWD
fi

if [[ "${rootdir}" = "." ]] ; then
  rootdir=`pwd`
fi

echo -e "rootdir: ${rootdir}"

# The actual path to the update site
src="${rootdir}/"

# Put only the really required plugins onto the published update site. But skip
# old ones.
trg="${rootdir}/published_update_site"

echo -e "Update site src=${src}"
echo -e "Published site=${trg}"

ls -al ${src}

rm -rf ${trg}/plugins
rm -rf ${trg}/features
rm -rf ${trg}/binaries
rm -rf ${trg}/*.xml
rm -rf ${trg}/*.jar
rm -rf ${trg}/

rm -rf ${rootdir}/.eclipse
rm -rf ${rootdir}/p2
rm -rf ${rootdir}/artifacts.xml

mkdir ${trg}

cp ${src}/site.xml ${trg}
mkdir ${trg}/features
mkdir ${trg}/plugins
mkdir ${trg}/binary


# This script is determining the required plugins.
echo -e "Copy features..."
cp -r ${src}/features ${trg}/

echo -e "Copy plugins..."
cp -r ${src}/plugins ${trg}/

echo -e "Copy binaries..."
cp -r ${src}/binary ${trg}/


eclipse="/opt/hp93000rt/el7/x86_64/ewc_415/eclipse-SDK-4.15-linux-gtk-x86_64/eclipse/eclipse"

if [[ ! -x "${eclipse}" ]] ; then
  echo -e "Missing file: ${eclipse}"
  exit 2
fi

# Now rebuild the update site.
echo -e "Rebuilding update site"
${eclipse} -noSplash --launcher.suppressErrors -consoleLog \
   -application org.eclipse.equinox.p2.publisher.UpdateSitePublisher \
   -configuration file:${rootdir}/.eclipse \
   -metadataRepository file:${trg} \
   -metadataRepositoryName Andrey_Loskutov_plugins \
   -artifactRepository file:${trg} \
   -artifactRepositoryName Andrey_Loskutov_plugins \
   -source ${trg} \
   -configs gtk.linux.x86_64 \
   -append false ## -debug ## -publishArtifacts

#   -compress \
   
if [[ $? -eq 0 ]]
then
  echo "Successfully generated metadata"
  echo -e "Files in working directory ${trg}:"
  ls -al ${trg}/*
  rm -rf ${trg}/features
  rm -rf ${trg}/plugins
  rm -rf ${trg}/binary
  
  rm -rf ${src}/p2
  rm -rf ${src}/.eclipse
  
  rm -rf ${src}/content.*
  rm -rf ${src}/artifacts.*
  cp  ${trg}/artifacts.* ${src}
  cp  ${trg}/content.* ${src}
else
  echo "Could not create metadata"
fi


