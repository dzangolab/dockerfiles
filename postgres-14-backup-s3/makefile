build:
	@printf "\033[0;32m>>> Building image\033[0m\n"
	docker build -t dzangolab/postgres-backup-s3:14 . 

push:
	@printf "\033[0;32m>>> Pushing image to docker hub\033[0m\n"
	docker push dzangolab/postgres-backup-s3:14 

test:
	@printf "\033[0;32m>>> Testing image\033[0m\n"
	docker compose up -d

test.down:
	@printf "\033[0;32m>>> Testing image\033[0m\n"
	docker compose down --rmi local --remove-orphans -v
