# QoS-daemon-for-VoIP
==========
This is a small small daemon which may be installed on a home router
(e.g OpenWRT) which will enable QoS for VoIP applications. It monitors
the bandwidth from the VoIP device. If it is high, it will
up-prioritize it. If it returns to normal, it will down-prioritize it.

Details
-------
At the time this was written, I used Vonage VoIP for our telephone service (we now use Google Voice). VoIP means that you have great connections if your Internet connection is fast, and horrible ones otherwise.

I set up quality of service (QoS) for VoIP using OpenWrt and the qos-re package. The way I set it up was that with QoS enabled, all other traffic was limited to 70kbs up/100 kbs down. These are extremely conservative limits for our line speed, but in order for QoS to work, it has to be the bottleneck in the connection. Otherwise, our router will send out VoIP packets first, but they’ll just sit and wait in an upstream queue. That upstream queue has to be empty if we want the VoIP packets to be fast, so we have to throttle all the packets in a queue locally, and then sending VoIP packets first will give us low latency. When a telephone call came in, we would now yell at each other to (a) stop using the Internet and (b) turn on QoS. With QoS running, the voice connection was pretty good. The problem was we’d always forget to turn it off, and throttling our bandwidth by that much caused issues.

At that point, we wanted a script that would turn QoS on when we were on the phone, and turn it off when we got off the phone. We found that `/proc/net/ip_conntrack` would give us the number of packets sent through each connection. We wrote a simple bash script that would look at that number every second, and compare number of packets to the previous timestep. If it was over a threshold for more than 3 steps, it would turn on QoS. If it was under the threshold, it would turn it off.

The thresholds may need some tweaking for some specific setups, but the script works and were running on our WRT54G until it broke: There are two useful files: `qos_daemon` is the actual script. `S96qos` is a two-liner that starts the daemon from `init.d`.

All of this is in the public domain, but if you do use it, acknowledgement in a README, Contributors.txt, flash screen, or similar is appreciated.
