#!/usr/bin/env lsc
cheerio = require('cheerio')
http = require('http')
util = require('util')
clc = require('cli-color')

url_template = 'http://tw.dictionary.yahoo.com/dictionary?p=%s'

parser = (html) ->
    out = new Array()
    $ = cheerio.load(html)
    word = $('a', '.summary').first().text()
    pronunkk = $('dd', '.pronun').first().text()
    pronundj = $('dd', '.pronun').last().text()
    explanation = $('p[class=explanation]').eq(0).text()
    out.push(clc.red.bold(word))
    out.push(util.format('KK:%s DJ%s', pronunkk, pronundj))
    out.push(clc.green(explanation))

    sample = (i, elem) ->
        $(elem).text()

    expitem = (i, elem) ->
        text = $('.exp',,elem).text()
        out.push(util.format('\t%s', text))
        if $('.sample ',, elem).children().length > 0
            text = $('.sample ',, elem).children().map(sample).join(' ')
            out.push(util.format('\t%s', text))

    explanations = (i, elem) ->
        text = $(elem).children('.type').text()
        out.push(clc.yellow(text))
        $('.exp-item',,elem).each(expitem)

    $('li[class=type-item]', '.explanations').each(explanations)

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

    httpget = http.get(url, (res) ->
        res.setEncoding('utf8')

        res.on('data', (chunk) ->
            htmlpage += chunk
        )

        res.on('end', ->
            out = parser(htmlpage)
            console.log(out.join('\n'))
        )

    ).on('error', (e) ->
        console.log("get error:" + e.message)
    )


if require.main === module
    main()
