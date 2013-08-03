# Install

```bash
gem install transync
```

You need settings file to be named `settings.yml` and to be in same directory from which we are running `transync` command.
For example see `settings.SAMPLE.yml`.

### Process

- Create new Google Doc Spreadsheet
- Copy it's `key` from URL to `settings.yml`
- Set all the languages and `xliff` you want to sync in `settings.yml` (look at `settings.SAMPLE.yml`).
- set `XLIFF_FILES_PATH` to set path where are your `xliff` files. In project do it with relative path so others can use it.
- run these commands respectively

### Running order

```
transync test   # test if all keys are set for all the languages: no output means that no key is missing
transync update # will test and add all the missing keys that are not presented for a particular language
transync init   # will sync all translations with Google spreadsheet. You need to run update command first, to ensure no keys are missing.

# After init was made you have these two to sync between gdoc and xliff
transync x2g
transync g2x
```

### Development on this gem

```
rake install && transync test
```

# Assumptions:

You have xliff files in one directory, named like: common.en.xliff where common is name of the file and also google doc
spreadsheet tab. en is language and you have google doc with structure where first row is key, language 1, language 2

# Features

Updating GDoc from our xliff files. It won't delete any key, it will only add new or change existing ones.

# Source

Gem docs available at http://gimite.net/doc/google-drive-ruby

# Known issues

It won't add keys as it should if not all languages are set in settings.yml
