## Developer Setup Notes

### Configuration
  * Copy config/secrets.yml.template to config/secrets.yml
  * Edit config/secrets.yml and paste in a new secret keys

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
script/import_mods_records ../mods-for-adrl/mods_demo_set/demo_sbhcmss36_SantaBarbaraPicturePostcards ../alexandria-images/special_collections/mss36-sb-postcards
script/import_mods_records ../mods-for-adrl/mods_demo_set/demo_sbhcmss78_FlyingAStudios ../alexandria-images/special_collections/spc-flying-a
```

