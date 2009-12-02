This is a Perl program that allows you to plurk from command line.

It was written by Peteris Krumins (peter@catonmat.net).
His blog is at http://www.catonmat.net  --  good coders code, great reuse.

The code is licensed under the GPL license.

Meet Peteris on Plurk: http://www.plurk.com/pkrumins

------------------------------------------------------------------------------

How to use this program.
------------------------

First you will need to set your username and password. You can do it this way:

Open plurk.pl and find these two lines at the beginning of the file:

    use constant USERNAME => 'your_username';
    use constant PASSWORD => 'your_password';

Change 'your_username' to your username, and 'your_password' to your password.

You can now plurk! Here is how to do it:

    $ ./plurk.pl [-a <action>] <message>

The default action is "says". You may set it to any of the following:

    loves,  likes, gives, hates, wants, wishes,  needs,
    will,   hopes, asks,  has,   was,   wonders, feels,
    thinks, says,  is. 

The "shares" action is not yet supported.

Here are some examples:

    $ ./plurk.pl -a thinks it's going to rain today

    This will plurk that you are thinking that "it's going to rain today".

    $ ./plurk.pl -a has read more books

    This will plurk that you have "read more books".

    $ ./plurk.pl hello world

    This will plurk that you say "hello world".


PS. There are actually two more command line arguments -u and -p, you can use
them to change your username and password on the fly.

For example:

    $ ./plurk.pl -u ateam -p bazooka "your plurk message here"

    This will plurk "your plurk message here" from user "ateam" with password
    "bazooka".

------------------------------------------------------------------------------

Happy plurking!


Sincerely,
Peteris Krumins
http://www.catonmat.net

