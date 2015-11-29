use v6;
unit class Email::Valid;

has Bool $.mx_check  = False;
has Bool $.tld_check = False;
has Bool $.allow_tags= False;
has Bool $.simple    = True; # Try only simple regex validation. Usefull in mose cases

# TODO allow quoted local parts
# TODO allow ip address parts ?
# TODO implement Punycode to convert for IDN
my Int $max_length = 254;
my Int $mailbox_max_length = 64;


# grammar got exported in the GLOBAL namespace ... wtf ?
my grammar Email::Valid::Tokens {
    token TOP     { ^ (<mailbox>)<?{$0.codes <= $mailbox_max_length}> '@' (<domain>)<?{$1.codes <= $max_length - $mailbox_max_length - 1}> $ }
    token mailbox { <:alpha +digit> [\w|'.'|'%'|'+'|'-']+<!after < . % + - >> } # we can extend allowed characters or allow quoted mailboxes
    token tld     { [ 'xn--' <:alpha +digit> ** 2..* | <:alpha> ** 2..15 ] }
    token domain  { ([ <!before '-'> [ 'xn--' <:alpha +digit> ** 2..* | [\w | '-']+ ] '.' ]) ** 1..4 <?{ all($0.flat) ~~ /^. ** 2..64$/ }>
         (<tld>)
    }
}

# Currently only simple regex validation implemented
method validate(Str $email!) returns Bool {

    if so $.simple {
        return so Email::Valid::Tokens.parse($email); # With so force bool context
    }

    return False;
}

# 0 -> mailbox
# 1 -> domain -> [subdomain1, subdomain2 ], tld --> Str $full_domain
# Returns Nil on fail
method parse(Str $email!) returns Match {
    return Email::Valid::Tokens.parse($email);
}
