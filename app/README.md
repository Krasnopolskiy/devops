# DevOps TODO

Sample todo list application for DevOps course

## Requirements

- NodeJS 18.17.1
- PostgreSQL 15.4

## Building

- Install dependencies with `npm install`
- Build application with `npm run build`
- Built application will appear in the `.next/standalone` directory

## Migrating database

- Set `DATABASE_URL` env variable to your target database. Ex: `postgresql://postgres:postgres@localhost:5432/devops_todo?schema=public`
- Install prisma database client with `npm install -g prisma`
- Run database migrations with `npm run migrate deploy`

**Important** - prisma client is looking for migrations in the `prisma` directory inside the directory where you're running the migrate command. By default, this directory is in the project root. But if you want to run migrations from another directory be sure to copy `prisma` directory from project root to the desired directory.

## Running

- Set `DATABASE_URL` env variable to your database. Ex: `postgresql://postgres:postgres@localhost:5432/devops_todo?schema=public`
- Start server by executing command `node server.js` from the build directory (`.next/standalone`)
- Server will be started on 3000 port by default. To change the default port set `PORT` env variable.

### Metrics

Metrics are available on `/metrics` path. For example: `http://localhost:3000/metrics`

## Linting

- Install dependencies with `npm install`
- Run linter with `npm run lint`

## Testing

- Install dependencies with `npm install`
- Install prisma client `npm install -g prisma`
- Set `DATABASE_URL` env variable to your test database. Ex: `postgresql://postgres:postgres@localhost:5432/devops_todo_test?schema=public`
- Start PostgreSQL
- Run tests with `npm run test`
- Code coverage reports will be available in the console output and `coverage` directory

## Development

- Copy `.env.sample` file to `.env`
- Edit `.env` file and set `DATABASE_URL` variable for your database
- Install dependencies with `npm install`
- Start PostgreSQL
- Create and migrate database with `npm run migrate dev`
- Start the development server with `npm run dev`
- Open http://localhost:3000 in your browser
