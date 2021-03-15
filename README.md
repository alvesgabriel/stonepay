# [Stonepay](http://stonepay.gigalixirapp.com/)

The application is running in the Gigalixir. [Click here](http://stonepay.gigalixirapp.com/) to open it.

## Run project with docker-compose

Obs: [docker](https://docs.docker.com/get-docker/) and [docker-compose](https://docs.docker.com/compose/install/) need to be installed

### Build project

```bash
docker-compose build
```

### Create and migrate your database

```bash
docker-compose run --rm phoenix mix ecto.setup
```

### Start project

```bash
docker-compose up
```

Now you can visit [`localhost:4000/`](http://localhost:4000/) from your browser.
