use Tk;

# ------------------------------ Space variables ----------------------------- #
$block_size = 50;
$width = 800;
$height = 450;

# ------------------------------- Window setup ------------------------------- #
my $mw = MainWindow->new;
my $canvas = $mw->Canvas(-width => $width, -height => $height, -background => 'gray75')->pack;

# ------------------------------- Terrain setup ------------------------------ #
# Helicopter
$heli = $canvas->create('rectangle', 0, 250, 50, 300, -fill => 'orange');

# Start platform
$start_pl = $canvas->create('rectangle', 0, 300, 100, 350, -fill => 'blue');

# End platform
$end_pl = $canvas->create('rectangle', 700, 100, 800, 150, -fill => 'blue');

# Obstacle - 01
$obs_1 = $canvas->create('rectangle', 200, 0, 300, 300, -fill => 'firebrick');

# Obstacle - 02
$obs_2 = $canvas->create('rectangle', 500, 450, 600, 150, -fill => 'firebrick');

# -------------------------------- Movement handling ------------------------------- #
my @obstacles = (
    $start_pl, $end_pl, $obs_1, $obs_2
);

$speed = 5;

# Track the state of the keys
my %key_state = (
    'Up' => 0,
    'Down' => 0,
    'Right' => 0,
    'Left' => 0,
);

# Move top
$mw->bind('<KeyPress-Up>', sub { $key_state{'Up'} = 1; });
$mw->bind('<KeyRelease-Up>', sub { $key_state{'Up'} = 0; });

# Move right
$mw->bind('<KeyPress-Right>', sub { $key_state{'Right'} = 1; });
$mw->bind('<KeyRelease-Right>', sub { $key_state{'Right'} = 0; });

# Move left
$mw->bind('<KeyPress-Left>', sub { $key_state{'Left'} = 1; });
$mw->bind('<KeyRelease-Left>', sub { $key_state{'Left'} = 0; });

# Move the rectangle based on the state of the keys
$mw->repeat(60, sub {
    my ($hx1, $hy1, $hx2, $hy2) = $canvas->bbox($heli);

    # Calculate the new position
    my $new_hx1 = $hx1;
    my $new_hy1 = $hy1;
    my $new_hx2 = $hx2;
    my $new_hy2 = $hy2;

    if ($key_state{'Up'} && $key_state{'Right'} && $hy1 > 0 && $hx2 < $canvas->cget('-width')) {
        $new_hx1 += $speed;
        $new_hy1 -= $speed;
        $new_hx2 += $speed;
        $new_hy2 -= $speed;
    } elsif ($key_state{'Up'} && $key_state{'Left'} && $hy1 > 0 && $hx1 > 0) {
        $new_hx1 -= $speed;
        $new_hy1 -= $speed;
        $new_hx2 -= $speed;
        $new_hy2 -= $speed;
    } elsif ($key_state{'Up'} && $hy1 > 0) {
        $new_hy1 -= $speed;
        $new_hy2 -= $speed;
    } elsif ($key_state{'Right'} && $hx2 < $canvas->cget('-width')) {
        $new_hx1 += $speed;
        $new_hx2 += $speed;
        if ($hy2 < $canvas->cget('-height')) {
            $new_hy1 += $speed;
            $new_hy2 += $speed;
        }
    } elsif ($key_state{'Left'} && $hx1 > 0) {
        $new_hx1 -= $speed;
        $new_hx2 -= $speed;
        if ($hy2 < $canvas->cget('-height')) {
            $new_hy1 += $speed;
            $new_hy2 += $speed;
        }
    } else {
        # If the Up key is not pressed, move the shape down
        # but only if it's not at the bottom of the canvas
        if ($hy2 < $canvas->cget('-height')) {
            $new_hy1 += $speed;
            $new_hy2 += $speed;
        }
    }

    # Check for collisions
    foreach my $item (@obstacles) {
        my ($ox1, $oy1, $ox2, $oy2) = $canvas->bbox($item);
        if (($new_hx1 + 2) < $ox2 && $new_hx2 > ($ox1 + 2) && $new_hy1 < $oy2 && $new_hy2 > $oy1) {
            print("# --- #\n");
            print("hx1: $new_hx1 - ox2: $ox2\n");
            print("hx2: $new_hx2 - ox1: $ox1\n");
            print("hy1: $new_hy1 - oy2: $oy2\n");
            print("hy2: $new_hy2 - oy1: $oy1\n");
            return;  # Don't move the helicopter
        }
    }

    # No collisions, so move the helicopter
    my $dx = $new_hx1 - $hx1;
    my $dy = $new_hy1 - $hy1;
    $canvas->move($heli, $dx, $dy);
});


# ------------------------------------ Run ----------------------------------- #
MainLoop;