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
    fs
    path
    https
    util
    readline
    cheerio
    lame
    speaker
    docopt
    clc: 'cli-color'
}

host_url = 'tw.dictionary.yahoo.com'
refer_url = 'https://tw.dictionary.yahoo.com'
path_template = '/dictionary?p=%s'

parser = (html) ->
    out = new Array()
    $ = cheerio.load(html)
    no_result = $('p', '.msg.no-result').text()
    if no_result.length > 0
        out.push(clc.red.bold(no_result))
        return out

    do #audio
        audiolink = $('audio source[type="audio/mpeg"]').first().attr('src')
        if audiolink and audiolink.length > 0
            https.get(audiolink, (res) ->
                res.pipe(new lame.Decoder()).pipe(new speaker())
            )

    do #short meaning
        (i, elem) <-! $('div.summary').each
        word = $('h2',, elem).text()
        query = $('dl', '.pronun', elem).text().trim()
        pronun = [i.trim() for i in query.split('\n')].join(' ')
        explanation = $('p[class=explanation]',, elem).text()

        out.push(clc.red.bold(word))
        out.push(pronun)
        out.push('\t' + clc.greenBright(explanation))

        synonym_label = $('h3', '.synonym.grammar', elem).text().trim()
        if synonym_label.length > 0
            synonym = $('p', '.synonym.grammar', elem).text()
            out.push('\t' + clc.yellow(synonym_label) + ': ' + synonym)

        $('div.forms.grammar',, elem).each( (i, elem) ->
            forms_label = $('h3',,elem).text().trim()
            forms = $('p', '.forms.grammar', elem).text()
            out.push('\t' + clc.yellow(forms_label) + ': ' + forms)
        )

    do #samples
        (i, elem) <-! $('li[class=type-item]', '.explanations').each
        text = $('.type',,elem).text()
        out.push(clc.yellow(text))

        (i, elem) <-! $('.exp-item',,elem).each
        text = $('p.exp',,elem).text()
        out.push('\n\t' + clc.bgBlue(text))

        (i, elem) <-! $('p.sample',, elem).each
        query = $(elem).text().trim()
        if query.length > 0
            sample = [i.trim() for i in query.split('\n')].join(' ')
            out.push(util.format('\t%s', sample))
    return out

queryWords = !(words, notify) ->
    htmlpage = ''
    p=util.format(path_template, words.replace(/ /g, "+"))

    options = {
        host: host_url,
        path: p,
        headers: {
            'Referer': refer_url
        }
    }

    httpget = https.get(options, !(res)->
        res.setEncoding('utf8')
        do
            (chunk) <-! res .on 'data'
            htmlpage += chunk
        do
            <-! res .on 'end'
            out = parser(htmlpage)
            console.log(out.join('\n'))
            if notify != void
                notify()
    )
    do
        (e)<-! httpget .on 'error'
        console.log("get error:" + e.message)


interactiveMode = !->
    rl = readline.createInterface({
        input: process.stdin,
        output: process.stdout
    })
    prefix = 'Enter word or phrase: '
    do
        (line) <-! rl.on 'line'
        words = line.trim().replace(/ /g, '+')
        if words.length > 0
            queryWords(words, !->
                rl.prompt()
            )
        else
            rl.prompt()
    do
        <-! rl.on 'close'
        process.exit(0)

    rl.setPrompt(prefix, prefix.length)
    rl.prompt()


main = (args) ->
    if args['<words>']
        queryWords(args['<words>'], void)
    else
        interactiveMode()

if require.main === module
    main(docopt.docopt(doc))
