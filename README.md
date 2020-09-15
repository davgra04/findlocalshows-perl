findlocalshows-perl
===================

An implementation of FindLocalShows using Perl and the Mojolicious web framework.

![](images/findlocalshows-perl.png)

## Build

```bash
docker-compose -f docker-compose.dgserv3.flsp.yaml build
```

## Deploy

```bash
# configure findlocalshows-perl
cp config.example.env config.env
vim config.env

# deploy containers
docker-compose -f docker-compose.dgserv3.flsp.yaml up -d
```
