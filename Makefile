up:
	docker-compose up

down:
	docker-compose down

postgres:
	docker-compose exec postgres env PGOPTIONS="--search_path=inventory" bash -c 'psql -U postgres postgres'

insert:
	docker-compose exec postgres env PGOPTIONS="--search_path=inventory" bash -c "psql -U postgres postgres -c \"INSERT INTO customers VALUES (default,'Sally','Thomas','sally.thomas@acme.com');\"" && \
	docker-compose exec postgres env PGOPTIONS="--search_path=inventory" bash -c "psql -U postgres postgres -c \"INSERT INTO customers VALUES (default,'George','Bailey','gbailey@foobar.com');\"" && \
	docker-compose exec postgres env PGOPTIONS="--search_path=inventory" bash -c "psql -U postgres postgres -c \"INSERT INTO customers VALUES (default,'Edward','Walker','ed@walker.com');\"" && \
	docker-compose exec postgres env PGOPTIONS="--search_path=inventory" bash -c "psql -U postgres postgres -c \"INSERT INTO customers VALUES (default,'Anne','Kretchmar','annek@noanswer.org');\""

update:
	docker-compose exec postgres env PGOPTIONS="--search_path=inventory" bash -c "psql -U postgres postgres -c \"UPDATE customers SET email = 'sally.thomas@baz.com' WHERE email = 'sally.thomas@acme.com';\""

delete:
	docker-compose exec postgres env PGOPTIONS="--search_path=inventory" bash -c "psql -U postgres postgres -c \"DELETE FROM customers WHERE email = 'gbailey@foobar.com';\""

clean:
	docker-compose rm -f
