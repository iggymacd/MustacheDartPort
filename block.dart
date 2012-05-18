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
      //print('found block $blockName');
      blocks[blockName] = new Block(blockName, blockContent, blockSource);
    }
    //check for tags outside the blocks 
    String strippedSource = source;
    blocks.forEach(f(String key, Block value){
      ////print('stripping ${value.source}');
      strippedSource = strippedSource.replaceAll(value.sourceField, '');
    });
    ////print('stsourceFieldSource is $strippedSource');
    Iterable<Match> tagMatches2 = VAR_REG_EX.allMatches(strippedSource);
    String tagName2;
    for (Match m2 in tagMatches2) {
      tagName2 = m2.group(1);
      //print('process tag $tagName2');
      tags[tagName2] = new Tag(tagName2);
      tags[tagName2].sourceField = m2.group(0);
    }
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
