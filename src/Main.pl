use Tk;
use DBI;
require 'SAT_Algorithm.pl';

# ------------------------------ Game variables ------------------------------ #
my $score = 0;

# Add a boolean variable to track if the game is won
my $game_won = 0;

# Add a boolean variable to track if the message box has been shown
my $message_shown = 0;

# Add a variable to track the bomb
my $bomb;

# Add a variable to track the bombs
my @bombs;

# Add a variable to track the tanks and their scores
my @tanks;

# ------------------------------ Space variables ----------------------------- #
my $heli_height = 25;
my $block_size = 50;
my $width = 800;
my $height = 800;
my @obstacles;

# ------------------------------- Window setup ------------------------------- #
my $mw = MainWindow->new;
my $canvas = $mw->Canvas(-width => $width, -height => $height, -background => 'white')->pack;

# Score display - Bottom right
my $score_text = $canvas->createText(750, 750, -text => "Score: $score", -fill => 'black');

# ------------------------------- Terrain setup ------------------------------ #
# Helicopter
my $image = $mw->Photo(-file => "helicopter.gif");
my $heli = $canvas->createImage(50, 575, -image => $image);

# Take-off platform
my @takeoff_coords = ((0, 600), (100, 600), (100, 650), (0, 650));
$takeoff_platform = $canvas->createPolygon(@takeoff_coords, -fill => 'skyblue');

# Landing platform
my @landing_coords = ((700, 100), (800, 100), (800, 150), (700, 150));
$landing_platform = $canvas->createPolygon(@landing_coords, -fill => 'skyblue');

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

# Prepare and execute the SQL query for tanks
my $sth_tanks = $dbh->prepare("SELECT coord_string, score FROM tank");
$sth_tanks->execute();

