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

# ------------------------------------ Run ----------------------------------- #
MainLoop;
