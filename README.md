# automap

Since scanning all ports and UDP can take a while, this tool does it for you in the background. This way, you can focus on other work while the scans run.

## Usage

To start using Nmap Automator, tell it which computers you want to check and choose the type of scan. It can check all TCP ports, just UDP ports, or both, and it saves the results where you want. Ideal for red team activities, CTF challenges, and cybersecurity learning.

## Basic Command Structure
By default, automap will scan both TCP and UDP ports.

```bash
./automap.sh [options] <TARGET_IP_1> [TARGET_IP_2] ...
```

## Options
```bash
./automap.sh -h                                                          

Usage: ./automap.sh [options] <TARGET_IP_1> [TARGET_IP_2] ...
Options:
  -a  Scan all TCP ports.
  -u  Scan UDP ports.
  -d  Specify the directory where the .nmap files will be saved (default is the current directory).
  -h  Show this help message.
```

## Examples
* To check all TCP ports for one computer
```bash
./automap.sh -a 192.168.1.1
```

* To scan only UDP ports
```bash
./automap.sh -u 192.168.1.1 192.168.1.2
```

* To scan both TCP and UDP ports and save the results somewhere specific
```bash
./automap.sh -b -d /path/to/output 192.168.1.1 192.168.1.2
```

Make sure you're allowed to scan the networks you're interested in, and that Nmap is set up on your computer.

## License

See [License](LICENSE).