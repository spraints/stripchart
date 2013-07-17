Show a live chart of your process's memory usage.

## Installation

To use stripmem in an existing application, add it to your Gemfile

    gem 'stripmem'

To use stripmem standalone, install it.

    gem install stripmem

## Usage

You can run this as a monitor of a new process and all processes spawned from it.

    $ stripmem tar cfv /dev/null ~

If you installed it in your Gemfile, you can monitor your rails server process, too:

    $ bundle exec stripmem rails server

To view the chart, open http://localhost:9999/
