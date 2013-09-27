#!/usr/bin/perl -w

# Author: T. Religa
# Licence: GNU Public Licence
# Date: 2004-12-28

# Extra things to be done: before splitting, apply regexp to each file
# sort out so that irs, ors work for 'strange' characters, such as \t, \n
# put so that one can modify line separator  (not \n all the time)

=head1 NAME

merge - merge files by common first column

=head1 SYNOPSIS

merge I<[options]> I<< file1 <file2> <file n> >>

=head1 DESCRIPTION

Merge the lines from each file into a single output based on the common first column. 

The program assumes that each file consists of lines arranged in a common pattern of a 'key', which is separated from the 'values' by a white space. Merge will combine lines of these multiple files under the common 'key'. In SQL database terminology, it would be equivalent to the 'JOIN' command. This program can do both FULL OUTER JOIN (i.e. include all the lines, regardless if present in all files) and INNER JOIN (i.e. include only the lines if present in all files). 

=head1 OPTIONS

The program accepts the following options:

=over 4

=item B<-k>

Print keys in front of the values.

=item B<-i> I<irs>

Input record separator (default: white space). The separator can be any perl regular expression. 

=item B<-r> I<kvs>

Separator between keys and values (default: <TAB>).

=item B<-o> I<ors>

Output separator between the values (default: <TAB>).

=item B<-e> I<value>

Include keys with no record for some files, giving it the specified I<value>. 

If this command is enabled, FULL OUTER JOIN is performed on the files. Otherwise, the program performs an INNER JOIN (i.e. combined lines only appear in the final output if key is present in all files). 

=item B<-s> I<regexp>

Apply the regexp before splitting (default: None).

=item B<-d> I<regexp>

Discard the lines starting with characters defined in this variable (default: None). 

Useful for removing comment lines. 

=item B<-f> 

Print file names on the top.

=item B<-v> 

Be verbose.

=item B<-h> 

Print out helpful help.

=back

head1 EXAMPLES

=head2 Dataset

=over 2

=item For the examples, the following two datasets will be used: 

C<< cat 1.dat 		E<10> E<8>
A 1 			E<10> E<8>
B 2 			E<10> E<8>
C 3 			E<10> E<8>
D 4 			E<10> E<8>
>>

C<< cat 2.dat 		E<10> E<8>
A 11 			E<10> E<8>
C 13 			E<10> E<8>
D 14 			E<10> E<8>
>>

=back

=head2 Examples

=over 2

=item Combine two datasets, by performing an 'INNER JOIN'. 

Only three lines will be returned and no keys printed (line with 'B' will be missing, since it is not present in the second file):

C<< merge 1.dat 2.dat >>

=item Combine two datasets, by performing a 'FULL OUTER JOIN', showing the keys and printing 'NA' for the missing key:

C<< merge -k -e "NA" 1.dat 2.dat >>

=item Combine three datasets, by performing a 'FULL OUTER JOIN', showing the keys, printing 'NA' for the missing keys and showing the file name on the top:

C<< merge -f -k -e "NA" 1.dat 2.dat 1.dat > all.dat >>
 
Then, quick statistical analysis can be performed on the datasets using C<r> command:

C<< r summary all.dat >>

=back

=head1 SEE ALSO

cut(1) paste(1) perl(1) r(1) R(1) 

=head1 AUTHOR

T. Religa

=head1 VERSION

  0.1

=cut


use Getopt::Std;

getopts('hvkfi:r:o:e:s:d:', \%opts);

&usage() if $opts{"h"};
$verbose = $opts{"v"};
$print_keys = $opts{"k"};
$irs = $opts{"i"} || '\s+'; # Input record separator
$kvs = $opts{"r"} || "\t"; # Key/values separator
$ors = $opts{"o"} || "\t"; # Output record separator
$print_filename = $opts{"f"}; # Print file names at the top
$empty = $opts{"e"}; # Treat empty keys. Either put the value of the empty or don't put them at all (default)
$regexp = $opts{"s"}; 
$discard = $opts{"d"};

