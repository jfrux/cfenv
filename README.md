railoenv
=====================
This is a dead simple RAILO EXPRESS CFML DEVELOPMENT ENVIRONMENT for Mac OS X / Linux.
Support for Windows may come soon but may be in a separate repository.

### Installation

- Open your Terminal.
- Copy/Paste `\curl -L https://raw.github.com/joshuairl/railoenv/master/binscripts/installer | bash`

### Features
Enables the ability to initialize a Railo context from any directory by doing the following:
```
$> mkdir -p ~/Projects/my_new_cfml_project
$> cd ~/Projects/my_new_cfml_project
$> railo_init
```

For more information about this technique, you can see an article by Mark Drew regarding his "railo_runner" technique that him and I thought up.
http://www.markdrew.co.uk/blog/post.cfm/running-railo-from-any-directory

### ToDo

- Allow for version selection and local / global railo versions a la rbenv / nodenv.
- `railoenv` CLI
- `railoenv new` command for creating a railo context in a directory
- `railoenv server` command for starting the local railo context with possible port options.
