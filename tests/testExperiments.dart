#import('../../ThirdParty/dartwatch-JsonObject/JsonObject.dart');

class Stooge extends JsonObject{
  Stooge(name, addresses):super(){
    this.name = name;
    this.addresses = addresses;
  }
  //List<Address> addresses;
  //String name;
}
class Address extends JsonObject{
  Address(city){
    this.city = city;
  }
  //String city;
}
class Episode extends JsonObject{
  Episode(year){
    this.year = year;
  }
  //String year;
}
class Example{
 static Map getModel(){
    List addresses;
    Map result = new Map();
    List stooges = new List();
    addresses = [new Address('Sydney'), new Address('Glace Bay')];
    print(addresses);
    stooges.add(new Stooge('Moe', addresses));
    addresses = [new Address('Halifax')];
    stooges.add(new Stooge('Larry', addresses));
    addresses = [new Address('Truro')];
    stooges.add(new Stooge('Curly', addresses));
    result['stooges'] = stooges;
    List episodes = new List();
    episodes = [new Episode('1967'), new Episode('1955'), new Episode('1949')];
    result['episodes'] = episodes;
    result['contact'] = 'John Doe';
    return result;
  }
}
void main(){
  Map myMap = Example.getModel();
  print(myMap);
}
