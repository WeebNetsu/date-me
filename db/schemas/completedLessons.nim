import allographer/schema_builder

let tblCompletedLessons* = table("completedLessons", [
    Column().foreign("userId")
    .reference("id")
    .on("users")
    .onDelete(SET_NULL),

    # incomplete, allographer does not have an array option
    # if time requires it, use the JSON option
    # if we'll be using JSON, we could possibly add it to
    # the users table
])