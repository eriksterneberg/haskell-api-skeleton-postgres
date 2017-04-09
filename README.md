# Haskell Micro Service Skeleton
This project will when finished offer a ready-to-deploy user micro service implemented in Haskell, optimized for production, with detailed instructions for deployment and maintenance. Before using this service please read the Credits section and thank the authors of the blog posts on which this project is based.

## Quickstart
### Dependencies
 - [Haskell Stack](http://haskellstack.org/)

### Setup database
Todo

### Test and compile repository
```
stack build

rest-service-skeleton
```

## Usage
 - -l, --latest_date: e.g. 2017-01-31; default is today
 
## Examples
```



```

## Credits


## Links
 - [DEV - Design & Usage - foo](link)

## Todo
 - Add endpoints for PUT and DELETE
 - Add more fields to User model
 - Refactor to use Reader to ask for database pool
 - Add error handling for failed POST (database connection error etc.)
 - Add encryption of login and password
 - Add more comments in code
 - Use defaultH to return internalServerError500 on error
 - Implement functional tests
 - Add database username, password and address as environment variables
 - Rename project to better name
 - Deploy on Heroku; deploy database on different dyno
