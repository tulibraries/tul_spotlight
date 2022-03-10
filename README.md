# TUL Spotlight

TUL Spotlight is an implementatino of the Spotlight Exhibition application for
Temple University Libraries.

This implementation includes configurations tools to use Docker in a local and
Kubernetes deployment

## Getting Started
---

### Install the Application

Clone the Git repository in your development enviornment

```
git clone git@github.com:tulibraries/tul_spotlight
cd tul_spotlight
bundle install
yarn --check-files install
cp config/master.key.example config/master.key
```

#### Local Development Enviornment

```
```

#### Build for Docker

```
make build
make pull_db
make build_solr
```

Run in a local docker container

Start your local docker desktop application or docker engine

```
make run_db
make run_solr
make run_app
```

Visit http://localhost:3000 to use the application

To deploy to Harbor repository, first, scan the docker image for
critical vulnerabilities

```
make scan
```

If vulnerabilities are found,  edit the Alpine Packages in `.docker/app/Dockerfile`,
Ruby Gem packages in `Gemfile`, and Yarn packages in `packages.json`.

If you make changes to the Ruby or Yarn packages, then update the lock file.

First build a development container, run the container and build update the lock files

```
make build_dev
amke run_dev
make shell_dev

bundle update
yarn --check-files install
exit
```

Then rebuild the TUL_Spotlight application image and rescan

```
make build
make scan
```

Send the image to Harbor
```
make deploy
```
