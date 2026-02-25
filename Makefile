.DEFAULT_GOAL := run

.PHONY: clean run

clean:
	docker compose down
	docker rm -f $(docker ps -a -q)
	docker volume rm "$(docker volume ls -q)"

run:
	docker compose up
