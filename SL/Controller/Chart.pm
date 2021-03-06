package SL::Controller::Chart;

use strict;
use parent qw(SL::Controller::Base);

use Clone qw(clone);
use SL::DB::Chart;
use SL::Controller::Helper::GetModels;
use SL::Locale::String qw(t8);
use SL::JSON;

use Rose::Object::MakeMethods::Generic (
  'scalar --get_set_init' => [ qw(charts models chart) ],
);

sub action_ajax_autocomplete {
  my ($self, %params) = @_;

  my $value = $::form->{column} || 'description';

  # if someone types something, and hits enter, assume he entered the full name.
  # if something matches, treat that as sole match
  # unfortunately get_models can't do more than one per package atm, so we do it
  # the oldfashioned way.
  if ($::form->{prefer_exact}) {
    my $exact_matches;
    # we still need the type filter so that we can't choose an illegal chart
    # via exact_match if we have preset a link type, e.g. AR_paid
    if (1 == scalar @{ $exact_matches = SL::DB::Manager::Chart->get_all(
      query => [
        SL::DB::Manager::Chart->type_filter($::form->{filter}{type}),
        or => [
          description => { ilike => $::form->{filter}{'all:substr:multi::ilike'} },
          accno       => { ilike => $::form->{filter}{'all:substr:multi::ilike'} },
        ]
      ],
      limit => 2,
    ) }) {
      $self->charts($exact_matches);
    }
  }

  my @hashes = map {
   +{
     value       => $_->displayable_name,
     label       => $_->displayable_name,
     id          => $_->id,
     accno       => $_->accno,
     description => $_->description,
    }
  } @{ $self->charts }; # neato: if exact match triggers we don't even need the init_parts

  $self->render(\ SL::JSON::to_json(\@hashes), { layout => 0, type => 'json', process => 0 });
}

sub action_test_page {
  $_[0]->render('chart/test_page');
}

sub action_chart_picker_search {
  $_[0]->render('chart/chart_picker_search', { layout => 0 }, charts => $_[0]->charts);
}

sub action_chart_picker_result {
  $_[0]->render('chart/_chart_picker_result', { layout => 0 });
}

sub action_show {
  my ($self) = @_;

  if ($::request->type eq 'json') {
    my $chart_hash;
    if (!$self->chart) {
      # TODO error
    } else {
      $chart_hash                     = $self->chart->as_tree;
      $chart_hash->{displayable_name} = $self->chart->displayable_name;
    }

    $self->render(\ SL::JSON::to_json($chart_hash), { layout => 0, type => 'json', process => 0 });
  }
}

sub init_charts {

  # disable pagination when hiding chart details = paginate when showing chart details
  if ($::form->{hide_chart_details}) {
    $_[0]->models->disable_plugin('paginated');
  }

  $_[0]->models->get;
}

sub init_chart {
  SL::DB::Chart->new(id => $::form->{id} || $::form->{chart}{id})->load;
}

sub init_models {
  my ($self) = @_;

  SL::Controller::Helper::GetModels->new(
    controller => $self,
    sorted => {
      _default  => {
        by  => 'accno',
        dir => 1,
      },
      accno       => t8('Account number'),
      description => t8('Description'),
    },
  );
}

1;
