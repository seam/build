#!/bin/sh

usage()
{
cat << EOF
usage: $0 options

This script will check out Seam 3.

OPTIONS:
   -h      Show this usage message
   -d      Destination directory, otherwise the PWD is used 
   -m      Checkout (clone) in manager mode (SSH mode) (default is read-only)
   -v      Be more verbose
   -du     Dont run git fetch if the repository has already been cloned
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
   echo "Detected previously cloned repository at $DESTINATION"
else
   echo "Creating target clone directory $DESTINATION"
   mkdir $DESTINATION
fi

for repo in $REPOS
do
   url="$GITBASE/$repo.git"
   repodir=$DESTINATION/$repo
   if [ -d $repodir ]
   then
      echo "Updating $repo"
      svncmd="git $GITARGS --git-dir=$DESTINATION/$repo/.git fetch"
   else
      echo "Cloning $repo"
      svncmd="git clone $GITARGS $url $DESTINATION/$repo"
   fi
   $svncmd
done
}

DESTINATION=`pwd`
READONLY=1
VERBOSE=0
GITBASE=
GITARGS=
GITFETCH=1

# NOTE still waiting on mail to be migrated
REPOS="build dist examples catch documents drools faces international jbpm jms persistence js-remoting resteasy security servlet wicket xml-config"

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
             GITFETCH=0
             work;
             ;;
         m)
             READONLY=0
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
