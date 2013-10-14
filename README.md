# Install

```bash
gem install transync
```

You need settings file to be named `transync.yml` and to be in same directory from which we are running `transync` command.
For example see `transync.SAMPLE.yml`.

## Assumptions

You have xliff files in one directory, named like: common.en.xliff where common is name of the file and also google doc
spreadsheet tab. en is language and you have google doc with structure where first row is key, language 1, language 2

## How does it work?

Updating GDoc from our xliff files. It won't delete any key, it will only add new or change existing ones. Same 
for direction from Gdoc to xliff.

### Process

- Create new Google Doc Spreadsheet
- Copy it's `key` from URL to `transync.yml`
- Set all the languages and `xliff` you want to sync in `transync.yml` (look at `transync.SAMPLE.yml`)
- set `XLIFF_FILES_PATH` to set path where are your `xliff` files. In project do it with relative path so others can use it
- set `MISSING_TRANSLATION_TEXT` to set what text should go to `target` element for translation
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

### Gem development

```
rake install && transync x2g|g2x test
ruby g2x_spec.rb
ruby x2g_spec.rb
```

When running with `test` as second argument, changes won't be written to files or spreadsheet.
