tbooster
========

Runs unit tests faster by not reloading the testing environment every time you're running a test. Currently works only with the defailt testing framework( TestUnit )

Usage:
---------------
replace `ruby` with `tbooster` when running tests:

tbooster test/unit/users.rb

OR

tbooster test/unit/users.rb -n test_user_exists?

Implementation:
--------------
Tbooster comes with an executable file which passes commands (the arguments it received) to a named pipe (found in tmp/tbooster_pipe) and ensures the two runner processes are started.

Runner processes
- first process loads the ruby testing environment and reads commands received on the named pipe mentioned above.
- second process listens for file changes (helpers, models, controlers and lib) and sends a reload command to the named pipe when a file was changed.

Processing commands:
- when a file was changed the command runner process loads that file again so that we have the testing environment up to date with the latest code changes.
- when a `run test` command was received we fork the process that holds the most recent testing environment and require the test file that needs to be runned

Isses:
-------

1. When changing branches in your repository if too many files were changes ree throws an error closing the process that holds the testing environment therefore we'll have to start it again
2. When reloading a file, constants are assigned again and a warning message will be displayed stating there is already a constant with that name
3. After a commands was issued you need to hit enter in the console to update the caret position
4. Reloading a file updates the existing methods or adds new ones. It's not deleting unused methods
