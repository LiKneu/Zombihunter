package lib::ScanFolders;
use strict;
use warnings;
use 5.24.0;

use Data::Dumper;

use Directory::Scanner;
use File::Find;
use Digest::MD5;
use Text::CSV;

require Exporter;

our @ISA = qw ( Exporter );

our @EXPORT = qw (
	scan_folders
	);

my $fh;
my $csv;

#-------------------------------------------------------------------------------
#   Scan recursively through all folders below the given one and return all
#   found filenames.
#
sub scan_folders {
	my $dir = shift;    # get starting directory for scanning

	my @present_time = localtime ( time );

	# file name format: zh_log_YYYY-MM-TT_hh_mm_ss.txt
	my $logfile_name = '.\zh_log_' .
		($present_time[5] += 1900) .    # year
		'-' . ($present_time[4] += 1) . # month
		'-' . $present_time[3] .        # day
		'_' . $present_time[2] .        # hour
		'_' . $present_time[1] .        # min
		'_' . $present_time[0] .        # sec
		'.txt';

	$csv = Text::CSV->new ( {
		binary   		=> 1,
		eol		    	=> $\,
		always_quote	=> 1,
	} ) or die "Cannot use CSV: ".Text::CSV->error_diag ();

	open $fh, ">:encoding(utf8)", $logfile_name or die "$logfile_name: $!";

	Directory::Scanner->for($dir)
		->recurse                           # recurse through subdirectories
		->ignore(sub { $_->is_dir })        # ignore directories
		->apply (sub { process_file ($_)})  # apply function to each found object
		->stream                            # start streaming
		->flatten;                          # flatten object to array??

	close $fh;
}

#-------------------------------------------------------------------------------
#   Processes a file and determines the following information about it:
#       path
#       extension
#       file size
#       last access
#       last mdification
#       last change
#       MD5 checksum
#
sub process_file {
	my $path = shift;

	my $md5 = checksum ( $path );

	# split filename at '.' to get the extension
	my @filecomponents = split ( /\./, $path->basename);

	my $extension;
	if ( scalar @filecomponents > 1 ) {
		$extension = $filecomponents[-1];   # file has an extension
	}
	else {
		$extension = '';                    # file doesn't have an extension
	}

	#  7: file size
	#  8: date last access
	#  9: last modification
	# 10: last change
	my ($file_size, $last_access, $last_mod, $last_change) = (stat $path)[7..10];
	my $line = [
		$path,
		$extension,
		$file_size,
		$last_access,
		$last_mod,
		$last_change,
		$md5 ];
#	say join ", ", @$line;

	my $status = $csv->print ($fh, $line);
	print $fh "\n";
}

#-------------------------------------------------------------------------------
#   Calculates the MD5 hash of a file (hexadecimal) and returns it
#
sub checksum {
	my $file = shift;

	open(FILE, '<', $file) or warn "Can't open $file: $!";
	binmode(FILE);
	my $md5 = Digest::MD5->new->addfile(*FILE)->hexdigest;
	close FILE;

	return($md5);
}

1;