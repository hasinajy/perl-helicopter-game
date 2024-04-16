# This file contains the SAT (Separating Axis Theorem) algorithm functions

# Calculates the dot product of two vectors
sub dot_product {
    my ($a, $b) = @_;
    return $a->[0]*$b->[0] + $a->[1]*$b->[1];
}

# Subtracts vector b from vector a
sub subtract {
    my ($a, $b) = @_;
    return [$a->[0]-$b->[0], $a->[1]-$b->[1]];
}

# Returns the perpendicular vector of a
sub perp {
    my ($a) = @_;
    return [-$a->[1], $a->[0]];
}

# Checks for collision between two polygons using the SAT algorithm
sub check_collision {
    my ($poly1, $poly2) = @_;

    foreach my $poly ($poly1, $poly2) {
        for my $i (0..$#$poly) {
            my $p1 = $poly->[$i];
            my $p2 = $poly->[($i+1) % @$poly];
            my $normal = perp(subtract($p2, $p1));

            my ($minA, $maxA) = (undef, undef);
            foreach my $p (@$poly1) {
                my $projection = dot_product($normal, $p);
                $minA = $projection if !defined($minA) || $projection < $minA;
                $maxA = $projection if !defined($maxA) || $projection > $maxA;
            }

            my ($minB, $maxB) = (undef, undef);
            foreach my $p (@$poly2) {
                my $projection = dot_product($normal, $p);
                $minB = $projection if !defined($minB) || $projection < $minB;
                $maxB = $projection if !defined($maxB) || $projection > $maxB;
            }

            if ($maxA < $minB || $maxB < $minA) {
                # No overlap, the polygons are separated
                return 0;
            }
        }
    }

    # No separating axis found, the polygons are colliding
    return 1;
}

1;  # Return true to indicate successful file inclusion
