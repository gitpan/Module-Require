package Module::Require;

use strict;
use vars qw: @ISA @EXPORT_OK $VERSION :;

$VERSION = '0.02';

@ISA = qw[ Exporter ];

# $Id: Require.pm,v 1.2 2001/12/17 21:47:28 jgsmith Exp $

@EXPORT_OK = qw: require_regex require_glob :;

sub require_regex {
    my %modules = ( );
    while(@_) {
        my $file = shift;
        $file =~ s{::}{/}g;
        $file .= ".pm";
        my $fileprefix = "";

        if($file =~ m{^(.*)/([^/]*)$}) {
            $fileprefix = $1;
            $file = $2;
        }

        # $file is guaranteed to not have a `/' in it :)
        my $filter = eval qq"sub { grep m/$file/, readdir \$_[0] }";

        # thanks to `perldoc -f require' for the basic logic here :)
        foreach my $prefix (@INC) {
            my $dh;
            opendir $dh, "$prefix/$fileprefix";
            my @files = &$filter($dh);
            closedir $dh;
            foreach my $f (@files) {
                my $realfilename = "$prefix/$fileprefix/$f";
                next if $INC{"$fileprefix/$f"};
                if( -f $realfilename ) {
                    $modules{"$fileprefix/$f"} = undef;
                    eval {
                        $INC{"$fileprefix/$f"} = $realfilename if do $realfilename;
                    };
                }
            }
        }
        delete @modules{grep m{$fileprefix/$file}, keys %INC} if defined wantarray;
    }
    return unless defined wantarray;
    return wantarray ? keys %modules : scalar keys %modules;
}

sub require_glob {
    my %modules = ( );
    while(@_) {
        my $file = shift;
        $file =~ s{::}{/}g;
        $file .= '\.pm';
        my $fileprefix = "";

        if($file =~ m{^(.*)/([^/]*)$}) {
            $fileprefix = "/" . $1;
            $file = $2;
        }

        # thanks to `perldoc -f require' for the basic logic here :)
        foreach my $prefix (@INC) {
            my @files = eval "<$prefix$fileprefix/$file>";
            foreach my $realfilename (@files) {
                my $f = $realfilename;
                $f =~ s{^$prefix$fileprefix/}{};
                next if $INC{$realfilename};
                if( -f $realfilename ) {
                    $modules{"$fileprefix/$f"} = undef;
                    eval {
                        if(do $realfilename) {
                            $INC{"$fileprefix/$f"} = $realfilename;
                            delete $modules{"$fileprefix/$f"};
                        }
                    };
                }
            }
        }
    }
    return unless defined wantarray;
    return wantarray ? keys %modules : scalar keys %modules;
}

1;

__END__

=head1 NAME

Module::RegexRequire

=head1 SYNOPSIS

 use Module::RegexRequire qw: require_regex require_glob :;

 require_regex q[DBD::.*];
 require_regex qw[DBD::.* Foo::Bar_.*];
 require_glob qw[DBD::* Foo::Bar_*];

=head1 DESCRIPTION

This module provides a way to load in a series of modules without having to
know all the names, but just the pattern they fit.  This can be useful for
allowing drop-in modules for application expansion without requiring
configuration or prior knowledge.

The C<require_regex> function takes a list of files and searches C<@INC>
trying to find all possible modules.  Only the last part of the module name
should be the regex expression (C<Foo::Bar_.*> is allowed, but C<F.*::Bar>
is not).  Each file found and successfully loaded is added to C<%INC>.  Any
file already in C<%INC> is not loaded.  No C<import> functions are called.

The function will return a list of files found but not loaded or, in a
scalar context, the number of such files.  This is the opposite of the
sense of C<require>, with true meaning at least one file failed to load.

Note that unlike the Perl C<require> keyword, quoting or leaving an
argument as a bareword does not affect how the function behaves.

The C<require_glob> function behaves the same as the C<require_regex>
function except it uses the glob operator (E<lt>E<gt>) instead of regular
expressions.

=head1 SEE ALSO

perldoc -f require.

=head1 AUTHOR

James G. Smith <jsmith@cpan.org>

=head1 COPYRIGHT

Copyright (C) 2001 Texas A&M University.  All Rights Reserved.

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

