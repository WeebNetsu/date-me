import json, asyncdispatch
import allographer/[connection, schema_builder, query_builder]

from schemas/users import tblUsers

let rdb* = dbOpen(Sqlite3, "db/test.db", maxConnections=1, timeout=5000)

rdb.schema([
  tblUsers,
])

# will automatically add this user to table if table is empty
seeder rdb, "users":
  waitFor rdb.table("users").insert(@[
    %*{
      "fullName": "Mike Sewer Labruska",
      "password": "password",
      "email": "user@gmail.com",
      "profilePicture": "/static/images/default.jpg",
      "likes": "anime,sports,movies,gaming,drinking",
      "description": "I want a date pls... I am cool I swear! I am actually a very sexy male, this profile picture is just to get your attention! Please go out with me!",
      "hasDong": "yes",
    },
  ])