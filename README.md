TenFour
=======

TenFour is Copyright (c) 2011 by Daniel Swain, dan.t.swain at gmail.com

TenFour is a simple site status monitor using cron and written in Ruby.  TenFour is not meant to be a replacement for full-fledged uptime monitoring sites.  I use it just to make sure the sites I'm responsible for are there and OK.

*Note* I haven't had a chance to test this, but TenFour may not work with Ruby 1.9.x because it uses the Ping built-in, which was discontinued.  If you can confirm this, let me know!

Setup
---

1. Clone the repository: `git clone git://github.com/dantswain/tenfour.git`.
2. In the TenFour directory, run `bundle install`.
3. Edit the configuration file `config/config.yml`.  It should look something like this:

        :sites:
          MySite: http://mysite.com/
          ClientSite: http://www.myclient.com

4. Install the cron job using `./tenfour.rb install`.  You may need to `chmod +x tenfour.rb`

That's it!  By default, the cron job will be set up to run once an hour and output to `status.txt` in the TenFour directory.

Configuration
---

Valid configuration options:

* `:sites:` - A list of sites that you want to check.  Each site should occupy one line in the config file and have the format `Name: url`.
* `:truth:` - A site that is reliably available.  The default is `http://google.com`.  TenFour will use this to guess whether your internet connection is available.  If this site is not available, TenFour will abort and log that the internet connection is unavailable.
* `:output:` - A hash:
** `:filename:` - Filename for output.  If the filename starts with "~" or "/", it will be assumed to be an absolute path.  Otherwise, the path is relative to the path of TenFour.  The default value is "status.txt"
** `:rewrite:` - Set to `true` to rewrite the output file every time TenFour runs.  Otherwise, output is appended.

Example configuration:

    :sites:
      MySite: http://example.com/
      ClientSite: http://foo.com/
    :truth: http://google.com   # here down is optional
    :output:                    
      :filename: ~/site_status.txt
      :rewrite: true

The default cron job frequency is once every hour.  You can change this by modifying `config/schedule.rb`

Command-line Usage
----

* Single command-line use:  `./tenfour.rb`
* To install cron job: `./tenfour.rb install`
* To remove the cron job: `./tenfour.rb uninstall`
