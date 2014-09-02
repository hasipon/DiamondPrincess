#!/usr/bin/perl
@prog = <>;
for (@prog) {
	chomp;
	s/^ +//;
	s/ +$//;
	@a = split(/ +/);
	if ($#a >= 1 && $a[0] eq 'FUNC') {
		$num_args{$a[1]} = $#a - 1;
	}
	$_ = join(' ', @a);
}
for (@prog) {
	@a = split(/ /);
	if ($#a >= 1 && $a[0] eq 'FUNC') {
		%type = ();
		for $i (2..$#a) {
			$type{$a[$i]} = 1;
		}
	} elsif ($#a >= 1 && $a[0] eq 'VAR') {
		for $i (1..$#a) {
			$type{$a[$i]} = 2;
		}
	} elsif ($#a >= 1 && $a[0] eq 'P') {
		if ($a[1] =~ /^-?\d+$/) {
			$a[0] = 'LDC';
		} elsif ($type{$a[1]} == 1) {
			$a[0] = 'PUSH';
		} elsif ($type{$a[1]} == 2) {
			$a[0] = 'GET';
		} else {
			$a[0] = 'LDF';
		}
		$_ = join(' ', @a);
	}
}
$id = 0;
$LN = 0;
for (@prog) {
	++ $LN;
	next if (/^$/ or /^;/);
	@a = split(/ /);
	if ($#a >= 0 && $a[0] eq 'debug') {
		print "LDC $LN\n";
		@a = ('CALL', 'debug_print');
	}
	if ($#a >= 1 && $a[0] eq 'CALL') {
		print "LDF $a[1] ;$LN\n";
		print "AP $num_args{$a[1]} ;$LN\n";
	} elsif ($#a >= 1 && $a[0] eq 'FUNC') {
		print "$a[1]:\n";
		%arg = {};
		for $i (0..($#a - 2)) {
			$arg{$a[$i+2]} = $i;
		}
		$hasVar = 0;
	} elsif ($#a >= 1 && $a[0] eq 'PUSH') {
		print "LD $hasVar $arg{$a[1]} ;PUSH $a[1] ;$LN\n";
	} elsif ($#a >= 0 && $a[0] eq 'VAR') {
		$hasVar = 1;
		print "DUM $#a ;$LN\n";
		for $i (0..($#a - 1)) {
			$var{$a[$i+1]} = $i;
			print "LDC 0 ;$LN\n";
		}
		++ $id;
		print "LDF __var_$id ;$LN\n";
		print "TRAP $#a ;$LN\n";
		print "__var_$id:\n";
	} elsif ($#a >= 1 && $a[0] eq 'GET') {
		print "LD 0 $var{$a[1]} ;GET $a[1] ;$LN\n";
	} elsif ($#a >= 1 && $a[0] eq 'SET') {
		print "ST 0 $var{$a[1]} ;SET $a[1] ;$LN\n";
	} elsif (/:$/) {
		print "$_\n";
	} else {
		print join(' ', @a), " ;$LN\n";
	}
}
