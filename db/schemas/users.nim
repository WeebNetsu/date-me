import allographer/schema_builder

let tblUsers* = table("users", [
    Column().increments("id").onDelete(CASCADE),
    Column().string("fullName", 100).unique(),
    Column().string("password"),
    Column().string("email").unique(),
])