#
# Regular cron jobs for the freeswitch package
#
0 4	* * *	root	[ -x /usr/bin/freeswitch_maintenance ] && /usr/bin/freeswitch_maintenance
