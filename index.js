// Initial entry point. Decides which directory of code to load

var main, helpers;

// Start your app with SS_DEV=1 to run the CoffeeScript /src code at runtime
if (process.env['SS_DEV']) {
  main = 'src/index.coffee';
  helpers = 'src/server_helpers.coffee'
} else {
  main = 'lib/index.js';
  helpers = 'lib/server_helpers'
}

// Load ss-backbone

module.exports = require('./' + main);

module.exports.helpers = require('./' + helpers);

