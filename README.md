[![Build Status](https://travis-ci.org/curationexperts/alexandria-v2.svg?branch=master)](https://travis-ci.org/curationexperts/alexandria-v2)

## Developer Setup Notes

### Configuration
  * Copy `config/ezid.yml.template` to `config/ezid.yml`
  * Copy `config/secrets.yml.template` to `config/secrets.yml`
  * Edit `config/secrets.yml` and paste in a new secret key
  * update the host\_name in `config/environments/{environment}.rb`
  * Copy `config/smtp.yml.template` to `smtp/secrets.yml` and edit the file

### Set up Jetty

```
rake jetty:unzip
rake jetty:start
```

### Set up Marmotta

Download and unzip: https://github.com/curationexperts/marmotta-standalone/archive/master.zip

Go into the unpacked archive and start it up.
```
java -jar start.jar -Xmx1024mb -Djetty.port=8180
```

Then configure it to connect to a Postgres instance by following the directions here:
http://marmotta.apache.org/configuration.html

### Install imagemagick

On a mac:
```
brew install imagemagick --with-jp2 --with-libtiff --with-ghostscript
```

### Run the test suite

  * Make sure jetty is running
  * `bundle exec rake spec`

### Seed the admin policies

```
rake db:seed
```

### Import Data

```
script/import_mods_records ../mods-for-adrl/mods_demo_set/demo_sbhcmss36_SantaBarbaraPicturePostcards ../alexandria-images/special_collections/mss36-sb-postcards/tiff-a16

script/import_mods_records ../mods-for-adrl/mods_demo_set/demo_sbhcmss78_FlyingAStudios ../alexandria-images/special_collections/spc-flying-a/conway-2010/16bit

script/import_mods_records ../mods-for-adrl/mods_demo_set/collection_records ./tmp
```

The first argument to the script is the directory that contains the MODS files.  The second argument is the directory that contains supporting files, such as image files.

Note:  When importing collections, the 2nd argument won't actually be used, so you can set it to any valid directory.

