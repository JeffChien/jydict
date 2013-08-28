#!/usr/bin/env node

module.exports = function(grunt) {
    grunt.initConfig({
        pkg: grunt.file.readJSON('package.json'),
        livescript: {
            src: {
                files: {
                    '<%= pkg.name %>.js': '<%= pkg.name %>.ls'
                }
            }
        },
    });
    grunt.loadNpmTasks('grunt-livescript');
    grunt.registerTask('default', ['livescript']);
}
