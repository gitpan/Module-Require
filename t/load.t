# $Id: load.t,v 1.1 2001/12/17 21:41:16 jgsmith Exp $

BEGIN { print "1..1\n"; }

eval {
    use Module::Require qw: require_regex require_glob :;
};

if($@) {
    print "not ok 1";
} else {
    print "ok     1";
}

1;
