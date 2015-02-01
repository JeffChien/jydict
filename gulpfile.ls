#!/usr/bin/env lsc
require! {
    'gulp'            : gulp
    'gulp-util'       : gutil
    'gulp-livescript' : livescript
}

config =
    livescript_files : 'src/**/*.ls'
    js_dir           : 'lib/'


gulp.task 'livescript', ->
    gulp.src config.livescript_files
        .pipe livescript { bare: true }
        .on 'error', gutil.log
        .pipe gulp.dest config.js_dir

gulp.task 'package.json', ->
    gulp.src 'package.ls'
        .pipe livescript { json: true }
        .on 'error', gutil.log
        .pipe gulp.dest './'

gulp.task 'watch', !->
    gulp.watch config.livescript_files, ['livescript']
    gulp.watch 'package.ls', ['package.json']

gulp.task 'default', ['package.json', 'livescript', 'watch']
