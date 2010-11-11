use strict;
use warnings;
use LWP::Simple;
use Net::Ping;

my $sixxs_pop_page_url= "http://www.sixxs.net/pops/";
my %pops = ();
my $pinger = Net::Ping->new("icmp");
$pinger->hires();

print "Retrieving page\n";
my $page_content = get( $sixxs_pop_page_url ); 
die unless defined $page_content;

print "Testing hosts\n";
while ( $page_content =~ m/>([A-z]+[0-9]+)</g )
{
	my $host = $1 . ".sixxs.net";
	print "Pinging ", $host, "... ";
	( my $resolvedhost, my $rtt, my $ip ) = $pinger->ping( $host, 0.5);
	if ( defined ( $ip ) )
	{
	  printf "%.2f ms\n", $rtt * 1000;
	  $pops{ $host } = $rtt;
        } else {
		print "no fair delay\n"
	}
}

$pinger->close();
my @ranked = sort { $pops{$a} <=> $pops{$b} } keys %pops;

print "And your winners are:\n";

for ( my $i = 0 ; $i < 5; $i++ )
{
   printf "%s (%.2f ms away)\n", $ranked[$i], $pops{ $ranked[$i] } * 1000;
}
