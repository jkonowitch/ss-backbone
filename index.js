// Initial entry point. Decides which directory of code to load

var file;

// Start your app with SS_DEV=1 to run the CoffeeScript /src code at runtime
if (process.env['SS_DEV']) {
  file = 'src/index.coffee';
} else {
  file = 'lib/index.js';
}

// Load ss-backbone
module.exports = require('./' + file);