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

$speed = 10;

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
$mw->repeat(20, sub {
    my ($left, $top, $right, $bottom) = $canvas->bbox($heli);

    if ($key_state{'Up'} && $key_state{'Right'} && $top > 0 && $right < $canvas->cget('-width')) {
        $canvas->move($heli, $speed, -$speed);
    } elsif ($key_state{'Up'} && $key_state{'Left'} && $top > 0 && $left > 0) {
        $canvas->move($heli, -$speed, -$speed);
    } elsif ($key_state{'Up'} && $top > 0) {
        $canvas->move($heli, 0, -$speed);
    } elsif ($key_state{'Right'} && $right < $canvas->cget('-width')) {
        $canvas->move($heli, $speed, $key_state{'Up'} && $top > 0 ? -$speed : ($bottom < $canvas->cget('-height') ? $speed : 0));
    } elsif ($key_state{'Left'} && $left > 0) {
        $canvas->move($heli, -$speed, $key_state{'Up'} && $top > 0 ? -$speed : ($bottom < $canvas->cget('-height') ? $speed : 0));
    } else {
        # If the Up key is not pressed, move the shape down
        # but only if it's not at the bottom of the canvas
        if ($bottom < $canvas->cget('-height')) {
            $canvas->move($heli, 0, $speed);
        }
    }
});

# ------------------------------------ Run ----------------------------------- #
MainLoop;