 #!/usr/bin/env bash

GREEN='\033[1;32m'
NC='\033[0m' # No Color

scp ubuntu@52.4.148.2:br_full_app.dump .

CONTAINER=blueraven-albatross-db-1

echo -e "\n${GREEN}Restoring backup to local docker container.${NC}\n"
docker exec -i $CONTAINER dropdb -h localhost -p 5432 -U dbadmin  --if-exists -e blueraven
docker exec -i $CONTAINER createdb -h localhost -p 5432 -U dbadmin  -T template0 -e blueraven

time docker exec -i $CONTAINER pg_restore -h localhost -p 5432 -U dbadmin \
        --dbname blueraven --clean --if-exists --no-owner --no-acl --verbose < br_full_app.dump

echo -e "\n${GREEN}Completed restore.${NC}"
