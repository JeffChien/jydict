#!/usr/bin/env lsc
doc = '''
Usage: jydict [-h | --help] [<words>]

query vocabulary or phrase from yahoo dictionary,
enter interactive mode with no arguments.

Positional arguments:
  words       words for query

Optional arguments:
  -h, --help  Show this help message and exit.
'''

require! {
    https
    readline
    docopt
    'cli-color': clc
    './request'
    '../': jydict
}

NoResultError = jydict.NoResultError

interactiveMode = !->
    rl = readline.createInterface do
        input: process.stdin,
        output: process.stdout

    prefix = 'Enter word or phrase: '
    rl.setPrompt(prefix, prefix.length)
    rl.prompt!
    rl.on 'line' (line) ->
        words = line.trim!.replace(/ /g, '+')
        if words.length > 0
            request.queryWords words
                .then (result) !->
                    console.log result.join('\n')
                    rl.prompt!
                .catch NoResultError, (e) !->
                    console.log clc.red.bold e.message
                .catch (e) !->
                    console.error 'get error:' + e.message
        else
            rl.prompt!
    rl.on 'close' !->
        process.exit(0)

export function main (argv = docopt.docopt doc)
    if argv['<words>']
        request.queryWords argv['<words>']
            .then (result) !->
                console.log result.join('\n')
            .catch NoResultError, (e) !->
                console.log clc.red.bold e.message
            .catch (e) !->
                console.error 'get error:' + e.message
    else
        interactiveMode!
