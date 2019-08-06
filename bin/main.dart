
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;


main(){

menu();


}


void menu(){

  print('-=-=-=-=-=-=   inicio -=-=-=-=-=-=-=-=-');
  print('\nSelecione uma opcao:');
  print('1 - ver cotacao de hoje');
  print('2 - Registrar cotacao de hoje');
  print('3 - Ver cotacoes registradas');

  String option = stdin.readLineSync();

  switch(int.parse(option)){

    case 1: today(); break;
    case 2: registerData();break;
    case 3: listData(); break;
    default:print('\n\n Opcao invalida'); menu(); break;

  }
}


listData(){

dynamic fileData = readFile();

fileData = (fileData != null && fileData.length > 0 ? json.decode(fileData) : List());


print('\n\n-=-=-=-=-=   Listagem de dados -=-=-=-=-=-=-');

fileData.forEach((data){

  print('${data['date']} -->  ${data['data']}');


});


}

registerData() async{


var hgData = await getData();
dynamic fileData = readFile();

fileData = (fileData != null && fileData.length > 0 ? json.decode(fileData) : List());

bool exists = false;

fileData.forEach((data){

  if(data['date'] == now())
    exists = true;
});


if(!exists){

  fileData.add({"date": now(),"data": "${hgData['data']}"});
  Directory dir = Directory.current;
  File file = new File(dir.path + '/meu_arquivo.txt');
  RandomAccessFile raf = file.openSync(mode: FileMode.write);

  raf.writeStringSync(json.encode(fileData).toString());
  raf.flushSync();
  raf.closeSync();


  print('\n\n-=-=-=-=-=-==  Dados salvos com sucesso -=-=-=-=-=-=-=-=-=');


}else
  print('\n\n -=-=-=-=-=-  nao adicionado, ja existe ocorrencia salva');



}

String readFile(){

  Directory dir = Directory.current;
  File file = new File(dir.path + '/meu_arquivo.txt');



  if(!file.existsSync()){

    print('arquivo nao encontrado');
    return null;
  }

  return file.readAsStringSync();

}






today() async {


  var data = await getData();

  print ('\n\n-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- HG Brasil Cotacao');
  print('${data['date']} -> ${data['data']}');
}


Future getData() async {

  String url='http://api.hgbrasil.com/finance?key=41a3d889';
  http.Response response = await http.get(url);


  if(response.statusCode == 200){

    var data = json.decode(response.body)['results']['currencies'];
    var usd = data['USD'];
    var eur = data['EUR'];
    var gbp = data['GBP'];
    var ars = data['ARS'];
    var btc = data['BTC'];

    Map formatedMap = Map();

    formatedMap['date'] = now();

    formatedMap['data'] = '${usd['name']}: ${usd['buy']} | ${eur['name']}: ${eur['buy']} | ${gbp['name']}: ${gbp['buy']} | ${ars['name']}: ${ars['buy']} | ${btc['name']}: ${btc['buy']}';

    return formatedMap;


  }else
    throw('Falhou');

}

String now(){


  var now = DateTime.now();

  return '${now.day.toString().padLeft(2,'0')}/${now.month.toString().padLeft(2,'0')}/${now.year.toString().padLeft(2,'0')}';
}