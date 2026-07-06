main.rs should only contain routes
views is a directory and a module, which will contain separate views files by the features. Like the user feature is users.rs which will contain hittable endpoint logic which is user related, and will be under /users/
system.rs in views is an exception as it can take several endpoints on root domain.
db_handler.rs should only contain db helper functions and must be the only file with raw SQL queries
