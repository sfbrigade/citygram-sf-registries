## Notes on the Street Use Permits service

* The data doesn't come from the city with lat/lng, so this service
is using the Geocoder gem to reverse-geocode the `permit_address`.

* If the `permit_address` isn't available, we geocode on the string
"`streetname` and `cross_street_1`, San Francisco, CA"

* Geocoding involves calls to an external serivce, so I made a simple
caching class (HashCache) to save on lookups. In production, I would swap
out HashCache for something like memcache or redis.

* Most of the Street Use Permit-specific logic is in the `lib/street_use_permit`
file. This leaves `lib/application.rb` to load dependencies and query the
SODA API.
