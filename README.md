Hello World Buildpack Lab
=========================
In this lab you will learn the basics of the build pack lifecycle by fixing a broken build script.  You will then use that build script to deploy a simple application that displays a message from a file called "message.msg".

Prerequisites
-------------
* A github account you can use to create a repository to push your buildpack to
    * Sign up at http://www.github.com
* Git installed to your machine
    * The easiest way to get git is to use Github's native app.  You can go to https://help.github.com/articles/set-up-git and use the link at the top of the page to download the Github native app.  Otherwise, follow the instructions to install git yourself if you want to do it the hard way.
* The cf command line tool installed to your system

Instructions
------------

### Step 1
Login to your github account, create a new repo called message-server-buildpack, and then clone it locally so that you can put your buildpack in it.

### Step 2
Copy the contents of the directory this file is in, and all subfolders to your newly cloned repo.  Commit this initial set of files, and then push the changes to Github.

### Step 3
Next, create a directory outside of your git repo that we can use to host our "application" files.  This directory doesn't need to be in git.

In this new directory, create a file called message.msg and put some text of your choice in it.  Nothing too fancy now...

### Step 4
Go to the Github interface and navigate to the root of the repo you pushed your copy of the buildpack to.  It will be similar to https://github.com/<your-user-name>/message-server-buildpack, if you named your repo as suggested above.  Copy this URL into the clipboard so you can use it in the next step.

### Step 5
Open up a terminal window and navigate to where you created the directory that contains the message.msg file.  

Target and login to the Cloud Foundry instance you are going to deploy your application to.  

Now push your application with your custom buildpack using the following command (replacing <your-copied-url> with the URL in the clipboard):

	cf push --buildpack=<your-copied-url>

You should see some output similar to the following:
```
cdelashmutt-mbp:message-app cdelashmutt$ cf push --buildpack=https://github.com/cdelashmutt-pivotal/buildpack-examples.git
Name> message-app

Instances> 1

1: 128M
2: 256M
3: 512M
4: 1G
Memory Limit> 64M 

Creating message-app... OK

1: message-app
2: none
Subdomain> message-app

1: cfapps.io
2: none
Domain> cfapps.io

Binding message-app.cfapps.io to message-app... OK

Create services for application?> n

Bind other services to application?> n

Save configuration?> y

Saving to manifest.yml... OK
Uploading message-app... OK
Preparing to start message-app... OK
-----> Downloaded app package (4.0K)
Initialized empty Git repository in /tmp/buildpacks/buildpack-examples/.git/
Got message:  Hello Cloud Foundry!

Putting start script into droplet
compile: I/O Error(2) during startup script copy: No such file or directory
Checking status of app 'message-app'...Application failed to stage
```

Wait.  What just happened?  We got an error??  Let's see if we can fix it...

### Step 6
The way this build script is supposed to work is that it simply copies a script called message-server.sh from the root of the buildpack into the root of the build directory for the droplet.

Check the output from the staging process.  It looks like there is an error message from one of the scripts in the buildpack.  Try to find out which script might be causing the error based on error message.  Look into the repo you created under the bin directory for the buildpack scripts. 

Once you find the problem and feel like you have corrected it, commit your changes, and push them to Github.  Try your build again and see if you get anything different happening.

Getting a new error?  It's ok, it's all part of the plan.  Just go to the next step.

### Step 7
This time you probably saw output similar to the following:
```
cdelashmutt-mbp:message-app cdelashmutt$ cf push --buildpack=https://github.com/cdelashmutt-pivotal/buildpack-examples.git
Using manifest file manifest.yml

Uploading message-app... OK
Stopping message-app... OK

Preparing to start message-app... OK
-----> Downloaded app package (4.0K)
Initialized empty Git repository in /tmp/buildpacks/buildpack-examples/.git/
Got message:  Hello Cloud Foundry!

Putting start script into droplet
compile: I/O Error(2) during startup script copy: No such file or directory
Checking status of app 'message-app'...Application failed to stage
cdelashmutt-mbp:message-app cdelashmutt$ cf push --buildpack=https://github.com/cdelashmutt-pivotal/buildpack-examples.git
Using manifest file manifest.yml

Uploading message-app... OK
Stopping message-app... OK

Preparing to start message-app... OK
-----> Downloaded app package (4.0K)
Initialized empty Git repository in /tmp/buildpacks/buildpack-examples/.git/
Got message:  Hello Cloud Foundry!

Putting start script into droplet
-----> Uploading droplet (4.0K)
Checking status of app 'message-app'...
  0 of 1 instances running (1 starting)
  0 of 1 instances running (1 down)
...repeated quite a few times...
  0 of 1 instances running (1 down)
  0 of 1 instances running (1 crashing)
Push unsuccessful.
TIP: The system will continue to attempt restarting all requested app instances that have crashed. Try 'cf app' to monitor app status. To troubleshoot crashes, try 'cf events' and 'cf crashlogs'.
```

That last statement in the output is a pretty good suggestion.  Let's try to execute 'cf crashlogs' and take a look at what happened.

Read through the logs and see what you find.  The staging_task.log cooresponds to the compile phase, and the stderr.log and stdout.log files coorespond to the release phase.

See the problem?  Try to fix it in the cooresponding script.

Once you fix that problem, commit and push again and try out your changes until you get a successful deploy.

You should see some output similar to the following when everything is working:
```
cdelashmutt-mbp:message-app cdelashmutt$ cf push --buildpack=https://github.cocdelashmutt-pivotal/buildpack-examples.git
Using manifest file manifest.yml

Uploading message-app... OK
Stopping message-app... OK

Preparing to start message-app... OK
-----> Downloaded app package (4.0K)
-----> Downloaded app buildpack cache (4.0K)
Initialized empty Git repository in /tmp/buildpacks/buildpack-examples/.git/
Got message:  Hello Cloud Foundry!

Putting start script into droplet
-----> Uploading droplet (4.0K)
Checking status of app 'message-app'...
  1 of 1 instances running (1 running)
Push successful! App 'message-app' available at message-app.cfapps.io
```

### Step 8
Now test out your "application" by going to the host name specified at the end of the successful deploy.  You should see the message from your message.msg file displayed in your browser.  If not, try using 'cf logs', and review your scripts to troubleshoot the issues yourself.

Summary
-------
In this lab, we saw explored the lifecycle of an application deployment through the process of troubleshooting the problems with a simple buildpack.  

At this point you should understand better how each script ties into each phase of the deployment process for an application in Cloud Foundry.  You should now also have a basic template for buildpacks that you can use as the basis to create your own.
