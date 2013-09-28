#!/usr/bin/perl

# Author: T. Religa
# Licence: GPL
# Date: 2012-03-11
#
# This 'simpleR' program will execute a number of simple commands in R on the dataset.
#

=head1 NAME

r - a simplified command line R environment

=head1 SYNOPSIS

r I<[options]> I<filename>

r I<[options]> I<[command]> I<filename>

=head1 DESCRIPTION

=head2 Overview

The program is a simple wrapper to use R functions on a single text file from the command line; useful for quick data plotting or statistical analysis. The program generates and runs R script that: (a) loads up data from the file as a single data frame assuming default parameters (b) runs R functions, described by preset options or passed directly to the script. 

=head2 Normal Usage

There are two ways to use it (which can be combined): 
 (1) execute one of the preset options 
 (2) run directly a R command

r I<[options]> I<filename>

See L<OPTIONS> for details on the command line switches supported.

r I<[command]> I<filename>

It can be any command supported by R, which takes a single data frame as an argument. The script will just add the name of the data frame to it. For example, for the 'summary' command the script will execute 'C<summary(d)>'.

The I<filename> can be any file present on the file system or I<->, to denote STDIN. This way, C<r> can be used as part of the Unix pipeline. See L<EXAMPLES> for more details.   

=head1 OPTIONS

This script currently supports the following command line switches:

=over 4

=item B<-k> I<columns>

Columns that should be taken into account (using R convention). E<10> E<8>
Execute R line: C<< d <- d[,columns] >>.

=item B<-a>

Attach the dataset to the environment. E<10> E<8>
Execute R line: C<< attach(d) >>.

=item B<-r>

Force the first row to have the row names.
Execute R line in C<< read.table >>: C<< row.names=1 >>.

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

Enable verbose output (goes to STDERR (i.e. 2nd file descriptor).

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

It was produced by C<r> by generating and executing the following R code:

C<< 
d <- read.table('iris.txt'); E<10> E<8>
summary(d) >>

=item The same as above, but using three different types of Linux redirection commands (pipe, standard input, named pipe):

(1) C<< cat iris.txt | r summary - >> 	E<10> E<8>
(2) C<< r summary - < iris.txt >>	E<10> E<8>
(3) C<< r summary <(cat iris.txt) >>	E<10> E<8>

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

=item Extract the first two columns of the dataset and save it as a new file:

C<< r -k 1:2 write.table iris.txt > new.txt >>

=item Develop a script to show summary of the dataset, pass it to C<R> and execute it, while discarding the C<r> output. Tested under Bash.

C<< r -v summary iris.txt 3>&1 1>&2 2>&3 2>/dev/null | R >>

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
getopts('o:k:e:s:daplrhvc', \%opts);

&usage() if $opts{"h"};
my $verbose = $opts{"v"} || 0;
my $extra_command = $opts{"e"} || "";
my $plot_out = $opts{"o"} || "plot.pdf";
my $attach = $opts{"a"};
my $plot = $opts{"p"};
my $keys = $opts{"k"} || "";
my $sep = $opts{"s"} || "";
my $row_names = $opts{"r"}; 
my $display = $opts{"d"};

# Load up extra arguments
my $file_name = "";
my $cmd_command="";
my $argvlength=@ARGV+0;
if ($argvlength==1) {
 $file_name = $ARGV[0];
} elsif ($argvlength==2) {
 $cmd_command = $ARGV[0];
 $cmd_command = $cmd_command."(d)";
 $file_name = $ARGV[1];
} else {
 &usage();
} 
# $ = $opts{""} || "";

# Load standard libraries, if needed
#my $library_commands="library(ggplot2); library(sqldf)";
my $library_commands="";


my $row_names_command="";
$row_names_command=", row.names=1" if $row_names;

my $sep_command="";
$sep_command=", sep='$sep'" if $sep;



my $table_command="";
if ($file_name=~/^-$/) { # STDIN file
 # There seem to be problems in R with picking up input from the STDIN
 # Input seems to be 'missing'. This is the work-around.
 $table_command = "# This loads the data from STDIN
rL <- readLines(pipe('cat /dev/stdin'));
tC <- textConnection(rL);
d <- read.table(tC $sep_command $row_names_command)";
} elsif ($file_name=~/dev\/fd/) {
 # The solution for named pipes seems to be the same as for STDIN?
 $table_command = "# This loads the data from named pipe
rL <- readLines(pipe('cat $file_name'));
tC <- textConnection(rL);
d <- read.table(tC $sep_command $row_names_command)";
} else { # Standard file
 die("$0: Dataset '$file_name' does not exist.") unless (-e "$file_name");
 $table_command="d <- read.table('$file_name' $sep_command $row_names_command)";
}

my $key_command="";
if ($keys) {
 $key_command = "d <- d[,$keys]";  
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
$table_command
$key_command
$cmd_command
$attach_command
$extra_command

$plot_command
quit()
";
warn($command) if $verbose;

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
 my $pdf_viewer = `which acroread 2>/dev/null || which evince 2>/dev/null || which open 2>/dev/null`;
 chomp $pdf_viewer;
 die("$0: PDF viewer not found on the computer.\n") unless $pdf_viewer;
 `$pdf_viewer "$plot_out"`;
}

sub usage()
  {
    my $txt="";
    if (@_) {$txt = "ERROR: @_\n";} 
    die("Usage: $0 [options] <files>
The program will execute simple commands in R.
 -k columns that should be taken into account
 -a attach the dataset to the environment
 -r force the first row to contain the row names 
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

