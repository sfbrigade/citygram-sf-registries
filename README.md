citygram-sf-registries
======================

All of the ETL scripts for Citygram SF

Our two initial datasets are new Tree Plantings and temporary Tow Away Zones. Both ETL routes are described in app.rb. For more information and a getting started
guide, see http://bit.ly/citygramsf.

## TODO

### General

 * refactor / reorganize the structure later.

### Tow-away

 * data does not include lat/lon, but instead has start/stop street
 numbers and a corresponding street.  We need to geocode this.

### Tree-planting

 * title could be nicer (some trees include species).
