#!/bin/perl
# Program Name: Pasteater
# Created: 2013-07-01
# Author: Brian "Hermit" Mork
# Version: 0.1 (2013-07-01)
# Package: Pasteater

use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/include";
use Pasteater::Core;
use Getopt::Long;
use Data::Dumper;
#use DateTime;

# Load modules and search targets
my @ARGLIST = @ARGV;
my @PASTEMODS = Pasteater::Core::loadModules();
my @SEARCHTERMS = Pasteater::Core::loadSearchTargets();
my %SETTINGS = Pasteater::Core::loadPESettings();

# Bring in the arguments
my ($SRCHTMP, @RUNSITES, $RUNSTOP, $VERBOSE);
GetOptions ('search|s=s' => \$SRCHTMP, 'runmods|rm=s' => \@RUNSITES, 'limit|l=i' => \$RUNSTOP, 'verbose|v' => \$VERBOSE );
@RUNSITES = split (/,/,join(',', @RUNSITES));
if (!defined($RUNSTOP)) {
  $RUNSTOP = "-1";
};
if ( scalar(@RUNSITES) == 0 ) {
	push( @RUNSITES, "ALL" );
}


# Set initial time
#my $LASTTIME = DateTime->now();

my $NUMUAS = Pasteater::Core::getNumberUAS();

foreach my $PMOD (<@PASTEMODS>) {
  my $LOOPCOUNTER = 0;
  if ( grep (/$PMOD/, @RUNSITES) || $RUNSITES[0] eq "ALL" ) {
    if ($VERBOSE) { print "\nProcessing site: $PMOD\n-------------------------\n"; }
    my $LISTCALL = "Pasteater::SiteModules::" . $PMOD . "::list";
    my $LISTSUB = \&$LISTCALL;
    my $DOWNCALL = "Pasteater::SiteModules::" . $PMOD . "::download";
    my $DOWNSUB = \&$DOWNCALL;
    my $RNDUAS = Pasteater::Core::getRandomUAString($NUMUAS);
    my @PASTES = &$LISTSUB('', '', $RNDUAS);
    foreach my $PASTE (<@PASTES>) {
      my $LOOPKILL = "False";
      my @DOWNFILE = &$DOWNSUB($PASTE, $RNDUAS);
      if ( ( $LOOPCOUNTER < $RUNSTOP ) || ( $RUNSTOP == "-1" ) ) {
        if ($VERBOSE) { print " - Processing $PASTE\n"; }
        foreach my $SEARCHITEM (<@SEARCHTERMS>) {
          if ( (grep (/$SEARCHITEM/, @DOWNFILE) ) && ( $LOOPKILL eq "False" ) ) {
            Pasteater::Core::writeFile($PMOD, $PASTE, @DOWNFILE);
            $LOOPKILL = "True";
          } # End processing of single search term 
        } # End loop for search terms 
      } # End loop limiting 
      $LOOPCOUNTER++;
    } # End loop of PASTES
  } # End conditional test for RUNSITES
} # End loop from PASTEMODS

exit 0;
