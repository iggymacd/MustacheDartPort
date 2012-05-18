class TemplateFactory {
  TemplateFactory(){
    dp = new TemplateParser(this);
  }
  
  Future<Template> compile(String name) {
    //TODO implement some kind of cache
    //Template Template = dp.compile(name);
    //TemplateCache.put(name, Template);
    var completer = new Completer();
    dp.compile(name, (Template results){
      completer.complete(results);
    }, (error) {
      completer.completeException(error);
    });
    return completer.future;
  }
  TemplateParser dp;
  
}
