# This file has been auto-generated. Do not modify it; it will be overwritten
# by rose_auto_create_model.pl automatically.
package SL::DB::Currency;

use strict;

use base qw(SL::DB::Object);

__PACKAGE__->meta->setup(
  table   => 'currencies',

  columns => [
    id   => { type => 'serial', not_null => 1 },
    name => { type => 'text', not_null => 1 },
  ],

  primary_key_columns => [ 'id' ],

  unique_key => [ 'name' ],
);

1;
;