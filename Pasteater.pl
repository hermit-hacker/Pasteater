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
use Data::Dumper;
#use DateTime;

# Load modules and search targets
my @PASTEMODS = Pasteater::Core::loadModules();
my @SEARCHTERMS = Pasteater::Core::loadSearchTargets();
my %SETTINGS = Pasteater::Core::loadPESettings();

# Set initial time
#my $LASTTIME = DateTime->now();

my $NUMUAS = Pasteater::Core::getNumberUAS();

foreach my $PMOD (<@PASTEMODS>) {
  print "\nProcessing site: $PMOD\n-------------------------\n";
  my $LISTCALL = "Pasteater::SiteModules::" . $PMOD . "::list";
  my $LISTSUB = \&$LISTCALL;
  my $DOWNCALL = "Pasteater::SiteModules::" . $PMOD . "::download";
  my $DOWNSUB = \&$DOWNCALL;
  my $RNDUAS = Pasteater::Core::getRandomUAString($NUMUAS);
  my @PASTES = &$LISTSUB('', '', $RNDUAS);
  foreach my $PASTE (<@PASTES>) {
    print ".";
    my $LOOPKILL = "False";
    my @DOWNFILE = &$DOWNSUB($PASTE, $RNDUAS);
    foreach my $SEARCHITEM (<@SEARCHTERMS>) {
      if ( grep (/$SEARCHITEM/, @DOWNFILE) && $LOOPKILL == "False" ) {
        Pasteater::Core::writeFile($PMOD, $PASTE, @DOWNFILE);
        $LOOPKILL = "True";
      }
    }
    #exit 1;
  }
}

exit 0;