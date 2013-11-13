# Groom your app’s CFML dev environment with cfenv.

Use cfenv to pick a Railo version for your application and ensure 
that your development environment matches production.

**Truly empowering.** Specify your app's Railo version once, in a single file. 
Keep all your teammates on the same page. No headaches running apps on different versions of Railo. 
Just Works™ from the command line. Override the Railo version anytime: just set an environment variable.

**It just works.** cfenv is concerned solely with managing and switching Railo versions. It's simple and predictable.

## Table of Contents

* [Installation](#installation)
  * [Basic GitHub Checkout](#basic-github-checkout)
    * [Upgrading](#upgrading)
  * [Homebrew on Mac OS X](#homebrew-on-mac-os-x)
  * [Installing Railo Versions](#installing-railo-versions)
  * [Uninstalling Railo Versions](#uninstalling-railo-versions)
* [How It Works](#how-it-works)
  * [Understanding PATH](#understanding-path)
  * [Understanding Shims](#understanding-shims)
  * [Choosing the Railo Version](#choosing-the-railo-version)
  * [Locating the Railo Installation](#locating-the-railo-installation)
* [Command Reference](#command-reference)
  * [cfenv local](#cfenv-local)
  * [cfenv global](#cfenv-global)
  * [cfenv start](#cfenv-start)
  * [cfenv shell](#cfenv-shell)
  * [cfenv versions](#cfenv-versions)
  * [cfenv version](#cfenv-version)
  * [cfenv rehash](#cfenv-rehash)
  * [cfenv which](#cfenv-which)
  * [cfenv whence](#cfenv-whence)
* [Development](#development)
  * [License](#license)

## Installation

If you're on Mac OS X, consider
[installing with Homebrew](#homebrew-on-mac-os-x).

### Basic GitHub Checkout

This will get you going with the latest version of cfenv and make it
easy to fork and contribute any changes back upstream.

1. Check out cfenv into `~/.cfenv`.

    ~~~ sh
    $ git clone https://github.com/joshuairl/cfenv.git ~/.cfenv
    ~~~

2. Add `~/.cfenv/bin` to your `$PATH` for access to the `cfenv`
   command-line utility.

    ~~~ sh
    $ echo 'export PATH="$HOME/.cfenv/bin:$PATH"' >> ~/.bash_profile
    ~~~

    **Ubuntu Desktop note**: Modify your `~/.bashrc` instead of `~/.bash_profile`.

    **Zsh note**: Modify your `~/.zshrc` file instead of `~/.bash_profile`.

3. Add `cfenv init` to your shell to enable shims and autocompletion.

    ~~~ sh
    $ echo 'eval "$(cfenv init -)"' >> ~/.bash_profile
    ~~~

    _Same as in previous step, use `~/.bashrc` on Ubuntu, or `~/.zshrc` for Zsh._

4. Restart your shell so that PATH changes take effect. (Opening a new
   terminal tab will usually do it.) Now check if cfenv was set up:

    ~~~ sh
    $ type cfenv
    #=> "cfenv is a function"
    ~~~

5. Install a Railo version.
   [Installing new Railo versions](#installing-railo-versions).

#### Upgrading

If you've installed cfenv manually using git, you can upgrade your
installation to the cutting-edge version at any time.

~~~ sh
$ cd ~/.cfenv
$ git pull
~~~

To use a specific release of cfenv, check out the corresponding tag:

~~~ sh
$ cd ~/.cfenv
$ git fetch
$ git checkout v0.0.5
~~~

If you've [installed via Homebrew](#homebrew-on-mac-os-x), then upgrade
via its `brew` command:

~~~ sh
$ brew update
$ brew upgrade cfenv railo-build
~~~

### Homebrew on Mac OS X

As an alternative to installation via GitHub checkout, you can install
cfenv using the [Homebrew](http://brew.sh) package
manager on Mac OS X:

~~~
$ brew tap joshuairl/homebrew-cfenv
$ brew update
$ brew install cfenv
~~~

Afterwards you'll still need to add `eval "$(cfenv init -)"` to your
profile as stated in the caveats. You'll only ever have to do this
once.

Mac OS X
~~~
$ nano ~/.bash_profile
~~~

Ubuntu-desktop / Linux Distros

~~~

~~~

### Neckbeard Configuration

Skip this section unless you must know what every line in your shell
profile is doing.

`cfenv init` is the only command that crosses the line of loading
extra commands into your shell. Coming from RVM, some of you might be
opposed to this idea. Here's what `cfenv init` actually does:

1. Sets up your shims path. This is the only requirement for cfenv to
   function properly. You can do this by hand by prepending
   `~/.cfenv/shims` to your `$PATH`.

2. Installs autocompletion. This is entirely optional but pretty
   useful. Sourcing `~/.cfenv/completions/cfenv.bash` will set that
   up. There is also a `~/.cfenv/completions/cfenv.zsh` for Zsh
   users.

3. Rehashes shims. From time to time you'll need to rebuild your
   shim files. Doing this automatically makes sure everything is up to
   date. You can always run `cfenv rehash` manually.

4. Installs the sh dispatcher. The sh dispatcher doesn't do
   anything crazy like override `cd` or hack your shell prompt, but if
   for some reason you need `cfenv` to be a real script rather than a
   shell function, you can safely skip it.

Run `cfenv init -` for yourself to see exactly what happens under the
hood.

### Installing Railo Versions

The `cfenv install` command downloads, and installs Railo Express versions for you.

~~~ sh
# list all available versions:
$ cfenv install -l

# install a Railo version:
$ cfenv install 4.1.1.009
~~~

### Uninstalling Railo Versions

As time goes on, Railo versions you install will accumulate in your
`~/.cfenv/versions` directory.

~~~ sh
# uninstall a railo version
$ cfenv uninstall 4.1.1.009
~~~

You can also remove old Railo versions by `rm -rf` the directory of the
version you want to remove. You can find the directory of a particular
Railo version with the `cfenv prefix` command, e.g. `cfenv prefix
4.1.1.009`.

### Starting a Railo Context

Once you have an installed version of Railo and have set it globally or locally for a project.
You can start the web server for your project with the `cfenv start` command.

~~~ sh
# start a railo web server in the current directory
$ cfenv start
~~~

You can also specify a custom port if the default `8888` just won't due.

~~~ sh
# define a custom port for the web server
$ cfenv start -p 3000
~~~

## How It Works

At a high level, cfenv intercepts Railo commands using shim
executables injected into your `PATH`, determines which Railo version
has been specified by your application, and passes your commands along
to the correct Railo installation.

### Understanding PATH

When you run a command like `railo_init`, your operating system
searches through a list of directories to find an executable file with
that name. This list of directories lives in an environment variable
called `PATH`, with each directory in the list separated by a colon:

    /usr/local/bin:/usr/bin:/bin

Directories in `PATH` are searched from left to right, so a matching
executable in a directory at the beginning of the list takes
precedence over another one at the end. In this example, the
`/usr/local/bin` directory will be searched first, then `/usr/bin`,
then `/bin`.

### Understanding Shims

cfenv works by inserting a directory of _shims_ at the front of your
`PATH`:

    ~/.cfenv/shims:/usr/local/bin:/usr/bin:/bin

Through a process called _rehashing_, cfenv maintains shims in that
directory to match every Railo command across every installed version
of Railo—`railo_init` only at this point.

railo_init is responsible for creating and/or starting a Railo context within the current directory.
We will be adding other separate command line tools for Railo and CFWheels framework at later date.
Shims are lightweight executables that simply pass your command along
to cfenv. So with cfenv installed, when you run, say, `railo_init`, your
operating system will do the following:

* Search your `PATH` for an executable file named `railo_init`
* Find the cfenv shim named `railo_init` at the beginning of your `PATH`
* Run the shim named `railo_init`, which in turn passes the command along to
  cfenv

### Choosing the Railo Version

When you execute a shim, cfenv determines which Railo version to use by
reading it from the following sources, in this order:

1. The `CFENV_VERSION` environment variable, if specified. You can use
   the [`cfenv shell`](#cfenv-shell) command to set this environment
   variable in your current shell session.

2. The first `.railo-version` file found by searching the directory of the
   script you are executing and each of its parent directories until reaching
   the root of your filesystem.

3. The first `.railo-version` file found by searching the current working
   directory and each of its parent directories until reaching the root of your
   filesystem. You can modify the `.railo-version` file in the current working
   directory with the [`cfenv local`](#cfenv-local) command.

4. The global `~/.cfenv/version` file. You can modify this file using
   the [`cfenv global`](#cfenv-global) command. If the global version
   file is not present, cfenv assumes you want to use the "system"
   Railo—i.e. whatever version would be run if cfenv weren't in your
   path.

### Locating the Railo Installation

Once cfenv has determined which version of Railo your application has
specified, it passes the command along to the corresponding Railo
installation.

Each Railo version is installed into its own directory under
`~/.cfenv/versions`. For example, you might have these versions
installed:

* `~/.cfenv/versions/4.1.1.009/`
* `~/.cfenv/versions/3.0.2.000/`
* `~/.cfenv/versions/3.3.3.001/`

Version names to cfenv are simply the names of the directories in
`~/.cfenv/versions`.


## Command Reference

Like `git`, the `cfenv` command delegates to subcommands based on its
first argument. The most common subcommands are:

### cfenv local

Sets a local application-specific Railo version by writing the version
name to a `.railo-version` file in the current directory. This version
overrides the global version, and can be overridden itself by setting
the `CFENV_VERSION` environment variable or with the `cfenv shell`
command.

    $ cfenv local 3.0.2.001

When run without a version number, `cfenv local` reports the currently
configured local version. You can also unset the local version:

    $ cfenv local --unset

### cfenv global

Sets the global version of Railo to be used in all shells by writing
the version name to the `~/.cfenv/version` file. This version can be
overridden by an application-specific `.railo-version` file, or by
setting the `CFENV_VERSION` environment variable.

    $ cfenv global 4.1.1.009

When run without a version number, `cfenv global` reports the
currently configured global version.

### cfenv start

Starts a railo web server context within the current directory.

    $ cfenv start

Also, you can specify the port the server will run on if the default `8888` just won't do.

    $ cfenv start --port 3000

### cfenv shell

Sets a shell-specific Railo version by setting the `CFENV_VERSION`
environment variable in your shell. This version overrides
application-specific versions and the global version.

    $ cfenv shell 4.1.1.009

When run without a version number, `cfenv shell` reports the current
value of `CFENV_VERSION`. You can also unset the shell version:

    $ cfenv shell --unset

Note that you'll need cfenv's shell integration enabled (step 3 of
the installation instructions) in order to use this command. If you
prefer not to use shell integration, you may simply set the
`CFENV_VERSION` variable yourself:

    $ export CFENV_VERSION=4.1.1.009

### cfenv versions

Lists all Railo versions known to cfenv, and shows an asterisk next to
the currently active version.

    $ cfenv versions
      4.1.1.009
      3.3.3.001
    * 3.0.2.001

### cfenv version

Displays the currently active Railo version, along with information on
how it was set.

    $ cfenv version
    4.1.1.009 (set by /Users/joshua/Projects/my_cfml_project/.railo-version)

### cfenv rehash

Installs shims for all Railo executables known to cfenv (i.e.,
`~/.cfenv/versions/*/bin/*`). Run this command after you install a new
version of Railo, or install a gem that provides commands.

    $ cfenv rehash

### cfenv which

Displays the full path to the executable that cfenv will invoke when
you run the given command.

    $ cfenv which railo_init
    /Users/joshua/.cfenv/versions/4.1.1.009/bin/railo_init

### cfenv whence

Lists all Railo versions with the given command installed.

    $ cfenv whence railo_init
    4.1.1.009
    3.3.3.001
    3.0.2.000

### Special Thanks

A big special thanks to Sam Stephenson (github.com/sstephenson) for building just a great Ruby tool called RBENV.
Without it, CFENV would be nothing.

### License

(The MIT license)

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
