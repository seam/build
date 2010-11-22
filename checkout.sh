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
   -c      Don't run git fetch if the repository has already been cloned
   -b      Build and install parent, tools and bom modules
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
   echo "Using existing destination directory $DESTINATION"
else
   echo "Creating destination directory $DESTINATION"
   mkdir $DESTINATION
fi

for repo in $REPOS
do
   unset gitcmd
   url="$GITBASE/$repo.git"
   repodir=$DESTINATION/$repo
   if [ -d $repodir ]
   then
      if [ "$GITFETCH" -eq "1" ]; then
         echo "Updating $repo"
         gitcmd="git $GITARGS --git-dir=$DESTINATION/$repo/.git fetch"
      else
         echo "Skipping existing cloned repository $DESTINATION/$repo"
      fi
   else
      echo "Cloning $repo"
      gitcmd="git clone $GITARGS $url $DESTINATION/$repo"
   fi
   if [ -n "$gitcmd" ]
   then
      $gitcmd
   fi
done

if [ "$BUILD" -eq "1" ]
then
   echo "Building Seam parent, tools and bom modules"
   cd build/parent
   mvn clean install
   cd -
   cd build/tools
   mvn clean install
   cd -
   cd dist
   mvn clean install -N
   cd -
fi
}

DESTINATION=`pwd`
READONLY=1
VERBOSE=0
GITBASE=
GITARGS=
GITFETCH=1
BUILD=0
RUN=1

# NOTE still waiting on mail to be migrated
REPOS="parent build dist examples catch documents drools faces international jbpm jms persistence js-remoting rest security servlet wicket xml-config clouds ticket-monster solder"

while getopts “hmd:bcv” OPTION
do
     case $OPTION in
         h)
             usage
             RUN=0
             ;;
         d)
             DESTINATION=$OPTARG
             ;;
         c)
             GITFETCH=0
             ;;
         m)
             READONLY=0
             ;;
         b)
             BUILD=1
             ;;
         v)
             VERBOSE=1
             ;;
         [?])
             usage;
             RUN=0
             ;;
     esac
done

if [ "$RUN" -eq "1" ]
then
   work;
fi
