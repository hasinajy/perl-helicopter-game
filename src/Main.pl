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

# -------------------------------- Key mapping ------------------------------- #
$move_step = 10;

my @obstacles = (
    $start_pl, $end_pl, $obs_1, $obs_2
);

# Move up
$mw->bind('<KeyPress-Up>', sub { 
  print("Move up!\n");

  my ($x0, $y0, $x1, $y1) = $canvas->bbox($heli);

  if ($y0 + $dy > 0) {
    $canvas->move($heli, 0, -$move_step);
  }
});

# Move left
$mw->bind('<KeyPress-Left>', sub {  
  print("Move left!\n");

  my ($x0, $y0, $x1, $y1) = $canvas->bbox($heli);

  if ($x0 - $move_step > 0) {
    $canvas->move($heli, -$move_step, 0);
  }
});

# Move right
$mw->bind('<KeyPress-Right>', sub {  
  print("Move right!\n");

  my ($x0, $y0, $x1, $y1) = $canvas->bbox($heli);
  
  if ($x0 + $move_step < $canvas->cget(-width) - $block_size) {
    $canvas->move($heli, $move_step, 0);
  }
});

# Auto move down
$mw->repeat(100 => sub {
  my ($x0, $y0, $x1, $y1) = $canvas->bbox($heli);
  
  if($y1 < $canvas->cget(-height)) {
    $canvas->move($heli, 0, 10);
  }
});

# ------------------------------------ Run ----------------------------------- #
MainLoop;