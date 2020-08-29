
CREATE TABLE artists (
    id INTEGER NOT NULL PRIMARY KEY,
    name TEXT,
    bit_id TEXT,
    url TEXT,
    image_url TEXT,
    thumb_url TEXT,
    facebook_page_url TEXT,
    mbid TEXT,
    updated TIMESTAMP
);

CREATE TABLE venues (
    id INTEGER NOT NULL PRIMARY KEY,
    name TEXT,
    latitude TEXT,
    longitude TEXT,
    city TEXT,
    region TEXT,
    country TEXT,
    updated TIMESTAMP
);

CREATE TABLE aliases (
    id INTEGER NOT NULL PRIMARY KEY,
    alias TEXT,
    artist_id INTEGER REFERENCES artists(id)
);

CREATE TABLE events (
    id INTEGER NOT NULL PRIMARY KEY,
    artist_id INTEGER REFERENCES artists(id),
    url TEXT,
    on_sale_datetime TEXT,
    datetime TEXT,
    description TEXT,
    title TEXT,
    venue_id INTEGER REFERENCES venues(id),
    lineup TEXT,
    added TIMESTAMP,
    updated TIMESTAMP,
    removed TIMESTAMP
);
