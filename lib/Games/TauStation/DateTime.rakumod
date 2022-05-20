my constant &formatter = DateTime.now.formatter; # get the default formatter

class GCT is DateTime is export {

    # 198.15/03:973 GCT = 2018-04-23T00:57:13.361615Z
    my constant catastrophe = DateTime.new: '1964-01-22T00:00:27.689615Z';

    my regex sign    { <.ws>? <[-−+]>? <.ws>? }
    my regex cycle   { <.ws>? \d**{1..*} <.ws>? }
    my regex day     { <.ws>? \d**{1..2} <.ws>? }
    my regex segment { <.ws>? \d**{1..2} <.ws>? }
    my regex unit    { <.ws>? \d**{1..3} <.ws>? }
    my regex gct-re {
      ^
        [$<rel>='D']? <sign> [ [<cycle> '.']? <day> ]?
        '/' <segment> ':' <unit> [:i 'GCT' <.ws>?]?
      $
    }
    my $formatter = my method {
        my $Δ = (self - catastrophe).Rat;
        my \neg      := $Δ < 0;
        my \cycles   := ($Δ = $Δ.abs / 100/24/60/60).Int;
        my \days     := (($Δ -= cycles.abs) *= 100).Int;
        my \segments := (($Δ -= days  ) *= 100).Int;
        my \units    := round ($Δ - segments) * 1000;
        sprintf ('-' if neg) ~ "%03d.%02d/%02d:%03d GCT",
            cycles, days, segments, units;
    }

