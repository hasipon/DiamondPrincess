#!/usr/bin/perl
$id = 0;
@b = ([]);
for (<>) {
	chomp;
	@a = split(/ /);
	$LN = $a[$#a];
	if ($#a >= 0 && $a[0] eq 'IF') {
		++ $id;
		push($b[$#b], "SEL __sel_$id-then __sel_$id-else $LN");
		push(@b, ["__sel_$id-then:"]);
		push(@els, "__sel_$id-else");
	} elsif ($#a >= 0 && $a[0] eq 'ELSE') {
		push($b[$#b], "JOIN $LN");
		push($b[$#b], "$els[$#els]:");
		$els[$#els] = "";
	} elsif ($#a >= 0 && $a[0] eq 'ENDIF') {
		if ($els[$#els] ne '') {
			push($b[$#b], "$els[$#els]:");
		}
		push($b[$#b], "JOIN $LN");
		pop(@els);
		$x = pop(@b);
		for $line (@$x) {
			push(@prog, $line);
		}
	} elsif ($#a >= 0 && $a[0] eq 'DO') {
		++ $id;
		push($b[$#b], "LDC 1 $LN");
		push($b[$#b], "SEL __sel_$id-loop 0 $LN");
		push(@b, ["__sel_$id-loop:"]);
		push(@loop, "__sel_$id-loop");
	} elsif ($#a >= 0 && $a[0] eq 'LOOP') {
		$L = pop(@loop);
		push($b[$#b], "LDC 1 $LN");
		push($b[$#b], "TSEL $L 0 $LN");
		push($b[$#b], "$L-end:");
		push($b[$#b], "JOIN $LN");
		$x = pop(@b);
		for $line (@$x) {
			push(@prog, $line);
		}
	} elsif ($#a >= 0 && $a[0] eq 'BREAK') {
		$L = $loop[$#loop];
		++ $id;
		$N = "__sel_$id-break";
		push($b[$#b], "TSEL $L-end $N $LN");
		push($b[$#b], "$N:");
	} else {
		push($b[$#b], join(' ', @a));
	}
}
$x = pop(@b);
for $line (@$x) {
	push(@prog0, $line);
}
for (@prog0) {
	print "$_\n";
}
for (@prog) {
	print "$_\n";
}
