REPO=l50
NAME=msf-dev

all: build run

build:
	bash scripts/generate_pw.sh
	docker build -t $(REPO)/$(NAME) .

run:
	docker run -d -p 4444:4444 -it --rm --env-file env --name=msf-dev $(REPO)/$(NAME)

destroy:
	docker stop msf-dev
