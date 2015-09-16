#!/usr/bin/perl

################################################################################
# Author:       Logan Sales
# Date:         September 7, 2013
# Class:        CS 5761
#
# Project:      Programming Assignment 1: ELIZA
# Due:          September 23, 2013
#
# Description:
#   Typically ELIZA just takes the form of a psychotherapist however
#   for this program she will be college academic advisor. It should
#   be noted the ELIZA is only as smart as it's programmer and can
#   be improved incrementally with a variety of responses and topics
#   to draw on.
#
# Usage:
#   $ perl Eliza.pl
#   > Hello, how can I help you today?
#   < I am very sad.
#   > What makes you say that?
#   ... etc.
#   To exit the program type "quit" or "exit"
#
# Algorithm:
#   * The main body of the program starts with a greeting to gather information
#     about the user.
#   * The it breaks into a while loop of prompts from the user and replies from
#     ELIZA.
#   * The parsing of the user input is really just a large if-else structure
#     with the most significant things it looks for at the top.
################################################################################

use strict;
use warnings;

use Eliza::Utilities qw(%PATTERNS %RESPONSES);

# information about the user
# some of this is collected initially, but other things like family can be
# gathered throughout the conversation
my %user = (
    name      => "you",
    major     => "",
    location  => "",
    relations => [],
);

my $default_count     = 0;      # incremented every time a default respose is
                                # used
my $DEFAULT_THRESHOLD = 2;      # how many times ELIZA can use a default
                                # response before attempting to change the topic
my $prompt_string     = "=> [$user{name}] ";
my $response_string   = "-> [ELIZA] ";

main();

sub main {
    my $input = "";
    my $exit = 0;
    print greet();
    until ($exit) {
        $input = prompt();
        unless ($input =~ $PATTERNS{quit}) {
            print respond($input);
        }
        else {
            $exit = 1;
        }
    }
    return;
}

sub greet {
    print "This is Eliza The Academic Advisor (PA 1 CS 5761 Fall 2013), programmed by Logan Sales.\n"
        . "If you tire of the conversation at any point, feel free to type \"quit\" or \"exit\" to end the program.\n"
        . $response_string . "Hello, I am an academic advisor. What is your name?\n";

    # collect the user's name
    my $name = prompt();
    $name =~ $PATTERNS{name};
    $user{name} = $+{name};
    $prompt_string = "=> [$user{name}] ";

    print $response_string . "Hello, $user{name}. What is your major?\n";

    # collect the user's major
    my $major = prompt();
    $major =~ $PATTERNS{major};
    $user{major} = $+{major};

    return $response_string . random_response("major") . $user{major} . "?\n";
}

# get input from the user
sub prompt {
    my $input;
    print $prompt_string;
    $input = <STDIN>;
    chomp $input;
    return $input;
}

# respond to the user
sub respond {
    my ($input) = @_;
    my $response = "";  # the initial form of the reply

    if ($input =~ $PATTERNS{crass}) {
        $response = random_response("crass");
    }
    elsif ($input =~ $PATTERNS{unspecific}) {
        $response = random_response("unspecific");
    }
    elsif ($input =~ $PATTERNS{always}) {
        $response = random_response("always");
    }
    elsif ($input =~ $PATTERNS{negative}) {
        $response = random_response("negative");
    }
    elsif ($input =~ $PATTERNS{positive}) {
        $response = random_response("positive");
    }
    elsif ($input =~ $PATTERNS{uncertain}) {
        # get a random response of the same form
        $response = random_response("subject") . "you have to ";

        # add the rest of what the user said for that sentence
        $response .= $+{rest}; 

        # replace I with you
        $response =~ s/I/you/g;
    }
    elsif ($input =~ $PATTERNS{what}) {
        $response = random_response("what");
    }
    elsif ($input =~ $PATTERNS{because}) {
        $response = random_response("because");
    }
    elsif ($input =~ $PATTERNS{apology}) {
        $response = random_response("apology");
    }
    elsif ($input =~ $PATTERNS{relationship}) {
        # get a random relationship response
        $response = random_response("relationship");

        # add the subject to the array of user relationships
        push @{$user{relations}}, $+{subject};

        # finish the reply with the subject and it must be formed as a question
        $response .= $+{subject} . "?";
    }
    elsif ($input =~ $PATTERNS{question}) {
        $response = random_response("question");
    }
    elsif ($input =~ $PATTERNS{thanks}) {
        $response = random_response("thanks");
    }
    elsif ($input =~ $PATTERNS{yes}) {
        $response = random_response("yes");
    }
    elsif ($input =~ $PATTERNS{no}) {
        $response = random_response("no");
    }
    elsif ($input =~ $PATTERNS{subject}) {
        # split the user input on non-word elements
        my @split_input  = split /\W/, $input;

        # join the input back together, but we're really only interested in the
        # first four words
        if (scalar @split_input > 4) {
            $input = join ' ', @split_input[0..3];
        }
        else {
            $input = join ' ', @split_input;
        }

        # get a random response for the subject
        $response = random_response("subject");

        # switch the subject around
        if ($input =~ m/^I/) {
            $input =~ s/I/you/;
        }
        else {
            $input =~ s/You/I/;
        }

        # switch the subject and possession around
        if ($input =~ m/\s+(me|my)/) {
            $input =~ s/\s+me/ you/;
            $input =~ s/\s+my/ your/;
        }
        else {
            $input =~ s/\s+your/ my/;
        }

        # make the subject lower case
        $input =~ s/(He|She|They)/lc($1)/e;

        # combine the response and the manipulated input
        $response .= $input ."?";
    }
    else {

        # choose the default response, if nothing else
        if ($default_count >= $DEFAULT_THRESHOLD) {

            # change the topic
            if (scalar (@{$user{relations}}) > 0) {

                # get a random family member
                my $rand_fam = rand @{$user{relations}};
                $rand_fam = $user{relations}[$rand_fam];

                # start to form the reply
                $response = "Tell me about your ";
                $response .= $rand_fam . ".";

                # remove the family member so they don't come up in conversation
                # again
                @{$user{relations}} = grep { $_ ne $rand_fam } @{$user{relations}};
            }
            else {
                $response = random_response("change_topic"); 
            }
#            if (exists $user{location}) {
#                $response = "Tell me $user{name}, what is $user{location} like?\n";
#            }
#            else {
#            }

            # reset the default count
            $default_count = 0;
        }
        else {
            # otherwise just go with a default response
            $default_count += 1;
            $response = random_response("default");
        }
    }

    return $response_string . $response . "\n";
}

# Get a random response for those that have more than one available, otherwise
# just return the default response if the parameter is utter trash.
sub random_response {
    my ($response) = @_;
    unless (defined $response) {
        $response = "default";
    }
    if (exists $RESPONSES{ $response }) {
        return $RESPONSES{ $response }[rand @{$RESPONSES{ $response }}];
    }
    else {
        return $RESPONSES{default}[rand @{$RESPONSES{default}}];
    }
}
