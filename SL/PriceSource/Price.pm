package SL::PriceSource::Price;

use strict;

use parent 'SL::DB::Object';
use Rose::Object::MakeMethods::Generic (
  scalar => [ qw(price description spec price_source invalid missing) ],
  array => [ qw(depends_on) ]
);

use SL::DB::Helper::Attr;
SL::DB::Helper::Attr::make(__PACKAGE__,
  price => 'numeric(15,5)',
);

sub source {
  $_[0]->price_source
  ?  $_[0]->price_source->name . '/' . $_[0]->spec
  : '';
}

sub full_description {
  my ($self) = @_;

  $self->price_source
    ? $self->price_source->description . ': ' . $self->description
    : $self->description
}

sub to_str {
  "source: @{[ $_[0]->source ]}, price: @{[ $_[0]->price]}, description: @{[ $_[0]->description ]}"
}

1;

__END__

=encoding utf-8

=head1 NAME

SL::PriceSource::Price - contrainer to pass calculated prices around

=head1 SYNOPSIS

  # in PriceSource::Base implementation
  $price = SL::PriceSource::Price->new(
    price        => 10.3,
    spec         => '10.3', # something you can easily parse later
    description  => t8('Fix price 10.3'),
    price_source => $self,
  )

  # special empty price in SL::PriceSource
  SL::PriceSource::Price->new(
    description => t8('None (PriceSource)'),
  );

  # invalid price
  SL::PriceSource::Price->new(
    price        => $original_price,
    spec         => $original_spec,
    description  => $original_description,
    invalid      => t8('Offer expired #1 weeks ago', $dt->delta_weeks),
    price_source => $self,
  );

  # missing price
  SL::PriceSource::Price->new(
    price        => $original_price,              # will keep last entered price
    spec         => $original_spec,
    description  => '',
    missing      => t8('Um, sorry, cannot find that one'),
    price_source => $self,
  );


=head1 DESCRIPTION

See L<SL::PriceSource> for information about the mechanism.

This is a container for prices that are generated by L<SL::PriceSource::Base>
implementations.

=head1 CONSTRUCTOR FIELDS

=over 4

=item C<price>

The price. A price of 0 is special and is considered undesirable. If passed as
part of C<available_prices> it will be filtered out. If returned as
C<best_price> or C<price_from_source> it will be warned about.

=item C<spec>

A unique string that can later be understood by the creating implementation.
Can be empty if the implementation only supports one price for a given
record_item.

=item C<description>

A localized short description of the origins of this price.

=item C<price_source>

A ref to the creating algorithm.

=item C<missing>

OPTIONAL. Both indicator and localized message that the price with this spec
could not be reproduced and should be changed.

=item C<invalid>

OPTIONAL. Both indicator and localized message that the conditions for this
price are no longer valid, and that the price should be changed.

=back

=head1 SEE ALSO

L<SL::PriceSource>,
L<SL::PriceSource::Base>,
L<SL::PriceSource::ALL>

=head1 BUGS

None yet. :)

=head1 AUTHOR

Sven Schoeling E<lt>s.schoeling@linet-services.deE<gt>

=cut
