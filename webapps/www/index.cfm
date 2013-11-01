<!DOCTYPE html>
<html>
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
	    <title>Welcome to Railo <cfoutput>#left(server.railo.version,3)#</cfoutput></title><link rel="stylesheet" href="res/css/style.css" type="text/css" media="all"/>
	</head>
    <body id="documentation" class="twoCol">
   	<div id="container" class="sysDocumentation">
   		<div id="masthead">
   			<div id="header" class="clearfix">
   				<div class="wrap"><h1><a href="http://www.getrailo.org/go.cfm/community_website">Default</a></h1>
   					<h2 id="navPrimary">Welcome to the Railo World!</h2>
   				</div>
   			</div>
   		</div>
   		<div id="content">
			<cfoutput>
   			<div class="wrap clearfix">
				<div class="sidebar" id="left">
					<ul class="navSecondary">
						<li><a href="http://www.getrailo.org/go.cfm/quick-start-guide" target="_blank">Getting Started</a>
						<li><a href="http://www.getrailo.org/go.cfm/community_website" target="_blank">Community Website</a></li>
						<li><a href="http://www.getrailo.org/go.cfm/wiki" target="_blank">Wiki - Documentation</a></li>
						<li><a href="http://www.getrailo.org/go.cfm/mailing-list" target="_blank">Railo Mailing List</a></li>
						<li><a href="http://www.getrailo.org/go.cfm/getrailo_com" target="_blank">Support &amp; Consulting</a></li>
					</ul>
				</div>			
   				<div id="deck">
   					<div class="bg"></div>
   					<div class="wrap">
   						<div class="lead">
							<h3>Railo #left(server.railo.version,3)#</h3>
							<p>You are now successfully running Railo #left(server.railo.version,3)#.
							<br>Please check the Railo Server Administrator for available updates and patches.
						</div>
   					</div>
   				</div>
   				<div id="main">
   					<div id="primary" class="content">
	   					<div id="explanation">
		   					<h2>Important Notes</h2>
							<p>Thank you for choosing Railo as your CFML engine. If you have installed Railo on a public server, please be sure to secure the Server and Web Administrators with strong passwords and whatever means you deem necessary.
							
							<p>If you are new to Railo, please check the <a href="http://www.getrailo.org/go.cfm/quick-start-guide" target="_blank">Getting Started</a> guide on our page on how to begin. In our Wiki you will find a lot of useful information and documentation.

							<p>To start running some code in this Railo instance, place it in the website's folder at:
							<div style="border: 1px solid ##999; border-radius: 5px; margin: 1em; padding: 1em; font-family: monospace;">#getDirectoryFromPath( expandPath( '/' ) )#</div>
						</div>

	   					<h2>System Information</h2>
	   					
	   					<cfset sysInfo = {

	   						  "Java Version"		: Server.java.version
	   						, "Railo Version"		: Server.Railo.version
	   						, "Railo Server"		: expandPath( '{railo-server}' )
	   						, "Servlet Container"	: Server.servlet.name
	   						, "System Time"			: listGetAt( now(), 2, "'" ) & " (#getTickCount()#)"
	   						, "Website Root"		: expandPath( '/' )
	   					}>

	   					<cfdump var="#sysInfo#" label="System Information">
	   					<p>

	   					<h2>Railo Administration</h2>
						<p>The default Railo Server and Web Administrator pages are located in the virtual folders <a href="#CGI.CONTEXT_PATH#/railo-context/admin/server.cfm">/railo-context/admin/server.cfm</a> and <a href="#CGI.CONTEXT_PATH#/railo-context/admin/web.cfm">/railo-context/admin/web.cfm</a> respectively.

						<p>In the case of the Web Administrator, the host determines the Web context, so for example, http://site1/railo-context/admin/web.cfm will administer site1, and http://site2/railo-context/admin/web.cfm will administer site2.

						<table id="table-admin">
							<tr><th>Admin Type</th><th>Virtual Folder</th><th>Settings File</th></tr>
							<tr><td><a href="#CGI.CONTEXT_PATH#/railo-context/admin/server.cfm">Server</a></td><td>/railo-context/admin/server.cfm</td><td>{railo-server}/context/railo-server.xml</td></tr>
							<tr><td><a href="#CGI.CONTEXT_PATH#/railo-context/admin/web.cfm">Web</a></td><td>/railo-context/admin/web.cfm</td><td>{railo-web}/railo-web.xml.cfm</td></tr>
						</table>

						<h2>Tag and Function Reference</h2>
						<ul>For a quick reference visit the following links: 
							<li><a href="#CGI.CONTEXT_PATH#/railo-context/doc/tags.cfm">Tags</a>
							<li><a href="#CGI.CONTEXT_PATH#/railo-context/doc/functions.cfm">Functions</a>
							<li><a href="#CGI.CONTEXT_PATH#/railo-context/doc/objects.cfm">Member Methods</a>
						</ul>
						
						<h2>Setup Tips</h2>
						<p>If you have installed Railo Express, please check out our 
						<a href="http://www.getrailo.org/go.cfm/Railo_Installation" target="_blank">installation guides</a> for other platforms and 
						application servers which are available in the wiki.
						
						<p>This page is running on the virtual host <b>#CGI.SERVER_NAME#</b> on port <b>#CGI.SERVER_PORT#</b>.  Check out the Wiki entry <a href="http://www.getrailo.org/go.cfm/Installation:CreateRailoContext" target="_blank">Creating New Virtual Hosts</a> to learn how to setup more virtual hosts and websites.
						
	   					<cfdump eval=CGI>
   					</div>
   				</div>
   			</div>
			</cfoutput>
   		</div>
   	</div>
   	<div id="footer" class="clearfix">
   		<div class="wrap">&copy;2006-<cfoutput>#year(now())#</cfoutput> Railo Technologies GmbH, Switzerland.</div>
   	</div>
   </body>
</html>
