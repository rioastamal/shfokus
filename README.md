## About shFokus

shFokus is Bash script to make you focus and stay productive by blocking distracting websites such as Facebook, Youtube, Twitter etc. It does the job by modifying your HOSTS file. So when you try to open those distracting websites it will go nowhere.

## Requirements

- Unix or Unix like based OS such as MacOS or Linux. (Windows is not tested)
- Bash version >= 3.2.57

## Installation

Method 1 - Clone the project repository from GitHub.

```
$ git clone git@github.com:rioastamal/shfokus.git
```

Method 2 - Download the zipped version from GitHub.

```
$ curl -O -L 'https://github.com/rioastamal/shfokus/archive/master.zip'
```

And then extract to your desired directory.

## Usage and Examples

Running shFokus with `-h` flag will give you list of options and examples.

```
$ bash ./shfokus.sh -h
```

```
Usage: ./shfokus.sh [OPTIONS]

Where OPTIONS:
  -a ACTION     Specify action name using ACTION.
  -f FILE       List of blocked websites from FILE. Default is ~/.shfokus. Will
                be created if not exists.
  -h            Print this help and exit.
  -r            Dry run mode. Print the content that will be written to hosts
                file.
  -t MINUTES    Specify how long in MINUTES sites should be blocked/unblocked.
                Default is '0' which means blocked/unblocked forever. Make sure
                there is no other shfokus instance running.
  -v            Display shFokus version.

List of available ACTION:
  - block    -> block website
  - unblock  -> release block

Example of ~/.shfokus (one domain per line):
  youtube.com
  www.youtube.com
  facebook.com
  www.facebook.com

Example 1 - Block distracting websites:

  $ sudo bash ./shfokus.sh -a block

Example 2 - Block distracting websites in 30 minutes:

  $ sudo bash ./shfokus.sh -a block -t 30

Example 3 - Unblock distracting websites.

  $ sudo bash ./shfokus.sh -a unblock

Example 4 - Unblock distracting websites in 10 minutes.

  $ sudo bash ./shfokus.sh -a unblock -t 10

-------------------------------- About shFokus --------------------------------

shFokus is Bash script to make you focus and stay productive by blocking
distracting websites such as Facebook, Youtube etc.

shFokus is free software licensed under MIT. Visit the project homepage
at https://github.com/rioastamal/shfokus.
```

### Create List of Distracting Websites

Bear in mind that this step is optional, if you skip this step shFokus will create it automatically. By default it will block Facebook, Youtube, Instagram, Twitter, Twitch and Netflix.

Let's start by creating list of websites that should be blocked. By default shFokus will search for `~/.shfokus` file to determine list of websites. In this example we are going to block Facebook and Twitter.

```
$ vi ~/.shfokus
```

```
facebook.com
www.facebook.coom
twitter.com
www.twitter.com
```

As you can see above you need to specify one domain per line.

### Block Distracting Websites

Because modifying HOSTS file `/etc/hosts` require root privilege then you need to run the command as root or with sudo. To start blocking use option `-a block`.

```
$ sudo bash ./shfokus.sh -a block
```

```
Stay focus and productive -- Have a great day :)
```

If you're concern about what shFokus about to write to your HOSTS file then you can run in dry-run mode first. By running in dry-run mode it will not touch your HOSTS file instead it will print to STDOUT.

```
$ bash ./shfokus.sh -a block -r
```

```
...
# Added by Docker Desktop
# To allow the same kube context to work on the host and the container:
127.0.0.1 kubernetes.docker.internal
# End of section
# shfokus_begin - DO NOT TOUCH
0.0.0.0 facebook.com www.facebook.coom twitter.com www.twitter.com
# shfokus_end
Stay focus and productive -- Have a great day :)
```

Notice that shFokus add new entry between `# shfokus_begin` and `# shfokus_end` at the end of HOSTS file.

### Block for Specific Duration

If you want block distracting websites for specific duration then use `-t` option. It accept value in minutes.

```
$ sudo bash ./shfokus.sh -a block -t 60
```

```
Stay focus and productive -- Have a great day :)
Block will be released in 3587 sec... CTRL+C to unblock
```

Block will automatically released in 60 minutes. If you want to release earlier use CTRL+C.

```
----- Interrupted by CTRL+C -----
Distracting websites has been unblocked -- Enjoy your day :)
```

### Unblock Distracting Websites

To release block of distracting websites use option `-a unblock`. It will remove values from your HOSTS file.

```
$ sudo bash ./shfokus.sh -a unblock
```

```
Distracting websites has been unblocked -- Enjoy your day :)
```

## Author

shFokus is written by Rio Astamal &lt;rio@rioastamal.net&gt;

## License

shFokus is open source licensed under [MIT license](http://opensource.org/licenses/MIT).
