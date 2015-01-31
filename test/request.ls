#!/usr/bin/env lsc
should = (require 'chai').should!
require! 'bluebird': promise

describe 'request', ->
    this.timeout 2000ms
    describe 'query superman', -> ``it``
        .. 'should get result contain 超人', (done) ->
            require! '../lib/request'
            words = 'superman'
            ans = '超人'
            request.queryWords words
                .then (result) !->
                    result.join('\n').should.have.string ans
                    done!
    describe 'query sentence "like father like son"', -> ``it``
        .. 'should get result contain 有其父必有其子', (done) ->
            require! '../lib/request'
            words = 'like father like son'
            ans = '有其父必有其子'
            request.queryWords words
                .then (result) !->
                    result.join('\n').should.have.string ans
                    done!
    describe 'query sentence "aasdfzxcv"', -> ``it``
        .. 'should get result contain no result', (done) ->
            require! '../lib/request'
            words = 'aasdfzxcv'
            ans = 'no result'
            request.queryWords words
                .catch (e) ->
                    e.message.should.have.string ans
                    done!
