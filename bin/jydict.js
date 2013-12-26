#!/usr/bin/env node
// Generated by LiveScript 1.2.0
(function(){
  var doc, fs, path, http, util, readline, cheerio, lame, speaker, docopt, clc, host_url, refer_url, path_template, parser, queryWords, interactiveMode, main;
  doc = 'Usage: jydict [-h | --help] [<words>]\n\nquery vocabulary or phrase from yahoo dictionary,\nenter interactive mode with no arguments.\n\nPositional arguments:\n  words       words for query\n\nOptional arguments:\n  -h, --help  Show this help message and exit.';
  fs = require('fs');
  path = require('path');
  http = require('http');
  util = require('util');
  readline = require('readline');
  cheerio = require('cheerio');
  lame = require('lame');
  speaker = require('speaker');
  docopt = require('docopt');
  clc = require('cli-color');
  host_url = 'tw.dictionary.yahoo.com';
  refer_url = 'http://tw.dictionary.yahoo.com';
  path_template = '/dictionary?p=%s';
  parser = function(html){
    var out, $, no_result, audiolink;
    out = new Array();
    $ = cheerio.load(html);
    no_result = $('p', '.msg.no-result').text();
    if (no_result.length > 0) {
      out.push(clc.red.bold(no_result));
      return out;
    }
    audiolink = $('div cite.audio').first().attr('sound');
    if (audiolink && audiolink.length > 0) {
      http.get(audiolink, function(res){
        return res.pipe(new lame.Decoder()).pipe(new speaker());
      });
    }
    $('div.summary').each(function(i, elem){
      var word, query, pronun, explanation, synonym_label, synonym;
      word = $('h2', void 8, elem).text();
      query = $('dl', '.pronun', elem).text().trim();
      pronun = (function(){
        var i$, ref$, len$, results$ = [];
        for (i$ = 0, len$ = (ref$ = query.split('\n')).length; i$ < len$; ++i$) {
          i = ref$[i$];
          results$.push(i.trim());
        }
        return results$;
      }()).join(' ');
      explanation = $('p[class=explanation]', void 8, elem).text();
      out.push(clc.red.bold(word));
      out.push(pronun);
      out.push('\t' + clc.greenBright(explanation));
      synonym_label = $('h3', '.synonym.grammar', elem).text().trim();
      if (synonym_label.length > 0) {
        synonym = $('p', '.synonym.grammar', elem).text();
        out.push('\t' + clc.yellow(synonym_label) + ': ' + synonym);
      }
      $('div.forms.grammar', void 8, elem).each(function(i, elem){
        var forms_label, forms;
        forms_label = $('h3', void 8, elem).text().trim();
        forms = $('p', '.forms.grammar', elem).text();
        return out.push('\t' + clc.yellow(forms_label) + ': ' + forms);
      });
    });
    $('li[class=type-item]', '.explanations').each(function(i, elem){
      var text;
      text = $('.type', void 8, elem).text();
      out.push(clc.yellow(text));
      $('.exp-item', void 8, elem).each(function(i, elem){
        var text;
        text = $('p.exp', void 8, elem).text();
        out.push('\n\t' + clc.bgBlue(text));
        $('p.sample', void 8, elem).each(function(i, elem){
          var query, sample;
          query = $(elem).text().trim();
          if (query.length > 0) {
            sample = (function(){
              var i$, ref$, len$, results$ = [];
              for (i$ = 0, len$ = (ref$ = query.split('\n')).length; i$ < len$; ++i$) {
                i = ref$[i$];
                results$.push(i.trim());
              }
              return results$;
            }()).join(' ');
            out.push(util.format('\t%s', sample));
          }
        });
      });
    });
    return out;
  };
  queryWords = function(words, notify){
    var htmlpage, p, options, httpget;
    htmlpage = '';
    p = util.format(path_template, words.replace(/ /g, "+"));
    options = {
      host: host_url,
      path: p,
      headers: {
        'Referer': refer_url
      }
    };
    httpget = http.get(options, function(res){
      res.setEncoding('utf8');
      res.on('data', function(chunk){
        htmlpage += chunk;
      });
      res.on('end', function(){
        var out;
        out = parser(htmlpage);
        console.log(out.join('\n'));
        if (notify !== void 8) {
          notify();
        }
      });
    });
    httpget.on('error', function(e){
      console.log("get error:" + e.message);
    });
  };
  interactiveMode = function(){
    var rl, prefix;
    rl = readline.createInterface({
      input: process.stdin,
      output: process.stdout
    });
    prefix = 'Enter word or phrase: ';
    rl.on('line', function(line){
      var words;
      words = line.trim().replace(/ /g, '+');
      if (words.length > 0) {
        queryWords(words, function(){
          rl.prompt();
        });
      } else {
        rl.prompt();
      }
    });
    rl.on('close', function(){
      process.exit(0);
    });
    rl.setPrompt(prefix, prefix.length);
    rl.prompt();
  };
  main = function(args){
    if (args['<words>']) {
      return queryWords(args['<words>'], void 8);
    } else {
      return interactiveMode();
    }
  };
  if (deepEq$(require.main, module, '===')) {
    main(docopt.docopt(doc));
  }
  function deepEq$(x, y, type){
    var toString = {}.toString, hasOwnProperty = {}.hasOwnProperty,
        has = function (obj, key) { return hasOwnProperty.call(obj, key); };
    var first = true;
    return eq(x, y, []);
    function eq(a, b, stack) {
      var className, length, size, result, alength, blength, r, key, ref, sizeB;
      if (a == null || b == null) { return a === b; }
      if (a.__placeholder__ || b.__placeholder__) { return true; }
      if (a === b) { return a !== 0 || 1 / a == 1 / b; }
      className = toString.call(a);
      if (toString.call(b) != className) { return false; }
      switch (className) {
        case '[object String]': return a == String(b);
        case '[object Number]':
          return a != +a ? b != +b : (a == 0 ? 1 / a == 1 / b : a == +b);
        case '[object Date]':
        case '[object Boolean]':
          return +a == +b;
        case '[object RegExp]':
          return a.source == b.source &&
                 a.global == b.global &&
                 a.multiline == b.multiline &&
                 a.ignoreCase == b.ignoreCase;
      }
      if (typeof a != 'object' || typeof b != 'object') { return false; }
      length = stack.length;
      while (length--) { if (stack[length] == a) { return true; } }
      stack.push(a);
      size = 0;
      result = true;
      if (className == '[object Array]') {
        alength = a.length;
        blength = b.length;
        if (first) {
          switch (type) {
          case '===': result = alength === blength; break;
          case '<==': result = alength <= blength; break;
          case '<<=': result = alength < blength; break;
          }
          size = alength;
          first = false;
        } else {
          result = alength === blength;
          size = alength;
        }
        if (result) {
          while (size--) {
            if (!(result = size in a == size in b && eq(a[size], b[size], stack))){ break; }
          }
        }
      } else {
        if ('constructor' in a != 'constructor' in b || a.constructor != b.constructor) {
          return false;
        }
        for (key in a) {
          if (has(a, key)) {
            size++;
            if (!(result = has(b, key) && eq(a[key], b[key], stack))) { break; }
          }
        }
        if (result) {
          sizeB = 0;
          for (key in b) {
            if (has(b, key)) { ++sizeB; }
          }
          if (first) {
            if (type === '<<=') {
              result = size < sizeB;
            } else if (type === '<==') {
              result = size <= sizeB
            } else {
              result = size === sizeB;
            }
          } else {
            first = false;
            result = size === sizeB;
          }
        }
      }
      stack.pop();
      return result;
    }
  }
}).call(this);