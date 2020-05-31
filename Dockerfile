FROM jwilder/nginx-proxy:latest

# docker-gen where GetCurrentContainerID has been fixed
# so it can recongnize containers from /proc/self/cgroup"
# with name containing  docker_limit.slice/
# Based on docker gen 1.7.4

COPY docker-gen /usr/local/bin/docker-gen

ENTRYPOINT ["/app/docker-entrypoint.sh"]

CMD ["forego", "start", "-r"]
