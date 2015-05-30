# Install

```bash
gem install transync
```

You need settings file to be named `transync.yml` and to be in same directory from which we are running `transync` command.
For example see `transync.SAMPLE.yml`.

## Google Drive OAuth

You'll need to create an API project for Google Drive. Good instructions are written
[here](https://github.com/google/google-api-ruby-client-samples/tree/master/drive#enable-the-drive-api).
Just copy and paste `client_id` and `client_secret` into `transync.yml` file.

## Assumptions

You have xliff files in one directory (I suggest `app/Resources/translations`), named like: `common.en.xliff` where `common`
is name of the file and also GDoc `spreadsheet tab`. `en` is language and you have GDoc with structure where
first row is `key`, `language 1`, `language 2`, ...

## How does it work?

Updating GDoc from our xliff files. It won't delete any key, it will only add new or change existing ones. Same
for direction from GDoc to xliff.

### Process

- Create new Google Doc Spreadsheet
- Copy it's `key` from URL to `transync.yml`
- Set all the languages and `xliff` files (without language) you want to sync in `transync.yml` (look at `transync.SAMPLE.yml`)
- set `XLIFF_FILES_PATH` to set path where are your `xliff` files. In project do it with relative path so others can use it
- set `MISSING_TRANSLATION_TEXT` to set what text should go to `target` element for translation
- run these commands respectively

### Running order

```
transync test   # test if all keys are set for all the languages. Also tests if everything in sync with GDoc
transync update # will test and add all the missing keys that are not presented for a particular language in XLIFF files
transync init   # will write all translations from XLIFF to GDoc spreadsheet. You need to run update command first, to ensure no keys are missing

# After init was made you have these two to sync modes between Gdoc and XLIFF
transync x2g
transync g2x
```

### Gem development

#### Running tests
```
ruby g2x_spec.rb
ruby x2g_spec.rb
ruby update_spec.rb
```

## TODO

- use ruby's 2.0 named parameters (more clear method calls)
- better tests (move out network dependency -> maybe try VCR, run all tests with RAKE)
- add to travis / code climate
