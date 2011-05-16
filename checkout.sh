#!/bin/sh

usage()
{
cat << EOF
usage: $0 options

This script will check out Seam 3.

OPTIONS:
   -a      When performing a fetch use --all to retrieve all remotes
   -b      Build and install parent, tools and bom modules
   -h      Show this usage message
   -d      Destination directory, otherwise the PWD is used 
   -m      Checkout (clone) in manager mode (SSH mode) (default is read-only)
   -v      Be more verbose
   -c      Don't run git fetch if the repository has already been cloned
   -p      Perform a git pull origin for each of the modules
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
   update=0
   unset gitcmd
   url="$GITBASE/$repo.git"
   repodir=$DESTINATION/$repo
   if [ -d $repodir ]
   then
      if [ "$GITFETCH" -eq "1" ]; then
         echo "Updating $repo"

         if [ "$FETCHALL" -eq "1" ]; then
           gitcmd="git $GITARGS --git-dir=$DESTINATION/$repo/.git fetch --all" 
         else 
           gitcmd="git $GITARGS --git-dir=$DESTINATION/$repo/.git fetch"
         fi

         update=1
         $gitcmd
      else
         echo "Skipping existing cloned repository $DESTINATION/$repo"
         update=1
      fi
   fi

   if [ "$PULL" -eq "1" ]; then
      cd $DESTINATION/$repo
      status=$(git status --porcelain)
      if [ -z "$status" ]; then
        echo "Pulling $repo"
        gitcmd="git $GITARGS pull"
        $gitcmd
        update=1
      else
        echo "Local changes, no pull occurred"
      fi
   fi

   if [ "$update" -eq "0" ]; then
      echo "Cloning $repo"
      gitcmd="git clone $GITARGS $url $DESTINATION/$repo"
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
FETCHALL=0
BUILD=0
PULL=0
RUN=1

REPOS="parent build dist examples catch config drools faces international jcr jms mail persistence remoting rest security servlet social solder validation ticket-monster wicket"

while getopts “aphmd:bcv” OPTION
do
     case $OPTION in
         a)
             FETCHALL=1
             ;;
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
         p)
             PULL=1
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
