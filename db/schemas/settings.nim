import allographer/schema_builder

let tblSettings* = table("settings", [
    Column().foreign("userId")
    .reference("id")
    .on("users")
    .onDelete(SET_NULL),

    Column().boolean("darkMode").default(false),
])