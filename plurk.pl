#!/usr/bin/perl 
#
# Peteris Krumins (peter@catonmat.net)
# http://www.catonmat.net  --  good coders code, great reuse
#
# Command line plurker.
#
# Version 1.0, 2009.12.02: fun release
#
# TODO Ideas:
# * Save cookie after successful login so that the program
#   didn't log in for each plurk.
# * Add <share> action.
# 

# Change these constants to set your username and password.
#
use constant USERNAME => 'your_username';
use constant PASSWORD => 'your_password';

#############################################
# Warning: DO NOT EDIT ANYTHING BELOW HERE! #
#############################################

my $usage = <<EOL;
Usage:
 plurk.pl -u <username> -p <password> -a <action> <message>

You may set your <username> and <password> as constants at the beginning of
the program. Then you may omit -u and -p and use plurker as:
 plurk.pl -a <action> <message>

<Action> is one of loves,  likes, gives, hates, wants, wishes,  needs,
                   will,   hopes, asks,  has,   was,   wonders, feels,
                   thinks, says,  is.    

The default action is 'says'. If you omit -a then the plurker can be used as:

    $ plurk <message>

Sharing a link, photo or youtube video is not currently supported.

<Message> is limited to no more than 140 characters.
EOL

use strict;
use warnings;
use WWW::Mechanize;

use constant VERSION => '1.0';

use constant DEBUG => 0;
use constant ACTIONS =>
    qw/loves  likes gives hates wants wishes  needs
       will   hopes asks  has   was   wonders feels
       thinks says  is/;

my ($username, $password, $action, $message) = parse_args();
print "$username\@$password $action '$message'\n" if DEBUG;

my $plurk = Plurk->new;

print "Logging in to Plurk...\n";
$plurk->login($username, $password);
die $plurk->error if $plurk->error;

print "Plurking...\n";
$plurk->plurk($action, $message);
die $plurk->error if $plurk->error;

print "Plurked: $username $action $message!\n";

sub parse_args {
    my ($username, $password, $action);

    # Extract and parse command line arguments
    my $argstr = join ' ', @ARGV;
    if ($argstr =~ /-u ?([^ ]+)/) { # Username -u
        $username = $1;
        $argstr =~ s/-u ?([^ ]+)//; # Wipe username
    }
    else {
        $username = USERNAME;
    }

    if ($argstr =~ /-p ?([^ ]+)/) { # Password -p
        # Assumes password does not contain spaces
        $password = $1;
        $argstr =~ s/-p ?([^ ]+)//; # Wipe password
    }
    else {
        $password = PASSWORD;
    }

    if ($argstr =~ /-a ?([^ ]+)/) {
        $action = $1;
        unless (grep { $_ eq $action } ACTIONS) {
            print "Error: no such action '$action'\n";
            print "Supported actions: ";
            print join(', ', ACTIONS), "\n";
            exit 1;
        }
        $argstr =~ s/-a ?([^ ]+)//; # Wipe action
    }
    else {
        $action = 'is';
    }

    $argstr =~ s/^ +//; # Wipe leading spaces from message
    unless (length $argstr) {
        print "Error: no message was given\n";
        exit 1;
    }
    if (length $argstr > 140) {
        print "Error: message exceeds 140 characters\n";
        print "It is currently ", length $argstr, " chars long. Please cut ",
              length($argstr) - 140, " char(s)!\n";
        exit 1;
    }
    
    return ($username, $password, $action, $argstr);
}

sub usage {
    print "Command line plurker by Peteris Krumins (peter\@catonmat.net)\n";
    print "http://www.catonmat.net  --  good coders code, great reuse\n";
    print "\n";
    print $usage;
    exit 1;
}

package Plurk;

use LWP::UserAgent;

sub new {
    bless {}, shift;
}

sub _init_mech {
    my $self = shift;
    my $mech = WWW::Mechanize->new(
        timeout   => 10,
        agent     => 'command line plurker/v'.main::VERSION,
        autocheck => 0
    );
    $self->{mech} = $mech;
}

sub login {
    my $self = shift;
    my ($username, $password) = @_;
    $self->_init_mech();
    $self->{mech}->post('http://www.plurk.com/Users/login', {
        nick_name => $username,
        password  => $password
    });
    unless ($self->{mech}->success) {
        $self->_mech_error("Failed logging in to Plurk.");
        return;
    }
    unless ($self->{mech}->content =~ /var SETTINGS/) {
        $self->error("Failed logging in to Plurk. Check your username/password.");
        return;
    }
    $self->{uid}  = $self->_extract_uid;
    $self->{lang} = $self->_extract_lang;
}

sub plurk {
    my ($self, $action, $msg) = @_;

    $self->{mech}->post('http://www.plurk.com/TimeLine/addPlurk', {
        qualifier   => $action,
        content     => $msg,
        uid         => $self->{uid},
        no_comments => 0,
        lang        => $self->{lang}
    });
    unless ($self->{mech}->success) {
        $self->_mech_error("Failed plurking.");
        return;
    }
}

sub _mech_error {
    my ($self, $error) = @_;
    $self->error($error, "HTTP Code:", $self->{mech}->status(), ".",
                         "Content:", substr($self->{mech}->content, 0, 512));
}

sub _extract_uid {
    my $self = shift;
    return $self->_extract_stuff('SETTINGS', 'user_id', '(\d+)');
}

sub _extract_lang {
    my $self = shift;
    return $self->_extract_stuff('GLOBAL', 'default_lang', '"([^"]+)"');
}

sub _extract_stuff {
    my ($self, $section, $name, $rx) = @_;
    if ($self->{mech}->content =~ /$section.+"$name": $rx/) {
        return $1;
    }
    else {
        $self->error("Failed extracting $name.");
    }
}

sub error {
    my $self = shift;
    return $self->{error} unless @_;
    $self->{error} = "@_";
}

