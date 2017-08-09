use warnings;
use strict;

my ($combinations, @rpts) = @ARGV;

my %loads;
my %combos;

#read combinations
open(IPT, "<", $combinations);
my $n = 0;
while(<IPT>){
	chomp($_);
	my @parts = split("\t", $_);
	$combos{$n} = \@parts;
	$n++;
}
close(IPT);

#read rpt files
foreach my $rpt (@rpts){
	open(IPT, "<", $rpt);
	my $LC;
	while(<IPT>){
		if(m/^\s+Load Case: SC(\d+)/){
			$LC = $1;
		}
		elsif(m/^\s+\d+\s+(\S+)\s+(\S+)\s+(\S+)\s*$/){
			unless($loads{$LC}){
				#initialize if case does not yet exist
				$loads{$LC} = [0, 0, 0, 0];
			}
			if($1 < 0){
				$loads{$LC}[0] = $loads{$LC}[0] + $1;
			}
			if($2 < 0){
				$loads{$LC}[1] = $loads{$LC}[1] + $2;
			}
			if($3){
				$loads{$LC}[2] = $loads{$LC}[2] + abs($3);
			}
			$loads{$LC}[3] = $loads{$LC}[3] + 1;
		}
	}
 }

$n = 0;

#do combinations
open(OPT, ">>", "PanelLoads.txt");
foreach my $combo (keys(%combos)){
	my @parts = @{$combos{$combo}};
	my $combined1 = $parts[0] * $loads{$parts[1]}[0] / $loads{$parts[1]}[3] + $parts[2] * $loads{$parts[3]}[0] / $loads{$parts[3]}[3];
	my $combined2 = $parts[0] * $loads{$parts[1]}[1] / $loads{$parts[1]}[3] + $parts[2] * $loads{$parts[3]}[1] / $loads{$parts[3]}[3];
	my $combined3 = $parts[0] * $loads{$parts[1]}[2] / $loads{$parts[1]}[3] + $parts[2] * $loads{$parts[3]}[2] / $loads{$parts[3]}[3];
	print OPT $parts[0]."x".$parts[1]."+".$parts[2]."x".$parts[3]."\t";
	print OPT $combined1."\t".$combined2."\t".$combined3."\n";
}