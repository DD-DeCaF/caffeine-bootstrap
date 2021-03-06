################################################################################
# Variables                                                                    #
################################################################################

# Docker images on the private Google Container Registry that need to be built locally.
local += design-storage
local += iam
local += id-mapper
local += map-storage
local += metanetx
local += warehouse
# Docker images depending on modeling-base that needs CPLEX.
modeling += metabolic-ninja
modeling += model-storage
modeling += simulations
# Collect all repositories.
repos += $(local)
repos += $(modeling)
repos += modeling-base
# Variables for image tag components.
# The date format corresponds to ISO-8601 but Unix compatible.
BUILD_DATE ?= $(shell date -u +%Y-%m-%d)
export BUILD_DATE  # Required for sub make calls.
CPLEX := "$(shell find cplex -iname 'cplex*.tar.gz')"

################################################################################
# All                                                                          #
################################################################################

## Perform a complete Caffeine installation.
all: check setup install initialize

################################################################################
# Check                                                                        #
################################################################################

.PHONY: check
## Test that important tools are present.
check:
	@./scripts/check.sh || (echo "There are missing dependencies."; exit 1)
	$(info **********************************************************************)
	$(info * NOTICE)
	$(info **********************************************************************)
	$(info * If you are only lacking CPLEX you can proceed with the installation)
	$(info * by interactively running the following commands:)
	$(info *     make setup install initialize)
	$(info * Please note that the platform will use the GLPK solver and)
	$(info * certain parts will run MUCH slower.)
	$(info **********************************************************************)

################################################################################
# Clean Up                                                                     #
################################################################################

.PHONY: clean clean-env
## Clean up all build files and directories.
clean: clean-env
	@if [ -d .build ]; then rm -r .build; fi
	$(info **********************************************************************)
	$(info * NOTICE)
	$(info **********************************************************************)
	$(info * Clean up complete.)
	$(info * If you want to start over removing all services and)
	$(info * ALL OF YOUR DATA, you can do so with:)
	$(info *     docker-compose down --volumes)
	$(info * Please go and have a cup of coffee before deciding to do so.)
	$(info **********************************************************************)

clean-env:
	@echo "$$(head -n1 .env)" > .env

################################################################################
# Setup                                                                        #
################################################################################

.PHONY: setup $(repos)
## Clone all repositories for local use.
setup: .env clean .build $(repos) tag-spy copy-cplex
	$(info **********************************************************************)
	$(info * NOTICE)
	$(info **********************************************************************)
	$(info * Please continue with:)
	$(info *    	make install initialize)
	$(info **********************************************************************)

.env:
	$(file >.env,POSTGRES_PASSWORD=)

.build:
	@mkdir .build

$(repos):
	./scripts/clone_or_pull.sh "$@" > /dev/null

tag-spy:
	docker pull dddecaf/tag-spy:latest

copy-cplex: modeling-base
	@echo $(shell [ -f $(CPLEX) ] > /dev/null \
		&& cp -n $(CPLEX) modeling-base/cameo/cplex/ \
		&& echo "CPLEX found." \
		|| echo "WARNING: No CPLEX compressed archive found.")

################################################################################
# Installation                                                                 #
################################################################################

## Build all Docker images.
install: .build .env .build/tags
	$(info **********************************************************************)
	$(info * NOTICE)
	$(info **********************************************************************)
	$(info * Installation complete. Please run the initialization next, with:)
	$(info *     make initialize)
	$(info **********************************************************************)

.build/tags: build-local build-modeling
	$(file >>.env,DESIGN_STORAGE_TAG=$(shell cat .build/DESIGN_STORAGE_TAG))
	$(file >>.env,IAM_TAG=$(shell cat .build/IAM_TAG))
	$(file >>.env,ID_MAPPER_TAG=$(shell cat .build/ID_MAPPER_TAG))
	$(file >>.env,MAP_STORAGE_TAG=$(shell cat .build/MAP_STORAGE_TAG))
	$(file >>.env,METANETX_TAG=$(shell cat .build/METANETX_TAG))
	$(file >>.env,WAREHOUSE_TAG=$(shell cat .build/WAREHOUSE_TAG))
	$(file >>.env,METABOLIC_NINJA_TAG=$(shell cat .build/METABOLIC_NINJA_TAG))
	$(file >>.env,MODEL_STORAGE_TAG=$(shell cat .build/MODEL_STORAGE_TAG))
	$(file >>.env,SIMULATIONS_TAG=$(shell cat .build/SIMULATIONS_TAG))
	@touch .build/tags

