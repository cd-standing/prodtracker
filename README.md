# Prodtracker
Tracker for the production and publication of article for The BMJ


## Overview

### Original tracker:

The current tracker is an HTML page which is updated by metadata from XML files called info files.
The tracker's main page gives an overview of the status of each article as to its status in production or publication in the form of a table.
There are links in the row for each article out to a QA Result page and a preview page, these pages each contain links to graphics and PDFs for that article.

Updates for each article happen when a fully styled article is exported by a Technical Editor from Word. The source XML file is then run through a production pipeline in ANT, the files required to represent each article are deposited in their relevant folders where the main tracker page will link to.

The tracker and its components are currently sat on a filesystem and requires network access to open the HTML page in a browser. This works well for our current setup as users generally have access to the network only from a secure login through the Forticlient VPN. This makes it difficult for external access however and also doesn't provide any way for external systems to access the metadata about each article.


### New tracker:

The new tracker should have the metadata for each article in a database, this should be served to the frontend and available anywhere. This should also have some security built in so that only people with BMJ email addresses can have access.

For this new version the idea is to have the backend consist of a MongoDB with the metadata as JSON and some server code in NodeJS to serve this to a front end.

The front end shouldn't be a single HTML table generated from XML info files but should be made of React components which are updated based upon the article metadata in the MongoDB. Binary files such as PDFs and graphics can be located in their relevant folders or in a single store. The linked HTML pages for the QA Report and HTML preview can initially remain as they are

## Work in progress...

The code currently consists of the backend only.

#### This consists of the following:

- /components (some old files from original prodtracker to work from)
- /src
  - /controllers
    - artInfoController.js (contains functions which facilitates requests to MongoDB and responses. GET, POST, PUT and DELETE)
  - /models
    - artInfoModel.js (contains schema for article info files which will populate Prodtracker table)
  - /routes
    - artInfoRoutes.js (contains "routes", the URL endpoints which will fire the requests to the server)
- index.js (sets up this server on port 4000 with the MongoDB and imports all necessary modules such as 'express', 'body-parser' and 'mongoose')

### To run this...


...
