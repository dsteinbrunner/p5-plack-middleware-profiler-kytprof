package Plack::Middleware::Profiler::KYTProf;
use strict;
use warnings;
use parent qw(Plack::Middleware);
our $VERSION = '0.01';

use Plack::Util::Accessor qw(
    namespace_regex
    ignore_class_regex
    context_classes_regex
    logger
    threshold
    remove_linefeed
    profiles
    mutes
);
use Devel::KYTProf;
use Module::Load;

sub prepare_app {
    my $self = shift;
    $self->set_kytprof_options;
    $self->load_profiles;
    $self->diable_module_profiling;
}

sub set_kytprof_options {
    my $self = shift;
    Devel::KYTProf->namespace_regex( $self->namespace_regex )
        if $self->namespace_regex;
    Devel::KYTProf->ignore_class_regex( $self->ignore_class_regex )
        if $self->ignore_class_regex;
    Devel::KYTProf->context_classes_regex( $self->context_classes_regex )
        if $self->context_classes_regex;
    Devel::KYTProf->logger( $self->logger )       if $self->logger;
    Devel::KYTProf->threshold( $self->threshold ) if $self->threshold;
    Devel::KYTProf->remove_linefeed( $self->remove_linefeed )
        if $self->remove_linefeed;
}

sub diable_module_profiling {
    my $self = shift;
    foreach my $module ( keys %{ $self->mutes || {} } ) {
        my $method = $self->mutes->{$module};
        Devel::KYTProf->mute( $module, $method );
    }
}

sub load_profiles {
    my $self = shift;

    my $profiles ||= $self->profiles;
    $profiles
        ||= ['Plack::Middleware::Profiler::KYTProf::Profile::DefaultProfile'];
    foreach my $profile (@$profiles) {
        print $profile ."\n";
        load $profile;
        $profile->load;
    }
}

sub call {
    my ( $self, $env ) = @_;

    my $res = $self->app->($env);

    if ( ref($res) && ref($res) eq 'ARRAY' ) {
        return $res;
    }

    Plack::Util::response_cb(
        $res,
        sub {
        }
    );
}

1;

__END__

=encoding utf-8

=head1 NAME

Plack::Middleware::Profiler::KYTProf - Profile psgi app with KYTProf

=head1 SYNOPSIS

  use Plack::Middleware::Profiler::KYTProf;

=head1 DESCRIPTION

Plack::Middleware::Profiler::KYTProf is


=head1 SOURCE AVAILABILITY

This source is in Github:

  http://github.com/dann/

=head1 CONTRIBUTORS

Many thanks to:

=head1 AUTHOR

Dann E<lt>techmemo@gmail.comE<gt>

=head1 SEE ALSO

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
