#!/usr/bin/perl
%L = {};
@b = ();
for (<>) {
	chomp;
	if (/^(.*):$/) {
		$L{$1} = $#b + 1;
	} else {
		push(@b, $_);
	}
}
for (@b) {
	s/^ +//;
	s/ +$//;
	/^([^;]*)(.*)$/;
	$stmt = $1;
	$cmt = $2;
	$stmt =~ s/ +$//;
	@c = split(/ +/, $stmt);
	for (@c) {
		if (exists $L{$_}) {
			$_ = $L{$_};
		}
	}
	print join(' ', @c), " $cmt\n";
}
