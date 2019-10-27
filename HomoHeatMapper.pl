#!/usr/bin/perl

#written by Bernhard Misof, ZFMK, Bonn
#version of 17th May 2013
#usage: script -i *.csv -[t|f]
#-t just the triangle
#-f full map
# you can specify both options -ft, input order of options does not matter
#Modified by LS Jermiin, CSIRO, on 19 Sept 2014

use strict          ;
use warnings        ;
use Getopt::Std		;

my %args=();
getopts("tfi:",\%args);


my $ref_matrix = &slurp_matrix($args{'i'});

print <<MATRIX;

	matrix successfully read
MATRIX


print <<MATRIX;
	drawing svg matrix

MATRIX


&matrix_full_svg($args{'i'},$ref_matrix) if !$args{'t'} and $args{'f'};

&matrix_triangle_svg_($args{'i'},&triangulate_matrix($ref_matrix)) if $args{'t'} and !$args{'f'};

&matrix_full_svg($args{'i'},$ref_matrix) and &matrix_triangle_svg_($args{'i'},&triangulate_matrix($ref_matrix)) if $args{'t'} and $args{'f'};
	
#_______________________________________________________________________

sub colour_code {

	my %code=();
	my %colours = ( 
		'c1'  => '#FFFFFF',
		'c2'  => '#FFFF99',
		'c3'  => '#FFFF33',    
		'c4'  => '#FFCC00',
		'c5'  => '#FF6600',
		'c6'  => '#FF0000',
		'c7'  => '#CC0033',
		'c8'  => '#990066',
		'c9'  => '#8800AA',
		'c10' => '#4400AA',
		'c11' => '#220055'
		);

		$code{'1'}= ['>=5e-2', $colours{'c1'}] ;
		$code{'2'}= ['<5e-2', $colours{'c2'}] ;
		$code{'3'}= ['<5e-3', $colours{'c3'}] ;
		$code{'4'}= ['<5e-4', $colours{'c4'}] ;
		$code{'5'}= ['<5e-5', $colours{'c5'}] ;
		$code{'6'}= ['<5e-6', $colours{'c6'}] ;
		$code{'7'}= ['<5e-7', $colours{'c7'}] ;
		$code{'8'}= ['<5e-8', $colours{'c8'}] ;
		$code{'9'}= ['<5e-9', $colours{'c9'}] ;
		$code{'10'}= ['<5e-10', $colours{'c10'}] ;
		$code{'11'}= ['<5e-11', $colours{'c11'}] ;

	return %code
}     

     
sub colour_rectangle {

	my $ref_rect=shift@_;
	my $colour='';
	my %colours = ( 
		'c1'  => '#FFFFFF',
		'c2'  => '#FFFF99',
		'c3'  => '#FFFF33',    
		'c4'  => '#FFCC00',
		'c5'  => '#FF6600',
		'c6'  => '#FF0000',
		'c7'  => '#CC0033',
		'c8'  => '#990066',
		'c9'  => '#8800AA',
		'c10' => '#4400AA',
		'c11' => '#220055'
		);
	for ($$ref_rect){
		$colour=$colours{'c11'} and last if $$ref_rect < 5e-11;
		$colour=$colours{'c10'} and last if $$ref_rect < 5e-10;
		$colour=$colours{'c9'}  and last if $$ref_rect <  5e-9;
		$colour=$colours{'c8'}  and last if $$ref_rect <  5e-8;
		$colour=$colours{'c7'}  and last if $$ref_rect <  5e-7;
		$colour=$colours{'c6'}  and last if $$ref_rect <  5e-6;
		$colour=$colours{'c5'}  and last if $$ref_rect <  5e-5;
		$colour=$colours{'c4'}  and last if $$ref_rect <  5e-4;
		$colour=$colours{'c3'}  and last if $$ref_rect <  5e-3;
		$colour=$colours{'c2'}  and last if $$ref_rect <  5e-2;
		$colour=$colours{'c1'}  and last if $$ref_rect >= 5e-2;
	}
	return $colour
}     

