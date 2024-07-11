CREATE KEYSPACE IF NOT EXISTS safesentry WITH REPLICATION = { 'class' : 'SimpleStrategy', 'replication_factor' : '1' };

CREATE TABLE IF NOT EXISTS safesentry.shopping_cart (
userid text PRIMARY KEY,
item_count int,
last_update_timestamp timestamp
);