# Fetch the data and create the tanks
while (my $row = $sth_tanks->fetchrow_hashref) {
    my $coord_string = $row->{coord_string};
    my $score = $row->{score};
    my @coords = split /-/, $coord_string;
    my @polygon_coords;
    foreach my $coord (@coords) {
        $coord =~ s/\[|\]//g;  # Remove the brackets
        my ($x, $y) = split /;/, $coord;
        push @polygon_coords, $x, $y;
    }
    # Create the tank on the canvas
    my $tank = $canvas->createPolygon(@polygon_coords, -fill => 'black');
    # Display the score inside the tank
    my $score_text = $canvas->createText($polygon_coords[0] + 25, $polygon_coords[1] + 10, -text => $score, -fill => 'white');
    # Store the tank and its score text in a hash
    push @tanks, { tank => $tank, score_text => $score_text, direction => 1 };
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
    'Space' => 0,  # Add a state for the Space key
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

# Add a hash to keep track of passed obstacles
my %passed_obstacles;

# Drop bomb
$mw->bind('<KeyPress-space>', sub {
    # Create a bomb
    my ($hx1, $hy1, $hx2, $hy2) = $canvas->bbox($heli);
    my $bomb = $canvas->createRectangle($hx1 + 25, $hy2, $hx1 + 35, $hy2 + 10, -fill => 'black');
    push @bombs, $bomb;
});

# Move the rectangle based on the state of the keys
my $repeat_id = $mw->repeat(60, sub {
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

    # Move the bombs
    foreach my $bomb (@bombs) {
        $canvas->move($bomb, 0, $speed);
        my ($bx1, $by1, $bx2, $by2) = $canvas->bbox($bomb);

        # Check for collisions with the obstacles
        foreach my $item (@obstacles) {
            my @obstacle_coords = $canvas->coords($item);
            my @bomb_vertices = ([$bx1, $by1], [$bx2, $by1], [$bx2, $by2], [$bx1, $by2]);
            my @obstacle_vertices;
            for (my $i = 0; $i < $#obstacle_coords; $i += 2) {
                push @obstacle_vertices, [$obstacle_coords[$i], $obstacle_coords[$i + 1]];
            }
            if (check_collision(\@bomb_vertices, \@obstacle_vertices)) {
                # If there's a collision, delete the bomb
                $canvas->delete($bomb);
                @bombs = grep { $_ != $bomb } @bombs;
            }
        }

        # Check for collisions with the sides of the frame
        if ($by2 > $canvas->cget('-height')) {
            $canvas->delete($bomb);
            @bombs = grep { $_ != $bomb } @bombs;
        }

        # Check for collisions with other bombs
        foreach my $other_bomb (@bombs) {
            next if $bomb == $other_bomb;  # Skip self
            my ($obx1, $oby1, $obx2, $oby2) = $canvas->bbox($other_bomb);
            my @bomb_vertices = ([$bx1, $by1], [$bx2, $by1], [$bx2, $by2], [$bx1, $by2]);
            my @other_bomb_vertices = ([$obx1, $oby1], [$obx2, $oby1], [$obx2, $oby2], [$obx1, $oby2]);
            if (check_collision(\@bomb_vertices, \@other_bomb_vertices)) {
                # If there's a collision, delete both bombs
                $canvas->delete($bomb);
                $canvas->delete($other_bomb);
                @bombs = grep { $_ != $bomb && $_ != $other_bomb } @bombs;
            }
        }
    }
    
    # Move the tanks
    foreach my $tank (@tanks) {
        my $dx = $speed * $tank->{direction};
        my ($tx1, $ty1, $tx2, $ty2) = $canvas->bbox($tank->{tank});

        # Check for collisions with the sides of the frame
        if ($tx1 + $dx < 0 || $tx2 + $dx > $canvas->cget('-width')) {
            # If there's a collision, reverse the direction
            $tank->{direction} *= -1;
            $dx *= -1;
        }

            # Check for collisions with the obstacles
        foreach my $item (@obstacles) {
            my @obstacle_coords = $canvas->coords($item);
            my @tank_vertices = ([$tx1 + $dx, $ty1], [$tx2 + $dx, $ty1], [$tx2 + $dx, $ty2], [$tx1 + $dx, $ty2]);
            my @obstacle_vertices;
            for (my $i = 0; $i < $#obstacle_coords; $i += 2) {
                push @obstacle_vertices, [$obstacle_coords[$i], $obstacle_coords[$i + 1]];
            }
            if (check_collision(\@tank_vertices, \@obstacle_vertices)) {
                # If there's a collision, reverse the direction
                $tank->{direction} *= -1;
                $dx *= -1;
                last;
            }
        }

        # Move the tank and its score text
        $canvas->move($tank->{tank}, $dx, 0);
        $canvas->move($tank->{score_text}, $dx, 0);
    }

    # Check for collisions in the new position
    foreach my $item (@obstacles) {
        my @obstacle_coords = $canvas->coords($item);

        my @heli_vertices_h = ([$hx1 + $dx, $hy1], [$hx2 + $dx, $hy1], [$hx2 + $dx, $hy2], [$hx1 + $dx, $hy2]);
        my @heli_vertices_v = ([$hx1, $hy1 + $dy], [$hx2, $hy1 + $dy], [$hx2, $hy2 + $dy], [$hx1, $hy2 + $dy]);

        my @obstacle_vertices;
        for (my $i = 0; $i < $#obstacle_coords; $i += 2) {
            push @obstacle_vertices, [$obstacle_coords[$i], $obstacle_coords[$i + 1]];
        }

        # Check for collisions separately for horizontal and vertical movements
        if (check_collision(\@heli_vertices_h, \@obstacle_vertices)) {
            # If there's a collision, don't move horizontally
            if ($dx > 0) { $dx = 0; }
            if ($dx < 0) { $dx = 0; }
        }
        if (check_collision(\@heli_vertices_v, \@obstacle_vertices)) {
            # If there's a collision, don't move vertically
            if ($dy > 0) { $dy = 0; }
            if ($dy < 0) { $dy = 0; }
        }
    }

    # Move the helicopter
    $canvas->move($heli, $dx, $dy);

    # Score tracker - Increment on passed obstacles
    foreach my $item (@obstacles) {
        # Skip the platforms
        next if $item == $takeoff_platform || $item == $landing_platform;

        my @obstacle_coords = $canvas->coords($item);
        my ($ox1, $oy1, $ox2, $oy2) = @obstacle_coords[0..3];  # Get the top left corner of the obstacle

        # Pass check: checks for the left side of the helicopter
        if ($hx1 > $ox2 && !$passed_obstacles{$item}) {
            # Mark the obstacle as passed
            $passed_obstacles{$item} = 1;

            # Increment score based on gap size
            if ($oy1 <= 3 * $heli_height) {
                $score += 4;
            } else {
                $score += 2;
            }

            $canvas->itemconfigure($score_text, -text => "Score: $score");
        }
    }

    # Check if the helicopter is within the landing platform
    if ($hx1 >= 700 && $hx2 <= 800 && ($hy2 + 2) == 100) {
        $game_won = 1;
        $mw->afterCancel($repeat_id);  # Stop the animation
    }

    # Winning screen
    if ($game_won && !$message_shown) {
        $message_shown = 1;  # Set the message box as shown
        my $response = $mw->messageBox(-message => "You won. Play again?", -type => "YesNo", -icon => "question");
        if ($response eq 'Yes') {
            exec($^X, $0);  # Replay
        } else {
            exit;  # Stop the entire program
        }
    }
});

# ------------------------------------ Run ----------------------------------- #
MainLoop;
