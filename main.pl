#!/usr/bin/perl

#-------------------------------------------------------------------------------
# Skript: main
#-------------------------------------------------------------------------------

use strict;
use warnings;
use 5.24.0;

my $VERSION = '18.12.2017';

use lib::ZombihunterConfig;
use lib::ZombihunterUI;
use lib::ScanFolders;

my $settings = read_config;

initiate_console( $VERSION );

my $choice = '';

until ( $choice =~ 'q' ){
	$choice = show_main_menu();

	if ( $choice =~ 'h') {
		show_help();
	}
	elsif ( $choice =~ '1' ) {
		$choice = edit_config( $settings );
		$settings = read_config();
	}
	elsif ( $choice =~ '2' ) {
		if ( show_scan_folder( $settings->{ScanFolder} ) ) {
			show_scanning();
			scan_folders( $settings->{ScanFolder} );
		}
	}
	else {
		exit;
	}
}

exit(0);