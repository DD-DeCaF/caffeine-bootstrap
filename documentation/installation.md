# How to Install the Caffeine Platform

1. Prerequisites

    You need git, docker, docker-compose and cplex to install and run the
    platform (see [documentation/cplex.md](cplex.md) for more information). To
    make sure all prerequisites are satisifed, run:

    ```
    make check
    ```

2. Installation

    Run the installation in multiple steps. Please note that you can run the installation 
    in parallel using `make -j`.
    
    1. Create all local repositories.

        ```
        make setup
        ```
    2. Copy your CPLEX archive to `modeling-base/cameo/`   .
    
    3. Build all Docker images.

        ```
        make install
        ```
       
        This may take a while (expect 10-15 minutes), depending on your bandwidth
        and processing power. We recommend you take a look at the `Makefile` to
        understand what it does. Again, you can reduce the time needed through parallelization
        but you need enough memory, too.
    
    4. Initialize the platform.
    
        ```
        make initialize
        ```

3. Running

    Start all services with docker-compose:

    ```
    docker-compose up --detach
    ```
   
    Optionally, you can look at the log output, too. It is a good place to spot errors.
    Please, at the very least, make sure that all services are running with

    ```
    docker-compose ps
    ```

    You may initially see "connection refused" errors or similar while services
    are starting up. It shouldn't take more than a minute until all services are
    ready and stop showing error messages.

    When the services are ready, point your browser to:
    [http://localhost:4200/](http://localhost:4200/). Replace `localhost` with
    the address of the machine if accessing it remotely.

