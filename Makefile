###
#
# 	Makefile for Docker projects
#
# 	Version: 1.0.1
# 	Author: Yves Vindevogel (vindevoy)
# 	Date: 2020-10-22
#
#	Fixes: Added the SHELL directive to make sure BASH is used
#
###


#
# Settings: specify to your own need
#
# IMAGE_REPO: your repository at DockerHub
# IMAGE_NAME: the name of your image
# IMAGE_VERSION: the version number (script also publishes as latest besides this number)
#


IMAGE_REPO=vindevoy
IMAGE_NAME=ubuntu-base
IMAGE_VERSION=20.04-0


######################
# DO NOT TOUCH BELOW #
######################


#
# Image tags: 		dvl - image created from the ./src/docker directory using the Dockerfile as written
#                   rel - image created from the ./build/docker directory using the optimised Dockerfile
#					latest - the 'rel' image tagged as latest for hub.docker.com
#				    IMAGE_VERSION - user defined version based on the latest version of the image
#


.PHONY: build

# make sure we are using bash, which is needed for the if-statements
SHELL := /bin/bash

# some info for the user
help:
	@echo ""
	@echo "USAGE:"
	@echo "  make init: create the base structure of the project"
	@echo "  make clean: remove build directory and as much as possible the existing development images"
	@echo "  make compile: create the Docker image line by line, with multiple layers, for fast development"
	@echo "  make test: run the compiled Docker image"
	@echo "  make build: optimize the Dockerfile and make an image based on it"
	@echo "  make run: run the optimized Docker image"
	@echo "  make tag: make tags of the 'build' image"
	@echo "  make publish: publish the image on hub.docker.com as 'VERSION' and 'latest'"
	@echo "  make remove: remove all images of this project"
	@echo "  make sysprune: do a big clean up"
	@echo "  make help: this help ..."
	@echo ""


# init creates the directories and empty Dockerfile
init:
	mkdir -p ./src/docker
	mkdir -p ./src/resources
	
	touch ./src/docker/Dockerfile


# clean removes the develop tag of the image, if it exists
clean:
	rm -rf ./build

	$(eval dvl=$(shell docker images | grep '$(IMAGE_REPO)/$(IMAGE_NAME)' | grep ' dvl ' | wc -l))
	if [[ "$(dvl)" -ne 0 ]]; then docker images | grep '$(IMAGE_REPO)/$(IMAGE_NAME)' | grep ' dvl ' | \
	sed 's/  */ /g' | cut -d ' ' -f3 | xargs docker image remove --force; fi

	$(eval rel=$(shell docker images | grep '$(IMAGE_REPO)/$(IMAGE_NAME)' | grep ' rel ' | wc -l))
	if [[ "$(rel)" -ne 0 ]]; then docker images | grep '$(IMAGE_REPO)/$(IMAGE_NAME)' | grep ' rel ' | \
	sed 's/  */ /g' | cut -d ' ' -f3 | xargs docker image remove --force; fi


# compile builds the docker image based on the src directory and tags the image as develop
# compile uses layer after layer to improve development speed, but produces a larger image than needed
compile:
	docker build -t $(IMAGE_REPO)/$(IMAGE_NAME):dvl ./src/docker


# run the image using the develop tag (created with compile)
test: compile
	docker run -it $(IMAGE_REPO)/$(IMAGE_NAME):dvl


# build builds the docker image based on the optimized build directory and tags the image as latest
# the produced image should be way smaller in size because of the layer optimasation
build:
	rm -rf ./build
	mkdir -p ./build/docker
	mkdir -p ./build/resources

	# optimize the Dockerfile, too complicated to do in shell
	python optimize.py

	# only copy if files or directories exist
	if [ `ls ./src/resources/ | wc -w` -gt 0 ]; then cp -R ./src/resources/* ./build/resources/ ; fi

	docker build -t $(IMAGE_REPO)/$(IMAGE_NAME):rel ./build/docker


run: build
	docker run -it $(IMAGE_REPO)/$(IMAGE_NAME):rel


# create the tags IMAGE_VERSION and latest based on a build
tag: build
	docker tag $(IMAGE_REPO)/$(IMAGE_NAME):rel $(IMAGE_REPO)/$(IMAGE_NAME):$(IMAGE_VERSION)
	docker tag $(IMAGE_REPO)/$(IMAGE_NAME):rel $(IMAGE_REPO)/$(IMAGE_NAME):latest


# publish the optimized image
publish: tag
	docker push $(IMAGE_REPO)/$(IMAGE_NAME):$(IMAGE_VERSION)
	docker push $(IMAGE_REPO)/$(IMAGE_NAME):latest


remove:
	$(eval ic=$(shell docker images | grep '$(IMAGE_REPO)/$(IMAGE_NAME)' | wc -l))
	
	@if [[ "$(ic)" -ne 0 ]]; then docker images | grep '$(IMAGE_REPO)/$(IMAGE_NAME)' | \
	sed 's/  */ /g' | cut -d ' ' -f3 | xargs docker image remove --force; fi


sysprune:
	docker system prune -f


#
# Information used:
# https://beenje.github.io/blog/posts/dockerfile-anti-patterns-and-best-practices/
# https://stackoverflow.com/questions/46089219/how-to-reduce-the-size-of-rhel-centos-fedora-docker-image
# https://www.codacy.com/blog/five-ways-to-slim-your-docker-images/
# https://github.com/jwilder/docker-squash
#

###
#
# 	Version history
#
# 	Version: 1.0.0
# 	Author: Yves Vindevogel (vindevoy)
# 	Date: 2019-10-29
#
# 	Initial version
#
###
