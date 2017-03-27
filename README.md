# Experimental dockerized [Angelfish](http://analytics.angelfishstats.com/)

Serial number/Server ID is in the form of XXXXX-XXXX-XXXX-XXXX-XXX where X is in [A-Z0-9]

```bash
docker build --build-arg AGFS_SERIAL_NUMBER="XXXXX-XXXX-XXXX-XXXX-XXX" . -t metabrainz/angelfish
docker run --name angelfish -dt -p 9000:9000 metabrainz/angelfish
```
