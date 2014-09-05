# Check that all the modules work.

use Test;

BEGIN { plan tests => 18; }

use strict;
use warnings;

eval 'use Portroach::Const ();';                    ok(!$@);
eval 'use Portroach::API();';                       ok(!$@);
eval 'use Portroach::Util ();';                     ok(!$@);
eval 'use Portroach::Config ();';                   ok(!$@);

eval 'use Portroach::SiteHandler ();';              ok(!$@);
eval 'use Portroach::SiteHandler::CPAN ();';        ok(!$@);
eval 'use Portroach::SiteHandler::GitHub ();';      ok(!$@);
eval 'use Portroach::SiteHandler::RubyGems ();';    ok(!$@);
eval 'use Portroach::SiteHandler::SourceForge ();'; ok(!$@);

eval 'use Portroach::SQL ();';                      ok(!$@);
eval 'use Portroach::SQL::SQLite ();';              ok(!$@);
eval 'use Portroach::SQL::Pg ();';                  ok(!$@);

eval 'use Portroach::Make ();';                     ok(!$@);
eval 'use Portroach::Template ();';                 ok(!$@);

eval 'use Portroach::DataSrc ();';                  ok(!$@);
eval 'use Portroach::DataSrc::Ports ();';           ok(!$@);
eval 'use Portroach::DataSrc::XML ();';             ok(!$@);

eval 'use Portroach ();';                           ok(!$@);
