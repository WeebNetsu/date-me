import allographer/schema_builder

let tblUsers* = table("users", [
    Column().increments("id").onDelete(CASCADE),
    Column().string("username", 50).unique(),
    Column().string("password"),
    Column().string("email").unique().nullable(),
])