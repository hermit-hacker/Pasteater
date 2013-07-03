#!/bin/perl
# Program Name: Core Module for Pasteater
# Created: 2013-07-01
# Author: Brian "Hermit" Mork
# Version: 0.1 (2013-07-01)
# Package: Pasteater::Core

package Pasteater::Core;

use strict;
use Module::Load;
use File::Path;

my $CONFDIR = "$FindBin::Bin/config";

sub loadModules() {
  my $MODDIR = "$FindBin::Bin/include/Pasteater/SiteModules";
  my @LOADEDMODS;
  opendir(DIR, $MODDIR);
  my @MODLIST = grep ( !/^\.\.?$/, readdir(DIR) );
  foreach my $MODFILE (@MODLIST) {
    my $MODLOC = "$FindBin::Bin/include/Pasteater/SiteModules/$MODFILE";
    my $MODNAME = readModule("$MODLOC");
    $MODNAME =~ s/[\r\n]//g;
    my $FULLMOD = "Pasteater::SiteModules::$MODNAME";
    eval { load $FULLMOD; };
    push @LOADEDMODS, $MODNAME;
  }
  closedir(DIR);
  return @LOADEDMODS;
}

sub readModule($) {
  open (my $MODTOREAD, $_[0]) or die "File $_[0] is not readable.\n";
  my @MODLINES = grep (/^\# Package\:\ /, <$MODTOREAD>);
  close ($MODTOREAD);
  return substr ( $MODLINES[0], 11 );
}

sub loadSearchTargets() {
  my @SRCHTRMS;
  open (my $CONFFILE, "$CONFDIR/search.conf" ) or die "The search.conf file is not readable.\n";
  foreach my $LINE (<$CONFFILE>) {
    push @SRCHTRMS, $LINE;
  }
  return @SRCHTRMS;
}

sub getRandomUAString($) {
  my $MAXVAL = $_[0];
  my $SEEDVAL = int( rand( $MAXVAL ) ) + 1;
  my $RUAS = getLine($SEEDVAL);
  return $RUAS;
}

sub loadPESettings() {
  my %PESETS = ();
  open (my $CONFFILE, "$CONFDIR/settings.conf" ) or die "The settings.conf file is not readable.\n";
  foreach my $LINE (<$CONFFILE>) {
    my $HKEY = (split ( /=/, $LINE ))[0];
    my $HVAL = (split ( /=/, $LINE ))[-1];
    $PESETS{ $HKEY } = "$HVAL";
  }
  return %PESETS;
}

sub writeFile($$@) {
  my ($PDIR, $PFILE, @FILECONTENT) = @_;
  my $TARGETDIR = "$FindBin::Bin/archives/" . $PDIR;
  checkDirectory($TARGETDIR);
  my $FILENAME = $TARGETDIR . "/" .$PFILE;
  open (TARGETFILE, ">$FILENAME");
  print TARGETFILE @FILECONTENT;
  close (TARGETFILE);
}

sub checkDirectory($) {
  my $DIRTOMAKE = $_;
  mkpath($DIRTOMAKE) unless -d $DIRTOMAKE;
}

sub getLine($) {
	my $LINENUM = $_[0];
	my $LOOPER = 0;
	open(my $UAFILE, "$CONFDIR/useragents.conf") or die "The useragents.conf file is not readable.\n";
	my @UAS = <$UAFILE>;
	close($UAFILE);
	my $CHOSENLINE = $UAS[$LINENUM];
	return $CHOSENLINE;
}

sub getNumberUAS() {
	open(my $UAFILE, "$CONFDIR/useragents.conf") or die "The useragents.conf file is not readable.\n";
	my $LINECOUNT;
	$LINECOUNT++ while <$UAFILE>;
	close($UAFILE);
	return $LINECOUNT;
}

1;