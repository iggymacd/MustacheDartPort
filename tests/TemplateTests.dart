#import('../Lib.dart');
#import('dart:io');//need this, even if the Lib.dart file contains an import

void main(){
  testTemplateFromFile();
}


void testTemplateFromFile(){
  //Map data = Example.getModel();
  Map data = new Map();
  data['header'] = {'title':'Sample Template'};
  data['footer'] = {'copyright':'&copy;'};
  data['stooges'] = [ { "name": "Moe", 'addresses':[ { "city": "Sydney" }, { "city": "Glace Bay" } ] },
                      { "name": "Larry", 'addresses':[ { "city": "Halifax" } ] },
                      { "name": "Curly", 'addresses':[ { "city": "Truro" } ] } ];
  data['episodes'] = [ { "year": "1967" },{ "year": "1955" },{ "year": "1949" } ];
  data['contact'] = 'John Doe';
  TemplateFactory tf = new TemplateFactory();
  Future<Template> futureTemplate = tf.compile('views/index.template');
  futureTemplate.handleException(onException(exception){
    print('error occurred while processing!');
  });
  futureTemplate.chain((Template template) => template.render(data))
    .then((String returnedString){
      checkResult(returnedString);
    });
}

void checkResult(String result){
  String expected = '''<html>
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
''';
  Expect.equals(expected, result);
}

