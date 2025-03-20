#!/bin/bash

echo "Apply database migrations"
npm run migrate deploy

exec "$@"
