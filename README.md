# Investigate using Postgres triggers and notifications to get a log of all changes 

* Start Postgres
  * `make up`
* Open a new psql session and listen for notifications
  * `make postgres`
  * `LISTEN table_log_write;`
* Do some inserts
  * `make insert`
* In your psql session, check for notifications
  * `SELECT 1;`
* In your psql session, check for events in the log table
  * `SELECT * FROM update_log;`
* Do the same for updates and deletes
  * `make update`
  * `make delete`
* Finish and clean up
  * `make down`
  * `make clean`
