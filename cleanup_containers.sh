#!/bin/bash

# Kill and/or remove named containers

# <container_name> is the value of "--name" parameter from: "$ docker container run [OPTS] --name <container_name> [IMAGE]"
# 
# Using static name for strict control and POCs where the name is fixed and expected all around the deployment.

echo "Killing and removing container <container_name>"

cleanup_containers() {
  if [ "$(docker ps -aq -f status=running -f name=<container_name>)" ]; then
      docker kill <container_name>
	  docker rm <container_name>
  fi
  
echo "Removing already stopped container <container_name>"

  if [ "$(docker ps -aq -f status=exited -f name=<container_name>)" ]; then
      docker rm <container_name>
  fi
}
cleanup_containers