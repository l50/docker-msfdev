# docker-msfdev
[![License](http://img.shields.io/:license-mit-blue.svg)](https://github.com/l50/docker-msfdev/blob/master/LICENSE)

Containerized and automated deployment of a metasploit development environment as per the instructions [found here](https://github.com/rapid7/metasploit-framework/wiki/Setting-Up-a-Metasploit-Development-Environment).

## Instructions
1. Begin by creating an env file: ```cp env.example env```
2. Fill out the various fields in the env file with the values specific to your github account information
3. Build the environment image with ```make build```
4. Create a container with ```make run``` and get an interactive shell to it with ```docker exec -it msf-dev bash```
5. Once inside, change to the msfdev user with ```su msfdev``` and navigate to the metasploit repo in the container by running ```cd ~/metasploit-framework```

At this point, you should have everything that you need to begin developing metasploit modules.

If there's something missing that you'd like to have in your development environment, you should be able to add it to either the ```Dockerfile``` or ```entrypoint/msfdev-entrypoint.sh```.
