var gulp = require('gulp');
var rename = require('gulp-rename');
var awspublish = require('gulp-awspublish');
var project = process.env.PROJECT_NAME;

gulp.task('deploy', ['compress'], function() {
  var publisher = awspublish.create({
    key: process.env.AWS_KEY,
    secret: process.env.AWS_SECRET,
    bucket: process.env.S3_BUCKET
  });

  return gulp.src('./build/**/*')
    // Optionally publish to a non-root path
    .pipe(rename(function(path) {
      path.dirname = project + '/' + path.dirname;
    }))
    .pipe(publisher.publish())
    // Optionally delete files in your bucket that are not in your local folder
    .pipe(publisher.sync(project ? (project + '/') : null))
    .pipe(publisher.cache())
    .pipe(awspublish.reporter());
});
