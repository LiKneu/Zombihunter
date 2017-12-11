package lib::ZombihunterConfig;

#-------------------------------------------------------------------------------
#   This package covers creation and handling of program environment like
#   reading the config file and creating target folders etd.
#-------------------------------------------------------------------------------

use strict;
use warnings;
use 5.24.0;

require Exporter;

our @ISA = qw ( Exporter );

our @EXPORT = qw (
	read_config
	);

#-------------------------------------------------------------------------------
#   Reads the Zombihunter config file and returns the result in a hash of arrays
#
sub read_config {
	my $config_path = './config/zombihunter.conf';

	my %config;

	open CONFIG, '<', $config_path or
		die "Couldn't read config file $config_path: $!";

	while (<CONFIG>) {
		my $line = $_;
		chomp $line;
		next if $line =~ /^#/;      # ignore comments
		next if $line =~ /^\s*?$/;  # ignore empty lines

		my ($key, $settings) = split '\|', $line;
		my @values = split ';', $settings;

		if ( scalar @values > 1 ) {
			$config{$key} = \@values;
		}
		elsif (scalar @values == 1 ) {
			$config{$key} = $values[0];
		}
		else {
			warn "Problem with config setting $key: $!";
		}
	}
	close CONFIG;

	return \%config;
}

1;