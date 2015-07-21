#!/usr/bin/perl -w

# Author: T. Religa
# Licence: GPL
# Date: 2003-05-07

use Getopt::Std;

getopts('x:y:t:e:r:o:s:c:p:l:m:3adghv', \%opts);

&usage() if $opts{"h"};
$verbose = $opts{"v"} || 0;
$xlabel = $opts{"x"} || "";
$ylabel = $opts{"y"} || "";
$title = $opts{"t"} || "";
$term = $opts{"e"} || 'postscript enhanced color "Helvetica" 16';
$range = $opts{"r"} && '['.$opts{"r"}.']' || '';
$out = $opts{"o"} || "plot.ps";
$data_style = $opts{"s"} || "points";
$grid = $opts{"g"} && "set grid" || "unset grid";
$commands = $opts{"c"} || "";
$commands2 = "";
$plot_commands = $opts{"p"} || "";
$display = $opts{"d"};
$mode = $opts{"m"} || "none";
$threedplot = $opts{"3"} || 0;
@file_names = @ARGV or &usage();
# $ = $opts{""} || "";

#$labelfile = $opts{"l"} || "";
#$labelxcount = $opts{"m"} || 1;
#$x2tics="";
#if ($labelfile) {
#  open(LF, "<$labelfile") or die("$0: Can't open '$labelfile' for reading.");
#  @lf=<LF>;$lf = shift @lf; chomp $lf; $x2tics = "set x2tics 1 font \"Courier, 10\" \nset x2tics (";
#  foreach $r (split //, $lf)
#  {
#    $x2tics .= "\"$r\" $labelxcount, ";
#    $labelxcount++;
#  }
#  $x2tics=~s/, $/)/;
#}
if ($mode=~/square/) {
  $commands="set size square\nf(x)=x\n".$commands;
  $plot_commands=", f(x)".$plot_commands;
}

$commands2="pause 1000\n" if $term=~/x11/;

$files = '"'.shift @file_names;
while ($f = shift @file_names)
{$files .= '","'.$f;}
$files .= '"';

if ($data_style=~/pm3/) {
  $commands="set pm3d\n".$commands;
  $threedplot=1;
}


#if ($plot_commands) {$plot_commands=", $plot_commands"; }

if ($threedplot) {
  $plot="splot";
} else {
  $plot="plot";
}

$command = "set xlabel '$xlabel'
set ylabel '$ylabel'
set title '$title'
set style data $data_style
set out '$out'
set term $term
set timestamp 'Generated on %a %b %d %H:%M:%S %Y by $ENV{USER}'

$grid
$commands
$plot $range $files$plot_commands
$commands2
quit
";
#$x2tics

print $command if $verbose;

$gnuplot_bin = `which gnuplot 2>/dev/null || echo "/usr/bin/gnuplot"`;
#$gnuplot_bin = `echo "/usr/bin/gnuplot"`;
chomp $gnuplot_bin;

die("$0: gnuplot not available in the path.") unless (-e $gnuplot_bin);

`$gnuplot_bin <<END
$command
END`;
die("$0: gnuplot exited with an error: $?") if $?;

if ($display) {
 $ps_viewer = `which gv 2>/dev/null || which kghostview 2>/dev/null || which evince 2>/dev/null || which open 2>/dev/null`;
 chomp $ps_viewer;
 die("$0: PS viewer not found on the computer.\n") unless $ps_viewer;
 `$ps_viewer "$out"`;
}

unless ($opts{"e"})
{
  open(LOG, ">>$out") or exit(0); # Don't write error, if we can't write -it's not important
  print LOG "%\n%\n";
  foreach (split /\n/, $command)
  {
    print LOG "%$_\n";
  }
  print LOG "%\n";
  close(LOG);
}

sub usage()
  {
    print("Usage: $0 [options] <files>
The program will plot the files using gnuplot.
 -x xlabel \t\t\t\t\t(default: '')
 -y ylabel \t\t\t\t\t(default: '')
 -t title \t\t\t\t\t(default: '')
 -e terminal type \t\t\t\t(default: postscript color)
 -o output file \t\t\t\t(default: plot.ps)
 -s data style  \t\t\t\t(default: dots)
 -c extra commands \t\t\t\t(default: None)
 -p extra commands to plot \t\t\t(default: None)
 -r range (in form min:max) \t\t\t(default: Auto)
 -3 the plot will be 3D (implied by style=pm3d)\t(default: No)
 -v enable verbose output
 -h print this helpful help message
");
    exit (0);
  }


#Local Variables:
#mode: perl
#mode: font-lock
#End:
