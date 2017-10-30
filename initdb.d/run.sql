CREATE SCHEMA inventory;
SET search_path TO inventory;

-- sample table
CREATE TABLE customers (
  id SERIAL NOT NULL PRIMARY KEY,
  first_name VARCHAR(255) NOT NULL,
  last_name VARCHAR(255) NOT NULL,
  email VARCHAR(255) NOT NULL UNIQUE
);
ALTER SEQUENCE customers_id_seq RESTART WITH 101;

-- log table
CREATE TABLE update_log (
  id SERIAL NOT NULL PRIMARY KEY,
  payload TEXT
);
ALTER SEQUENCE update_log_id_seq RESTART WITH 1001;
GRANT ALL ON update_log TO PUBLIC;

-- function to update the log table
CREATE OR REPLACE FUNCTION table_update_log() RETURNS trigger AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    INSERT INTO update_log VALUES(default, json_build_object('table', TG_TABLE_NAME, 'op', TG_OP, 'before', '', 'after', row_to_json(NEW)));
  ELSIF TG_OP = 'UPDATE' THEN
    INSERT INTO update_log VALUES(default, json_build_object('table', TG_TABLE_NAME, 'op', TG_OP, 'before', row_to_json(OLD), 'after', row_to_json(NEW)));
  ELSIF TG_OP = 'DELETE' THEN
  	INSERT INTO update_log VALUES(default, json_build_object('table', TG_TABLE_NAME, 'op', TG_OP, 'before', row_to_json(OLD), 'after', ''));
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- create triggers for all tables
DO
$$
DECLARE
    tbl   regclass;
BEGIN
   FOR tbl IN
      SELECT c.oid
      FROM   pg_class     c
      JOIN   pg_namespace n ON n.oid = c.relnamespace
      WHERE  relkind = 'r'
      AND    n.nspname = 'inventory'
      AND    c.relname != 'update_log'
      AND    c.relname !~~ 'pg_%'
    LOOP
      EXECUTE 'CREATE TRIGGER ' || tbl || '_update_log_update AFTER UPDATE ON ' || tbl || ' FOR EACH ROW EXECUTE PROCEDURE table_update_log();';
      EXECUTE 'CREATE TRIGGER ' || tbl || '_update_log_insert AFTER INSERT ON ' || tbl || ' FOR EACH ROW EXECUTE PROCEDURE table_update_log();';
      EXECUTE 'CREATE TRIGGER ' || tbl || '_update_log_delete AFTER DELETE ON ' || tbl || ' FOR EACH ROW EXECUTE PROCEDURE table_update_log();';
   END LOOP;
END
$$;

-- notify on changes to update_log
CREATE OR REPLACE FUNCTION table_log_notify() RETURNS trigger AS $$
DECLARE
BEGIN
  PERFORM pg_notify('table_log_write', json_build_object('event', NEW)::text);
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER table_log_notify_write AFTER INSERT ON update_log FOR EACH ROW EXECUTE PROCEDURE table_log_notify();
