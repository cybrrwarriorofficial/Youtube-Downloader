#!/usr/bin/perl

use strict;
use warnings;
## Two arguments
##    $1 YouTube URL from the browser
##    $2 Prefix to the file name of the video (optional)
#

## Collect the URL from the command line argument
my $url = $ARGV[0] or die "\nError: You need to specify a YouTube URL\n\n";

## Declare the user defined file name prefix
my $prefix = defined($ARGV[1]) ? $ARGV[1] : "";

## Download the HTML code from the YouTube page
my $html = `wget -Ncq -e "convert-links=off" --keep-session-cookies --save-cookies /dev/null --no-check-certificate "$url" -O-`  or die  "\nThere was a problem downloading the HTML file.\n\n";

## Collect the title of the page to use as the file name
my ($title) = $html =~ m/<title>(.+)<\/title>/si;
$title =~ s/[^\w\d]+/_/g;
$title =~ s/_youtube//ig;
$title =~ s/^_//ig;
$title = lc ($title);

## Collect the URL of the video
my ($download) = $html =~ /"url_encoded_fmt_stream_map"([\s\S]+?)\,/ig;

## Clean up the URL by translating Unicode and removing unwanted strings
$download =~ s/\:\ \"//;
$download =~ s/%3A/:/g;
$download =~ s/%2F/\//g;
$download =~ s/%3F/\?/g;
$download =~ s/%3D/\=/g;
$download =~ s/%252C/%2C/g;
$download =~ s/%26/\&/g;
$download =~ s/sig=/signature=/g;
$download =~ s/\\u0026/\&/g;
$download =~ s/(type=[^&]+)//g;
$download =~ s/(fallback_host=[^&]+)//g;
$download =~ s/(quality=[^&]+)//g;

## Collect the URL and signature since the HTML page randomizes the order
my ($signature) = $download =~ /(signature=[^&]+)/;
my ($youtubeurl) = $download =~ /(http.+)/;
$youtubeurl =~ s/&signature.+$//;

## Combine the URL and signature in order to use in Wget
$download = "$youtubeurl\&$signature";

## A bit more cleanup 
$download =~ s/&+/&/g;
$download =~ s/&itag=\d+&signature=/&signature=/g;

## Print the file name of the video collected from the web page title for us to see on the CLI
print "\n Download: $prefix$title.webm\n\n";

## Download the file using Wget and background the Wget process
system("wget -Ncq -e \"convert-links=off\" --load-cookies /dev/null --tries=50 --timeout=45 --no-check-certificate \"$download\" -O $prefix$title.webm &");

#### EOF #####