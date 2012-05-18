class Template{
  Template(this.content):
    blocks = new Map<String, Block>(),
    includes = new Map<String, Include>(),
    renderMap = new Map<String, String>(),
    tags = new Map<String, Tag>(){
      parse(content);
  }

  /*
  * Method will accept a Map, and populate a template 
  * Each child element (blocks and variables) will be processed as well
  * as any <included> directives
  * In case processing takes some significant time, we leverage a Future
  */
  Future<String> render(Map data){
    var completer = new Completer();
    String result = content;
    List futuresPending = new List();
    try{
     data.forEach((String key, Dynamic value){
      if(value is List){
        //print('found a list in template');
        String blockRenderResult = blocks[key].render(value);
        //print('blockRenderResult $key is $blockRenderResult');
        result = result.replaceAll(blocks[key].sourceField, blockRenderResult);
      }else if(includes.containsKey(key)){
        //process include recursively
        print('process include');
        TemplateFactory tf = new TemplateFactory();
        //TODO - allow for with and without extension on file - replace /views with variable
        Future futureTemplate = tf.compile('views/$key.template');
        futuresPending.add(futureTemplate);
            futureTemplate.handleException(onException(exception){
                print('error occurred while processing include!');
              });
            futureTemplate.chain((Template template) => template.render(value))
            .transform(transformation(returnedString){
              print('here..................');
              print(returnedString.trim());
              print('here..................');
              result = result.replaceAll('{{>${includes[key].filename}}}', returnedString.trim());
            });
      }else{
        result = result.replaceAll('{{${tags[key].name}}}', value);
      }
     });
    }catch(Exception e){
      completer.completeException(e);
    }
    Futures.wait(futuresPending).then(onComplete(List futureResults){
      print('result is $result');
      completer.complete(result);
    });
    
    return completer.future;
  }
  
  /*
  * Method will accept a string, and recursively identify and store 
  * each child element (blocks and variables and includes)
  */
  void parse(String source){
    print('in parse, parsing $source');
    //identify outermost blocks
    if(!BLOCK_REG_EX.hasMatch(source)){
      print('no blocks found...');
      if(!VAR_REG_EX.hasMatch(source)){
        print('no tags found');
        return;
      }
      // if we get here there are tags present
      Iterable<Match> tagMatches = VAR_REG_EX.allMatches(source);
      String tagName;
      for (Match m in tagMatches) {
        tagName = m.group(1);
        //print('process tag $tagName');
        tags[tagName] = new Tag(tagName);
        tags[tagName].sourceField = m.group(0);
      }
      return;
      
    }
    //if we get here, there are blocks present
    Iterable<Match> blockMatches = BLOCK_REG_EX.allMatches(source);
    String blockName;
    String blockContent;
    String blockSource;
    for (Match m in blockMatches) {
      blockName = m.group(1);
      blockContent = m.group(2);
      blockSource = m.group(0);
      print('found block $blockName');
      blocks[blockName] = new Block(blockName, blockContent, blockSource);
    }
    //check for tags outside the blocks 
    String strippedSource = source;
    blocks.forEach(f(String key, Block value){
      ////print('stripping ${value.source}');
      strippedSource = strippedSource.replaceAll(value.sourceField, '');
    });
    ////print('strippedSource is $strippedSource');
    Iterable<Match> tagMatches2 = VAR_REG_EX.allMatches(strippedSource);
    String tagName2;
    for (Match m2 in tagMatches2) {
      tagName2 = m2.group(1);
      print('found tag $tagName2');
      tags[tagName2] = new Tag(tagName2);
      tags[tagName2].sourceField = m2.group(0);
    }

    Iterable<Match> includeMatches = INCLUDE_REG_EX.allMatches(strippedSource);
    String includeName;
    for (Match m3 in includeMatches) {
      includeName = m3.group(1);
      print('found include $includeName');
      includes[includeName] = new Include(includeName);
      includes[includeName].sourceField = m3.group(0);
    }

  }

  //instance variables
  String name;
  File fileName;
  Directory fileDirectory;
  Map<String, Block> blocks;
  Map<String, Tag> tags;
  Map<String, Include> includes;
  Map<String, String> renderMap;
  String content;
}