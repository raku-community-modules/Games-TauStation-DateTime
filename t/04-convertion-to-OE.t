use lib 'lib';
use Test;
use Games::TauStation::DateTime;

plan 302;

is GCT.new('1964-01-22T01:42:56.925148Z'), '000.00/00:000 GCT',
    'Catastrophe time Old Earth -> GCT';
is GCT.new('000.00/00:000 GCT').OE, '1964-01-22T01:42:56.925148Z',
    'Catastrophe time GCT -> Old Earth';

for ^100 {
    my $t := 1524424977.922727.rand.Rat;
    is GCT.new($t).OE,       DateTime.new($t), ".OE with time $t";
    is GCT.new($t).OldEarth, DateTime.new($t), ".OldEarth with time $t";
    is-deeply GCT.new($t).DateTime, DateTime.new($t),
        ".DateTime with time $t";
}
