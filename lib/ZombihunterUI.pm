package lib::ZombihunterUI;

#-------------------------------------------------------------------------------
#   This module holds user interface (UI) functions.
#   The UI is based on Win32::Console commands.
#-------------------------------------------------------------------------------

use strict;
use warnings;
use 5.24.0;

use Win32::Console;
use Path::Tiny;

use lib::ScanFolders;

require Exporter;

our @ISA = qw ( Exporter );

our @EXPORT = qw (
	initiate_console
	show_main_menu
	edit_config
	show_scan_folder
	show_scanning
	show_scanfiles
	show_help
	);

our $CONSOLE;

sub initiate_console {
	my $version = shift;

	$CONSOLE = Win32::Console->new(STD_OUTPUT_HANDLE);
	$CONSOLE->Title("ZombiHunter (version: $version)");
	$CONSOLE->SetIcon("./graphics/skull_01.ico");  # set application icon
	$CONSOLE->Window(1, 0, 0, 80, 25);	        # set size of console
}

#-------------------------------------------------------------------------------
#   Show the entries of the main nenu
#
sub show_main_menu {
	$CONSOLE->Cls();
	print "\n  M A I N  M E N U\n\n";
	print "  1 - edit settings\n";
	print "  2 - scan folder\n";
	print "  3 - generate statistics\n";
	print "  4 - reorganize folder\n";
	print "\n  h - help\n";
	print "  q - exit program\n\n";
	print "\n  Your choice: ";
	my $input = <STDIN>;
	chomp $input;
	return $input;
}

sub edit_config {
	my $settings = shift;
	$CONSOLE->Cls();
	print "\n  C O N F I G  S E T T I N G S\n\n";
	print "  Folder to be scanned:\n";
	print "    $settings->{ScanFolder}\n";
	print "\n  Common folder:\n";
	print "    $settings->{CommonFolder}\n";
	print "\n  Ignored folders:\n";
	say "    " . join '; ', @{$settings->{FolderIgnore}};
	print "\n  Ignored file types:\n";
	say "    " . join '; ', @{$settings->{FileTypeIgnore}};
	print "\n  Edit config (y/n)? ";

	my $input = <STDIN>;
	chomp $input;
	my $stat;
	if ( $input =~ /y|Y/ ) {
		# TODO: handle path to config file centrally/not spread throughout code
		$stat = `start notepad .\\config\\zombihunter.conf`;
		return '';
	}
	elsif ( $input =~ /n|N/ ) {
		return '';
	}
}

#-------------------------------------------------------------------------------
#   Shows the menu to start scanning of chosen folder/drive
#
sub show_scan_folder {
	my $folder = shift;

	$CONSOLE->Cls();
	print "\n  S C A N  F O L D E R\n\n";
	print "\n  Start scanning " . uc ($folder) . " (y/n)? ";

	my $input = <STDIN>;
	chomp $input;
	if ( $input =~ /y|Y/ ) {
		return '1';
	}
	elsif ( $input =~ /n|N/ ) {
		return '0';
	}
}

#-------------------------------------------------------------------------------
#   Shows a status while scanning folders/drives
#
sub show_scanning {
	$CONSOLE->Cls();
	print "\n  S C A N N I N G\n\n";
}

#-------------------------------------------------------------------------------
#
#
sub show_scanfiles {
	my $scanfiles = shift;      # array ref holding all available scanfiles

	$CONSOLE->Cls();
	print "\n  A V A I L A B L E  S C A N F I L E S\n\n";
	print "\n  Following scanfiles are available:\n";

	my $nmbr = 1;
	foreach my $set ( @$scanfiles ) {
		$nmbr = ' ' . $nmbr if $nmbr < 10;
		say "  $nmbr) $set->[1]";
		$nmbr++;
	}

	print "\n  Choose one of the numbers: ";
	my $input = <STDIN>;
	chomp $input;
	if ( $input =~ /[0-9]{1,2}/ and $input <= scalar @$scanfiles ) {
		return $input;
	}
	else {
		say "\n  $input is not a file number!";
		print "\n  Press any key to continue... ";
		$input = <STDIN>;
		return undef;
	}
}

#-------------------------------------------------------------------------------
#   Show help for Zombihunter
#
sub show_help {
	$CONSOLE->Cls();
	print "\n  H E L P\n\n";
	print qq~  1 - edit settings
      This allows you to change the settings of Zombihunter.
      For example you can change which folder has to be scanned or where the
      common/double files have to be copied to.
  2 - scan folder
      This starts the scanning of the folder/drive you have specified in the
      settings.
      The scanning process can take a while since during this process a MD5
      checksum of each file is calculated to help identifying double files even
      though they might have different names.
  3 - generate statistics
      Generates a statistics based on one of the scanfiles.
      Statistics are e.g. how many files and directories were scanned.
  4 - reorganize folder
      This starts to copy the first of each double files family into the common
      directory, deletion of all doublettes and replacement of those files by
      Windows shortcuts.
      C A U T I O N !  It is a hell of work to undo this operation manually.
                       A BACKUP IS HIGHLY RECOMMENDED!
~;
	print "\n  Continue with any key...";
	my $input = <STDIN>;
}

1;