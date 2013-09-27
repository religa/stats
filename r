#!/usr/bin/perl

# Author: T. Religa
# Licence: GPL
# Date: 2012-03-11
#
# This program will execute a number of simple commands in R on the dataset.
#

=head1 NAME

r - a simplified command line R environment

=head1 SYNOPSIS

r [options] filename

r [options] [command] filename

=head1 DESCRIPTION

=head2 Overview

The program is a simple wrapper to use R functions on a single text file from the command line; useful for quick data plotting or statistical analysis. The program generates and runs R script that: (a) loads up data from the file as a single data frame assuming default parameters (b) runs R functions, described by preset options or passed directly to the script. 

=head2 Normal Usage

There are two ways to use it (which can be combined): 
 (1) execute one of the preset options 
 (2) run directly a R command

  $ r [options] filename
See L<"OPTIONS"> for details on the command line switches supported.

  $ r [command] filename

It can be any command supported by R, which takes a single data frame as an argument. The script will just add the name of the data frame to it. For example, for the 'summary' command the script will execute 'summary(d)'.

=head1 OPTIONS

This script currently supports the following command line switches:

=over 4

=item B<-k> I<columns>

Columns that should be taken into account (using R convention). E<10> E<8>
Execute R line: C<< d <- d[,columns] >>.

=item B<-a>

Attach the dataset to the environment. E<10> E<8>
Execute R line: C<< attach(d) >>.

=item B<-e> I<command>

Execute the specified R command after loading the dataset.

=item B<-s> I<separator>

Input record separator (default: white space)

=item B<-p>

Plot the dataset and save it as a pdf file. E<10> E<8>
Execute R line: C<< pdf('plot.pdf'); plot(d); dev.off() >>.

=item B<-o> I<file>

Output file name for the plotted PDF file (default: plot.pdf).

=item B<-d>

Display plotted dataset (using acroread or evince).

=item B<-v>

Enable verbose output

=item B<-h>

Print this helpful help message

=back

=head1 EXAMPLES

=head2 Dataset

=over 2

=item All the examples use the famous iris dataset generated from R using:

C<< write.table(iris, "iris.txt") >>

C<< 
tomek@localhost:~$ head -n3 iris.txt 	E<10> E<8>
"Sepal.Length" "Sepal.Width" "Petal.Length" "Petal.Width" "Species" E<10> E<8>
"1" 5.1 3.5 1.4 0.2 "setosa" 		E<10> E<8>
"2" 4.9 3 1.4 0.2 "setosa" 		E<10> E<8>
"3" 4.7 3.2 1.3 0.2 "setosa" 		E<10> E<8>
>>

=back

=head2 Examples

=over 2

=item Simple summary of the dataset: E<10> E<8>

C<< r summary iris.txt >>

It was produced by C<r> by generating and executing the following R code: E<10> E<8>
C<< 
d <- read.table('iris.txt') E<10> E<8>
summary(d) >>


=item Summary of the first two columns of the dataset, while showing the executed R script:

C<< r -v -k 1:2 summary iris.txt >>

=item Compute correlation coefficient between 1,3 and 4th column of the dataset:

C<< r -k 'c(1,3,4)' cor iris.txt >>

=item Plot and display the entire data as well as only first two columns:

C<< r -dp iris.txt E<10> E<8>
r -dp -k 1:2 iris.txt >>

=item Find the line of best fit between Sepal.Length and Petal.Length:

C<< r -ae 'lm(Sepal.Length ~ Petal.Length)' iris.txt E<10> E<8>
r -e 'attach(d); lm(Sepal.Length ~ Petal.Length)' iris.txt >>

=item Execute a t-test between the two datasets:

C<< r -ae 't.test(Sepal.Length, Petal.Length)' iris.txt >>

=back

=head1 SEE ALSO

gnuplot(1) perl(1) R(1)

=head1 AUTHOR

T. Religa

=head1 VERSION

  0.1

=cut

use strict;
use warnings;
use Getopt::Std;

my %opts;
getopts('o:k:e:s:daplhvc', \%opts);

&usage() if $opts{"h"};
my $verbose = $opts{"v"} || 0;
my $extra_command = $opts{"e"} || "";
my $plot_out = $opts{"o"} || "plot.pdf";
my $attach = $opts{"a"};
my $plot = $opts{"p"};
my $keys = $opts{"k"} || "";
my $sep = $opts{"s"} || "";
#my $row_names = $opts{"r"} || "NULL"; 
my $display = $opts{"d"};

# Load up extra arguments
my $file_name = "";
my $cmd="";
my $argvlength=@ARGV+0;
if ($argvlength==1) {
 $file_name = $ARGV[0];
} elsif ($argvlength==2) {
 $cmd = $ARGV[0];
 $cmd = $cmd."(d)";
 $file_name = $ARGV[1];
} else {
 &usage();
} 
# $ = $opts{""} || "";

# Load standard libraries, if needed
#my $library_commands="library(ggplot2); library(sqldf)";
my $library_commands="";


die("$0: Dataset '$file_name' does not exist.") unless (-e "$file_name");


if ($keys) {
 $keys = "d <- d[,$keys]";  
}

my $plot_command="";
if ($plot) {
$plot_command="pdf('$plot_out')
plot(d)
dev.off()
";
}

my $attach_command="";
$attach_command="attach(d)" if $attach;

my $command=""; 
$command = $command."
$library_commands
d <- read.table('$file_name', sep='$sep')
$keys
$cmd
$attach_command
$extra_command

$plot_command
";
print $command if $verbose;

my $Rscript=`which Rscript`; chomp $Rscript;
die("$0: Could not find R") unless (length($Rscript));


my $script_name = "/tmp/$$.rtmp";
open(my $SH, ">$script_name") or die ("$0: Cannot open '$script_name' for writing");
print $SH "$command";
close($SH);

# Execute the script in R.
my $Rscript_output=system("$Rscript --no-save --no-restore $script_name");
print("$Rscript_output");
die("$0: $Rscript exited with an error: $?") if $?;

unlink($script_name);

# Show the plot, if wanted
if ($display && $plot) {
 my $pdf_viewer = `which acroread 2>/dev/null || which evince 2>/dev/null`;
 chomp $pdf_viewer;
 die("$0: PDF viewer not found on the computer.\n") unless $pdf_viewer;
 `$pdf_viewer "$plot_out"`;
}

sub usage()
  {
    my $txt="";
    if (@_) {$txt = "ERROR: @_\n";} 
    die("Usage: $0 [options] <files>
The program will execute simple commands R.
 -k columns that should be taken into account
 -a attach the dataset to the environment
 -e execute the specified R command after loading the dataset
 -s input record separator (default: white space)
 -p plot the dataset and save it as a pdf file
 -o output file name for the plotted PDF file (default: plot.pdf)
 -d display plotted dataset (using acroread or evince)
 -v enable verbose output
 -h print this helpful help message
    for full help, type: perldoc $0 
$txt");
  }


#Local Variables:
#mode: perl
#mode: font-lock
#End:

