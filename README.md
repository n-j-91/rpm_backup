# rpm_backup

# Author Nayanajith Chandradasa
# Date: 2017-10-29

This script will archive any rpms which are older than a specified time period to a backup location.

You can also define a value for minimum number of rpms to be retained at the original repository.

Retention time is defined in second; 

e.g.: If you want to keep rpms only if they are younger than 2 months; $EPOCHRETENTION=60*60*24*30*2=5184000;
e.g.: If you want to keep at least 5 rpms in the original repository regardless of the age; $MINRETAINED=5

Additionally you can define the backup location and repository root using $RPMLOCATION and $RPMBACKUPLOCATION parameters.

