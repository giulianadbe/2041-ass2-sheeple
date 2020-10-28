#!/usr/bin/perl
# COMP2041 Assignment 2 - Sheeple
# Giuliana De Bellis z5309331
# 
# Shell --> Perl compiler
# Takes shell scripts (or stdin) as input and outputs Perl
# Implemented for a subset of Shell

use strict;
use warnings;

while (my $line = <>) {
    # handle #! line
    $line =~ s/^#!.*/#!\/usr\/bin\/perl -w/;

    # replace $1..$9 with $ARGV[0]..$ARGV[9]
    if ($line !~ /'[^']*\$/) {
        $line =~ s/(?<!')\$1/\$ARGV[0]/;
        $line =~ s/(?<!')\$2/\$ARGV[1]/;
        $line =~ s/(?<!')\$3/\$ARGV[2]/;
        $line =~ s/(?<!')\$4/\$ARGV[3]/;
        $line =~ s/(?<!')\$5/\$ARGV[4]/;
        $line =~ s/(?<!')\$6/\$ARGV[5]/;
        $line =~ s/(?<!')\$7/\$ARGV[6]/;
        $line =~ s/(?<!')\$8/\$ARGV[7]/;
        $line =~ s/(?<!')\$9/\$ARGV[8]/;
        $line =~ s/(?<!')\$#/\$#ARGV+1/;
        $line =~ s/(?<!')\$@/\@ARGV/;
        $line =~ s/(?<!') \$\*/ \@ARGV/;
    }

    # variables which don't need single quotes
    $line =~ s/(\s*)(\w+)=([0-9]+|@.+|\$.+|\`.+)\n/$1\$$2 = $3;\n/;

    # $* --> join(' ', @ARGV) behaviour in perl 
    $line =~ s/(?<!')\$\*/join\(\' \', \@ARGV\)/;
    
    ### handle double quotes ###
    if ($line =~ /'(.*)"(.*)"(.*)'/) { 
        # single quotes with double quotes inside --> escape
        $line =~ s/'(.*)"(.*)"(.*)'/$1\\"$2\\"$3/;
    } elsif ($line =~ /(\s*)print "([^"]*)"/) { 
        # print with quotes already
    } elsif ($line =~ /(.*)join\(' ', \@ARGV\)(.*)/) {
        $line =~ s/"//g;
    } elsif ($line =~ /[^"]*"[^"]*'[^"]*'[^"]*"[^"]*/) { 
        # if double quotes around single quotes, keep
    } elsif ($line =~ /(\s*)for [^"]*"[^"]*"[^"]*/) {
        # maintain double quotes in for loop, handled later on
    } else {
        # remove ""
        $line =~ s/"//g;
    }
    
    ### handle single quotes ###
    if ($line =~ /\(\'\w+\'\)/) {
        # if in a for loop, keep ''
    } elsif ($line =~ /^[^']*'[^']*$/) {
        # if apostrophes used in a string, keep ''
    } elsif ($line =~ /(.*)join\(' ', \@ARGV\)(.*)/) { 
        # keep quotes for join
    } elsif ($line =~ /[^"]*"[^"]*'[^"]*'[^"]*"[^"]*/) { 
        # single quotes in double quotes
        if ($line =~ /(\s*)for (\w+) in "([^\$\@]*)"/) { 
            # if in a for loop, keep ""
        } else {
            $line =~ s/"//g;
        }
    } elsif ($line =~ /(\s*)for (.+?(?=in))in (.*)/) { 
        # single quotes in for loop, handle later
    } else {
        $line =~ s/'//g;
    }

    # variables which need single quotes
    $line =~ s/(\s*)(\w+)=([^\@0-9\$]+)\n/$1\$$2 = '$3';\n/;

    # handle single line comments
    $line =~ s/(\s*)#(.*)/$1#$2/;

    # echo --> print
    if ($line =~ /(\s*)echo -n (.*)/) {
        # echo -n option
        $line =~ s/(\s*)echo -n (.*)/$1print "$2";/;
        # escape $ characters
        $line =~ s/(.*)\$([0-9#@].*)/$1\\\$$2/g;
        # dont include comments in print
        $line =~ s/(.*)#(.*)";/$1";#$2/;
    } elsif ($line =~ /(\s*)echo (.*)/) {
        # ordinary echo
        $line =~ s/(\s*)echo (.*)/$1print "$2\\n";/;
        # escape $ characters
        $line =~ s/(.*)\$([0-9#@].*)/$1\\\$$2/g;
        # dont include comments in print
        $line =~ s/(.*)#(.*)\\n";/$1\\n";#$2/;
    }

    # system calls
    $line =~ s/(\s*)([^\$\(]?ls .*|ls$)/$1system "$2";/;
    $line =~ s/(\s*)([^\$\(]?pwd .*|pwd$)/$1system "$2";/;
    $line =~ s/(\s*)([^\$\(]?id .*|id$)/$1system "$2";/;
    $line =~ s/(\s*)([^\$\(]?date .*|date$)/$1system "$2";/;
    $line =~ s/(\s*)([^\$\(]?rm .*)/$1system "$2";/;
    $line =~ s/(\s*)([^\$\(]?date .*|date$)/$1system "$2";/;

    # cd --> chdir
    $line =~ s?(\s*)cd (.*)?$1chdir '$2';?;

    # for loops --> foreach 
    if ($line =~/(\s*)for (.+?(?=in))in (.*[\[\]\?\*]+.*)/) {
        # handle files and glob, use of *, ?, []
        # also handle "" inside glob, remove if already there dont add another pair
        if ($line !~ /"/) {
            $line =~ s/(\s*)for (.+?(?=in))in (.*[\[\]\?\*]+.*)/$1foreach \$$2(glob(\"$3\")) {/;
        } else {
            $line =~ s/(\s*)for (.+?(?=in))in (.*[\[\]\?\*]+.*)/$1foreach \$$2(glob($3)) {/;
        }
    } elsif ($line =~ /(\s*)for (.+?(?=in))in (join\(.*)/) {
        # handle join case
        $line =~ s/(\s*)for (.+?(?=in))in (join\(.*)/$1foreach \$$2($3) {/;
    } elsif ($line =~ /(\s*)for (.+?(?=in))in (.*)/) {
        # list of variables/words in for
        if ($line =~ /"[^\@\$]+"/) { 
            # with double quotes --> one single variable
            $line =~ s/"//g;
            $line =~ s/(\s*)for (.+?(?=in))in (.*)/$1foreach \$$2("$3") {/;
        } elsif ($line =~ /'/) { 
            # with single quotes, ensure single quotes together, others separate at \s
            # use ~ as a temporary substitute for \s between single quotes
            $line =~ s/'(\w*)(\s)+(\w*)'/$1~$3/g;
            $line =~ /(\s*)for (.+?(?=in))in (.*)/;
            my @list = split / /, $3;
            my @args;
            foreach my $arg (@list) {
                # create an args array, with '' around non-digits/special variables
                if ($arg =~ /[\d|^\@|^\$\#]/) {
                    push @args, $arg;
                } elsif ($arg =~ /~/){
                    $arg =~ s/~/ /g;
                    $arg = "'$arg'";
                    push @args, $arg;
                } else {
                    $arg = "'$arg'";
                    push @args, $arg;
                }
            }
            @list = join(', ', @args);
            $line =~ s/(\s*)for (.+?(?=in))in (.*)/$1foreach \$$2(@list) {/;
        } else { 
            # if no quotes in for loop values, split at every whitespace
            $line =~ s/"//g;
            $line =~ /(\s*)for (.+?(?=in))in (.*)/;
            my @list = split / /, $3;
            my @args;
            foreach my $arg (@list) {
                # create an args array, with '' around non-digits/special variables
                if ($arg =~ /[\d|^\@|^\$\#]/) { 
                    push @args, $arg;
                } else {
                    $arg = "'$arg'";
                    push @args, $arg;
                }
            }
            @list = join(', ', @args);
            $line =~ s/(\s*)for (.+?(?=in))in (.*)/$1foreach \$$2(@list) {/;
        }
    }

    # do -> ''
    if ($line =~ /(\s*)do(\s*)$/) {
        chomp $line;
        $line = '';
    }

    # done --> }
    $line =~ s/(\s*)done/$1}/;

    # exit --> just add ;
    $line =~ s/(\s*)exit 0$/$1exit 0;/;
    $line =~ s/(\s*)exit 1$/$1exit 1;/;

    # read
    if ($line =~ /(\s*)#(\s*)while read (.*)/) {
        $line =~ s/(\s*)#(\s*)(while )read (.*)/$1#$2$3\(\$$4 = <STDIN>\) {\n#    $1$2chomp \$$4;/;
    } elsif ($line =~ /(\s*)[^#]?(\s*)while read (.*)/) {
        $line =~ s/(\s*)(while )read (.*)/$1$2\(\$$3 = <STDIN>\) {\n    $1chomp \$$3;/;
    } elsif ($line =~ /(\s*)read (.*)/) {
        $line =~ s/(\s*)read (.*)/$1\$$2 = <STDIN>;\n$1chomp \$$2;/;
    }


    # if test or [] -->  if () and similarly for elif
    if ($line =~ /^(\s*)(if|while) (test|\[)/) {
        # ( x )     x
        $line =~ s/(\s*)(if|while) (?:test|\[) \( (.*) \) ?\]?/$1$2 \($3\) {/;
        # -n x      length x
        $line =~ s/(\s*)(if|while) (?:test|\[) -n (.*) ?\]?/$1$2 \(length $3\) {/;
        # -z x      x eq ""
        $line =~ s/(\s*)(if|while) (?:test|\[) -z (.*) ?\]?/$1$2 \($3 eq \"\"\) {/;
        # x = y     eq
        $line =~ s/(\s*)(if|while) (?:test|\[) ([^\$]\S+) = ([^\$]\S+) ?\]?/$1$2 \(\'$3\' eq \'$4\'\) {/;
        # x != y    ne
        $line =~ s/(\s*)(if|while) (?:test|\[) ([^\$]\S+) != ([^\$]\S+) ?\]?/$1$2 \(\'$3\' ne \'$4\'\) {/;
        # $x = 'y'     eq
        $line =~ s/(\s*)(if|while) (?:test|\[) (\$\S+) = ([^\$]\S+) ?\]?/$1$2 \($3 eq \'$4\'\) {/;
        # $x != 'y'    ne
        $line =~ s/(\s*)(if|while) (?:test|\[) (\$\S+) != ([^\$]\S+) ?\]?/$1$2 \($3 ne \'$4\'\) {/;
        # 'x' = $y     eq
        $line =~ s/(\s*)(if|while) (?:test|\[) ([^\$]\S+) = (\$\S+) ?\]?/$1$2 \(\'$3\' eq $4\) {/;
        # 'x' != $y    ne
        $line =~ s/(\s*)(if|while) (?:test|\[) ([^\$]\S+) != (\$\S+) ?\]?/$1$2 \(\'$3\' ne $4\) {/;
        # $x = $y     eq
        $line =~ s/(\s*)(if|while) (?:test|\[) (\$\S+) = (\$\S+) ?\]?/$1$2 \($3 eq $4\) {/;
        # $x != $y    ne
        $line =~ s/(\s*)(if|while) (?:test|\[) (\$\S+) != (\$\S+) ?\]?/$1$2 \($3 ne $4\) {/;
        # 1 -eq 2   ==
        $line =~ s/(\s*)(if|while) (?:test|\[) (\S+) -eq (\S+) ?\]?/$1$2 \($3 == $4\) {/;
        # 1 -ge 2   >=
        $line =~ s/(\s*)(if|while) (?:test|\[) (\S+) -ge (\S+) ?\]?/$1$2 \($3 >= $4\) {/;
        # 1 -gt 2   >
        $line =~ s/(\s*)(if|while) (?:test|\[) (\S+) -gt (\S+) ?\]?/$1$2 \($3 > $4\) {/;   
        # 1 -le 2   <=
        $line =~ s/(\s*)(if|while) (?:test|\[) (\S+) -le (\S+) ?\]?/$1$2 \($3 <= $4\) {/;
        # 1 -lt 2   <
        $line =~ s/(\s*)(if|while) (?:test|\[) (\S+) -lt (\S+) ?\]?/$1$2 \($3 < $4\) {/;
        # 1 -ne 2   !=
        $line =~ s/(\s*)(if|while) (?:test|\[) (\S+) -ne (\S+) ?\]?/$1$2 \($3 != $4\) {/;
        # file tests
        $line =~ s/(\s*)(if|while) (?:test|\[) (-\S) (\S+) ?\]?/$1$2 \($3 '$4'\) {/;
    } elsif ($line =~ /(\s*)elif (?:test|\[)/) {
        # ( x )     x
        $line =~ s/(\s*)elif (?:test|\[) \( (.*) \) ?\]?/$1} elsif \($2\) {/;
        # -n x      length x
        $line =~ s/(\s*)elif (?:test|\[) -n (.*) ?\]?/$1} elsif \(length $2\) {/;
        # -z x      x eq ""
        $line =~ s/(\s*)elif (?:test|\[) -z (.*) ?\]?/$1} elsif \($2 eq \"\"\) {/;
        # x = y     eq
        $line =~ s/(\s*)elif (?:test|\[) ([^\$]\S+) = ([^\$]\S+) ?\]?/$1} elsif \(\'$2\' eq \'$3\'\) {/;
        # x != y    ne
        $line =~ s/(\s*)elif (?:test|\[) ([^\$]\S+) != ([^\$]\S+) ?\]?/$1} elsif \(\'$2\' ne \'$3\'\) {/;
        # $x = y     eq
        $line =~ s/(\s*)elif (?:test|\[) (\$\S+) = ([^\$]\S+) ?\]?/$1} elsif \($2 eq \'$3\'\) {/;
        # $x != y    ne
        $line =~ s/(\s*)elif (?:test|\[) (\$\S+) != ([^\$]\S+) ?\]?/$1} elsif \($2 ne \'$3\'\) {/;
        # x = $y     eq
        $line =~ s/(\s*)elif (?:test|\[) ([^\$]\S+) = (\$\S+) ?\]?/$1} elsif \(\'$2\' eq $3\) {/;
        # x != $y    ne
        $line =~ s/(\s*)elif (?:test|\[) ([^\$]\S+) != (\$\S+) ?\]?/$1} elsif \(\'$2\' ne $3\) {/;
        # $x = $y     eq
        $line =~ s/(\s*)elif (?:test|\[) (\$\S+) = (\$\S+) ?\]?/$1} elsif \($2 eq $3\) {/;
        # $x != $y    ne
        $line =~ s/(\s*)elif (?:test|\[) (\$\S+) != (\$\S+) ?\]?/$1} elsif \($2 ne $3\) {/;
        # 1 -eq 2   ==
        $line =~ s/(\s*)elif (?:test|\[) (\S+) -eq (\S+) ?\]?/$1} elsif \($2 == $3\) {/;
        # 1 -ge 2   >=
        $line =~ s/(\s*)elif (?:test|\[) (\S+) -ge (\S+) ?\]?/$1} elsif \($2 >= $3\) {/;
        # 1 -gt 2   >
        $line =~ s/(\s*)elif (?:test|\[) (\S+) -gt (\S+) ?\]?/$1} elsif \($2 > $3\) {/;   
        # 1 -le 2   <=
        $line =~ s/(\s*)elif (?:test|\[) (\S+) -le (\S+) ?\]?/$1} elsif \($2 <= $3\) {/;
        # 1 -lt 2   <
        $line =~ s/(\s*)elif (?:test|\[) (\S+) -lt (\S+) ?\]?/$1} elsif \($2 < $3\) {/;
        # 1 -ne 2   !=
        $line =~ s/(\s*)elif (?:test|\[) (\S+) -ne (\S+) ?\]?/$1} elsif \($2 != $3\) {/;
        # file tests
        $line =~ s/(\s*)elif (?:test|\[) (-\S+) (\S+) ?\]?/$1} elsif \($2 '$3'\) {/;
    }

    # else --> else {
    $line =~ s/(\s*)else$/$1} else {/;

    # then --> ''
    if ($line =~ /(\s*)then$/) {
        chomp $line;
        $line = $1;
    }

    # fi --> }
    $line =~ s/(\s*)fi$/$1}/;

    # expr
    if ($line =~ /^(\s*)`expr (.*)`/) {
        # at the beginning of a line, add ;
        $line =~ s/^(\s*)`expr (.*)`/$1$2;/;     
    } else {
        # stored in a variable, no need to add ;
        $line =~ s/(\s*)`expr (.*)`/$1$2/;
    }
    # '*' --> *
    $line =~ s/'\*'/\*/g;

    # $(()) arithmetic and $()
    # $() --> backticks
    # $(()) --> math that perl can handle
    $line =~ s/(\s*)\$\(([^\(].*)\)/$1`$2`/;
    if ($line =~ /(\s*)\$\(\((.*)\)\)/) {
        $line =~ s/(\s*)\$\(\((.*)\)\)/$1$2/;
        $line =~ s/\s([A-Za-z_]+)\s/ \$$1 /g;
        $line =~ s/^(\s*)\$(\$.*)/$1$2/;
    }

    # check ; in right spot if an inline comment present
    $line =~ s/(.*)#(.*);/$1;#$2/;

    print $line;
}