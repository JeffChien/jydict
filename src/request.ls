#!/usr/bin/env lsc
require! {
    util
    cheerio
    https
    'cli-color': clc
    'bluebird': promise
    '../': jydict
}

NoResultError = jydict.NoResultError

host_url = 'tw.dictionary.yahoo.com'
refer_url = 'https://tw.dictionary.yahoo.com'
path_template = '/dictionary?p=%s'

parse = (html) ->
    out = new Array!
    $ = cheerio.load(html)
    no_result = $('p', '.msg').text()
    if no_result
        return promise.reject(new NoResultError('no result'))

    do #short meaning
        (i, elem) <-! $('div.summary').each
        word = $('h2',, elem).text!
        query = $('dl', '.pronun', elem).text!.trim!
        pronun = [i.trim! for i in query.split('\n')].join(' ')
        explanation = $('p[class=explanation]',, elem).text!

        out.push(clc.red.bold(word))
        out.push(pronun)
        out.push('\t' + clc.greenBright(explanation))

        synonym_label = $('h3', '.synonym.grammar', elem).text!.trim!
        if synonym_label.length > 0
            synonym = $('p', '.synonym.grammar', elem).text!
            out.push('\t' + clc.yellow(synonym_label) + ': ' + synonym)

        $('div.forms.grammar',, elem).each( (i, elem) ->
            forms_label = $('h3',,elem).text!.trim!
            forms = $('p', '.forms.grammar', elem).text!
            out.push('\t' + clc.yellow(forms_label) + ': ' + forms)
        )

    do #samples
        (i, elem) <-! $('li[class=type-item]', '.explanations').each
        text = $('.type',,elem).text!
        out.push(clc.yellow(text))

        (i, elem) <-! $('.exp-item',,elem).each
        text = $('p.exp',,elem).text!
        out.push('\n\t' + clc.bgBlue(text))

        (i, elem) <-! $('p.sample',, elem).each
        query = $(elem).text!.trim!
        if query
            sample = [i.trim! for i in query.split '\n'].join ' '
            out.push util.format '\t%s', sample
    return promise.resolve(out)

getRequest = promise.method (option) ->
    return new promise (resolve, reject) !->
        html = ''
        req = https.get option, (res) !->
            res.on 'data', (chunk) !-> html += chunk
            res.on 'end', !-> resolve(html)
            res.on 'error', (e) !-> reject(e)
        req.end!

export function queryWords (words)
    options = do
        host: host_url
        path: util.format path_template, words.replace(/ /g, '+')
        headers: do
            Referer: refer_url
    return getRequest(options).then parse
