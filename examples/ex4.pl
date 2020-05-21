#!/usr/bin/env perl

use strict;
use warnings;

use File::Temp;
use IO::Barf;
use Plack::App::File::PYX;
use Plack::Runner;

# Temporary file with PYX.
my $temp_pyx_file = File::Temp->new->filename;

# PYX file in UTF8, prepared for windows-1250 output.
my $pyx = <<'END';
(html
(head
(title
-žščřďťň
)title
(meta
Acharset windows-1250
)meta
)head
(body
(div
-Hello in windows-1250 encoding - Ahoj světe!
)div
)body
)html
END
barf($temp_pyx_file, $pyx);

# Run application with one PYX file.
my $app = Plack::App::File::PYX->new(
        'encoding' => 'windows-1250',
        'file' => $temp_pyx_file,
        'indent' => 'Tags::Output::Indent',
)->to_app;
Plack::Runner->new->run($app);

# Output:
# HTTP::Server::PSGI: Accepting connections at http://0:5000/

# > curl http://localhost:5000/
# XXX in windows-1250 encoding
# <html>
#   <head>
#     <title>
#       žščřďťň
#     </title>
#     <meta charset="windows-1250">
#     </meta>
#   </head>
#   <body>
#     <div>
#       Hello in windows-1250 encoding - Ahoj světe!
#     </div>
#   </body>
# </html>