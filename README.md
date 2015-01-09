## Developer Setup Notes

### Configuration
  * Copy config/secrets.yml.template to config/secrets.yml
  * Edit config/secrets.yml and paste in a new secret keys

### Set up Jetty

```
rake jetty:unzip
rake jetty:start
```

### Set up test files:

```
script/import_mods_records ../mods-for-adrl/mods_demo_set
```

