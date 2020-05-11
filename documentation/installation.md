# How to Install the Caffeine Platform

1. Prerequisites

    You need git, docker, docker-compose and ideally CPLEX to install and run
    the platform (see [documentation/cplex.md](cplex.md) for more information).
    As described there, please start by placing your CPLEX compressed archive
    (`cplex_128.tar.gz`) in the `cplex/` directory.

     Please also set an administrative password for the database server.  The
     username is automatically `postgres`. You can either define an environment
     variable `POSTGRES_PASSWORD` (`export POSTGRES_PASSWORD=...` on Linux and
     MacOS) or write it to a `.env` file (`POSTGRES_PASSWORD=...`).

     To make sure all prerequisites are satisfied, run:

    ```
    make check
    ```

2. Installation

    Run the installation in multiple steps. Please note that you can run the
    installation in parallel using `make -j` (you may want to synchronize output
    in that case with `-O`).

    1. Create all local repositories.

        ```
        make setup
        ```
    2. Build all Docker images.

        ```
        make install
        ```

        This may take a while (expect 10-15 minutes), depending on your
        bandwidth and processing power. We recommend you take a look at the
        `Makefile` to understand what it does. Again, you can reduce the time
        needed through parallelization but you need enough memory, too.

    3. Initialize the platform. **Careful, this will reset all database
       volumes.** So don't run this command after using the platform for a
       while.

        ```
        make initialize
        ```

3. Running

    Start all services with docker-compose:

    ```
    docker-compose up --detach
    ```

    Optionally, you can look at the log output, too. It is a good place to spot
    errors.  Please, at the very least, make sure that all services are running
    with

    ```
    docker-compose ps
    ```

    You may initially see "connection refused" errors or similar while services
    are starting up. It shouldn't take more than a minute until all services are
    ready and stop showing error messages.

    When the services are ready, point your browser to:
    [http://localhost:4200/](http://localhost:4200/). Replace `localhost` with
    the address of the machine if accessing it remotely.

