#!/usr/bin/env bash

ssh benitez@192.168.5.155
# password: 123456


docker logs --tail 100 -f <container-id>
docker exec -it <container-id> bash
