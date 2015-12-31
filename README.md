# raspi-pix
A set of shell scripts and systemd units to co-ordinate periodic taking of photos and transferring them to a web server. 
All raspberry pi-s.

The raspberry pi-s are all running arch linux. This means that systemd is a fact of life. This is the first time I have used it to replace cron jobs.

I leant some hard lessons about the difference between systemd units and bash scripts. In a nutshell, put all but the simplest tasks in scripts and call them from ExecStart.
Variable subsitution doesn't work in systemd.


Network topology
----------------

### Originating (cam-equipped) hosts

### Agreggator and web server



