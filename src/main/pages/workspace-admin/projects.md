---
title: "Projects"
keywords: workspace, runtime, project, projects
tags: [workspace, runtime, docker, kubernetes]
sidebar: user_sidebar
permalink: projects.html
folder: workspace-admin
---

## Projects in Workspaces

{% include links.html %}

Projects are always associated with a workspace and saved in a workspace configuration:

```json
"projects": [
   {
     "description": "A basic example using Spring servlets. The app returns values entered into a submit form.",
     "source": {
       "location": "https://github.com/che-samples/web-java-spring.git",
       "type": "git",
       "parameters": {}
     },
     "links": [],
     "mixins": [],
     "problems": [],
     "name": "web-java-spring",
     "type": "maven",
     "path": "/web-java-spring",
     "attributes": {}
   }
 ]
 ```
Once a project is saved into a workspace config, the IDE will check if the project exists on a file system, and if not, import it using `source.location` URL. It happens at IDE initialization stage.

You can add Git projects, remotely hosted archives, your GitHub projects or project samples that Eclipse Che offers out of the box. Project import tools can be found both in User Dashboard (when creating a new workspace or editing an existing one) on in the IDE, Workspace menu.

{% include image.html file="workspaces/projects.png" %}

## Sub-Projects

A sub-project is a portion of a project that can have sets of commands run against it where the sub-directory is treated as the root working directory. Sub-projects make it possible to organize a single repository into multiple, independently buildable and runnable units. To create a module, right click on a folder in the IDE explorer tree and select `Convert to Project`.  You can then execute commands directly against this sub-projects.

## Into  

You can step into or out of the project tree. If you step into a folder, that folder will be set as the project tree root and the explorer will redraw itself. All commands are then executed against this folder root.

## Project Type Definition  

Plug-in developers can define their own project types. Since project types trigger certain behaviors within the IDE, the construction of the projects is important to understand.

1. **A project has type.** Project type is defined as one primary type and zero or more mixin types. A primary project type is one where the project is editable, buildable and runnable. A mixin project type defines additional restrictions and behaviors of the project, but by itself cannot be a primary project type. The collection of primary and mixin types for a single project define the aggregate set of attributes that will be stored as meta data within the project.

2. **Project types describe different aspects of a project** such as types of source files inside, the structure of the explorer tree, the way in which a command will be executed, associated workflows, and which plug-ins must be installed.

3. **A project defines a set of attributes.** The attributes of a project can be mandatory or optional. Attributes that are optional can be dynamically set at runtime or during configuration.

4. **Sub-projects may have different project types than their parents.** Modules may physically exist within the tree structure of the parent (as its subfolders) or outside (the parent is a soft link to the module project).
