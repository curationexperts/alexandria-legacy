[![Build Status](https://travis-ci.org/curationexperts/alexandria-v2.svg?branch=master)](https://travis-ci.org/curationexperts/alexandria-v2)

## Developer Setup Notes

### Configuration
  * Copy config/secrets.yml.template to config/secrets.yml
  * Edit config/secrets.yml and paste in a new secret keys
  * update the host\_name in config/environments/{environment}.rb

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

### Set up test files:

```
script/import_mods_records ../mods-for-adrl/mods_demo_set/demo_sbhcmss36_SantaBarbaraPicturePostcards ../alexandria-images/special_collections/mss36-sb-postcards/tiff-a16
script/import_mods_records ../mods-for-adrl/mods_demo_set/demo_sbhcmss78_FlyingAStudios ../alexandria-images/special_collections/spc-flying-a/conway-2010/16bit
```

