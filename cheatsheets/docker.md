# Docker

## Mental model

- **Image** = a frozen filesystem + metadata. Read-only. Like a class.
- **Container** = a running (or stopped) instance of an image. Like an object.
- **Volume** = storage that outlives the container. Without one, data dies
  when the container is removed.
- **Dockerfile** = the recipe that builds an image.

Most confusion comes from mixing up image and container. `docker images` lists
recipes; `docker ps` lists things made from them.

## Daily commands

```bash
docker ps                       # running containers
docker ps -a                    # ... including stopped ones
docker images                   # local images
docker logs <container>         # its stdout
docker logs -f <container>      # follow the logs
docker exec -it <container> sh  # shell inside a running container
docker stop <container>
docker rm <container>
docker rmi <image>
```

`-it` = interactive + allocate a TTY. Without it, the shell exits immediately.

## Running things

```bash
docker run hello-world

docker run -d \                 # detached (background)
  --name mydb \                 # a name I can refer to later
  -p 5432:5432 \                # hostPort:containerPort
  -e POSTGRES_PASSWORD=secret \ # environment variable
  -v pgdata:/var/lib/postgresql/data \   # named volume
  postgres:16
```

Port mapping direction: `-p HOST:CONTAINER`. The left side is what you type in
your browser. Getting this backwards is the classic first mistake.

```bash
docker run --rm -it ubuntu bash   # throwaway container, deleted on exit
```

`--rm` is your friend for experiments — otherwise stopped containers pile up.

## Dockerfile basics

```dockerfile
FROM node:20-alpine
WORKDIR /app
COPY package*.json ./
RUN npm ci                  # deps layer, cached unless package.json changes
COPY . .                    # source layer, changes often
EXPOSE 3000
CMD ["node", "server.js"]
```

Order matters: put things that change rarely (dependency install) *above*
things that change constantly (your source). Docker caches layers, and one
changed layer invalidates every layer below it.

```bash
docker build -t myapp:latest .
docker build --no-cache -t myapp:latest .    # when the cache lies to you
```

`CMD` vs `ENTRYPOINT`: `CMD` is the default command (easily overridden at run
time). `ENTRYPOINT` is the thing that always runs, with `CMD` as its default
arguments.

## Compose

`docker-compose.yml`:

```yaml
services:
  web:
    build: .
    ports:
      - "3000:3000"
    environment:
      - DATABASE_URL=postgres://postgres:secret@db:5432/app
    depends_on:
      - db

  db:
    image: postgres:16
    environment:
      - POSTGRES_PASSWORD=secret
    volumes:
      - pgdata:/var/lib/postgresql/data

volumes:
  pgdata:
```

```bash
docker compose up -d        # start everything
docker compose logs -f web  # follow one service's logs
docker compose down         # stop and remove containers
docker compose down -v      # ... and delete the volumes (destroys data)
docker compose up --build   # rebuild images first
```

Inside compose, services reach each other by **service name** as hostname
(`db:5432`, not `localhost:5432`). `localhost` inside a container means that
container, not your machine.

## Cleaning up (Docker eats disk)

```bash
docker system df            # what's using space
docker container prune      # remove stopped containers
docker image prune -a       # remove unused images
docker volume prune         # remove unused volumes — CHECK FIRST, this is data
docker system prune -a      # nuke everything unused
```

## Things that bit me

- Container exits immediately → its main process finished. A container lives
  exactly as long as PID 1 does.
- `COPY` can't reach outside the build context (the directory you passed to
  `docker build`). No `COPY ../file`.
- Editing files inside a running container is pointless — they vanish on
  rebuild. Change the Dockerfile or mount a volume.
- On Apple Silicon / ARM, add `--platform linux/amd64` when an image has no
  ARM build.
