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
modeling += simulations
modeling += model-storage
# Collect all repositories.
repos += $(local)
repos += $(modeling)
repos += modeling-base
# Variables for image tag components.
BUILD_DATE ?= $(shell date --utc --iso-8601=date)
export BUILD_DATE  # Required for sub make calls.

################################################################################
# Clean up                                                                     #
################################################################################

.PHONY: clean clean-env
## Clean up all build files and directories.
clean: clean-env
	@if [ -d .build ]; then rm --recursive .build; fi

clean-env:
	@echo "$$(head -n1 .env)" > .env

################################################################################
# Setup                                                                        #
################################################################################

.env:
	$(file >.env,POSTGRES_PASSWORD=)

.PHONY: setup $(repos)
## Clone all repositories for local use.
setup: .env clean $(repos)
	@mkdir .build
	$(info **********************************************************************)
	$(info * NOTICE)
	$(info **********************************************************************)
	$(info * 1. Please copy your CPLEX archive, for example, 'cplex_128.tar.gz',)
	$(info *    to 'modeling-base/cameo/' now.)
	$(info * 2. Please set the POSTGRES_PASSWORD in the '.env' file.)
	$(info **********************************************************************)

$(repos):
	./scripts/clone_or_pull.sh "$@" > /dev/null

################################################################################
# Installation                                                                 #
################################################################################

## Build all Docker images.
install: build-local build-modeling
	$(info **********************************************************************)
	$(info * NOTICE)
	$(info **********************************************************************)
	$(info * Installation complete. Go ahead and start the platform with: )
	$(info *     docker-compose up --detach)
	$(info **********************************************************************)

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
# Build local images                                                           #
################################################################################

# Build an image from a local repository and record its unique tag in a file.
define build-local-repository
$(info Building $1...)
$(eval NAME := $(shell echo "$1" | tr '[:lower:]-' '[:upper:]_'))
$(eval TAG := $(call build-tag,$1))
$(file >.build/$(NAME)_TAG,$(TAG))
$(MAKE) -C $1 build-travis > /dev/null
@touch .build/$1
endef

## Build images depending on publicly available wsgi-base and postgres-base.
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
# Build modeling images                                                        #
################################################################################

# Build a modeling image from a repository and record its unique tag in a file.
define build-modeling-repository
$(info Building $1...)
$(eval BASE_TAG := $(shell cat .build/MODELING_BASE_TAG))
$(eval NAME := $(shell echo "$1" | tr '[:lower:]-' '[:upper:]_'))
$(eval BUILD_TAG := $(call build-tag,$1))
$(eval BUILD_COMMIT := $(call commit,$1))
$(eval BUILD_TIMESTAMP := $(shell date --utc --iso-8601=seconds))
$(file >.build/$(NAME)_TAG,$(BUILD_TAG))
docker build --build-arg BASE_TAG=$(BASE_TAG) \
	--build-arg BUILD_COMMIT=$(BUILD_COMMIT) \
	--build-arg BUILD_TIMESTAMP=$(BUILD_TIMESTAMP) \
	--tag gcr.io/dd-decaf-cfbf6/$1:$(BUILD_TAG) \
	$1
@touch .build/$1
endef

## Build images depending on proprietary solver in modeling-base.
build-modeling: .build/metabolic-ninja .build/model-storage .build/simulations

.build/modeling-base:
	$(info Building $(@F)...)
	$(eval TAG := cameo_$(BUILD_DATE)_$(call short-commit,$(@F)))
	$(file >.build/MODELING_BASE_TAG,$(TAG))
	$(MAKE) -C $(@F) build-cameo > /dev/null
	@touch .build/$(@F)

.build/metabolic-ninja: .build/modeling-base
	$(call build-modeling-repository,$(@F))

.build/model-storage: .build/modeling-base
	$(call build-modeling-repository,$(@F))

.build/simulations: .build/modeling-base
	$(call build-modeling-repository,$(@F))

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
