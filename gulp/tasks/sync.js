var sync = require('browser-sync');
var gulp = require('gulp');

gulp.task('sync', ['templates', 'build:js', 'build:css', 'build:images'], function() {
  sync.init(['build/**'], {
    server: {
      baseDir: 'build'
    }
  });
});
