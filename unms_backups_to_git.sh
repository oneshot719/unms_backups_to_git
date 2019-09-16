#!/bin/bash

###############
# variables
###############
export host=`echo \`hostname\``
export unms_backups="/home/unms/data/unms-backups/backups"
export config_backups="/home/unms/data/config-backups"
export repodir="/scripts/reponamehere"
export date=`date +"%m-%d-%Y_%H:%M:%S"`
export repo_url="git@github.com:whatever.git"
export ssh_key="/root/.ssh/git"
#exec ssh-agent bash
#ssh-add $ssh_key


echo "Starting to backup UNMS backups and all device backups to Git..."
echo ""

####################
# PURGE EXISTING
####################

rm -rf $repodir

echo "$repodir has been cleaned, pulling latest from git..."
echo ""


##########################
# PULL EXISTING FROM GIT
##########################

echo ""
echo "#--------------------------------#"
echo "Date: $date"
echo "Pulling latest configs from git..."
GIT_SSH_COMMAND="ssh -i $ssh_key" git clone $repo_url $repodir
echo ""

mkdir -p $repodir/BACKUPS/config-backups/
mkdir -p $repodir/BACKUPS/unms-backups/backups/

##########################
# Grabbing unms-backups
##########################

echo ""
echo "Grabbing UNMS backups from: $unms_backups"
yes | cp -r $unms_backups/* $repodir/BACKUPS/unms-backups/backups/
echo ""

##############
# Breaking out and extracting the backups so we get visibility into changes
##############


cd $repodir/BACKUPS/unms-backups/backups/
for file in $(ls | grep -v _extracted)
do
    echo ""
    echo "Extracting configs from: $file"
    export file_extracted=`echo $file"_extracted"`
    echo "Creating directory for extracted contents: $file_extracted"
    rm -rf $file_extracted
    mkdir $file_extracted
    tar -xzvf $file -C $file_extracted
    echo "Done with $file"
    echo ""
done

##########################
# Grabbing config-backups
##########################

# removing extracted dirs for cleaner workload

rm -rf $repodir/BACKUPS/config-backups/*/*_extracted

echo ""
echo "Grabbing UNMS backups from: $config_backups"
yes | cp -r $config_backups/* $repodir/BACKUPS/config-backups/
echo ""

##############
# Breaking out and extracting the backups so we get visibility into changes
##############
cd $repodir/BACKUPS/config-backups/
rm -rf multi
for folder in $(ls | grep -v _extracted)
do
    echo ""
    echo "Nesting deeper into configs from: $folder"
    cd $folder
         for file in $(ls | grep -v _extracted)
         do
                echo ""
                echo "Working directory is"
                pwd
                echo "Looking at $file inside: $folder"
                export file_extracted=`echo $file"_extracted"`
                echo "Creating directory for extracted contents: $file_extracted"
                # rm -rf $file_extracted
                mkdir $file_extracted
                tar -xzvf $file -C $file_extracted
                echo "Done with: $repodir/BACKUPS/config-backups/$folder/$file"
                echo ""
        done
    cd $repodir/BACKUPS/config-backups/
    echo "Done with $folder"
    echo ""
done



##################
# Pushing to GIT
##################

echo ""
echo "Pushing configs to GIT..."
cd $repodir
git -C $repodir/ add -A
git -C $repodir/ commit -m "Pushing latest changes to git..."
# git -C $repodir/ push origin master
GIT_SSH_COMMAND="ssh -i $ssh_key" git push origin master
echo "Done"
exit