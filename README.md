Tools that speed up statistical analysis using Linux command line. 
==================================================================

`merge` - merge files by common first column
------------------------------------------

The program assumes that each file consists of lines arranged in a common pattern of a 'key', which is separated from the 'values' by a white space. Merge will combine lines of these multiple files under the common 'key'. In SQL database terminology, it would be equivalent to the 'JOIN' command. This program can do both FULL OUTER JOIN (i.e. include all the lines, regardless if present in all files) and INNER JOIN (i.e. include only the lines if present in all files).

`pairs` - merge two files by common first column and perform an operation on them
------------------------------------------

Merge the lines from each file into a single output based on the common first column. The program assumes that each file consists of lines arranged in a common pattern of a 'key', which is separated from the 'value' by a white space. Pairs will combine lines of these two files under the common 'key' and then perform an operation on the two values.

`plot` - plot the files using gnuplot
------------------------------------------

Generate `gnuplot` input file and pass it to the graphics program to generate plot in postscript that can be opened in one of the graphics viewers. Perfect for fast data visualization on the command line. 

`r` - a simplified command line R environment
-------------------------------------------

The program is a simple wrapper to use R functions on a single text file from the command line. The program generates and runs R script that: (a) loads up data from the file as a single data frame assuming default parameters (b) runs R functions, described by preset options or passed directly to the script. 

