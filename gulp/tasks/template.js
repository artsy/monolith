var fs = require('fs');
var gulp = require('gulp');
var jade = require('gulp-jade');
var eco = require('gulp-eco');
var concat = require('gulp-concat');

gulp.task('template:development', function() {
  gulp.src('src/html/index.jade')
    .pipe(jade({ locals: {} }))
    .pipe(gulp.dest('build'));
});

gulp.task('templates', function () {
  gulp.src('src/assets/javascripts/**/*.eco')
    .pipe(eco())
    .pipe(concat('templates.js'))
    .pipe(gulp.dest('./build/javascripts'));
});

gulp.task('template:production', ['rev:clean'], function() {
  var manifest = JSON.parse(fs.readFileSync('build/rev-manifest.json', 'utf8'));
  gulp.src('src/html/index.jade')
    .pipe(jade({ locals: { assets: manifest } }))
    .pipe(gulp.dest('build'));
});
