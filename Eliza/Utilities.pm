package Eliza::Utilities;

################################################################################
# Eliza::Utilities
# Description: This module mostly contains patterns the Eliza will look for and
#              any replies it might have to them.
# Note: Some of these replies have been adapted from An Eliza Script from the
#       January 1966 Communications of the ACM by Joseph Weizenbaum.
################################################################################

use strict;
use warnings;

use base qw(Exporter);

use Readonly;

our @EXPORT    = qw();
our @EXPORT_OK = qw(%PATTERNS %RESPONSES);

Readonly our %PATTERNS => (
    subject => qr{
        \A                                  # from the start of the string
        \s*                                 # optional leading whitespace
        (?<subject>(I|You|She|He|They))     # subject key words
        \s+                                 # spaces
        (?<verb>\w+)                        # verb key word
        \s+                                 # spaces
        (?<self>(your|my|me|their))         # the other subject of the sentence
        \s+                                 # space
        (?<noun>\w+)                        # noun key word
    }xmsi,

    name => qr{
        (                       # a few optional ways to start the sentence
            My\sname\sis\s|     # "My name is"
            I'm\s|              # etc
            I\sam\s
        )?
        \b
        (?<name>\w+)            # the name we are looking for
        \b
    }xmsi,

    major => qr{
        (
            It's\s|
            It\sis\s|
            My\smajor\sis\s|
        )?
        \b
        (?<major>\w+(\s+\w+)?)      # the major we are looking for
        \b
    }xmsi,

    quit => qr{
        \A              # from the begining of the string
        (quit|exit)     # end program key words
        \z              # to the end of the string
    }xmsi,

    negative => qr{     # this simply looks for a lot of generally negitive words
        \b
        (
            probation |
            expulsion |
            expelled |
            give\sup |
            lose |
            loss |
            lost |
            worried |
            scared |
            fail |
            stress |
            stressed |
            upset
        )
        \b
    }xmsi,

    positive => qr{         # similar to negative but on a positive note
        \b
        (
            Dean's\sList |
            honors |
            promotion |
            offer |
            good |
            position |
            fun |
            vacation |
            job         # arguable on whether this is indeed positive
        )
        \b
    }xmsi,

    apology => qr{
        \b
        sorry       # why are you apologizing to a machine?
        \b
    }xmsi,

    relationship => qr{     # specific relationship key words
        \b
        my
        \s+
        (?<subject>(
                mother |    # how I met your mother
                mom |
                father |
                dad |
                brother |
                sister |
                husband |
                wife
            )
        )
        \b
    }xmsi,

    yes => qr{
        \b
        yes     # indeed
        \b
    }xmsi,

    no => qr{
        \b
        no      # negatory
        \b
    }xmsi,

    question => qr{
        \b
        question    # so many questions
        \b
    }xmsi,

    thanks => qr{
        \b
        (thank\syou|thanks)     # Thanking a machine, I see.
        \b
    }xmsi,

    uncertain => qr{    # another way to ask questions
        \b
        Do\s+I\s+                   # the "do I" is necessary
        (have\sto\s|need\sto\s)?    # have/need to is optional
        (?<rest>.*(\.|\?))          # the part we will regurgitate
    }xmsi,

    unspecific => qr{
        \b
        (
            everyone |      # who?
            everybody |
            someone |
            somebody |
            nobody |
            noone
        )
        \b
    }xmsi,

    always => qr{
        \b
        always      # all the time
        \b
    }xmsi,

    what => qr{
        \A          # from the start of the string
        \s*         # optional yucky leading whitespace
        What        # ?!
        \b
    }xmsi,

    because => qr{
        \A
        \s*
        because     # because because because!
        \b
    }xmsi,

    crass => qr{        # the G version :P
        \b
        (
            stupid |
            idiot |
            shut\sup |
            crap |
            hell
        )
        \b
    }xmsi,
);

# These reponses are pretty self-explainitory. Many of them correspond to
# patterns above, but some can be used with others. However some are up to
# the programmer to complete with whatever the user says.
Readonly our %RESPONSES => (
    greeting => "",

    default => [
        "Tell me more.",
        "Go on.",
        "Can you elaborate on that?",
        "That's quite interesting.",
    ],

    subject => [
        "What makes you say ",
        "What makes you think ",
        "Why do you say ",
        "Why do you think ",
    ],

    major => [
        "Do you like ",
        "Are you enjoying ",
    ],

    change_topic => [
        "What plans are you making for your future?",
        "Have you thought about what you might do after you graduate?",
        "Tell me more about your family.",
    ],

    negative => [
        "That's too bad. What do you think you can do to fix the situation?",
        "I'm sorry to hear that. Perhaps things will work out better?",
    ],

    positive => [
        "Good to hear. You must feel good about that.",
        "You must feel excited",
    ],

    apology => [
        "Please don't apologize.",
        "Apologies are not necessary.",
    ],

    relationship => [
        "What does this have to do with your ",
        "Can you tell me more about your ",
    ],

    yes => [
        "You seem quite positive.",
        "You are sure.",
        "Are you sure?",
        "I see.",
        "I understand.",
    ],

    no => [
        "Are you saying \'no\' just to be negative?",
        "You are being a bit negative.",
        "Why not?",
    ],

    question => [
        "Indeed. How can I assist you?",
        "Of course. How can I help you?",
    ],

    thanks => [
        "You're welcome. Is there anything I can help you with?",
        "Not a problem. Now is there anthing I can assist you with?",
    ],

    unspecific => [
        "Can you think of anyone in particular?",
        "Who, for example?",
        "Are you thinking of anyone in particular?",
        "Who, may I ask?",
        "Someone special perhaps?",
        "You have a particular person in mind, don't you?",
    ],

    always => [
        "Can you think of a specific example?",
        "When?",
        "What incident are you thinking of?",
        "Really, always?",
    ],

    what => [
        "Does that question interest you?",
        "What is it you really want to know?",
        "Why are such questions on your mind?",
        "What answer would please you most?",
        "What do you think?",
        "What comes to your mind when you ask that?",
        "Have you asked such a question before?",
        "Have you asked anyone else?",
    ],

    because => [
        "Is that the real reason?",
        "Don't any other reasons come to mind?",
        "Does that reason seem to explain anything else?",
        "What other reasons might there be?",
    ],

    crass => [
        "Let's try to keep things civil.",
        "I hope you don't kiss your mother with that mouth.",
        "There's no need for language like that here.",
        "I understand you're upset, but let's not use language like that here.",
    ],
);

1;
