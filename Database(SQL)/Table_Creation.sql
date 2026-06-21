CREATE TABLE markets (
    market_id INTEGER PRIMARY KEY,
    market TEXT,
    countryiso3 TEXT,
    admin1 TEXT,
    admin2 TEXT,
    latitude REAL,
    longitude REAL
);

CREATE TABLE prices (
    date DATE,
    market_id INTEGER,
    category TEXT,
    commodity TEXT,
    commodity_id INTEGER,
    unit TEXT,
    pricetype TEXT,
    currency TEXT,
    price REAL,
    usdprice REAL,

    FOREIGN KEY (market_id)
    REFERENCES markets(market_id)
);