# Descend into a sub-directory which should be a git repository.
# Parse out the default branch and current commit.
# Return the compiled image tag using the current BUILD_DATE.
build-tag = $(shell cd "$1" \
		&& branch=$$(git rev-parse --abbrev-ref HEAD) \
		&& short_commit=$$(git rev-parse --short HEAD) \
		&& echo "$${branch}_$(BUILD_DATE)_$${short_commit}")

# Descend into a sub-directory which should be a git repository.
# Return the current git branch name.
branch = $(shell cd "$1" \
		&& echo "$$(git rev-parse --abbrev-ref HEAD)")

# Descend into a sub-directory which should be a git repository.
# Return the current git commit hash.
commit = $(shell cd "$1" \
		&& echo "$$(git rev-parse HEAD)")

# Descend into a sub-directory which should be a git repository.
# Return the short version of the current git commit hash (7 characters).
short-commit = $(shell cd "$1" \
		&& echo "$$(git rev-parse --short HEAD)")

################################################################################
# Build Local Images                                                           #
################################################################################

# Build an image from a local repository and record its unique tag in a file.
define build-local-repository
$(info Building $1...)
$(eval NAME := $(shell echo "$1" | tr '[:lower:]-' '[:upper:]_'))
$(eval TAG := $(call build-tag,$1))
$(file >.build/$(NAME)_TAG,$(TAG))
$(MAKE) -C $1 build-travis
@touch .build/$1
endef

build-local: .build/design-storage .build/iam .build/id-mapper .build/map-storage \
	.build/metanetx .build/warehouse

.build/design-storage:
	$(call build-local-repository,$(@F))

.build/iam:
	$(call build-local-repository,$(@F))

.build/id-mapper:
	$(call build-local-repository,$(@F))

.build/map-storage:
	$(call build-local-repository,$(@F))

.build/metanetx:
	$(call build-local-repository,$(@F))

.build/warehouse:
	$(call build-local-repository,$(@F))

################################################################################
# Build Modeling Images                                                        #
################################################################################

# Build a modeling image from a repository and record its unique tag in a file.
define build-modeling-repository
$(info Building $1...)
$(eval BASE_TAG := $(shell cat .build/MODELING_BASE_TAG))
$(eval NAME := $(shell echo "$1" | tr '[:lower:]-' '[:upper:]_'))
$(eval BUILD_TAG := $(call build-tag,$1))
$(eval BUILD_COMMIT := $(call commit,$1))
$(file >.build/$(NAME)_TAG,$(BUILD_TAG))
docker build --build-arg BASE_TAG=$(BASE_TAG) \
	--build-arg BUILD_COMMIT=$(BUILD_COMMIT) \
	--tag gcr.io/dd-decaf-cfbf6/$1:$(BUILD_TAG) \
	$1
@touch .build/$1
endef

build-modeling: .build/metabolic-ninja .build/model-storage .build/simulations

.build/modeling-base:
	$(info Building $(@F)...)
	$(eval TAG := cameo_$(BUILD_DATE)_$(call short-commit,$(@F)))
	$(file >.build/MODELING_BASE_TAG,$(TAG))
	$(MAKE) -C $(@F) build-cameo
	@touch .build/$(@F)

.build/metabolic-ninja: .build/modeling-base
	$(call build-modeling-repository,$(@F))

.build/model-storage: .build/modeling-base
	$(call build-modeling-repository,$(@F))

.build/simulations: .build/modeling-base
	$(call build-modeling-repository,$(@F))

################################################################################
# Initialize Services                                                          #
################################################################################

