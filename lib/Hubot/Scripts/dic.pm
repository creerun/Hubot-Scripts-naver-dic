package Hubot::Scripts::dic;

use utf8;
use strict;
use warnings;
use Encode;
use Data::Printer;

sub load {
    my ( $class, $robot ) = @_;
 
    $robot->hear(
        qr/^dic (.*)/i,    
        \&dic_process,
    );
}

sub dic_process {
    my $msg = shift;
    my $user_input = $msg->match->[0];

    $msg->http("http://dic.naver.com/search.nhn?dicQuery=$user_input&query=$user_input&target=dic&ie=utf8&query_utf=&isOnlyViewEE=")->get(
            sub { 
                my ( $body, $hdr )  = @_;
                return if ( !$body || $hdr->{Status} !~ /^2/ );
                my $decode_body = decode ("utf-8", $body);
                my $kr_define;
                my @en_define;

                if ( $user_input =~ /^[\w+]/ ) {
                    if ( $decode_body =~ m{<!--  krdic -->(.*?)<!--  krdic -->}gsm ) {
                        my $krdic = $1;

                        if ( $krdic =~ m{<br>\s*\d{1,}\.\s*(.+)\s*<br>}g ) {
                            $kr_define = $1;
                        }
                        elsif ( $krdic =~ m{\s*(.+)\s*<br>}g ) {
                            $kr_define = $1;
                        }
                    }

                    if ( $decode_body =~ m{<!-- endic -->(.*?)<!-- endic -->}gsm ) {
                        my $endic = $1;

                        if ( $endic =~ m{\d{1,}\.(.+)</br>}g ) {
                            my $en_wr_define = $1;
                            p $en_wr_define;
                        }

                        @en_define = @{[ $endic =~ m/<a href="javascript:endicAutoLink([^\s]+);"/g ]}[0,1,2];

                    }
                    $msg->send("KO -[$kr_define]");
                    $msg->send("EN -[@en_define]");
                }
                else {
                    $msg->send("In English");
                }
            }
        );
}
1;

=pod

=head1 Name 

    Hubot::Scripts::dic
 
=head1 SYNOPSIS

    dic <word> 

=head1 AUTHOR

    YunChang Kang <codenewb@gmail.com>
 
=cut
