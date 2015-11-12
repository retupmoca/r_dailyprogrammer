multi div3($num where { $_ % 3 == 0 }) { say "$num 0";   $num      / 3 }
multi div3($num where { $_ % 3 == 1 }) { say "$num -1"; ($num - 1) / 3 }
multi div3($num where { $_ % 3 == 2 }) { say "$num 1";  ($num + 1) / 3 }

sub MAIN {
    my $num = +get;
    $num .= &div3 until $num == 1;
}
