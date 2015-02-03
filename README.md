[![Build Status](https://travis-ci.org/curationexperts/alexandria-v2.svg?branch=master)](https://travis-ci.org/curationexperts/alexandria-v2)

## Developer Setup Notes

### Configuration
  * Copy `config/secrets.yml.template` to `config/secrets.yml`
  * Edit `config/secrets.yml` and paste in a new secret key
  * update the host\_name in `config/environments/{environment}.rb`
  * Copy `config/smtp.yml.template` to `smtp/secrets.yml` and edit the file

### Set up Jetty

```
rake jetty:unzip
rake jetty:start
```

### Install imagemagick

On a mac:
```
brew install imagemagick --with-jp2 --with-libtiff --with-ghostscript
```

### Run the test suite

  * Make sure jetty is running
  * `bundle exec rake spec`

### Import Data

```
script/import_mods_records ../mods-for-adrl/mods_demo_set/demo_sbhcmss36_SantaBarbaraPicturePostcards ../alexandria-images/special_collections/mss36-sb-postcards/tiff-a16
script/import_mods_records ../mods-for-adrl/mods_demo_set/demo_sbhcmss78_FlyingAStudios ../alexandria-images/special_collections/spc-flying-a/conway-2010/16bit
```