## Initialize all databases and services. COMPLETELY REMOVES EXISTING DATA.
initialize: .build .build/neo4j .build/demo
	$(info **********************************************************************)
	$(info * NOTICE)
	$(info **********************************************************************)
	$(info * Initialization complete. Go ahead and start the platform with:)
	$(info *     docker-compose up --detach)
	$(info * You can inspect and follow the logs of all services with:)
	$(info *     docker-compose logs --tail="all" --follow)
	$(info **********************************************************************)

.build/volumes: .build
	docker-compose down --volumes
	@touch .build/$(@F)

.build/ssh-keys: .build/volumes
	$(info Generating SSH key pairs...)
	docker-compose run --rm iam ssh-keygen -t rsa -b 2048 -f keys/rsa -N "" -m PEM
	@touch .build/$(@F)

.build/databases: .build/ssh-keys
	$(info Creating databases...)
	docker-compose up --detach postgres
	./iam/scripts/wait_for_postgres.sh
	docker-compose exec -T postgres psql -U postgres -c "create database iam;"
	docker-compose exec -T postgres psql -U postgres -c "create database maps;"
	docker-compose exec -T postgres psql -U postgres -c "create database metabolic_ninja;"
	docker-compose exec -T postgres psql -U postgres -c "create database model_storage;"
	docker-compose exec -T postgres psql -U postgres -c "create database warehouse;"
	docker-compose exec -T postgres psql -U postgres -c "create database designs;"
	docker-compose run --rm iam flask db upgrade
	docker-compose run --rm map-storage flask db upgrade
	docker-compose run --rm metabolic-ninja flask db upgrade
	docker-compose run --rm model-storage flask db upgrade
	docker-compose run --rm warehouse flask db upgrade
	docker-compose run --rm design-storage flask db upgrade
	@touch .build/$(@F)

.build/neo4j: .build/databases
	$(info Populating id-mapper...)
	docker-compose up --detach neo4j
	docker-compose exec -T neo4j neo4j-admin load --from=/dump/id-mapper.dump
	@touch .build/$(@F)

.build/demo: .build/databases
	$(info Creating demo users...)
	docker-compose run --rm --volume="$(CURDIR)/scripts:/bootstrap" iam \
		python /bootstrap/generate-demo-users.py
	@touch .build/$(@F)

################################################################################
# Self Documenting Commands                                                    #
################################################################################

.DEFAULT_GOAL := show-help

# Inspired by
# <http://marmelab.com/blog/2016/02/29/auto-documented-makefile.html>
# sed script explained:
# /^##/:
# 	* save line in hold space
# 	* purge line
# 	* Loop:
# 		* append newline + line to hold space
# 		* go to next line
# 		* if line starts with doc comment, strip comment character off and loop
# 	* remove target prerequisites
# 	* append hold space (+ newline) to line
# 	* replace newline plus comments by `---`
# 	* print line
# Separate expressions are necessary because labels cannot be delimited by
# semicolon; see <http://stackoverflow.com/a/11799865/1968>
.PHONY: show-help
show-help:
	@echo "$$(tput bold)Available rules:$$(tput sgr0)"
	@echo
	@sed -n -e "/^## / { \
		h; \
		s/.*//; \
		:doc" \
		-e "H; \
		n; \
		s/^## //; \
		t doc" \
		-e "s/:.*//; \
		G; \
		s/\\n## /---/; \
		s/\\n/ /g; \
		p; \
	}" ${MAKEFILE_LIST} \
	| LC_ALL='C' sort --ignore-case \
	| awk -F '---' \
		-v ncol=$$(tput cols) \
		-v indent=19 \
		-v col_on="$$(tput setaf 6)" \
		-v col_off="$$(tput sgr0)" \
	'{ \
		printf "%s%*s%s ", col_on, -indent, $$1, col_off; \
		n = split($$2, words, " "); \
		line_length = ncol - indent; \
		for (i = 1; i <= n; i++) { \
			line_length -= length(words[i]) + 1; \
			if (line_length <= 0) { \
				line_length = ncol - indent - length(words[i]) - 1; \
				printf "\n%*s ", -indent, " "; \
			} \
			printf "%s ", words[i]; \
		} \
		printf "\n"; \
	}' \
	| more $(shell test $(shell uname) = Darwin \
	&& echo '--no-init --raw-control-chars')
