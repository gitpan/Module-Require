use ExtUtils::MakeMaker;
# $Id: Makefile.PL,v 1.1 2001/12/17 21:41:12 jgsmith Exp $

WriteMakefile( NAME => 'Module::Require',
               VERSION_FROM => 'lib/Module/Require.pm',
               dist         => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
             );