sub slurp_matrix{
	my $file=shift@_;
	my $index=0;
	my @matrix=();
	open my $in,'<',$file or die "Could not open $file!\n";
	while (<$in>){
		s/\r\n/\n/;
		s/\r/\n/;
		chomp;
		$index++;
		next if $index==1;
		s/ //g;
		my @arr=split",",$_;
		$arr[$index-1]='na';
		push @matrix,\@arr
	}
	return \@matrix
}

sub triangulate_matrix{
	my $ref_matrix=shift@_;
	my @matrix=@$ref_matrix;
	for my $row (@matrix){
		for (1..@$row-1){
			last if $row->[$_] eq 'na';
			$row->[$_]='' if $row->[$_]=~  /\d+/
		}
	} 
	return \@matrix
}

sub matrix_full_svg {
	
	my ($file,$matrix) = @_ ;

	my $nrows          = @{$matrix}     ; $nrows--    ; $nrows    *= 10  ; 
	my $ncolumns       = @{$$matrix[0]} ; $ncolumns-- ; $ncolumns *= 10  ;
		
	my $init_line = '<?xml version="1.0" encoding="UTF-8" standalone="no"?>' ;
	my $gen_line  = '<!-- created by matrix_reduction.pl -->'                ;

	my @TAXA ;
	
	open my $fh_matrix_out , ">" , "$file.full.svg"                          ; 

	my $width = $ncolumns + 40                                               ;
	my $height= $nrows    + 40                                               ;


print $fh_matrix_out <<FRAME;
$init_line
$gen_line
<svg
   xmlns:svg="http://www.w3.org/2000/svg"
   xmlns="http://www.w3.org/2000/svg"
   version="1.0"
   width="$width"
   height="$height"
   id="svg2">
  <defs
     id="defs4" />

FRAME

my $y = $height/4;
my $x = 0;

for my $row ( @$matrix ) {

	my $taxon = $row->[0];
	$x = ($width-($width/2+80))/2+10;

	for my $rect (@$row[1..@$row-1]) {
		my $id = int rand 100000 ;
			if (defined $taxon){
				my $x_coord=$x-3;
				my $y_coord=$y+7/2;	

print $fh_matrix_out <<TAXA;
<text
     x="$x_coord" y="$y_coord"
     style="font-size:7px;font-style:normal;font-weight:normal;text-align:end;text-anchor:end;fill:black;fill-opacity:1;stroke:none;stroke-width:1px;stroke-linecap:butt;stroke-linejoin:miter;stroke-opacity:1;font-family:Helvetica"
     id="text1892"
     >$taxon</text>
TAXA
				undef($taxon)	
			}	
		if ($rect eq 'na'){
			my $w_rect=10/2;
			my $h_rect=10/2;
			my $colour='white';
			my $second=$y+10/2;
			my $third=$x+10/2;
			
print $fh_matrix_out <<RECT;
<rect
     width="$w_rect"
     height="$h_rect"
     x="$x"
     y="$y"
     style="fill:$colour;fill-opacity:1;stroke:black;stroke-width:0.1;stroke-miterlimit:10;stroke-dasharray:none;stroke-opacity:1"
     id="rect$id" />
<path
     d = "M $x $y l $w_rect $h_rect" stroke="black" stroke-width="0.2"   />
RECT
#Previous path inserted by LS Jermiin 19 Sep 2014

=pod
<path
     style="fill:none;stroke:#000000;stroke-width:0.1;stroke-linecap:butt;stroke-linejoin:miter;stroke-opacity:1;stroke-miterlimit:4;stroke-dasharray:none"
     d="M $x,$second $third,$y"
     id="path4401"
     inkscape:connector-curvature="0" />
<path
     style="fill:none;stroke:#000000;stroke-width:0.1;stroke-linecap:butt;stroke-linejoin:miter;stroke-opacity:1;stroke-miterlimit:4;stroke-dasharray:none"
     d="M $third,$second $x,$y"
     id="path4401"
     inkscape:connector-curvature="0" />
RECT
=cut
		}
		
		if ($rect=~ /\d+/){
			my $w_rect=10/2;
			my $h_rect=10/2;
			my $colour=&colour_rectangle(\$rect);
print $fh_matrix_out <<RECT;
<rect
     width="$w_rect"
     height="$h_rect"
     x="$x"
     y="$y"
     style="fill:$colour;fill-opacity:1;stroke:black;stroke-width:0.1;stroke-miterlimit:10;stroke-dasharray:none;stroke-opacity:1"
     id="rect$id" />
RECT
	
		}
		$x += 10/2
	}
	$y += 10/2
}

#print colour code on right side of triangle

my $x_colour_code = $x+30;
my $x_text = $x+50;
my $y_colour_code = $height/4;
my $y_text = $height/4+9;
my $w_rect=10;
my $h_rect=10;

my %code = &colour_code();
my @n_colour = sort{ $a<=>$b} keys %code;

for (@n_colour){
	
	my $code=${$code{$_}}[1];
	my $text=${$code{$_}}[0];
	
	for($text){
		s/\>/\&gt\; / if !/\=/;
		s/\</\&lt\; / if !/\=/;
		s/\>\=/\&\#x2265\; / if /\=/;
		s/\<\=/\&\#x2264\; / if /\=/;
	} 
	
	print $fh_matrix_out <<RECT;
<rect
     width="$w_rect"
     height="$h_rect"
     x="$x_colour_code"
     y="$y_colour_code"
     style="fill:$code;fill-opacity:1;stroke:black;stroke-width:0.1;stroke-miterlimit:10;stroke-dasharray:none;stroke-opacity:1"
     id="100" />
<text
     x="$x_text" y="$y_text"
     style="font-size:8px;font-style:normal;font-weight:normal;text-align:front;text-anchor:front;fill:black;fill-opacity:1;stroke:none;stroke-width:1px;stroke-linecap:butt;stroke-linejoin:miter;stroke-opacity:1;font-family:Helvetica"
     id="text1892"
     >$text</text>
RECT

	$y_colour_code += 10;
	$y_text += 10	
}	

print $fh_matrix_out <<FINISH;

</svg>

	
FINISH

}


