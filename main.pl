#!/usr/bin/perl

#-------------------------------------------------------------------------------
# Skript: main
#-------------------------------------------------------------------------------

use strict;
use warnings;
use 5.24.0;

my $VERSION = '20.12.2017';

use lib::ZombihunterConfig;
use lib::ZombihunterUI;
use lib::ScanFolders;
use lib::EvaluateData;
use lib::OrganizeData;

my $settings = read_config;

initiate_console( $VERSION );

my $choice = '';

until ( $choice =~ 'q' ){           # exit program
	$choice = show_main_menu();

	if ( $choice =~ 'h') {          # help
		show_help();
	}
	elsif ( $choice =~ '1' ) {      # edit settings
		$choice = edit_config( $settings );
		$settings = read_config();
	}
	elsif ( $choice =~ '2' ) {      # scan folder
		if ( show_scan_folder( $settings->{ScanFolder} ) ) {
			show_scanning();
			scan_folders( $settings->{ScanFolder} );
		}
	}
	elsif ( $choice =~ '3' ) {      # reorganize folder

		# TODO: allow user to select the scanfile dynamically
		my $data = read_log('./scans/zh_log_2017-12-18_6_53_15.txt');

		loop_data( $data, $settings->{CommonFolder} );
	}
	else {
		exit;
	}
}

exit(0);