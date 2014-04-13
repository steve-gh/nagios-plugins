#!/usr/bin/perl -T
# nagios: -epn
#
#  Author: Hari Sekhon
#  Date: 2014-04-11 20:11:15 +0100 (Fri, 11 Apr 2014)
#
#  http://github.com/harisekhon
#
#  License: see accompanying LICENSE file
#

# still calling v1 for compatability with older CM versions
#
# http://cloudera.github.io/cm_api/apidocs/v1/index.html

$DESCRIPTION = "Nagios Plugin to check Cloudera Manager version via Rest API

Using v1 of the API for compatability purposes

Tested on Cloudera Manager 4.8.2 and 5.0.0";

$VERSION = "0.1";

use strict;
use warnings;
BEGIN {
    use File::Basename;
    use lib dirname(__FILE__) . "/lib";
}
use HariSekhonUtils;
use HariSekhon::ClouderaManager;

$ua->agent("Hari Sekhon $progname version $main::VERSION");

my $api_ping;
my $cluster_version;
my $cm_version;
my $expected;
my $validate_config;

%options = (
    %hostoptions,
    %useroptions,
    %cm_options_tls,
    "e|expected=s"      =>  [ \$expected,           "Expected version regex (optional)" ],
);

@usage_order = qw/host port user password tls ssl-CA-path tls-noverify expected/;

get_options();

$host       = validate_host($host);
$port       = validate_port($port);
$user       = validate_user($user);
$password   = validate_password($password);

my $expected_regex = validate_regex($expected) if defined($expected);

vlog2;
set_timeout();

$status = "OK";

$url = "$api/cm/version";
cm_query();
unless($json->{"version"}){
    quit "CRITICAL", "version field not returned from Cloudera Manager. $nagios_plugins_support_msg_api";
}
$msg = "Cloudera Manager version '" . $json->{"version"} . "'";
if(defined($expected_regex)){
    unless($json->{"version"} =~ $expected_regex){
        critical;
        $msg .= " (expected: '$expected')";
    }
}

quit $status, $msg;