use Tk;
use DBI;
require 'SAT_Algorithm.pl';  # Include the SAT algorithm functions

# ------------------------------ Space variables ----------------------------- #
my $block_size = 50;
my $width = 800;
my $height = 450;
my @obstacles;

# ------------------------------- Window setup ------------------------------- #
my $mw = MainWindow->new;
my $canvas = $mw->Canvas(-width => $width, -height => $height, -background => 'gray75')->pack;

# ------------------------------- Terrain setup ------------------------------ #
# Helicopter
my $image = $mw->Photo(-file => "helicopter.gif");
my $heli = $canvas->createImage(50, 275, -image => $image);

# Take-off platform
my @takeoff_coords = ((0, 300), (100, 300), (100, 350), (0, 350));
$takeoff_platform = $canvas->createPolygon(@takeoff_coords, -fill => 'green');

# Landing platform
my @landing_coords = ((700, 100), (800, 100), (800, 150), (700, 150));
$landing_platform = $canvas->createPolygon(@landing_coords, -fill => 'purple');

push @obstacles, $takeoff_platform;
push @obstacles, $landing_platform;

# --------------------------- Database integration --------------------------- #
# Database connection parameters
my $dsn = "DBI:mysql:database=helicopter_game;host=localhost";
my $username = "root";
my $password = "";

# Connect to the database
my $dbh = DBI->connect($dsn, $username, $password, { RaiseError => 1, AutoCommit => 1 });

# Prepare and execute the SQL query
my $sth = $dbh->prepare("SELECT coord_string FROM shape");
$sth->execute();

# Fetch the data and create the obstacles
while (my $row = $sth->fetchrow_hashref) {
    my $coord_string = $row->{coord_string};
    my @coords = split /-/, $coord_string;
    my @polygon_coords;
    foreach my $coord (@coords) {
        $coord =~ s/\[|\]//g;  # Remove the brackets
        my ($x, $y) = split /;/, $coord;
        push @polygon_coords, $x, $y;
    }
    # Create the obstacle on the canvas
    my $obstacle = $canvas->createPolygon(@polygon_coords, -fill => 'firebrick');
    push @obstacles, $obstacle;
}

# Disconnect from the database
$dbh->disconnect();

# -------------------------------- Movement handling ------------------------------- #
my $speed = 5;

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

    # Calculate the potential movement in each direction
    my $dx = 0;
    my $dy = 0;

    if ($key_state{'Up'} && $hy1 > 0) {
        $dy -= $speed;
    }
    if ($key_state{'Right'} && $hx2 < $canvas->cget('-width')) {
        $dx += $speed;
    }
    if ($key_state{'Left'} && $hx1 > 0) {
        $dx -= $speed;
    }
    if (!$key_state{'Up'} && $hy2 < $canvas->cget('-height')) {
        $dy += $speed;
    }

    # Check for collisions in the new position
    foreach my $item (@obstacles) {
        my @obstacle_coords = $canvas->coords($item);

        # Convert the flat lists of coordinates into a list of [x, y] pairs
        my @heli_vertices_h = ([$hx1 + $dx, $hy1], [$hx2 + $dx, $hy1], [$hx2 + $dx, $hy2], [$hx1 + $dx, $hy2]);
        my @heli_vertices_v = ([$hx1, $hy1 + $dy], [$hx2, $hy1 + $dy], [$hx2, $hy2 + $dy], [$hx1, $hy2 + $dy]);

        my @obstacle_vertices;
        for (my $i = 0; $i < $#obstacle_coords; $i += 2) {
            push @obstacle_vertices, [$obstacle_coords[$i], $obstacle_coords[$i + 1]];
        }

        # Check for collisions separately for horizontal and vertical movements
        if (check_collision(\@heli_vertices_h, \@obstacle_vertices)) {
            print("Horizontal collision detected with obstacle\n");
            # If there's a collision, don't move horizontally
            if ($dx > 0) { $dx = 0; }
            if ($dx < 0) { $dx = 0; }
        }
        if (check_collision(\@heli_vertices_v, \@obstacle_vertices)) {
            print("Vertical collision detected with obstacle\n");
            # If there's a collision, don't move vertically
            if ($dy > 0) { $dy = 0; }
            if ($dy < 0) { $dy = 0; }
        }
    }

    # Move the helicopter
    $canvas->move($heli, $dx, $dy);
});

# ------------------------------------ Run ----------------------------------- #
MainLoop;
