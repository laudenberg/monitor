# Monitor

Small utilities to monitor server resources from the inside and outside. They track statistics every minute and aggregate them over hours, days and months and send mail alerts when values get critical.

## Requirements

* All periodically invoked scripts are `bash` and `awk`.
* `arguments-from-config.rb` is used by `cron.sh` at installation to read JSON data from a file and write arguments for `collect.sh` and requires `ruby`.
* `alert.rb` is used to send meaningful information per mail when critical values show up and also requires `ruby`.
* `curl` is used when specifying `-ping` to benchmark a web request.
* Mail is sent via `mailx` command.

## Installation

1. Clone this repository.
2. `cd monitor`
3. `./bootstrap.sh` creates data directory and files.
4. Edit `config.json` to fit your needs and copy it to `./data`.
5. `./cron.sh data/config.json` outputs cron jobs.
6. `crontab -e` and add cron jobs to crontab.
7. Remove first line from data/minute, because network delta is skewed.

## Usage and Functionality

See example `config.json` on what is possible. Hopefully this is self explanatory enough.

Everything is written to files in the `data`-directory. For every timespan in `minute`, `hour`, `day`, `month` there is a file of that name where averages are written, once every time the cron job for that timespan is executed. `hour` averages over the last 60 lines of `minute` and so on. Additionally, this aggregation is done every minute for every timespan such that ongoing months, days and hours get live data. These are stored with the `-live` suffix. The large logs are additionally truncated such that the last 100 lines of every timespan is written to files with suffix `-100`.

## `collect.sh`

`collect.sh` is the workhorse for collecting data and invoking alerts when critical values are observed. You ususally don't need to specify arguments directly, because `cron.sh` builds its command line from `config.json`. It builds a line in the log file based on and in the order of arguments specified:

* `-timestamp` adds a timestamp in seconds since epoch.
* `-load` adds the one minute load average.
* `-mem` adds free memory in %.
* `-disk "/"` adds free space in % of the mount point specified.
* `-down "eth0"` adds number of downloaded bytes in the last minute.
* `-up "eth0"` adds number of uploaded bytes in the last minute
* `-ping "https://www.google.com/"` adds amount of time `curl` took to get the specified web page. On status code other than `200`, a value of 11 is written. When the request fails fatally, the value is 12.

A line in the log file could look like this:

`1487342401 0.11 30 14 47580 124069 0.078`

Additionally `collect.sh` needs to know at what critical values mails need to be sent and from which config file these commands are read. The shell script dows not evaluate the config file by itself but passes it on to scripts which need it.

* `-alerts "NULL 2 90 90 NULL NULL 10"` specifies at what values mails are sent. `NULL` means no mail is sent at all. The example in conjunction with the log line above would mean mails are sent if:
    - load is greater or equals 2
    - less than 10 per cent free memory
    - less than 10 per cent free disk space
    - the web request fails or takes longer than 10 seconds
* `-config data/config.json` specifies which config file built this command line

All of the above functionality is specified in `config.json`. Fields that should appear in the log file need to be wrapped inside an `aggregate` to be able to tag the fields with a server name or similiar. Personally, I use this to separate local from remote information (like ping).

### ping

`ping` is the only operation in `collect.sh` that could take some time longer than a second. When multiple pings are specified they are executed in parallel. This was fun to implement in bash.

I use `ping` not to check the local internet connection of the machine running the monitor but to cross-check websites on my other servers.

The 10 seconds request limit and error values of 11 and 12 seconds are hard-coded for now, I'm deeply sorry.

### down and up

`down` and `up` are used to log data traffic in the last minute. The implementation is clunky right now, as it reads RX and TX data from `/proc/net/dev`, saves old values in `data/down` and `data/up` and calculates the delta every minute. In consequence, only a single interface is supported right now. Also, reboots reset the RX and TX counters such that the first recorded minute after usually results in negative traffic which in turn is set to 0.

## Workflow

A user needs these commands:

* `bootstrap.sh` creates `data` directories and files
* `cron.sh` outputs `collect.sh` and `average-and-truncate.sh` commands to add to crontab.
    - `arguments-from-config.rb` reads `config.json` to write command line arguments for cron jobs.

These commands are called from cron:

* `collect.sh` collects and writes log data.
    - `average.sh` averages data for `hour-live`, `day-live`, `month-live`.
    - `truncate.sh` truncates `minute-100` to 100 last lines.
    - `check-alert.sh` checks logged values against critical values.
        + `alert.rb` sends mail alerts if critical values are exceeded.
* `average-and-truncate.sh` uses `average.sh` and `truncate.sh` to write `hour`, `day`, `month`, `hour-100`, `day-100`, `month-100`.


## Evaluation

`collect.sh` writes data for easy visualization. I usually look at a line graph per field, with lines for each timespan. For this, the `-live`-files in addition to the `-100`-files can be used. I save the `config.json` inside the `data`-folder because it can give the visualization software context.

## Known issues

* Network traffic calculation is clunky.
* Maximum values for web requests are hard-coded.
* Aggregation over hours, days and months are based on line count and not on timestamps.
* Mails are sent multiple times as long as the critical value is exceeded.
