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
   -du     Dont run SVN update if the module already exists
EOF
}

work()
{

if [ "$READONLY" -eq "1" ]
then
   SVNBASE="http://anonsvn.jboss.org/repos/seam"
else
   SVNBASE="https://svn.jboss.org/repos/seam"
fi

if [ "$VERBOSE" -eq "0" ]
then
   SVNARGS="--quiet"
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
   url="$SVNBASE/modules/$module/trunk"
   moduledir=$DESTINATION/$module
   if [ -d $moduledir ]
   then
      echo "Updating $module"
      svncmd="svn up $SVNARGS $DESTINATION/$module"
   else
      echo "Checking out $module"
      svncmd="svn co $SVNARGS $url $DESTINATION/$module"
   fi
   $svncmd
done

url="$SVNBASE/dist/trunk"
moduledir=$DESTINATION/dist
if [ -d $moduledir ]
then
   echo "Updating dist"
   svncmd="svn up $SVNARGS $DESTINATION/dist"
else
   echo "Checking out dist"
   svncmd="svn co $SVNARGS $url $DESTINATION/dist"
fi
$svncmd

url="$SVNBASE/examples/trunk"
moduledir=$DESTINATION/examples
if [ -d $moduledir ]
then
   echo "Updating examples"
   svncmd="svn up $SVNARGS $DESTINATION/examples"
else
   echo "Checking out examples"
   svncmd="svn co $SVNARGS $url $DESTINATION/examples"
fi
$svncmd


url="$SVNBASE/build/trunk"
moduledir=$DESTINATION/build
if [ -d $moduledir ]
then
   echo "Updating build"
   svncmd="svn up $SVNARGS $DESTINATION/build"
else
   echo "Checking out build"
   svncmd="svn co $SVNARGS $url $DESTINATION/build"
fi
$svncmd
}

DESTINATION=`pwd`
READONLY=0
VERBOSE=0
SVNBASE=
SVNARGS=
SVNUPDATE=1

MODULES="documents drools faces international jbpm jms persistence remoting resteasy security servlet wicket xml"

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
