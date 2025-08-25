This plugin moves idle players to the readyroom.
Does not apply to bots, admins and spectators.

Needs compiling from SMA to .amxx with AMXX studio.

Place the compiled amxx in to amxmodx/plugins

Add the following line in amxmodx/config/plugins.ini

AFKRR.amxx

Can be combined with idlekicker.amxx

By default the idle time is 150 sec.
#define IDLE_TIME 150.0 // idle time in seconds


