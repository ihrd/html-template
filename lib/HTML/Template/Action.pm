class HTML::Template::Action;
has Str  $!namespace = '_root';
has Hash %!params;
has Hash %!meta;

method TOP ($/) {
    make $( $/<contents> );
}

method contents ($/) {
    #say "contents: $/";
    my $str = $($/<plaintext>);
    if $/<chunk> {
        for $/<chunk> {
            #say "iterate chunk: $_";
            $str ~= $( $_ );
        }
    }
    #say "make in contents: $str";
    make $str;
}

method chunk ($/) {
    #say "chunk $/";
    make  $($/<directive>) ~ $($/<plaintext>); 
}

method plaintext ($/) {
    #say "plaintext: $/";
    make ~$/
}

method directive ($/, $key) {
    #say "directive: $/, key: $key";
    make $( $/{$key} ); 
}

method insertion ($/) {
    say "insert: $/";
    my $name  = ~$/<attributes><name>;

    my $value = self.param($name);

    if $/<attributes><escape> {
        # RAKUDO: Segfault here :(
        #$value = escape($value, ~$/<attributes><escape>[0]);
        # workaround:
        my $et = ~$/<attributes><escape>[0];
        if $et eq 'HTML' {
            $value = escape($value, 'HTML');
        }
        elsif $et eq 'URL' | 'URI' {
            $value = escape($value, 'URL');
        }
    }
 
    # RAKUDO: Scalar type not implemented yet
    warn "Param $name is a { $value.WHAT }" unless $value ~~ Str | Int;
    
    make ~$value;
}

method if_statement ($/) {
    #say "if_statement: $/";
    my $name = $/<attributes><name>;
    if self.param($name) {
        #say 'true';
        make $($/<contents>);
    } else {
        #say 'false';
        if $/<else> {
            make $($/<else>);
        } else {
            make '';
        }
    }
}

method for_statement ($/) {
    say "for_statement: $/";
    my $name = ~$/<attributes><name>;
    my $iterations = self.param($name);
   
    for $iterations.list -> $i {
        say 'I:' ~ $i.perl;
        $!namespace = $name;
        %!meta{$name} = hash $i;
        make $($/<contents>);
    }

    $!namespace = '_root';

}
method param ($name) {
    say "Get param $name";
    say "params: " ~ %!params.perl;
    say "meta: " ~ %!meta.perl;
    if $!namespace eq '_root' {
        return %!params{$name};
    }
    else {
        my %meta = %!meta{$!namespace};
        return %meta{$name};
    }
}
# vim:ft=perl6
