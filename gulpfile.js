'use strict'

var gulp      	= require('gulp')
  , purescript 	= require('gulp-purescript')
	, rimraf 			= require('rimraf')
  , connect     = require('gulp-connect')
  ;

var jsFileName = 'examples.js';

var paths = {
	purescripts: 'src/**/*.purs',
	javascripts: 'src/' + jsFileName,
  resources: ['resources/**/*'],
	bowerSrc: 'bower_components/purescript-*/src/**/*.purs',
  ffi: 'bower_components/purescript-*/src/**/*.js',
};

gulp.task('compile', function(cb) {
	var psc = purescript.psc({
		// Compiler options
    src: [paths.purescripts, paths.bowerSrc],
    ffi: paths.ffi,
		output: "output",
    module: "Blocks"
	});
  return psc;
});

gulp.task('bundle', ['compile'], function() {
  return purescript.pscBundle({
    src: 'output/**/*.js',
    output: 'app/examples.js',
    module: [
      'Blocks.RainbowCircle',
      'Blocks.ArcCorners4',
      'Blocks.CounterclockwiseArc',
      'Blocks.PieChart',
      'Blocks.DonutMultiples'
]
  });
});

gulp.task('copy-d3', function() {
  return gulp.src('bower_components/d3/*.js').pipe(gulp.dest('app'));
});

gulp.task('clean-resources', function (cb) {
  rimraf('app/**/*.html', cb);
});

gulp.task('copy-resources', ['clean-resources'], function () {
  return gulp.src('resources/**/*').pipe(gulp.dest('app'));
});

var connectTask = gulp.task('connect', ['copy-d3', 'copy-resources', 'bundle'], function() {
  connect.server({
    root: 'app',
    port: 8083,
    livereload: true
  });
});

gulp.task('reload', ['bundle', 'copy-resources'], function () {
  gulp.src(paths.resources).pipe(connect.reload());
});

gulp.task('watch', function(cb) {
  var allSrcs = paths.purescripts
    .concat(paths.bowerSrc)
    .concat(paths.javascripts)
    .concat(paths.resources)
    ;
  doConnect();
  gulp.watch(allSrcs, function() {
    if (connected)
      gulp.start('reload');
    else
      doConnect();
  });

  var connected = false;
  function doConnect() {
    gulp.start('connect').on('task_stop', function(event) {
      if (event.task === 'connect')
        connected = true;
    });
  }
});

gulp.task('default', ['watch']);
