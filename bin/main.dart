
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


// metodo que exibe o conteudo do arquivo salvo
listData(){

dynamic fileData = readFile();

fileData = (fileData != null && fileData.length > 0 ? json.decode(fileData) : List());

print('\n\n-=-=-=-=-=   Listagem de dados -=-=-=-=-=-=-');

fileData.forEach((data){

  print('${data['date']} -->  ${data['data']}');


});


}


// metodo que salva em arquivo o que recebe da api
registerData() async{


var hgData = await getData();
dynamic fileData = readFile();

// se o arquivo estiver vazio, cria uma lista vazia
fileData = (fileData != null && fileData.length > 0 ? json.decode(fileData) : List());

bool exists = false;

//caso nao esteja vazio, armazena a data de hoje na ocorrencia recebida
fileData.forEach((data){

  if(data['date'] == now())
    exists = true;
});


// se ocorrencia nao existir no arquivo, salva

if(!exists){


  // salva o mapa com data e dados em cada objeto do json
  fileData.add({"date": now(),"data": "${hgData['data']}"});

  // salva o arquivo no diretorio corrente
  Directory dir = Directory.current;
  File file = new File(dir.path + '/meu_arquivo.txt');
  RandomAccessFile raf = file.openSync(mode: FileMode.write);

  // salva em formato json, depois fecha o arquivo
  raf.writeStringSync(json.encode(fileData).toString());
  raf.flushSync();
  raf.closeSync();


  print('\n\n-=-=-=-=-=-==  Dados salvos com sucesso -=-=-=-=-=-=-=-=-=');


}else
  print('\n\n -=-=-=-=-=-  nao adicionado, ja existe ocorrencia salva');



}


// metodo para ler o conteudo do arquivo
String readFile(){

  Directory dir = Directory.current;
  File file = new File(dir.path + '/meu_arquivo.txt');

  if(!file.existsSync()){

    print('arquivo nao encontrado');
    return null;
  }

  return file.readAsStringSync();

}





//  exibe em tela os dados recebidos da api formatando a partir do mapa
today() async {

  var data = await getData();

  print ('\n\n-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- HG Brasil Cotacao');
  print('${data['date']} -> ${data['data']}');
}



// metodo que recebe os dados da api
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


    // cria um mapa para os dados recebidos
    Map formatedMap = Map();

    formatedMap['date'] = now();

    formatedMap['data'] = '${usd['name']}: ${usd['buy']} | ${eur['name']}: ${eur['buy']} | ${gbp['name']}: ${gbp['buy']} | ${ars['name']}: ${ars['buy']} | ${btc['name']}: ${btc['buy']}';

    return formatedMap;


  }else
    throw('Falhou');

}


//metodo que retorna a data de hoje formatada
String now(){


  var now = DateTime.now();

  return '${now.day.toString().padLeft(2,'0')}/${now.month.toString().padLeft(2,'0')}/${now.year.toString().padLeft(2,'0')}';
}