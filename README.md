# couchbase-sql-shell

originally forked from **cli-console**  
[![Gem Version](https://badge.fury.io/rb/cli-console.png)](http://badge.fury.io/rb/cli-console)

SQL-like Shell Environment for Couchbase

## Features

* Shell environment with MySQL-like command set for accessing data in Couchbase
* Pretty printed output

## Installation

Run shell.rb from the shell directory

### Dependecies

Ruby version 1.9.x or newer  
[HighLine](http://rubygems.org/gems/highline)  
[Couchbase](http://rubygems.org/gems/couchbase)  
Also uses net/http and json

## Usage Example

Commands supported include:  

    CONNECT <server>, <username>, <password>
    SHOW VERISON|BUCKETS
    DESCRIBE [<bucketname>]
more to follow..

![couchbase-sql-shell screenshot](http://avensolutions-images.s3-website-us-east-1.amazonaws.com/couchbase-sql-shell.png)

