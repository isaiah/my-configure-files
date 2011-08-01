#!/usr/bin/env ruby
#response = `tail -n 1 /home/isaiah/.getmail/log`
response = `getmail -n`
mailIcon='/usr/share/icons/gnome/32x32/actions/mail-mark-unread.png'
if response =~ /(\d+) messages \(\d+ bytes\) retrieved/
  `notify-send -u 'normal' -t 8000 -i #{mailIcon} "New Mail" "<span color='#33CC00'>You have retrieved #{$1} new mails</span>"` unless $1.to_i == 0
end
