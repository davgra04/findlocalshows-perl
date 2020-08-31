

CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    username TEXT,
    password TEXT
);

CREATE TABLE artists (
    id SERIAL PRIMARY KEY,
    name TEXT,
    bit_id TEXT UNIQUE,
    url TEXT,
    image_url TEXT,
    thumb_url TEXT,
    facebook_page_url TEXT,
    mbid TEXT,
    updated TIMESTAMP
);

CREATE TABLE followed_artists (
    id SERIAL PRIMARY KEY,
    name TEXT,
    first_query_complete BOOLEAN NOT NULL,
    deleted BOOLEAN NOT NULL,
    artist_id TEXT REFERENCES artists(bit_id)
);

-- CREATE TABLE venues (
--     id SERIAL PRIMARY KEY,
--     name TEXT,
--     latitude TEXT,
--     longitude TEXT,
--     city TEXT,
--     region TEXT,
--     country TEXT,
--     updated TIMESTAMP
-- );

-- CREATE TABLE aliases (
--     id SERIAL PRIMARY KEY,
--     alias TEXT,
--     artist_id TEXT REFERENCES artists(id)
-- );

CREATE TABLE events (
    id SERIAL PRIMARY KEY,
    artist_id TEXT REFERENCES artists(bit_id),
    event_id TEXT,
    url TEXT,
    on_sale_datetime TEXT,
    datetime TEXT,
    description TEXT,
    title TEXT,
    -- venue_id INT REFERENCES venues(id),
    venue TEXT,
    country TEXT,
    region TEXT,
    city TEXT,
    lineup TEXT,
    added TIMESTAMP
    -- updated TIMESTAMP,
    -- removed TIMESTAMP
);
