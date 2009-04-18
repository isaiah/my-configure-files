#!/usr/bin/perl -w
# $Id$
# -*- perl -*- vim:set ft=perl et sw=4 sts=4:

use strict;
use Irssi;
use vars qw($VERSION %IRSSI);

$VERSION = "0.01";
%IRSSI = (
authors     => 'Donald Ephraim Curtis',
contact     => 'dcurtis@cs.uiowa.edu',
name        => 'notify.pl',
description => 'notify Awesome WM of irssi message',
license     => 'GNU General Public License',
);

sub notify {
  my ($dest, $text, $stripped) = @_;
  my $server = $dest->{server};


  return if (!$server || !($dest->{level} & MSGLEVEL_HILIGHT));

  my %replacements = (
  '<' => '<',
  '>' => '>',
  '&' => '&',
  "\"" => """,
  );
  my $replacement_string = join '', keys %replacements;
  $stripped =~ s/([\Q$replacement_string\E])/$replacements{$1}/g;

  system("notify-send -t 7500 \"<span color='#ffffff'>".$dest->{target}."</span>\""." \"".$stripped."\"");
  open(FILE,">>/home/dcurtis/irssi");
  print FILE $stripped . "\n";
  close (FILE);


}

Irssi::signal_add('print text', 'notify');

