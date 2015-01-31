#!/usr/bin/env lsc
require! util

export function NoResultError (message)
    this.name = 'NoResultError'
    this.message = (message || '')

util.inherits(NoResultError, Error)

export function cli
    require \./cli .main!
