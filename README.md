# Install

  gem 'rubber_ring', :git => 'git://github.com/zigomir/rubber_ring.git'

You need settings file needs to be named `settings.yml`. For example see `settings.SAMPLE.yml`.

### Example

    transync x2g path/to/your/xliff/files
    transync g2x path/to/your/xliff/files

### Example for testing within this gem

    rake install && transync x2g test/fixtures

# Assumptions:

You have xliff files in one directory, named like: common.en.xliff where common is name of the file and also google doc
spreadsheet tab. en is language and you have google doc with structure where first row is key, language 1, language 2

# Config

Google doc
https://docs.google.com/a/astina.ch/spreadsheet/ccc?key=0ApAHdLDpSUFudHhuWU9vQ0ZPaWNoV3VxU045cXhHLWc#gid=3
key = 0ApAHdLDpSUFudHhuWU9vQ0ZPaWNoV3VxU045cXhHLWc


GDOC_KEY = 0ApAHdLDpSUFudHhuWU9vQ0ZPaWNoV3VxU045cXhHLWc

# Features

Updating GDoc from our xliff files. It won't delete any key, it will only add new or change existing ones.

# Source

Gem docs available at http://gimite.net/doc/google-drive-ruby

# Known issues

It won't add keys as it should if not all languages are set in settings.yml

# TODO

- support for yaml files
