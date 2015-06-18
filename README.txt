################################################################################
# Setup
################################################################################

The goal of the project is to teach vocabulary in any world language to reach
a university-level vocabulary (~10,000 words). Words are scraped in frequency
order as they appear in Wikipedia, and defined according to the definitions
on en.wiktionary.org.

Words are presented via a web application.


################################################################################
# web/*
################################################################################

This directory contains all of the code that runs on the server. This
includes the web scraper, database management, the API, and a dictionary
management application accessible to users with the correct permissions. The API
and management application are accessible only via https://

web/scripts/scraper
	
	The scraper. Reads massive wikipedia dump files, fills out MongoDB
	collections, indexes the database, defines words, sorts by frequency, and
	compiles dictionaries.

web/pylib

	Python files that are not executed as scripts. Shared resource for scripts
	and for the API.

web/static

	Static files used by the API.

web/templates/

	Templates rendered by the the management application.


################################################################################
# app/*
################################################################################

This directory contains the static portion of the website which comprises the
user-facing application. Can be accessed via http://


################################################################################
# scripts/*
################################################################################

Platform admin scripts. Handles the super simple release system, compiling
code, watching files, etc.


################################################################################
# config/*
################################################################################

Basic config information.
