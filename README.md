Show a live chart of your process's memory usage.

![example](https://f.cloud.github.com/assets/20158/812189/e4b87038-eeeb-11e2-9ead-f4c4e6b5b589.png)

## Installation

To use stripmem in an existing application, add it to your Gemfile

    gem 'stripchart'

To use stripmem standalone, install it.

    gem install stripchart

## Usage

Start it up like this:

    $ while true; do sleep 0.5 ; echo n $RANDOM; done | stripchart

To view the chart, open http://localhost:9999/
