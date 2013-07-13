#!/usr/bin/env lsc
require! {
    cheerio
    http
    util
    clc: 'cli-color'
}


url_template = 'http://tw.dictionary.yahoo.com/dictionary?p=%s'

parser = (html) ->
    out = new Array()
    $ = cheerio.load(html)
    no_result = $('p', '.msg.no-result').text()
    if no_result.length > 0
        out.push(clc.red.bold(no_result))
        return out

    word = $('a', '.summary').first().text()
    query = $('dl', '.pronun').first().text().trim()
    pronun = [i.trim() for i in query.split('\n')].join(' ')

    explanation = $('p[class=explanation]').first().text()
    out.push(clc.red.bold(word))
    out.push(pronun)
    out.push(clc.greenBright(explanation))

    do
        (i, elem) <-! $('li[class=type-item]', '.explanations').each
        text = $('.type',,elem).text()
        out.push(clc.yellow(text))

        (i, elem) <-! $('.exp-item',,elem).each
        text = $('p.exp',,elem).text()
        out.push(clc.bgBlue('\n\t' + text))

        (i, elem) <-! $('p.sample',, elem).each
        query = $(elem).text().trim()
        if query.length > 0
            sample = [i.trim() for i in query.split('\n')].join(' ')
            out.push(util.format('\t%s', sample))

    synonym_label = $('h3', '.synonym.grammar').text().trim()
    if synonym_label.length > 0
        synonym = $('p', '.synonym.grammar').text()
        out.push(clc.yellow(synonym_label) + ': ' + synonym)

    $('div.forms.grammar').each( (i, elem) ->
        forms_label = $('h3',,elem).text().trim()
        forms = $('p', '.forms.grammar', elem).text()
        out.push(clc.yellow(forms_label) + ': ' + forms)
    )
    return out


main = ->
    htmlpage = ''
    if process.argv.length == 2
        return

    word = process.argv[2]
    url = util.format(url_template, word)

    httpget = http.get(url, !(res)->
        res.setEncoding('utf8')
        do
            (chunk) <-! res .on 'data'
            htmlpage += chunk
        do
            <-! res .on 'end'
            out = parser(htmlpage)
            console.log(out.join('\n'))
    )
    do
        (e)<-! httpget .on 'error'
        console.log("get error:" + e.message)


if require.main === module
    main()
