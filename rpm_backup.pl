#!/usr/bin/perl -w

#Author Nayanajith Chandradasa
#Date: 2017-10-29
#This script will archive any rpms which are older than a specified time period to a backup location.
#You can also define a value for minimum number of rpms to be retained at the original repository.
#Retention time is defined in second; 
#e.g.: If you want to keep rpms only if they are younger than 2 months; $EPOCHRETENTION=60*60*24*30*2=5184000;
#e.g.: If you want to keep at least 5 rpms in the original repository regardless of the age; $MINRETAINED=5
#Additionally you can define the backup location and repository root using $RPMLOCATION and $RPMBACKUPLOCATION parameters.


use strict;
use warnings;

our $RPMLOCATION="/srv/yum";
our $RPMBACKUPLOCATION="/mnt/ephemeral";
our $TODAY=`date +\%Y-\%m-\%d | xargs echo -n`;
our $MINRETAINED=5;
our $EPOCHRETENTION=5184000;
our $EPOCHTODAY=`date --date="$TODAY" +\%s`;

print("Today:$TODAY\n");


sub recreate_repo{

	my $REPO=$RPMLOCATION."/".$_[0];
	if ( -e "$REPO/repodata" ){

		if ( -e "$REPO/repodata.bk" ){
            #Un-comment below two line if you want to recreate the repository everytime a backup takes place.
			#system("sudo","-u","yum","rm","-rf","$REPO/repodata.bk");
		}
		#system("sudo","-u","yum","mv","$REPO/repodata","$REPO/repodata.bk")
	}
	
	system("sudo","-u","yum","/usr/bin/createrepo","--update","$REPO");

}

sub run_archive{

	my $RECREATE=0;
	my $REPOBACKUP=$RPMBACKUPLOCATION."/yum.moved.".$TODAY."/".$_[0];
	system("mkdir","-p","$REPOBACKUP");
	my $REPO=$RPMLOCATION."/".$_[0];
    	
	system("sudo","-u","yum","mkdir","-p","$REPO/.repodata");
	
	my @RPMSARR=glob("$REPO/*.rpm");
	my %RPMSHASH=();
	foreach (@RPMSARR){

		no warnings 'uninitialized';
		my @temp=split("/",$_);
		my $temprpmpkg=$temp[scalar(@temp)-1];
		#print("File Name: ".$temp[scalar(@temp)-1]."\n");
                if (my ($match) = $temprpmpkg =~ m/(^([a-z]{1,}-)([a-z]{0,}-)*)/){
				
			$RPMSHASH{"$match"}+=1;
		}

	}

	foreach my $j (@RPMSARR){
			
		#print("$j:$RPMSHASH{$j}\n");
		#print("$j\n");
		no warnings 'uninitialized';
                my @temp=split("/",$j);
                my $temprpmpkg=$temp[scalar(@temp)-1];
		my ($match) = $temprpmpkg =~ m/(^([a-z]{1,}-)([a-z]{0,}-)*)/;

		my ($LASTMOD)=`stat -c \%y $j | awk '{print \$1}'`;
		my ($EPOCHLASTMOD)=`date --date="$LASTMOD" +\%s`;
		#print("$EPOCHLASTMOD\n");
		if( $MINRETAINED < $RPMSHASH{"$match"} && ($EPOCHTODAY - $EPOCHLASTMOD) > $EPOCHRETENTION ){

			print("Moving $j to $REPOBACKUP\n");
			system("mv","$j","$REPOBACKUP/");
			$RPMSHASH{"$match"}-=1;
			$RECREATE=1;
		}		
	}

	#sleep(5);
	if ( $RECREATE == 1 ){
		print("Recreating $REPO\n");
		recreate_repo("$_[0]");
	}
	else{
		print("Nothing was archived. No need to recreate $REPO\n");
	}

	if ( -e "$REPO/.repodata" ) {
		system("sudo","-u","yum","rm","-rf","$REPO/.repodata");
	}
}

#If Repo name is test-1
run_archive("test-1"");

exit 0;