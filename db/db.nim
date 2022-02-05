import allographer/connection
import allographer/schema_builder

from schemas/users import tblUsers
from schemas/settings import tblSettings
from schemas/completedLessons import tblCompletedLessons

# todo make below conditional, if test then use sqlite, else use mysql
let rdb* = dbOpen(Sqlite3, "db/test.db", maxConnections=1, timeout=5000)

rdb.schema([
    tblUsers,
    tblSettings,
    tblCompletedLessons
])

#[
    # sqlite code for creating tables
    CREATE TABLE "users" (
        "id"	INTEGER NOT NULL UNIQUE,
        "username"	TEXT NOT NULL UNIQUE,
        "password"	TEXT NOT NULL,
        "email"	TEXT UNIQUE,
        PRIMARY KEY("id" AUTOINCREMENT)
    );

import asyncdispatch
import allographer/query_builder
import std/json

proc main(){.async.}=
  await rdb.table("Users").insert(@[
    %*{"username": "Nickalon", "password": "2sdx3d34"}
  ])

  echo await rdb.table("Users").get()

waitFor main()
 ]#