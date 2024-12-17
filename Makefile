create_db:
	bash init_user.sh
	createdb scooters

dump_db:
	pg_dump scooters > db_dump.db

drop_current_db: dump_db
	psql -U ${USER} -d postgres -a -c "DROP DATABASE scooters;"

init_from_dump_db: create_db
	psql scooters < db_dump.db

tables:
	psql -U ${USER} -d scooters -a -f src/create_db.sql

triggers:
	psql -U ${USER} -d scooters -a -f src/add_triggers.sql

procedures:
	psql -U ${USER} -d scooters -a -f src/add_procedures.sql

data:
	psql -U ${USER} -d scooters -a -f src/insert_data.sql

additional:
	psql -U ${USER} -d scooters -a -f src/additional_actions.sql

init_db: create_db tables triggers procedures data additional


run_db:
	psql -U ${USER} -d scooters

