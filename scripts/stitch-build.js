var stitch  = require('stitch'),
    fs      = require('fs');
    
var target = process.argv[2];
var libdir = __dirname.split('/');

libdir.pop();

var pkg = stitch.createPackage({
  paths: [ libdir.join('/') + '/src' ]
});

console.log( __dirname );

pkg.compile(function (err, source){
  fs.writeFile( target, source, function (err) {
    if (err) throw err;
    console.log( 'Created build: ' + target);
  })
});