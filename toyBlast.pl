# files must be names 'perlblastdata.txt' and 'query.txt' for program to work
# report each string in the database that has one or more substrings matching any substring in the query that has a length at least t. 
# report the actual length of the longest matching substring.

# prompt user input for kmer size
print "Please input kmer size: ";
$k = <>;
chomp $k;
$kCopy = $k;

# prompt user input for threshold
print "Please input the threshold: ";
$threshold = <>;
chomp $threshold;

%kmer = ();                   # initializes the hash called kmer.
$i = 1;
$/= "";
$str='';

# Open output file for writing and reading
open (OUT, ">perlBlastV3Out.txt");
open INB, 'perlblastdata.txt';

# Read lines from perlblastdata.txt
while($q=<INB>){
    # remove newline, return char + concatenate
    $q =~s/\r//g;
    $q =~s/\n//g;

    $str = $str . $q;

    # generate kmers from each line
    while (length($q) >= $k) {
        $q =~ m/(.{$k})/; #extract kmer substring
        
        # store kmers in hash
        if (defined $kmer{$1}) {   
            push (@{$kmer{$1}}, $i);  #defined is a function that returns true
        } else {
            $kmer{$1} = [$i];
        }

        $i++;
        $q = substr($q, 1, length($q) -1); #slide window to the right
    }
}

# Print some initial information to the output file
print OUT "String: $str\n";
print OUT "Threshold: $threshold\n";
print OUT "Kmer Size: $k\n";

# ~~~~~~~~ VIEW HASH TBLE ~~~~~~~~
#foreach $key (sort keys(%kmer)) {
#    $pos = join(', ' , @{$kmer{$key}});
#    print OUT "string $key are in positions $pos \n";
#}

# Open query file for reading
open INQ, 'query.txt';
while($line=<INQ>){
    $line =~s/\r//g; # remove return
    $line =~s/\n//g; # remove newline char

    $sOG = $line;
    @Sstr = split(//,$sOG); #split query into array of char
    @Qstr = split(//,$str); #split database string into array of char

    # initialize hash for query kmers and soring matches
    %skmer = ();
    $n = 1;
    %stringhash = ();
    
    # output file 
    print OUT "query: $line\n";
    print OUT "\n";
    print OUT "Strings in the database that has 1+ substrings matching any substring query that is least $threshold length: \n";  

    # generate kmers fomr query line
    while (length($line) >= $kCopy){
        $line =~ m/(.{$kCopy})/;
        
        # store positions of query kmers in hash skmer
        if (defined $skmer{$1}){
        if (defined $skmer{$1}){
            push (@{$skmer{$1}}, $n);
        } elsif (!defined $skmer{$1}) {
            $skmer{$1} = [$n];
        }
    
        # check if database contains matching kmers
        if (defined $kmer{$1}){
            foreach $j (keys @{$kmer{$1}} ) {
                print OUT "$1\n";

                # calculate positions and lengths for potential matches
                $posS = $n-1;
                $posQ = $kmer{$1}[$j]-1;
                
                $leftS = $posS;
                $leftQ = $posQ;

                $maxQ = @Qstr-1;
                $maxS = @Sstr-1;
            
                $rightQ = $posQ + $kCopy - 1;
                $rightS = $posS + $kCopy - 1;
                 
                 # extend potential match leftwards
                while($leftS > 0 && $leftQ > 0){
                    if ($Qstr[$leftQ-1] ne $Sstr[$leftS-1] ){
                        last;
                    } else{
                        --$leftQ;
                        --$leftS;
                    }
                }
                
                # extend potential match rightwards
                while($rightQ < $maxQ && $rightS < $maxS){
                    if ($Qstr[$rightQ+1] ne $Sstr[$rightS+1] ){
                        last;
                    } else {
                        ++$rightQ;
                        ++$rightS;
                    }
                }
                
                $L=$rightQ - $leftQ + 1;

                # store matched substrings in stringhash if they meet threshold
                if ($L >= $threshold) {
                    $match= substr($sOG, $leftS,$L);
                    
                    if (defined $stringhash{$match}) {
                        $hashVal = $leftQ + 1;

                        foreach $threshold (keys @{$stringhash{$match}}) {
                            if ($stringhash{$match}[$threshold] != $hashVal) {
                                push (@{stringhash{$match}}, $hashVal);
                            }
                        }
                    } elsif (!defined $stringhash{$match}) {
                        $hashVal =  $leftQ + 1;
                        $stringhash{$match} = [$hashVal];
                    }
                }
            }
        }

        $line = substr($line, 1, length($line)-1);
        $n++;
    }

    # find longest string and store in file 
    my $length = 0;
    my $res;
    foreach $Skey (sort keys(%stringhash)) {
        $oc = join(', ' , @{$stringhash{$Skey}});
        if ($length < length ($Skey)){
            $res = $Skey;
            $length = length ($Skey);
        }
    }
    print OUT "\n";
    print OUT "longest string is $length letters: $res \n";
}

# close files 
close INQ;
close INB;
close OUT;

