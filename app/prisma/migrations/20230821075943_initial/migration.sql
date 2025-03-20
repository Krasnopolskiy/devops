-- CreateEnum
CREATE TYPE "task_state" AS ENUM ('todo', 'done');

-- CreateTable
CREATE TABLE "tasks" (
    "id" SERIAL NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "state" "task_state" NOT NULL,
    "title" TEXT NOT NULL,

    CONSTRAINT "tasks_pkey" PRIMARY KEY ("id")
);
