#!/usr/bin/env lsc -cj
author:
    name: ['Chia-Yu Chien']
    email: 'jeffchien13@gmail.com'
name: 'jydict'
description: 'eng-cht dictionary'
version: '0.2.1'
preferGlobal: 'true'
main: 'lib/index.js'
bin:
    jydict: 'bin/jydict'
scripts:
    test: """
        mocha
    """
    prepublish: """
        lsc -cj package.ls &&
        lsc -bc -o lib src
    """
dependencies:
    'cheerio': '^0.18.0'
    'cli-color': '^0.3.2'
    'docopt': '^0.4.1'
    'bluebird': '^2.9.4'
devDependencies:
    'LiveScript': '^1.3.1'
    'grunt': '^0.4.5'
    'grunt-cli': '^0.1.13'
    'grunt-contrib-watch': '^0.6.1'
    'grunt-livescript': '^0.5.3'
    'mocha': '^2.1.0'
    'chai': '^1.10.0'
repository:
    type: 'git'
    url: 'https://github.com/JeffChien/jydict'
engines: {node: '*'}
