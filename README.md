# Dir Monitoring

Expose dir content modifications using a daemon for filesystem changes detectetion and a http daemon for content visualization

### Configuration

dir-monitoring.pl
- Define $dir variable por specific path to monitor
- Define $logfile variable in order to track changes events

Example: 

---
my $dir = "/home";
my $logfile = "/var/log/newfiles.log";



http-daemon.pl
- Define $dir variable por specific path to monitor
- Define LocalPort in order to bind to the http server


Example

---
my $dir = "/home";
...
'LocalPort' => 8888,
...

