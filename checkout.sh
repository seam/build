#!/bin/sh

usage()
{
cat << EOF
usage: $0 options

This script will check out Seam.

OPTIONS:
   -h      Show this message
   -d      Destination directory, otherwise the PWD is used 
   -r      Checkout in readonly mode from anonsvn
   -v      Be more verbose
   -du     Dont run git fetch if the module already exists
EOF
}

work()
{

if [ "$READONLY" -eq "1" ]
then
   GITBASE="git://github.com/seam"
else
   GITBASE="git@github.com:seam"
fi

if [ "$VERBOSE" -eq "0" ]
then
   GITARGS=""
fi
  
if  [ -d $DESTINATION ]
then
   echo "Checking out to $DESTINATION"
else
   echo "Creating directory $DESTINATION to checkout to"
   mkdir $DESTINATION
fi

for module in $MODULES
do
   url="$GITBASE/$module.git"
   moduledir=$DESTINATION/$module
   if [ -d $moduledir ]
   then
      echo "Updating $module"
      svncmd="git $GITARGS --git-dir=$DESTINATION/$module/.git fetch"
   else
      echo "Checking out $module"
      svncmd="git clone $GITARGS $url $DESTINATION/$module"
   fi
   $svncmd
done

url="$GITBASE/dist.git"
moduledir=$DESTINATION/dist
if [ -d $moduledir ]
then
   echo "Updating dist"
   svncmd="git $GITARGS --git-dir=$DESTINATION/dist/.git fetch"
else
   echo "Checking out dist"
   svncmd="git clone $GITARGS $url $DESTINATION/dist"
fi
$svncmd

url="$GITBASE/examples.git"
moduledir=$DESTINATION/examples
if [ -d $moduledir ]
then
   echo "Updating examples"
   svncmd="git $GITARGS --git-dir=$DESTINATION/examples/.git fetch"
else
   echo "Checking out examples"
   svncmd="git clone $GITARGS $url $DESTINATION/examples"
fi
$svncmd


url="$GITBASE/build.git"
moduledir=$DESTINATION/build
if [ -d $moduledir ]
then
   echo "Updating build"
   svncmd="git $GITARGS --git-dir=$DESTINATION/build/.git fetch"
else
   echo "Checking out build"
   svncmd="git clone $GITARGS $url $DESTINATION/build"
fi
$svncmd
}

DESTINATION=`pwd`
READONLY=0
VERBOSE=0
GITBASE=
GITARGS=
SVNUPDATE=1

MODULES="catch documents drools faces international jbpm jms mail persistence js-remoting resteasy security servlet wicket xml-config"

while getopts “hrd:v” OPTION
do
     case $OPTION in
         h)
             usage
             ;;
         d)
             DESTINATION=$OPTARG
             work;
             ;;
         du)
             SVNUPDATE=0
             work;
             ;;
         r)
             READONLY=1
             work;
             ;;
         v)
             VERBOSE=1
             work;
             ;;
         [?])
             usage;
             ;;
     esac
done

if [ "$#" -eq "0" ]
then
   work;
fi
