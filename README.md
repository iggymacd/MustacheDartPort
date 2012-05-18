template.dart
=============

**template.dart** is a derivative of [mustache](http://mustache.github.com/).

This project is a result of a few things. I am building a web site in Dart, and required a template
library to allow me to re-use some parts of the site. There is a client side template language, but 
I decided that I could benefit not only from the library, but also from the experience of 
implementing this library. A server side templating language is better suited for my website as well.

I have been using templating technologies in Java for many years starting with Tiles, and briefly
used Velocity and Freemarker on a few projects. In the past year I have been trying to learn NodeJS, 
as well as Dart, so I have come across some other template solutions in many of the resources I
have been looking at lately. I came across Mustache, and was thinking that there are so many language
implementations of Mustache, it made sense to start one for Dart.

`Starting` is the key word here. There are features that are still not implemented, but there are enough
features implemented to get started and accomplish a fair bit.

Thanks to Seth Ladd for his blog;

[Futures] (http://blog.sethladd.com/2012/03/using-futures-in-dart-for-better-async.html)

It was a terrific help in finding my way around Futures in the Dart language.

## Request for contributions:

- Documentation
- Bug reports / fixes
- API feedback
- Optimizations
- Better name for the library

## Features:

- Data is provided by objects or Maps and are accessed via non-private fields or maps
- Futures are used where potentially expensive tasks are performed 
- Include directive is supported for importing templates from other files
- Nested blocks are supported

## Templates

A template is a string that contains
any number of blocks, includes and tags. Tags are indicated by the double braces that
surround them. `{{person}}` is a tag, and a block looks like `{{#contacts}}`. An include 
directive looks like `{{>footer}}`

There are several types of tags available in template.dart.

### Variables

The most basic tag type is a simple variable. A `{{name}}` tag renders the value
of the `name` key in the current context. If there is no such key, nothing is
rendered.

### Sections

Sections render blocks of text one or more times, depending on the value of the
key in the current context.

A section begins with a pound and ends with a slash. That is, `{{#person}}`
begins a `person` section, while `{{/person}}` ends it. The text between the two
tags is referred to as that section's "block".

The behavior of the section is determined by the value of the key.

#### Non-Empty Lists

If the `person` key exists and is not `null`, `undefined`, or `false`, and is
not an empty list the block will be rendered one or more times.

When the value is a list, the block is rendered once for each item in the list.
The context of the block is set to the current item in the list for each
iteration. In this way we can loop over collections.


Example template file:

  <html>
  {{>header}}
  <br></br>
  {{#stooges}}
  <b>Goes by the name {{name}}.</b>
    {{#addresses}}
    <b>Lives in {{city}}.</b>
    {{/addresses}}
  {{/stooges}}
  <b>{{contact}}</b>
  <br></br>
  {{#episodes}}
    <b>{{year}}</b>
  {{/episodes}}
  {{>footer}}

with included templates from separate files:

  <head>
    <title>{{title}}</title>
  </head>

and

  <b>{{copyright}}</b>

Might be populated by the following:

  Map data = new Map();
  data['header'] = {'title':'Sample Template'};
  data['footer'] = {'copyright':'&copy;'};
  data['stooges'] = [ { "name": "Moe", 'addresses':[ { "city": "Sydney" }, { "city": "Glace Bay" } ] },
                      { "name": "Larry", 'addresses':[ { "city": "Halifax" } ] },
                      { "name": "Curly", 'addresses':[ { "city": "Truro" } ] } ];
  data['episodes'] = [ { "year": "1967" },{ "year": "1955" },{ "year": "1949" } ];
  data['contact'] = 'John Doe';

And would result in:
<pre>
<html>
<head>
  <title>Sample Template</title>
</head>
<br></br>
<b>Goes by the name Moe.</b>
    <b>Lives in Sydney.</b>
    <b>Lives in Glace Bay.</b>
<b>Goes by the name Larry.</b>
    <b>Lives in Halifax.</b>
<b>Goes by the name Curly.</b>
    <b>Lives in Truro.</b>
<b>John Doe</b>
<br></br>
    <b>1967</b>
    <b>1955</b>
    <b>1949</b>
<b>&copy;</b>
</pre>
Usage, as shown in one the tests:

  TemplateFactory tf = new TemplateFactory();
  Future<Template> futureTemplate = tf.compile('views/index.template');
  futureTemplate.handleException(onException(exception){
    print('error occurred while processing!');
  });
  futureTemplate.chain((Template template) => template.render(data))
    .then((String returnedString){
      //process returned string
    });

Things to do:

- Lots of refactoring to do
- Performance testing 
- Implement other features from Mustache, as well as some other relevant template languages today
- More complete documentation
- Better and more complete examples
- Add support for [Log4Dart] (https://github.com/Qalqo/log4dart)
- Add more documentation on using [JsonObject] (https://github.com/chrisbu/dartwatch-JsonObject) 
