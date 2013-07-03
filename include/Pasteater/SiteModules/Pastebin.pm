# Program Name: Pasteater
# Created: 2013-07-01
# Author: Lee "MadHat" Heath
# Version: 1.0 (2013-07-02)
# Package: Pastebin
# Site: http://pastebin.com/
package Pasteater::SiteModules::Pastebin;

use LWP::UserAgent;
use strict;
use vars qw(@LIST @DATA $VERSION $SITE $RAW $MATCH);

$VERSION = '1.0';

sub Version { $VERSION; }

$SITE = 'http://pastebin.com/archive';
$RAW =  'http://pastebin.com/raw.php?i=<ID>';
$MATCH = '<a href="/(\w{8,})">.+</a></td>';

sub list {
  my ($LAST_TIME, $LAST_ID, $USER_AGENT) = @_;
  my $UA = LWP::UserAgent->new;
  $USER_AGENT = $USER_AGENT?$USER_AGENT:'Mozilla/5.0 (iPad; U; CPU OS 3_2_1 like Mac OS X; en-us) AppleWebKit/531.21.10 (KHTML, like Gecko) Mobile/7B405';
  $UA->agent($USER_AGENT);
  my $SITE_REQ = HTTP::Request->new('GET', $SITE);
  my $SITE_RES = $UA->request($SITE_REQ);
  if (!$SITE_RES->is_error) {
    my @file = split("\n", $SITE_RES->content);
	foreach my $LINE (@file) {
	  if ($LINE =~ (/$MATCH/)) {
	    push @LIST, $1;
	  }
	}
  } else {
    my $CODE = $SITE_RES->code;
    my $CONTENT = $SITE_RES->content;
	@LIST = ('', $CODE, $CONTENT);
  }
  @LIST = ('', 'No Pastes Found') if ($#LIST < 1);
  return(@LIST);
}

sub download {
  my ($ID, $USER_AGENT) = @_;
  my $UA = LWP::UserAgent->new;
  return ('', 'BAD ID') if ($ID !~ /^[\w\d]+$/);
  $USER_AGENT = $USER_AGENT?$USER_AGENT:'Mozilla/5.0 (iPad; U; CPU OS 3_2_1 like Mac OS X; en-us) AppleWebKit/531.21.10 (KHTML, like Gecko) Mobile/7B405';
  $UA->agent($USER_AGENT);
  $RAW =~ s/\<ID\>/$ID/;
  my $SITE_REQ = HTTP::Request->new('GET', $RAW);
  my $SITE_RES = $UA->request($SITE_REQ);
  if (!$SITE_RES->is_error) {
    @DATA = split("\n", $SITE_RES->content);
  } else {
    my $CODE = $SITE_RES->code;
    my $CONTENT = $SITE_RES->content;
	@DATA = ('', $CODE, $CONTENT);
  }
  @DATA = ('', 'No Content Returned') if ($#DATA < 1);
  return(@DATA);
}

1;