    proto method new (|) {*}
    multi method new (|c) {
        (try self.DateTime::new: |c, :$formatter) // die "Invalid arguments to"
          ~ " {::?CLASS.raku}.new. Use any valid DateTime.new arguments, a GCT"
          ~ " time (e.g. `198.14/07:106 GCT`) or GCT duration"
          ~ " (e.g `D3/00:000 GCT`)\n\nCapture of the args you gave: {c.raku}"
    }
    multi method new (Str:D $_ --> ::?CLASS:D) {
        when &gct-re {
          my \Δ := (
            ($<sign>//'').trim eq '-' || ($<sign>//'').trim eq '−' ?? -1 !! 1
          ) * ((($<cycle>//0)*100 + ($<day>//0) + $<segment>/100)*24*60*60
            + $<unit>*.864);
          self.new: ($<rel> ?? now !! catastrophe.Instant) + Δ, :$formatter
        }
        nextsame
    }

    multi method later(:cycle(:$cycles)!) {
        self.later(seconds => $cycles*100*24*60*60, |%_)
    }
    multi method later(:segment(:$segments)!) {
        self.later(seconds => $segments/100*24*60*60, |%_)
    }
    multi method later(:unit(:$units)!) {
        self.later(seconds => $units*0.864, |%_)
    }

    multi method earlier(:cycle(:$cycles)!) {
        self.earlier(seconds => $cycles*100*24*60*60, |%_)
    }
    multi method earlier(:segment(:$segments)!) {
        self.earlier(seconds => $segments/100*24*60*60, |%_)
    }
    multi method earlier(:unit(:$units)!) {
        self.earlier(seconds => $units*0.864, |%_)
    }

    method OE() { self.clone: :&formatter }
    method OldEarth() { self.OE }
    method DateTime() { DateTime.new: self.Instant }
}

=begin pod

=head1 NAME

Games::TauStation::DateTime — Convert TauStation's Galactic Coordinated Time to Old Earth Time

=head1 SYNOPSIS

=begin code :lang<raku>

use Games::TauStation::DateTime;

# Show time in GCT or Old Earth time:
say GCT.new('193.99/59:586 GCT');    # OUTPUT: «193.99/59:586 GCT␤»
say GCT.new('193.99/59:586 GCT').OE; # OUTPUT: «2017-03-03T16:00:32.229148Z␤»

# Show duration from now:
say GCT.new('D12/43:044 GCT');    # OUTPUT: «198.27/19:285 GCT␤»
say GCT.new('D12/43:044 GCT').OE; # OUTPUT: «2018-05-05T06:20:12.543815Z␤»

# Adjust date using GCT or Old Earth time units:
say GCT.new('193.99/59:586 GCT').later(:30segments).earlier(:2hours);
# OUTPUT: «193.99/81:253 GCT␤»

# We inherit from DateTime class:
say GCT.new('2018-04-03T12:20:43Z');    # OUTPUT: «197.95/44:321 GCT␤»
say GCT.new('193.99/59:586 GCT').posix; # OUTPUT: «1488556832␤»

=end code

=head1 DESCRIPTION

This module implements a subclass of
L<C<DateTime>|https://docs.raku.org/type/DateTime>
that lets you convert times between L<TauStation|https://taustation.space/>'s
L<Galactic Coordinated Time (GCT)|https://alpha.taustation.space/archive/general/gct>
and Old Earth (i.e. "real life") time.

=head1 METHODS

=head2 Inherited

Inherits all methods from L<C<DateTime>|https://docs.raku.org/type/DateTime>

=head2 new

=begin code :lang<raku>

multi method new(Str:D $ where /<gct-time>/ --> GCT:D);
multi method new(Str:D $ where /<gct-duration>/ --> GCT:D);

=end code

In addition to regular L<C<DateTime> constructors|https://docs.raku.org/type/DateTime#method_new>,
two new ones are provided that take a string with either a GCT time or
GCT duration, which is similar to time, except it's prefixed with uppercase
letter C<D> (see L<CORETECHS archive for details|https://alpha.taustation.space/archive/general/gct>).

Negative times and durations are allowed. For durations, the minus sign goes
after letter C<D> Cycle and day units may be omitted. When cycle is omitted,
the dot that normally follows it must be omitted as well; when both cycle
and day are omitted, the slash before the time must be present. Whitespace
can be used between units and separators.

These are examples of valid times:

=item 198.14/07:106GCT`
=item 198.14/07:106 GCT`
=item  - 198 . 14 / 07 : 106 GCT`
=item  14/07:106 GCT`
=item -14/07:106 GCT`
=item  /07:106 GCT`
=item -/07:106 GCT`

These are examples of valid durations:
=item D198.14/07:106GCT`
=item D198.14/07:106 GCT`
=item D - 198 . 14 / 07 : 106 GCT`
=item D 14/07:106 GCT`
=item D-14/07:106 GCT`
=item D /07:106 GCT`
=item D-/07:106 GCT`

=head2 OE / OldEarth

=begin code :lang<raku>

say GCT.new('D12/43:044 GCT');          # OUTPUT: «198.27/19:285 GCT␤»
say GCT.new('D12/43:044 GCT').OE;       # OUTPUT: «2018-05-05T06:20:12.543815Z␤»
say GCT.new('D12/43:044 GCT').OldEarth; # OUTPUT: «2018-05-05T06:20:12.543815Z␤»

=end code

C<.OE> is an alias for C<.OldEarth>. The methods don't take any arguments and
return a cloned C<GCT> object with L<C<.formatter>|https://docs.perl6.org/type/DateTime#%28Dateish%29_method_formatter>
set to the default L<C<DateTime>|https://docs.perl6.org/type/DateTime> formatter
(i.e. the date when printed would be printed as Old Earth time instead of GCT).

=head2 DateTime

=begin code :lang<raku>

say GCT.new('D12/43:044 GCT').DateTime;       # OUTPUT: «2018-05-05T06:29:14.494109Z␤»
say GCT.new('D12/43:044 GCT').DateTime.^name; # OUTPUT: «DateTime␤»

=end code

Coerces a C<GCT> object to plain
L<C<DateTime>|https://docs.raku.org/type/DateTime> object.

=head1 AUTHOR

Zoffix Znet

=head1 COPYRIGHT AND LICENSE

Copyright 2017 Zoffix Znet

Copyright 2018 - 2022 Raku Community

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod

# vim: expandtab shiftwidth=4
