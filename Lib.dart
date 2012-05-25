#library('Templates');
#import('dart:io');
#import('template.dart');
#import('block.dart');
#source('tag.dart');
#source('template_factory.dart');
#source('include.dart');
#source('template_parser.dart');
/*
* Regular expressions below are used in the library to accomplish specific tasks.
*
* BLOCK_REG_EX - identifies a block opening and closing tag. The block
* identified will be the most outer of all blocks found in the source string
* that begin with {{#<tagname>}}, and that end in {{/<tagname>}}. The expression
* is designed such that when performing matches using RegExp in Dart, the entire
* match including surrounding tags can be retrieved using m.match(0). The
* contents between the opening and closing tag can be retrieved using m.match(2).
* The tag label can be retrieved using m.match(1);
*
* VAR_REG_EX - identifies variables (that will eventually be replaced) within
* the source string that are delimited with {{ opening tags and }} closing tags.
*
* INCLUDE_REG_EX - identifies variables within the source string that are
* delimited with {{> opening tags and }} closing tags.
*/
final RegExp BLOCK_REG_EX = const RegExp('.*{{#(.+?)}}.*\\n([\\s\\S]+)(\\n.*){{\/\\1}}');
final RegExp VAR_REG_EX = const RegExp('{{([\^>].+?)}}');
final RegExp INCLUDE_REG_EX = const RegExp('{{>(.+?)}}');

/**
 * Create new Tags and set the map with matches found by caller.
 */
Map<String, Tag> setTags(Map<String, Tag> map, Collection matches){
  String _name, _sourceField;
  matches.forEach((Match m) {
    _sourceField = m.group(0);
    _name = m.group(1);
    map[_name] = new Tag(_name, _sourceField);
  });
  return map;
}

/**
 * Create new Includes and set the map with matches found by caller.
 */
Map<String, Include> setIncludes(Map<String, Include> map, Collection matches){
  String _name, _sourceField;
  matches.forEach((Match m) {
    _sourceField = m.group(0);
    _name = m.group(1);
    map[_name] = new Include(_name, _sourceField);
  });
  return map;
}

/**
 * Create new Blocks and set the map with matches found by caller.
 * Returns a List :
 * [0] = The source stripped of the Blocks that were found in matches collection.
 * [1] = The map with new Block matches found by caller.
 */
List<Object> setBlocks(Map<String, Block> map, Collection matches, String source){
  String _name, _content, _source;
  matches.forEach((Match m) {
    _source = m.group(0);
    _name = m.group(1);
    _content = m.group(2);
    map[_name] = new Block(_name, _content, _source);
    source = source.replaceAll(map[_name].sourceField, '');
  });
  return [source, map];
}