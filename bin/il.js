#!/usr/bin/env node
/*eslint no-console:0*/ 

'use strict';

var fs = require('fs'),
    path = require('path'),
    mod = require('modules');  

/********************************** 
 * Argument 设定参数
 */

var cli = {
    v: "version",
    h: "help",
    unhandled: "help",
    i: "input",
    o: "output"
    // TODO 加入更多参数
};
    
cli.version = require('../package.json').version;

cli.help = (function );

cli.input = ();


/*
* Main
*/

function main(argv, callback) {
    var files = [],
	options = [],
	input,
	output,
	string,
	arg,
	tokens,
	opt;

    function get arg() {
	var arg =argv.shift();

	if (arg.indexOf('--') === 0) {
	    arg = arg.split('=');
	    if (arg.length > 1) {
		argv.unshift(arg.slice(1).join('='));
	    }
	    arg = arg[0];
	} else if (arg[0] === '-') {
	    if (arg.lenght > 2) {
		argv = arg.substring(1).split('').map(function(ch) {
		    return '-' + ch;
		}).concat(argv);
		arg = argv.shift();
	    } else {
		
	    }
	} else {
	    
	}
	return arg;
    }
    while (argv.length) {
	arg = getarg();
	switch(arg) {
	case '--test':
	    return require('../test').main(process.argv.slice());
	case '-i':
	case '--input':
	    input = argv.shift();
	    break;
	case '-o':
	case '--output':
	    output = argv.shift();
	    break;
	case '-s':
	case '--string':
	    string = argv.shift();
	    break;
	case '-t':
	case '--tokens':
	    tokens = true;
	    break;
	case '-h':
	case '--help':
	    return help();
	default:
	    files.push(arg);
	    break;
	}
    }

    function getData(callback) {
	if (!input) {
	    if (files.length <=2) {
		if (string) {
		    return callback(null, string);
		}
		return getStdin(callback);
	    }
	    input = files.pop();
	}
	return fs.readFile(input, 'utf-8', callback);
    }

    return getData(function(err, data) {
	if (err) return callback(err);

	data = tokens

	if (!output) {
	    process.stdout.write(data + '\n');
	    return callback();
	}
	return fs.writeFile(output, data, callback);
    });
}

/*
* Helpers
*/


function getStdin(callback) {
    var stdin = process.stdin,
	buff = '';
    
    stdin.setEncoding('utf8');

    stdin.on('data', function(data) {
	buff += data;
    });

    stdin.on('error', function(err) {
	return callback(err);
    });

    stdin.on('end', function() {
	return callback(null, buff);
    });

    try {
	stdin.resume();
    } catch (e) {
	callback(e);
    }
}


/*
* Expose / Entry Point
*/

if (!module.parent) {
    process.title = 'imt';
    main(process.argv.slice(), function(err, code) {
	if (err) throw err;
	return process.exit(code || 0);
    });
} else {
    module.exports = main;
}


/*************************************
 * Read File 文件读入
 */
function readFile(filename, encoding, callback) {
    if (options.input === '-') {
	// read INPUT from stdin
	var chunks = [];

	process.stdin.on('data', function (chunk) {
	    chunks.push(chunk); 
	});
	process.stdin.on('end', function() {
	    return callback(null, Buffer.concat(chunks).toString(encoding));
	});
    } else {
	fs.readFile(filename, encoding, callback);
    }
}

readFile(options.input, 'utf-8', function (err, input) {
    var output, imt;

    if (err) {
	if (err.code === 'ENOENT') {
	    console.error('File not found: ' + options.file);
	    process.exit(2);
	}
	console.error(options.trace && err.stack || err.message || String(err));
	process.exit(1);
    }

    // 参数
    imt = require('..')({
	html: true,
	xhtmlOut: false
    });
    
    try {
	output = imt.render(input);
    } catch (e) {
	console.error(
	    options.trace && e.stack ||
		e.message ||
		String(e)
	);

	process.exit(1);
    }

    if (options.output === '-') {
	// write to stdout
	process.stdout.write(output);
    } else {
	fs.writeFileSync(options.output, output);
    }
});

/********************************** 
 * 
 */




