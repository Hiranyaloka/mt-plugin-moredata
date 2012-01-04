# Copyright 2011 Rick Bychowski
# This program is free software; you can redistribute it and/or modify it
# under the terms of either: the GNU General Public License as published
# by the Free Software Foundation; or the Artistic License.
# See http://dev.perl.org/licenses/ for more information.

package MoreData::Plugin;
use MT 4.2;
use warnings;
use strict;
use MT::Util qw(decode_html);

sub moredata {
  my ($str, $val, $ctx) = @_; # val is the data name and optional format (or default format)
  $str = decode_html($str);
  my $dataname; # retrieved from $val
  my $content;  # extracted from $str
  my $datastring; # extracted from $str
  my $result; # processed from $datastring
# retrieve configuration defaults
  my $config = _moredata_config($ctx);
# open tag is required
  my $opentag = $config->{ moredata_opentag } or die "MoreData requires an open tag\n";
  my $closetag = $config->{ moredata_closetag } || ''; # not required
# retrieve format and data separator from tag parameters
  my $format_cfg = $config->{'moredata_format'};
  my $format = '';
  if (ref($val) eq 'ARRAY') {
    $dataname = @$val ? $val->[0] : '' ; #dataname can be empty
    $format = $val->[1] || $format_cfg ;
  } else { 
    $dataname = $val || '';
    $format = $format_cfg
  }
  die "No format specified in args or configuration" unless $format;
# extract datastrings
  my $substrings_aref = _retrieve_strings($str, $opentag, $closetag, $dataname) or die "cannot extract substrings from string\n";
  $content = _trim($$substrings_aref[0]);
  return $content if $dataname eq "__content__";
  $datastring = _trim($$substrings_aref[1]);
  return $datastring  if ($dataname eq '__data__'); # return all data as string
  return $datastring unless (length($datastring)); # no sense in processing an empty string
  my $datasep_cfg = $config->{'moredata_datasep'};
  length($datasep_cfg) or die "The data separation string must be configured\n";
  my $hashsep_cfg = $config->{'moredata_hashsep'} || '';
  length($hashsep_cfg) or die "The hash separation string must be configured\n";
# send data and parameters to desired format for result
  if ($format eq 'array') {
    $result = _moredata_array($datastring, $datasep_cfg);
  } elsif  ($format eq 'hash') {
    $result = _moredata_hash($datastring, $hashsep_cfg);
  } elsif  ($format eq 'string') {
    $result = $datastring;
  } else {
    die "no format : $!";
  }
  return $result;
}

sub _moredata_array {
  my ($datastring, $datasep_cfg) = @_;
  use Text::CSV;
  my $csv = Text::CSV->new ({ binary => 1, auto_diag => 1, allow_whitespace    => 1,  sep_char => "$datasep_cfg" });
  my $io;
  open ($io, "<:encoding(utf8)", \$datastring) or die "Cannot use CSV: $!".Text::CSV->error_diag ();
  my $row = $csv->getline ($io);
  $row || undef;
}

 sub _moredata_hash {
  my ($datastring, $hashsep) = @_;
  use Text::CSV;
  my $csv = Text::CSV->new ({ binary => 1, auto_diag => 1, allow_whitespace    => 1,  sep_char => "$hashsep" });
  my $io;
  open ($io, "<:encoding(utf8)", \$datastring) or die "Cannot use CSV: $!".Text::CSV->error_diag ();
  my %hash;
  while (my $colref = $csv->getline($io)) {
    next unless length $colref->[0];
    my $count = scalar @{$colref};
    die "$count is an odd number of keys and values in hash assignment at @{$colref}.\n" if $count%2; 
    $hash{$colref->[0]} = $colref->[1];
   }
  scalar %hash ? \%hash : undef;
}
 
sub _moredata_config {
  my $ctx = shift;
  my $plugin = MT->component("MoreData");
  my $blog = $ctx->stash('blog');
  if ( !$blog ) {
      my $blog_id = $ctx->var('blog_id');
      $blog = MT->model('blog')->load($blog_id);
  }
  my $blog_id = $blog->id;
  my $scope = "blog:" . $blog_id;
  my $config = $plugin->get_config_hash($scope);
  return $config;
}

# return content and data strings from string and tags
sub _retrieve_strings {
  my ($str, $opentag, $closetag, $dataname) = @_;
  my $content = $str;
  my $datastring = '';
# content is all non-data, datastring all data
  die "MoreData requires an open tag in plugin configuration.\n" unless (length($opentag));
# check that we have a string with length.
  my $stringlength = length($str);
  return [$content, $datastring] unless ($stringlength);   
# return unless opentag is found in string
  my $openposition = index($str,$opentag); # start of _all_ the data
  return [$content, $datastring] if ($openposition == -1);
# close tag cannot be subset of open tag
  die "MoreData close tag cannot be substring of the open tag.\n"
    unless (index($opentag,$closetag) == -1);
# extract the content and data strings
  my $closeposition; # end of _all_ the data
  if (length($closetag) and rindex($str,$closetag) != -1) { # closetag found
    $closeposition = rindex($str,$closetag);
  } else {
    $closeposition = $stringlength;
  }
  my $datalength = $closeposition - $openposition; # length of _all_ data
  die "MoreData open tag must precede the close tag.\n" if ($datalength < 0); #tags in wrong order;
  $content = substr($str, 0, $openposition) . substr($str, ($closeposition + length($closetag)), $stringlength); #length argument can be beyond the end
# data includes open tag but not close tag
  $datastring = substr($str, $openposition, $datalength); # _all_ data
  return [$content, $datastring] if ($dataname eq ('__data__' || '__content__')); # return content and data as strings
  return [$content, $datastring] unless length($datastring); # no reason to process empty datastring
# search for named datastring
  my $nameopentag = $opentag . $dataname . '='; # selected data requires the equal sign appended
  my $length_tagname = length($nameopentag);
  my $nameopenposition = 0;
  my $namecloseposition = 0;
  my $named_data;
  my $append_string;
  until ($nameopenposition == -1) {
# locate the desired selected data within the datastring
    $nameopenposition = index($datastring, $nameopentag, $namecloseposition);
    last if ($nameopenposition == -1);
    if (index($datastring, $opentag, $nameopenposition + 1) != -1 ) {  # if we find another opentag following current one
      $namecloseposition = index($datastring, $opentag, $nameopenposition + 1);
    } elsif (index($datastring, $closetag, $nameopenposition + 1) != -1 ) {  # otherwise use closing tag
      $namecloseposition = index($datastring, $closetag, $nameopenposition);
    } else {  # else just use end of file
      $namecloseposition = $datalength;
    }
    my $namedatalength = $namecloseposition - $nameopenposition - $length_tagname;
    $append_string = substr($datastring, $nameopenposition + $length_tagname, $namedatalength);
    $named_data .= "$append_string" if $append_string;
    last if ($namecloseposition == $datalength);
  }
  return [$content, $named_data];
}

# Perl trim function to remove whitespace from the start and end of the string
sub _trim {
  my $string = shift;
  $string =~ s/^\s+//;
  $string =~ s/\s+$//;
  return $string;
}


1;
