# How to Install the Platform Without Internet Access

1. Prerequisites

    Please follow the instructions of the [normal guide](installation.md) until you have
    completed the `make install` step on a machine which **does** have internet
    access.

2. Build image tarball

    Create a tarball  with:

    ```
    ./scripts/save-image-tarball.sh
    ```

    You should end up with a `caffeine-images.tar.gz` file.

3. Load the images

    Move the resulting `caffeine-images.tar.gz` archive to the server where the platform
    will run and load them with:

    ```
    gunzip -c caffeine-images.tar.gz | docker load
    ```

    Now initialize the services with:

    ```
    make initialize
    ```

3. Running

    Start all services with docker-compose:

    ```
    docker-compose up --detach
    ```

    You may initially see "connection refused" errors or similar while services
    are starting up. It shouldn't take more than a minute until all services are
    ready and stop showing error messages.

    When the services are ready, point your browser to:
    [http://localhost:4200/](http://localhost:4200/) Replace `localhost` with
    the address of the machine if accessing it remotely.

