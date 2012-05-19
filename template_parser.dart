class TemplateParser {
  TemplateParser(this.templateFactory);
  
  void compile(String filePath, Function callback, Function error) {
    File file = new File(filePath);
    InputStream inStream = file.openInputStream();
    StringInputStream reader = new StringInputStream(inStream);
    if (!file.existsSync()) {
      error(new Exception('Failed to find: $file'));
    }
    Template result;
    StringBuffer sb = new StringBuffer();
    reader.onLine = (){
      sb.add('${reader.readLine()}\n');
    };
    reader.onClosed = (){
      //print('in onClosed');
      inStream.close();
      result = new Template(sb.toString());
      //print(result);
      callback( result );
    };
    reader.onError = (e){
      error(e);
    };
  }  
  TemplateFactory templateFactory;
}
