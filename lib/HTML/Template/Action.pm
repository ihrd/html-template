class HTML::Template::Action;
has %!params is rw;

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
    my $value = %!params{$name};

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
    if %!params{$name} {
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
    my $name = ~$/<attributes><name>;
    my $iterations = %!params{$name};
    # %!params<!FIRST> = True;
    ...
}
# vim:ft=perl6
