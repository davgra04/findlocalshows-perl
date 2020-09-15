findlocalshows-perl
===================

![](images/findlocalshows-perl.png)

An implementation of FindLocalShows using Perl and the Mojolicious web framework.

## Build

```bash
docker-compose -f docker-compose.dgserv3.flsp.yaml build
```

## Deploy

```bash
# configure findlocalshows-perl
cp flsp.config.example.env flsp.config.env
vim flsp.config.env

# deploy containers
docker-compose -f docker-compose.dgserv3.flsp.yaml up -d
```
