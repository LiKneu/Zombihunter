package lib::ScanFolders;
use strict;
use warnings;
use 5.24.0;

use Data::Dumper;

use Directory::Scanner;
use File::Find;
use Digest::MD5;
use Text::CSV;
use Win32::Console;

use lib::ZombihunterUI;

require Exporter;

our @ISA = qw ( Exporter );

our @EXPORT = qw (
	scan_folders
	process_file
	get_time_stamp
	);

my $fh;     # file handle to output scan results
my $err_fh; # file handle to output error messages
my $csv;

#-------------------------------------------------------------------------------
#   Scan recursively through all folders below the given one and return all
#   found filenames.
#
sub scan_folders {
	my $dir = shift;    # get starting directory for scanning

	my $time_stamp = get_time_stamp();

	my $logfile_name = '.\scans\zh_log_' . $time_stamp . '.txt';

	$csv = Text::CSV->new ( {
		binary   		=> 1,
		eol		    	=> $\,
		always_quote	=> 1,
	} ) or die "Cannot use CSV: ".Text::CSV->error_diag ();

	open $fh, ">:encoding(utf8)", $logfile_name or
		die "Couldn't open file for scan results $logfile_name: $!";

	open $err_fh, ">:encoding(utf8)", './logs/error_' . $time_stamp . '.log' or
		die "Couldn't open file for error log $err_fh: $!";

	say $fh "\"DIRECTORY SCAN FROM $time_stamp: $dir\"";

	Directory::Scanner->for($dir)
		->recurse                           # recurse through subdirectories
		->ignore(sub { $_->is_dir })        # ignore directories
		->apply (sub { process_file ($_)})  # apply function to each found object
		->stream                            # start streaming
		->flatten;                          # flatten object to array??

	print $fh "\"END OF SCAN FILE\"";

	close $err_fh;
	close $fh;
}

#-------------------------------------------------------------------------------
#   Processes a file and determines the following information about it:
#       path
#       extension
#       file size
#       last access
#       last modification
#       last change
#       MD5 checksum
#
sub process_file {
	my $path = shift;
	state $count;

	# give the status of the scanning process so that user doesn't interrupt
	# the script
	$lib::ZombihunterUI::CONSOLE->WriteChar (
		"No. of files scanned: " . $count++, 2, 4 );

	# clear content in the console before..
	$lib::ZombihunterUI::CONSOLE->FillChar(" ", 100*4, 0, 6);
	# ..writing it anew
	$lib::ZombihunterUI::CONSOLE->WriteChar ( $path, 2, 6 );

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

	my $status = $csv->print ($fh, $line);
	print $fh "\n";
}

#-------------------------------------------------------------------------------
#   Calculates the MD5 hash of a file (hexadecimal) and returns it
#
sub checksum {
	my $file = shift;

	my $md5;

	if ( open(FILE, '<', $file) ) {
		binmode(FILE);
		$md5 = Digest::MD5->new->addfile(*FILE)->hexdigest;
		return($md5);
	}
	else {
		say $err_fh "Cant open $file for MD5 calculation: $!";
	}
}

#-------------------------------------------------------------------------------
#   Returns a formatted time stamp e.g. for log file naming.
#
sub get_time_stamp {
	my @present_time = localtime ( time );

	# format: YYYY-MM-DD_hh_mm_ss
	my $time_stamp =
		($present_time[5] += 1900) .    # year
			'-' . ($present_time[4] += 1) . # month
			'-' . $present_time[3] .        # day
			'_' . $present_time[2] .        # hour
			'_' . $present_time[1] .        # min
			'_' . $present_time[0];         # sec

	return $time_stamp;
}

1;