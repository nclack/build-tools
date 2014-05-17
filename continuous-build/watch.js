/**
 * Copyright (c) 2014 Nathan Clack, All Rights Reserved
 */
var fs   = require('fs'),
    path = require('path'),
    cp   = require('child_process');

var settings = {
  'exclude' : ['build']
};

var watches = {};

function walk(root,ret) {
  fs.stat(root,function(err,stats) {
    if(err)
      console.warning(err);
    if(stats.isDirectory()) {
      fs.readdir(root,function(err,files) {
        if(err)
          console.warning(err);
        files.forEach(function(file) {
          if(settings.exclude.indexOf(file)>-1)
            return;
          walk(path.join(root,file),ret);
        });
      });
    } else { // only watch the files
      watches[root]=fs.watch(root,function(evt) {ret(evt,root);});
    }
  });
}

if(process.argv.length < 4) {
  console.log(usage());
  return;
}

/* Control for the process launched
 * when the watch is tripped.
 */
var running = false; // prevent firing multiple times from one event
var cmd = {
  'root' : process.argv[3],
  'args' : process.argv.slice(4)
};
var opts = {
  'cwd'  : process.cwd,
  'env'  : process.env,
  'stdio': 'inherit'
  };

walk(process.argv[2],function fire(evt,filename) {
  console.log({'evt':evt,'filename':filename})
  // reset the watch so it fires again.  See Note [1] below for more.
  watches[filename].close();
  watches[filename]=fs.watch(filename,function(evt) {fire(evt,filename);});

  if(!running) {
    // Often fires twice [2].
    var p = cp.spawn(cmd.root,cmd.args,opts);
    p.on('close',function() {
      running = false;
    });
  } else {
    console.log('Still running: Ignoring change.')
  }
});


function usage() {
  return "Usage: node watch.js <path> <command>\n\n"+
         "       Change settings in watch.js to configure."
}

/* Notes
[1]: Some editors replace the file on write so that the old
     file handle gets obliterated.  A new watch has to get
     created to continue watching a file at the same path.
[2]: It seems like every change event happens twice (on OSX).
     Not sure what I can do about it.
*/
