import json, asyncdispatch
import allographer/[connection, schema_builder, query_builder]

from schemas/users import tblUsers
from schemas/settings import tblSettings

# todo make below conditional, if test then use sqlite, else use mysql
let rdb* = dbOpen(Sqlite3, "db/test.db", maxConnections=1, timeout=5000)

rdb.schema([
  tblUsers,
  tblSettings,
])

# will automatically add this user to table if table is empty
seeder rdb, "users":
  waitFor rdb.table("users").insert(@[
    %*{
      "fullName": "user",
      "password": "password",
      "email": "user@gmail.com",
    },
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