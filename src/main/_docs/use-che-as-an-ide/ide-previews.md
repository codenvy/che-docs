---
tags: [ "eclipse" , "che" ]
title: Previews
excerpt: ""
layout: docs
permalink: /:categories/previews/
---
{% include base.html %}
Preview objects are URLs that reference specific files or endpoints activated by your project when you run a [command]({{base}}{{site.links["ide-commands"]}}). For example, you may have a command to start a Spring application server and deploy your project's artifacts into the application server. A preview object can be used to present the user with the URL of the deployed application.

# Create  
Preview objects are stored as part of command. {{ site.product_mini_name }} will generate the preview URL during the command execution and present the URL to the user as part of the command output. You can add a preview URL of any format within the command editor.

![command-preview.png]({{base}}{{site.links["command-preview.png"]}})

The preview object will dynamically determine the appropriate URL when the command is run.

![Capture_preview.PNG]({{base}}{{site.links["Capture_preview.PNG"]}})

# Access Previews
From the command toolbar, you can get a quick access to all the severs that are running in your workspace's machines.

![command-toolbar.png]({{base}}{{site.links["command-toolbar.png"]}})
