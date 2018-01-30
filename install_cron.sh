#!/bin/bash
cp sample.nginx.cron nginx.cron

sed -i "s/{nginx-path}/$(pwd)/g" nginx.cron

mv nginx.cron /etc/cron.d

