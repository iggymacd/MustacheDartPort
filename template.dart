#library('template');
#import('dart:io');//need this, even if the Lib.dart file contains an import
#import('Lib.dart');
#import('block.dart');

class Template{
  Template(this.content):
    blocks = new Map<String, Block>(),
    includes = new Map<String, Include>(),
    renderMap = new Map<String, String>(),
    tags = new Map<String, Tag>(){
      parse(content);
  }

  /**
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
        //print('process include');
        TemplateFactory tf = new TemplateFactory();
        //TODO - allow for with and without extension on file - replace /views with variable
        Future futureTemplate = tf.compile('views/$key.template');
        futuresPending.add(futureTemplate);
            futureTemplate.handleException(onException(exception){
                print('error occurred while processing include!');
              });
            futureTemplate.chain((Template template) => template.render(value))
            .transform(transformation(returnedString){
//              print(returnedString.trim());
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
      //print('result is $result');
      completer.complete(result);
    });

    return completer.future;
  }

  /**
   * Method will accept a string, and recursively identify and store
   * each child element (blocks and variables and includes)
   */
  void parse(String source){
    //print('in parse, parsing $source');
    //identify outermost blocks
    if(!BLOCK_REG_EX.hasMatch(source)){
      print('no blocks found...');
      if(!VAR_REG_EX.hasMatch(source)){
        print('no tags found');
        return;
      }
      // if we get here there are tags present
      tags = setTags(tags, VAR_REG_EX.allMatches(source));
      return;
    }
    //if we get here, there are blocks present
    List<Object> vals = setBlocks(blocks, BLOCK_REG_EX.allMatches(source), source);
    String strippedSource = vals[0];
    blocks = vals[1];

    tags = setTags(tags, VAR_REG_EX.allMatches(strippedSource));
    includes = setIncludes(includes, INCLUDE_REG_EX.allMatches(strippedSource));
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