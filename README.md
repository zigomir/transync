# Install

```bash
gem install transync
```

You need settings file to be named `settings.yml` and to be in same directory from which we are running `transync` command.
For example see `settings.SAMPLE.yml`.

### Example

```bash
transync init path/to/your/xliff/files
transync x2g path/to/your/xliff/files
transync g2x path/to/your/xliff/files
```

### Process

- Create new Google Doc Spreadsheet
- Copy it's `key` from URL to `settings.yml`
- Set all the languages and xliff you want to sync in `settings.yml` (look at `settings.SAMPLE.yml`).

### Example for testing within this gem

```bash
rake install && transync x2g test/fixtures
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