sub matrix_triangle_svg_ {
	
	my ($file,$matrix) = @_ ;

	my $nrows          = @{$matrix}     ; $nrows--    ; $nrows    *= 10  ; 
	my $ncolumns       = @{$$matrix[0]} ; $ncolumns-- ; $ncolumns *= 10  ;
		
	my $init_line = '<?xml version="1.0" encoding="UTF-8" standalone="no"?>' ;
	my $gen_line  = '<!-- created by matrix_reduction.pl -->'                ;

	my @TAXA ;
	
	open my $fh_matrix_out , ">" , "$file.triangle.svg"                      ; 

	my $width = $ncolumns + 40                                               ;
	my $height= $nrows    + 40                                               ;


print $fh_matrix_out <<FRAME;
$init_line
$gen_line
<svg
   xmlns:svg="http://www.w3.org/2000/svg"
   xmlns="http://www.w3.org/2000/svg"
   version="1.0"
   width="$width"
   height="$height"
   id="svg2">
  <defs
     id="defs4" />

FRAME

my $y = $height/4;
my $x = 0;

my $row_index=0;

for my $row ( @$matrix ) {

	my $taxon = shift @$row;
	$x = ($width-($width/2+80))/2+10;
	for my $rect (@$row) {
		my $id = int rand 100000 ;
	
			if ($rect eq 'na'){
				my $w_rect=10/2;
				my $h_rect=10/2;
				my $colour='green';
				my $second=$y+10/2;
				my $third=$x+10/2;
			
#Commented out by LS Jermiin 19 Sep 2014
#print $fh_matrix_out <<RECT;
#<rect
#     width="$w_rect"
#     height="$h_rect"
#     x="$x"
#     y="$y"
#     style="fill:$colour;fill-opacity:1;stroke:black;stroke-width:0.1;stroke-miterlimit:10;stroke-dasharray:none;stroke-opacity:1"
#     id="rect$id" />
#RECT

=pod
<path
     style="fill:none;stroke:#000000;stroke-width:0.1;stroke-linecap:butt;stroke-linejoin:miter;stroke-opacity:1;stroke-miterlimit:4;stroke-dasharray:none"
     d="M $x,$second $third,$y"
     id="path4401"
     inkscape:connector-curvature="0" />
<path
     style="fill:none;stroke:#000000;stroke-width:0.1;stroke-linecap:butt;stroke-linejoin:miter;stroke-opacity:1;stroke-miterlimit:4;stroke-dasharray:none"
     d="M $third,$second $x,$y"
     id="path4401"
     inkscape:connector-curvature="0" />
RECT
=cut
			
			if (defined $taxon){
				my $x_coord=$x+5/2;
				my $y_coord=$y+12/2;	

print $fh_matrix_out <<TAXA;
<text
     x="$x_coord" y="$y_coord"
     style="font-size:7px;font-style:normal;font-weight:normal;text-align:end;text-anchor:end;fill:black;fill-opacity:1;stroke:none;stroke-width:1px;stroke-linecap:butt;stroke-linejoin:miter;stroke-opacity:1;font-family:Helvetica"
     id="text1892"
     transform="rotate(315 $x_coord $y_coord)"
     >$taxon</text>
TAXA
				undef($taxon)	
			}
			
			}		
		
		if ($rect=~ /\d+/){
			my $w_rect=10/2;
			my $h_rect=10/2;
			my $colour=&colour_rectangle(\$rect);
print $fh_matrix_out <<RECT;
<rect
     width="$w_rect"
     height="$h_rect"
     x="$x"
     y="$y"
     style="fill:$colour;fill-opacity:1;stroke:black;stroke-width:0.1;stroke-miterlimit:10;stroke-dasharray:none;stroke-opacity:1"
     id="rect$id" />
RECT
		}
		$x += 10/2
	}
	$y += 10/2
}

#print colour code on right side of triangle

my $x_colour_code = $x+30;
my $x_text = $x+50;
my $y_colour_code = $height/4;
my $y_text = $height/4+9;
my $w_rect=10;
my $h_rect=10;

my %code = &colour_code();
my @n_colour = sort{ $a<=>$b} keys %code;

for (@n_colour){
	
	my $code=${$code{$_}}[1];
	my $text=${$code{$_}}[0];
	
	for($text){
		s/\>/\&gt\; / if !/\=/;
		s/\</\&lt\; / if !/\=/;
		s/\>\=/\&\#x2265\; / if /\=/;
		s/\<\=/\&\#x2264\; / if /\=/;
	} 
	
	print $fh_matrix_out <<RECT;
<rect
     width="$w_rect"
     height="$h_rect"
     x="$x_colour_code"
     y="$y_colour_code"
     style="fill:$code;fill-opacity:1;stroke:black;stroke-width:0.1;stroke-miterlimit:10;stroke-dasharray:none;stroke-opacity:1"
     id="100" />
<text
     x="$x_text" y="$y_text"
     style="font-size:8px;font-style:normal;font-weight:normal;text-align:front;text-anchor:front;fill:black;fill-opacity:1;stroke:none;stroke-width:1px;stroke-linecap:butt;stroke-linejoin:miter;stroke-opacity:1;font-family:Helvetica"
     id="text1892"
     >$text</text>
RECT

	$y_colour_code += 10;
	$y_text += 10	
}	

print $fh_matrix_out <<FINISH;

</svg>

	
FINISH

}