&usage("You must give at least one file name for pairing up!") if (@ARGV+0)<1;


my $db = {};
my $count=0;
my @order=(); # This is order of the keys in the output

foreach $file (@ARGV)
  {
    open(INFILE, "<$file") or die("$0: Can't open '$file' for reading."); 
    while(<INFILE>)
      {
	chomp;s/^\s+//; # ([\w\d])[^\d\w]+?$/$1/;
        # Apply the regexp
        eval "s/$regexp/g" if $regexp;
        next if defined($discard) && m/^[$discard]/;
	@fields = split(/$irs/, $_, 2);
	if ((@fields+0) != 2)
	  {
	    warn("$0: Couldn't split line '$_' into 'key, value' in '$file'\n");
	    next;
	  }
	($key, $value) = @fields;

	if (exists $db{$key})
	  {
	    $refa = $db{$key};
	    &equalise($refa); # This is to make sure each array has the same number of elements, since some of the files might be missing some of the keys
	    $l = (@{$refa} + 0);
	    if ($l > $count && (@ARGV+0)>1) 
	      {
		# Different behaviour when processing only one file or many files.
		warn ("$0: Key '$key' already exists for file '$file'. Not adding value '$value'.\n");
		next;
	      }
	    push (@{$refa}, $value);
	    $db{$key} = $refa;
	  }
	else
	  {
	    my @a = ();
	    if (not $count) # Processing the first file
	      {
                push(@order, $key);
		@a = ($value);
	      }
	    else
	      {
		# Previous files did not have that key...
		# Decide what to do
		if (defined $empty) # Include the key
		  {
                    push(@order, $key);
		    &equalise(\@a);
		    push(@a, $value)
		  }
		else # Don't include the key
		  {
		    next;
		  }
	      }
	    $db{$key} = \@a;
	  }
      }
    close(INFILE);
    $count++;
  }

$"=$ors;

if ($print_filename) 
  {
    # print "Key".$kvs if $print_keys;
    print "".$kvs if $print_keys;
    print "@ARGV\n";

  }
#if($transpose && $empty && $print_filename) 
#  {
#    my $trans = ()
#    foreach $k (@ARGV) 
#      {
#        @a=();
#        $trans{$k}=\@a;
#      }
#    while (($key, $refdb) = each %db)
#      { 
#        $i=0;
#        foreach $k (@ARGV) {
#          $refa = $trans{$k};
#          
#          $i++;
#	}
#        push (@{$refa}, $value);
#        $db{$key} = $refa;
#
#
#
#        $trans
#        print "$key".$kvs if $print_keys;
#        print "@{$value}\n";
#      }
#
#  }
#
#while (($key, $value) = each %db)
foreach $key (@order)
  { 
    $value = $db{$key};
    &equalise($value);
    if (!defined $empty)
      {
	# If the last file did not have the element, don't print it.
	next if ((@{$value}+0)<$count);
      }
    print "$key".$kvs if $print_keys;
    print "@{$value}\n";
  }

sub equalise()
  {
    # For the given array, equalise the number of elements, if $defined empty
    local $refa = $_[0];
    if (defined $empty)
      {
	$l = (@{$refa} + 0);
	foreach ($l..($count-1)) 
	  {
	    push (@{$refa}, $empty);
	  }
	
      }
  }

sub log()
  {
    warn("$0: @_ \n") if $verbose;
  }

sub usage()
  {
    die("Usage: $0 [options] <files>
@_
 -k \t print keys at the front of the values
 -i \t input record separator \t\t\t\t (default: \\t)
 -r \t if keys are printed, separator between them and keys \t (default: \\t)
 -o \t output separator between the values \t\t\t (default: \\t)
 -e \t include keys with no record for some files.
 -s \t apply the regexp before splitting \t\t\t (default: None)
 -d \t discard the lines starting with characters defined in this variable (default: None)
 -f \t Print file names on the top 
 -v \t be verbose
 -h \t print out this helpful help
    \t for full help, type: perldoc $0
");
  }


#Local Variables:
#mode: perl
#mode: font-lock
#End:
