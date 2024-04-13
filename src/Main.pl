use Tk;

# Space variables
$block_size = 50;
$width = 800;
$height = 450;

# Window setup
my $mw = MainWindow->new;
my $canvas = $mw->Canvas(-width => $width, -height => $height, -background => 'gray75')->pack;

# Run
MainLoop;