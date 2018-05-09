#!/usr/bin/env perl6
use v6;

my @grid;
my $count;
my $current = 0;

for $*IN.lines -> $line {
    if !$count {
        $count = +$line;
    }
    elsif $current++ < $count {
        @grid.push: $line.comb;
    }
    else {
        last;
    }
}

my $out = Channel.new();
my @dir = [0, 1], [0, -1], [1, 0], [-1, 0], [1, 1], [-1, -1], [1, -1], [-1, 1];
gather {
    for 0..^$count -> $start-x {
        for 0..^$count -> $start-y {
            for @dir -> $d {
                my $i = $start-x;
                my $j = $start-y;
                my $num = 0;
                while 0 <= $i < $count && 0 <= $j < $count {
                    $num = $num * 10 + @grid[$i][$j];
                    take $num;
                    $i += $d[0];
                    $j += $d[1];
                }
            }
        }
    }
}.unique.race.map({ $out.send($_) if $_.is-prime; });
$out.close;
my @prime = $out.list;

say +@prime;
say @prime.join(", ");
