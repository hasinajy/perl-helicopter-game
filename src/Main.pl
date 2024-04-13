use Tk;

# Space variables
$block_size = 50;
$width = 800;
$height = 450;

# Window setup
my $mw = MainWindow->new;
my $canvas = $mw->Canvas(-width => $width, -height => $height, -background => 'gray75')->pack;

# ------------------------------- Terrain setup ------------------------------ #
# Start platform
$platform_1 = $canvas->create('rectangle', 0, 300, 100, 350, -fill => 'blue');

# End platform
$platform_2 = $canvas->create('rectangle', 700, 100, 800, 150, -fill => 'blue');

# Run
MainLoop;