# How to Install the Caffeine Platform

1. Prerequisites

    You need git, docker, docker-compose and cplex to install and run the
    platform (see [documentation/cplex.md](cplex.md) for more information). To
    make sure all prerequisites are satisifed, run:

    ```
    ./scripts/check.sh
    ```

2. Installation

    Run the installation script with:

    ```
    ./scripts/install.sh
    ```

    This may take a while (expect 10-15 minutes), depending on your bandwidth
    and processing power. We recommend you take a look at the script to
    understand what it does.

3. Running

    Start all services with docker-compose:

    ```
    docker-compose up
    ```

    You may initially see "connection refused" errors or similar while services
    are starting up. It shouldn't take more than a minute until all services are
    ready and stop showing error messages.

    When the services are ready, point your browser to:
    [http://localhost:4200/](http://localhost:4200/). Replace `localhost` with
    the address of the machine if accessing it remotely.

