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
    pronunkk = $('dd', '.pronun').first().text()
    pronundj = $('dd', '.pronun').last().text()
    explanation = $('p[class=explanation]').first().text()
    out.push(clc.red.bold(word))
    out.push(util.format('KK:%s DJ%s', pronunkk, pronundj))
    out.push(clc.green(explanation))

    do
        (i, elem) <-! $('li[class=type-item]', '.explanations').each
        text = $('.exp',,elem).text()
        out.push(util.format('\t%s', text))

        (i, elem) <-! $('.exp-item',,elem).each
        text = $('.exp',,elem).text()
        out.push(util.format('\t%s', text))
        if $('.sample ',, elem).children().length > 0
            text = $('.sample ',, elem).children().map( (i, elem) ->
                   $(elem).text()
            ).join(' ')
            out.push(util.format('\t%s', text))

    labal = $('h3', '.synonym.grammar').text()

    synonym = $('a', '.synonym.grammar').map( (i, elem) ->
        $(elem).text()
    ).join(', ')
    out.push(clc.yellow(labal) + ': ' + synonym)

    $('div.forms.grammar').each( (i, elem) ->
        labal = $('h3',,elem).text()
        text = $('a', '.forms.grammar', elem).map( (i, elem) ->
            $(elem).text()
        ).join(', ')
        out.push(clc.yellow(labal) + ': ' + text)
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
