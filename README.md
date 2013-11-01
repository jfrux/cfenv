railo-devenv-mac
================

This is my RAILO CFML ENGINE development environment for Mac.

I'm able to go into a new directory such as ~/Projects/my_new_app/ and type "railo_init" and it will route everything appropriately.
Starts the individual context on http://localhost:8888/

Download the latest Railo 4.x Express with Jetty from http://getrailo.com/
Place those files inside a directory on your Macintosh HD, we're going to use `/usr/local/railo` for ours.

Copy the files in this repo over top of the railo folder so finish setup.

Open up Terminal.app and type:
`chmod +x /usr/local/railo/railo_init`

And then edit bashrc file:
`nano ~/.bashrc`

Add these lines to `.bashrc`
export RAILO_INIT=/usr/local/railo
export PATH=$RAILO_INIT:$PATH

Then press CTRL+O to write to the file.

Now if you close and re-open Terminal, you should 
