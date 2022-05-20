[![Actions Status](https://github.com/raku-community-modules/Games-TauStation-DateTime/actions/workflows/test.yml/badge.svg)](https://github.com/raku-community-modules/Games-TauStation-DateTime/actions)

NAME
====

Games::TauStation::DateTime — Convert TauStation's Galactic Coordinated Time to Old Earth Time

SYNOPSIS
========

```raku
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
```

DESCRIPTION
===========

This module implements a subclass of [`DateTime`](https://docs.raku.org/type/DateTime) that lets you convert times between [TauStation](https://taustation.space/)'s [Galactic Coordinated Time (GCT)](https://alpha.taustation.space/archive/general/gct) and Old Earth (i.e. "real life") time.

METHODS
=======

Inherited
---------

Inherits all methods from [`DateTime`](https://docs.raku.org/type/DateTime)

new
---

```raku
multi method new(Str:D $ where /<gct-time>/ --> GCT:D);
multi method new(Str:D $ where /<gct-duration>/ --> GCT:D);
```

In addition to regular [`DateTime` constructors](https://docs.raku.org/type/DateTime#method_new), two new ones are provided that take a string with either a GCT time or GCT duration, which is similar to time, except it's prefixed with uppercase letter `D` (see [CORETECHS archive for details](https://alpha.taustation.space/archive/general/gct)).

Negative times and durations are allowed. For durations, the minus sign goes after letter `D` Cycle and day units may be omitted. When cycle is omitted, the dot that normally follows it must be omitted as well; when both cycle and day are omitted, the slash before the time must be present. Whitespace can be used between units and separators.

These are examples of valid times:

  * 198.14/07:106GCT`

  * 198.14/07:106 GCT`

  * - 198 . 14 / 07 : 106 GCT`

  * 14/07:106 GCT`

  * -14/07:106 GCT`

  * /07:106 GCT`

  * -/07:106 GCT`

These are examples of valid durations:

  * D198.14/07:106GCT`

  * D198.14/07:106 GCT`

  * D - 198 . 14 / 07 : 106 GCT`

  * D 14/07:106 GCT`

  * D-14/07:106 GCT`

  * D /07:106 GCT`

  * D-/07:106 GCT`

OE / OldEarth
-------------

```raku
say GCT.new('D12/43:044 GCT');          # OUTPUT: «198.27/19:285 GCT␤»
say GCT.new('D12/43:044 GCT').OE;       # OUTPUT: «2018-05-05T06:20:12.543815Z␤»
say GCT.new('D12/43:044 GCT').OldEarth; # OUTPUT: «2018-05-05T06:20:12.543815Z␤»
```

`.OE` is an alias for `.OldEarth`. The methods don't take any arguments and return a cloned `GCT` object with [`.formatter`](https://docs.perl6.org/type/DateTime#%28Dateish%29_method_formatter) set to the default [`DateTime`](https://docs.perl6.org/type/DateTime) formatter (i.e. the date when printed would be printed as Old Earth time instead of GCT).

DateTime
--------

```raku
say GCT.new('D12/43:044 GCT').DateTime;       # OUTPUT: «2018-05-05T06:29:14.494109Z␤»
say GCT.new('D12/43:044 GCT').DateTime.^name; # OUTPUT: «DateTime␤»
```

Coerces a `GCT` object to plain [`DateTime`](https://docs.raku.org/type/DateTime) object.

AUTHOR
======

Zoffix Znet

COPYRIGHT AND LICENSE
=====================

Copyright 2017 Zoffix Znet

Copyright 2018 - 2022 Raku Community

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

