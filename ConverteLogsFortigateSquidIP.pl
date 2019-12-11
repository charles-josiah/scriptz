#######
#
# Script devenvolvido por: Sérgio Fischer <fischer at multitask.com.br> 
# Adaptado: Charles Josiah <charles.alandt at gmail.com> 
#
# Converte logs do fortinet em formato syslog, para formato do squid. 
# Permitindo que seja relatorios de navegação padrão SARG
#
# Modo de uso: cat Fortinet.log | ConverteLogsFortigateSquidIP.pl > log_formato_squid.log

#!/usr/bin/perl

use lib '/usr/local/Multitask/mtadm/bin';
use MTAdm;

my %buffer=();
my %n=();
my $lstData='';
while(<>) {
  next unless (m/ action="?([^\s]+) /);
  my $action=lc(substr($1,0,4));
  next if ($action ne 'pass');

  m/ date=(\d\d\d\d)-(\d\d)-(\d\d) time=(\d\d:\d\d):\d\d /;
  my $data="$3/$2/$1 $4";

#  next unless (m/ user="([^"]+)" /);
#  my $user=lc($1);

  next unless (m/ srcip=([0-9\.]+) /);
  my $srcip=$1;

  m/ service="?([^\s]+?)"? /;
  my $service=lc($1);
  m/ hostname="([^"]+)" .+url="([^"]+)" /;
  my $hostname=$1;
  my $url=$2;
  next unless (m/ sentbyte=(\d+) rcvdbyte=(\d+) /);
  my $bytes=$1+$2;

  if ($lstData) {
    if ($lstData ne $data) {
      my $epoch=ConverteData($lstData);
      foreach my $user (keys %n) {
        my $duration=($n{$user} > 60000) ? 1 : int(60000/$n{$user});
        $n{$user}--;
        foreach my $n (0..$n{$user}) {
          printf "$epoch.%03d $duration %s\n", $n, $buffer{$user}[$n];
        }
      }
      $lstData=$data;
      %buffer=();
      %n=();
    }
  } else {
    $lstData=$data;
  }
  $n{$user}++;
  $n=$n{$user}-1;
  $buffer{$user}[$n]="$srcip TCP_MISS/200 $bytes GET $service://$hostname$url $user - -";
}
my $epoch=ConverteData($lstData);
foreach my $user (keys %n) {
  my $duration=($n{$user} > 60000) ? 1 : int(60000/$n{$user});
  $n{$user}--;
  foreach my $n (0..$n{$user}) {
    printf "$epoch.%03d $duration %s\n", $n, $buffer{$user}[$n];
  }
}
