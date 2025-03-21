#!/bin/bash

set -e

mkdir -p /etc/docker/

tee /etc/docker/daemon.json << EOF
{
  "insecure-registries": [
    ${JENKINS_AGENT_INSECURE_REGISTRIES}
  ]
}
EOF

echo "${JENKINS_AGENT_SSH_PUBKEY}" >> .ssh/authorized_keys

echo "Start Docker daemon"

if [ -f /var/run/docker.pid ]; then
  echo "Killing Docker and removing stale docker.pid file"
  pkill dockerd || true
  rm -f /var/run/docker.pid
fi

dockerd --host=unix:///var/run/docker.sock --host=tcp://0.0.0.0:2375 &

until docker info > /dev/null 2>&1; do
  echo "Waiting for Docker to start..."
  sleep 1
done

echo "Docker started successfully"

exec setup-sshd
