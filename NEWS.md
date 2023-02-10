# Ripc 0.1.3

* `ipc_get_icons()` and `ipc_get_populations()` changed so all date columns
converted from character to date explicitly.

# Ripc 0.1.2

* `ipc_get_analyses()` and `ipc_get_country()` changed to use `anl_id`.
* `ipc_get()` memoised to avoid repeated calls to the API. Now all 
`ipc_get_...()` functions are cached in a session.

# Ripc 0.1.1

* `ipc_get_population()` was fixed so renaming worked correctly
* Update GitHub README and documentation.

# Ripc 0.1.0

* IPC API functionality implemented.
* HDX download functionality deprecated.

# Ripc 0.0.1

* Initial release.
