#!/usr/bin/perl -w
# usage: fdupes -r DIR | fdupeslink.pl
use strict;

my @list;
while(<>) {
  chomp;
  if($_ eq "") {
    my $first = shift @list;
    foreach my $f (@list) {
      my @cmd = (qw"ln -f", $first, $f);
      print "@cmd\n";
      system(@cmd);
    }
    @list = ();
  } else {
    push(@list, $_);
  }
}
