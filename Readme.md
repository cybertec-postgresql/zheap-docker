# Demo Docker Container for Postgres zHeap

## How to run

```sh
docker run --name zHeap -p 5432:5432 -d cybertecpostgresql/zheap
```

## Connecting

```sh
# Username: postgres
# Password: postgres

psql -h localhost -p 5432 -U postgres
```
