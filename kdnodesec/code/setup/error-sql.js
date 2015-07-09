/***
 * Excerpted from "Secure Your Node.js Web Application",
 * published by The Pragmatic Bookshelf.
 * Copyrights apply to this code. It may not be used to create training material, 
 * courses, books, articles, and the like. Contact us if you are in doubt.
 * We make no guarantees that this code is fit for any purpose. 
 * Visit http://www.pragmaticprogrammer.com/titles/kdnodesec for more book information.
***/
'use strict';

//  CREATE TABLE `accounts` (
//  `id` int(11) NOT NULL AUTO_INCREMENT,
//  `name` varchar(255) NOT NULL,
//  `email` varchar(255) NOT NULL,
//      PRIMARY KEY (`id`)
//  ) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=3 ;
//
//  INSERT INTO `accounts` (`id`, `name`, `email`) VALUES
//  (1, 'karl', 'karl@dyyna.com'),
//  (2, 'juhan', 'juhan@gmail.com');

var mysql = require('mysql');
var express = require('express');
var args = require('minimist')(process.argv);

if(!args.u || !args.d || !args.p) {
    console.log('This example requires the ' +
    '-u (user), ' +
    '-d (mysql db) and ' +
    '-p (password) command line variables');

    process.exit();
}

var connection = mysql.createConnection({
    host     : 'localhost',
    user     : args.u,
    database : args.d,
    password : args.p,
    multipleStatements: true // This is so we can execute multiple statements
});
connection.connect();

var app = express();

app.get('/', function (req, res) {
    res.send('ok');
});

app.get('/:name', function(req, res, next){

    // Query the account based on url parameters
    // As you can see we use no validation on the name parameter
    connection.query('SELECT * FROM accounts WHERE name="' + req.params.name + '"',
        function(err, rows, fields) {
            if (err) {
                next(err);
                return;
            }
            res.send(JSON.stringify(rows));
        });
});

app.listen(3000);
