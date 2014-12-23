use v6;

my @filters = 
    'lol' => 'laugh out loud',
    'dw'  => 'don\'t worry',
    'hf'  => 'have fun',
    'gg'  => 'good game',
    'brb' => 'be right back',
    'g2g' => 'got to go',
    'wtf' => 'what the fuck',
    'wp'  => 'well played',
    'gl'  => 'good luck',
    'imo' => 'in my opinion';

for lines() -> $line is copy {
    for @filters -> $filter {
        my $s = $filter.key;
        my $v = $filter.value;
        $line.=subst(/(^|<-[a..zA..Z0..9]>)$s(<-[a..zA..Z0..9]>|$)/, -> $/ { $0 ~ $v ~ $1 }, :g);
    }
    say "'$line'";
}