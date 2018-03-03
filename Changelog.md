# Changelog for mi-core-unifi

# Changelog

## core-unifi-5.6.26

### New

* Get SSL Certificate via Lets Encrypt [Max Stockner]
* Import Lets Encrypt certificate into Ubiquity Controller [Max Stockner]
* Added NGINX Proxy [Max Stockner]

## core-unifi-5.0.7

### New

* Accept Java license, remove snappy-java because it&#x27;s working. [Thomas Merkel]
* Move to core dir which allow automatically import because of core-base image. [Thomas Merkel]

### Other

* Core.io readme. [Thomas Merkel]
* Dont use root directory to store temporary settings. [Thomas Merkel]
* Move configuration and installation of UniFi to custimze script. [Thomas Merkel]

  This should be done during the image building to have one stable image
  which matching the correct version number of the software.

* Add comment about what is going on here. [Thomas Merkel]
* Move to default 05 location to matching core.io style. [Thomas Merkel]

  Modify default mount points for delegate datasets

* Keep versioning in manifest file. [Thomas Merkel]
* Migrate configurations to more like our core.io structure. [Thomas Merkel]

## aerrow-unifi-15.4.1

### Other

* Based on 15.4.1 [Arthur van der Peijl]
* No cleanup of root to keep .jar file. [Arthur van der Peijl]
* Update Unify 5.0.7. [Arthur van der Peijl]
* Add files via upload. [Arthur van der Peijl]
* Delete snappy-java-1.1.2.4.jar. [Arthur van der Peijl]
* Update to Unify 5.0.7. [Arthur van der Peijl]
* Update naar 5.0.7. [Arthur van der Peijl]
* Install rsyslog. [Arthur van der Peijl]

## poop-unifi-15.3.0

### Other

* Correct indenting. [Marco Wessel]
* Initial commit. [Marco Wessel]
* Forked from CyBeRoni/mi-poop-unifi
