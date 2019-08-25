CREATE TYPE INVENTORY_ITEM_CHANGE AS ENUM ('added', 'removed');

CREATE TABLE inventory (
    id SERIAL PRIMARY KEY,
    name VARCHAR(128) UNIQUE,
    price INTEGER
);

COMMENT ON COLUMN inventory.name IS 'The unique name of the inventory item';
COMMENT ON COLUMN inventory.price IS 'The default sales price of the item';

CREATE TABLE transactions (
    id SERIAL PRIMARY KEY,
    amount INTEGER NOT NULL,
    description TEXT,
    time TIMESTAMP NOT NULL DEFAULT now()
);

COMMENT ON COLUMN transactions.amount IS
    'The amount of money that was transferred in the transaction';

CREATE TABLE transaction_bundles (
    id SERIAL PRIMARY KEY,
    transaction_id INTEGER NOT NULL REFERENCES transactions(id),
    bundle_price INTEGER CHECK (bundle_price >= 0),
    change INTEGER NOT NULL
);

COMMENT ON TABLE transaction_bundles IS
    'A bundle of items in a transaction. For single items or groups of items that are sold as a package.';
COMMENT ON COLUMN transaction_bundles.bundle_price IS
    'The actual price of the item bundle in this transaction. For human reference only.';

CREATE TABLE transaction_items (
    id SERIAL PRIMARY KEY,
    bundle_id INTEGER NOT NULL REFERENCES transaction_bundles(id),
    item_id INTEGER NOT NULL REFERENCES inventory(id)
);

COMMENT ON TABLE transaction_items IS
    'Individual items in a tansaction bundle.';


CREATE FUNCTION transaction_balance() RETURNS INTEGER AS $$
    SELECT COALESCE(SUM(amount)::INTEGER, 0) FROM transactions;
$$ language sql;

-- Show the number of inventory items in stock by counting added
-- transaction_items and subtracting removed transaction_items.
CREATE MATERIALIZED VIEW inventory_stock AS
SELECT i.id, i.name, COALESCE(SUM(change), 0)::INTEGER AS stock FROM inventory as i
	LEFT JOIN transaction_items AS item ON item.item_id = i.id
	LEFT JOIN transaction_bundles as bundle ON bundle.id = item.bundle_id
GROUP BY i.id, i.name;

CREATE FUNCTION refresh_inventory_stock()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
    REFRESH MATERIALIZED VIEW inventory_stock;
    RETURN NULL;
END
$$;

CREATE TRIGGER refresh_inventory_stock
AFTER INSERT OR UPDATE OR DELETE OR TRUNCATE
ON inventory
FOR EACH STATEMENT
EXECUTE PROCEDURE refresh_inventory_stock();

CREATE TRIGGER refresh_inventory_stock
AFTER INSERT OR UPDATE OR DELETE OR TRUNCATE
ON transaction_bundles
FOR EACH STATEMENT
EXECUTE PROCEDURE refresh_inventory_stock();

CREATE TRIGGER refresh_inventory_stock
AFTER INSERT OR UPDATE OR DELETE OR TRUNCATE
ON transaction_items
FOR EACH STATEMENT
EXECUTE PROCEDURE refresh_inventory_stock();