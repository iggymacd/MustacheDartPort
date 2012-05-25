#library('block');
#import('dart:io');//need this, even if the Lib.dart file contains an import
#import('Lib.dart');

class Block {
  Block(this.name, this.content, this.sourceField):
    blocks = new Map<String, Block>(),
    tags = new Map<String, Tag>(){
    parse(content);
  }

  /*
  * Method will accept a List of Maps, and populate a template.
  * Each child element (blocks and variables) will be processed.
  * returns a String representing the rendered block
  */
  String render(List<Map> data){
    String result = '';//content;
    //print('block $name render data is $data. Content is $content');
    String iterationContent;
    int count = 0;
    data.forEach((Map currentMap){
      iterationContent = content;
      currentMap.forEach((String key, Dynamic value){
        //iterationContent = result;
        if(value is List){
          //print('found a list');
          String blockRenderResult = blocks[key].render(value);
          //print('replace\n ${blocks[key].sourceField} \nwith\n ${blockRenderResult}');
          iterationContent = iterationContent.replaceAll(blocks[key].sourceField, blockRenderResult);
        }else{
          //print('\nreplace\n{{${tags[key].name}}}\nwith\n$value\nin\n$iterationContent');
          iterationContent = iterationContent.replaceAll('{{${tags[key].name}}}', value);
        }
      });if(count == 0){
        result += '$iterationContent';
      }else{
        result += '\n$iterationContent';
      }
      count++;
    });
    return result;
  }

  /*
  * method will accept a string, and recursively identify and store
  * each child element (blocks and variables)
  */
  void parse(String source){
    //identify outermost blocks
    if(!BLOCK_REG_EX.hasMatch(source)){
      //print('no blocks found...');
      if(!VAR_REG_EX.hasMatch(source)){
        //print('no tag found');
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
  }

  String name;
  File fileName;
  Directory fileDirectory;
  Map<String, Block> blocks;
  Map<String, Tag> tags;
  Map<String, Dynamic> blockMap;
  String content;
  String sourceField;
}
