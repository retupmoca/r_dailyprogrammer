class Board::Cell {
    has @.possible;

    method clone {
        my @new = @!possible;
        self.new(:possible(@new));
    }

    method remove-possible($num) {
        if $.solved && $.value == $num {
            return Nil;
        }
        if @.possible.grep($num, :k) -> @index {
            @!possible.splice(@index[0], 1);
        }
        return True;
    }

    method set($value) {
        if @.possible.grep($value) {
            @!possible = $value;
            return True;
        }
        else {
            return Nil;
        }
    }

    method solved {
        return +@.possible == 1;
    }

    method value {
        $.solved ?? @.possible[0] !! Nil;
    }
}

class Board {
    has @.cells;
    has $.size;

    submethod BUILD(:$!size, :@!cells) {
        unless @!cells {
            for ^($!size * $!size) {
                @!cells.push(Board::Cell.new(:possible(1..$!size)));
            }
        }
    }

    method clone {
        my @new;
        for @!cells {
            @new.push: $_.clone;
        }

        self.new(:size($!size), :cells(@new));
    }

    method set-cell($x, $y, $value) {
        my $pos = $x + $!size*$y;
        return Nil unless @.cells[$pos].set($value);

        for 0..^$!size {
            my $posx = $_ + $!size*$y;
            my $posy = $x + $!size*$_;

            if $posy != $pos {
                my $cell = @.cells[$posy];
                if $cell.possible == 2 && $cell.possible.grep($value) {
                    return Nil unless $cell.remove-possible($value);
                    return Nil unless self.set-cell($x, $_, $cell.possible[0]);
                }
                else {
                    return Nil unless $cell.remove-possible($value);
                }
            }
            if $posx != $pos {
                my $cell = @.cells[$posx];
                if $cell.possible == 2 && $cell.possible.grep($value) {
                    return Nil unless $cell.remove-possible($value);
                    return Nil unless self.set-cell($_, $y, $cell.possible[0]);
                }
                else {
                    return Nil unless $cell.remove-possible($value);
                }
            }
        }

        return True;
    }

    method print {
        my $pos = 0;
        for 0..^$!size -> $y {
            for 0..^$!size -> $x {
                my $c = @.cells[$pos++];
                print $c.value // '?';
                print ' ';
            }
            print "\n";
        }
    }
}

class Constraint {
    has @.cells;
    has $.operation;
    has $.value;

    method test($values) {
        if $.operation eqv &[*]|&[+] { 
            return $values.reduce($.operation) == $.value;
        }
        else {
            my @permutations = $values.permutations;
            for @permutations {
                if $_.reduce($.operation) == $.value {
                    return True;
                }
            }
            return False;
        }
    }
}

sub solve($board, @constraints) {
    # pull the first constraint off and try to solve it
    my $constraint = @constraints.pop;
    my @values;
    my $i = 0;
    for $constraint.cells {
        my $pos = $_<x> + $_<y> * $board.size;
        @values[$i++] = $board.cells[$pos].possible;
    }
    my @options = @values.reduce(&[X])
                         .grep({ $constraint.test($_); })
                         .unique(:with(&[eqv]));
    OPTS: for @options -> $option {
        my $testboard = $board.clone;
        $i = 0;
        for $constraint.cells {
            my $value = $option[$i++];
            my $ret = $testboard.set-cell($_<x>, $_<y>, $value);
            next OPTS unless $ret;
        }
        if @constraints.elems {
            my @tmp = @constraints;
            my $ret = solve($testboard, @tmp);
            return $ret if $ret;
            next;
        }
        else {
            return $testboard;
        }
    }
    return Nil;
}

sub MAIN {
    my $size = +get;
    my $board = Board.new(:$size);

    my @constraints;
    for lines() {
        last unless $_;
        my @line = $_.split(/\s+/).grep(*.chars);
        my $value = @line.shift;
        my $str_operation = @line.shift;
        my @xy;
        for @line {
            my @parts = $_.comb(/./);
            @parts[0] .= uc;
            @xy.push({ :x(ord(@parts[0]) - 65), :y(@parts[1] - 1) });
        }

        my $operation;
        given $str_operation {
            when '+' { $operation = &[+] }
            when '-' { $operation = &[-] }
            when '*' { $operation = &[*] }
            when '/' { $operation = &[/] }
        }

        if $str_operation eq '=' {
            # just set the thing
            $board.set-cell($_<x>, $_<y>, $value) for @xy;
        }
        else {
            @constraints.push: Constraint.new(:cells(@xy), :$value, :$operation);
        }
    }

    @constraints .= sort({ $^b.cells <=> $^a.cells });

    solve($board, @constraints).print;
}
