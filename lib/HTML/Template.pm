class HTML::Template;

use Text::Escape;
use HTML::Template::Grammar;
use HTML::Template::Action;

has Str  $!in;
has Hash %!params;
has %!meta;

method from_string( Str $in ) {
    return self.new(in => $in);
}

method from_file($file_path) {
    return self.from_string( slurp($file_path) );
}

method param( Pair $param ) {
    %!params{$param.key} = $param.value;
}

method with_params( Hash %params ) {
    %!params = %params;
    return self;
}

method output {
    self.make;
}


method make ($in?) {
    HTML::Template::Grammar.parse( ($in || $!in), :action(HTML::Template::Action.new: params => %!params) );
    return $($/);
}

# vim:ft=perl6
