
--------------------------------------------------------------------------------
-- Create necessary tables
--------------------------------------------------------------------------------

-- contains artist data queried from bandsintown
CREATE TABLE artists (
    id INT GENERATED ALWAYS AS IDENTITY,
    name TEXT,
    bit_id TEXT UNIQUE,
    url TEXT,
    image_url TEXT,
    thumb_url TEXT,
    facebook_page_url TEXT,
    mbid TEXT,
    updated TIMESTAMP
);

-- contains event data queried from bandsintown
CREATE TABLE events (
    id INT GENERATED ALWAYS AS IDENTITY,
    artist_id TEXT REFERENCES artists(bit_id),
    event_id TEXT,
    url TEXT,
    on_sale_datetime TEXT,
    datetime TEXT,
    description TEXT,
    title TEXT,
    venue TEXT,
    country TEXT,
    region TEXT,
    city TEXT,
    lineup TEXT,
    added TIMESTAMP
);

-- contiains users and their associated password and settings
CREATE TABLE users (
    id INT GENERATED ALWAYS AS IDENTITY,
    username TEXT,
    password TEXT
);

-- contiains list of artists followed by the user
CREATE TABLE followed_artists (
    id INT GENERATED ALWAYS AS IDENTITY,
    name TEXT,
    first_query_complete BOOLEAN NOT NULL,
    deleted BOOLEAN NOT NULL,
    artist_id TEXT REFERENCES artists(bit_id)
);

-- contains list of findlocalshows-supported regions
CREATE TABLE supported_regions (
    id INT GENERATED ALWAYS AS IDENTITY,
    region TEXT
);

CREATE TABLE settings (
    id INT GENERATED ALWAYS AS IDENTITY,
    secret TEXT NOT NULL
);

--------------------------------------------------------------------------------
-- Pre-populate tables
--------------------------------------------------------------------------------

INSERT INTO supported_regions (region) VALUES ('Virtual'), ('AL'), ('AK'), ('AZ'),
    ('AR'), ('CA'), ('CO'), ('CT'), ('DE'), ('FL'), ('GA'), ('HI'), ('ID'), ('IL'),
    ('IN'), ('IA'), ('KS'), ('KY'), ('LA'), ('ME'), ('MD'), ('MA'), ('MI'), ('MN'),
    ('MS'), ('MO'), ('MT'), ('NE'), ('NV'), ('NH'), ('NJ'), ('NM'), ('NY'), ('NC'),
    ('ND'), ('OH'), ('OK'), ('OR'), ('PA'), ('RI'), ('SC'), ('SD'), ('TN'), ('TX'),
    ('UT'), ('VT'), ('VA'), ('WA'), ('WV'), ('WI'), ('WY');
