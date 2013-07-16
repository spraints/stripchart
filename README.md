Show a live chart of your process's memory usage.

## Installation

(todo)

## Usage

You can run this as a monitor of an existing process or processes.

    $ stripmem -p 12345 -p 12344

You can run this as a monitor of a new process and all processes spawned from it.

    $ stripmem tar cfv /dev/null ~
