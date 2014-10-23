citygram-sf-registries
======================

All of the ETL scripts for Citygram SF

Some sample/WiP connectors can be found in ./connectors.  These are
currently standalone ruby apps that export different data sources
in GeoJSON format.  For more information and a getting started
guide, see http://bit.ly/citygramsf.

## TODO

### General

 * refactor / reorganize the structure later.

### Tow-away

 * data does not include lat/lon, but instead has start/stop street
 numbers and a corresponding street.  We need to geocode this.

### Tree-planting

 * title could be nicer (some trees include species).
