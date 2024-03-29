import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:app_gifss/view/gif_page.dart';
import 'package:share/share.dart';
import 'package:transparent_image/transparent_image.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _criterioBusca;
  int _paginacao = 0;

  dynamic _buscarGifs() async {
    http.Response response;

    if (_criterioBusca == null || _criterioBusca == '')
      response = await http.get(
          'https://api.giphy.com/v1/gifs/trending?api_key=EP1brARtmocVpTgQTBXpfYKc2IuCrCEI&limit=20&rating=G');
    else
      response = await http.get(
          'https://api.giphy.com/v1/gifs/search?api_key=EP1brARtmocVpTgQTBXpfYKc2IuCrCEI&q=$_criterioBusca&limit=19&offset=$_paginacao&rating=G&lang=pt');

    return json.decode(response.body);
  }

  int _getQuantidade(List dados) {
    if (_criterioBusca == null || _criterioBusca == '')
      return dados.length;
    else
      return dados.length + 1;
  }

  Widget _exibeListaGifs(BuildContext context, AsyncSnapshot sanpshot) {
    return GridView.builder(
      padding: EdgeInsets.all(10),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10),
      itemCount: _getQuantidade(sanpshot.data['data']),
      itemBuilder: (context, index) {
        if ((_criterioBusca == null || _criterioBusca == '') ||
            index < sanpshot.data['data'].length)
          return GestureDetector(
            /*child: Image.network(
              sanpshot.data['data'][index]['images']['fixed_height']['url'],
              height: 300,
              fit: BoxFit.cover,
            ),*/
            child: FadeInImage.memoryNetwork(
              key: Key(DateTime.now().millisecondsSinceEpoch.toString()),
              placeholder: kTransparentImage,
              image: sanpshot.data['data'][index]['images']['fixed_height']
                  ['url'],
              height: 300,
              fit: BoxFit.cover,
            ),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          new GifPage(sanpshot.data['data'][index])));
            },
            onLongPress: () {
              Share.share(sanpshot.data['data'][index]['images']['fixed_height']
                  ['url']);
            },
          );
        else
          return Container(
            child: GestureDetector(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 70,
                  ),
                  Text(
                    'Carregar mais...',
                    style: TextStyle(color: Colors.white, fontSize: 22),
                  )
                ],
              ),
              onTap: () {
                setState(() {
                  _paginacao += 19;
                });
              },
            ),
          );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Image.network(
            'https://developers.giphy.com/branch/master/static/header-logo-8974b8ae658f704a5b48a2d039b8ad93.gif'),
        centerTitle: true,
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(10),
            child: TextField(
              decoration: InputDecoration(
                  labelText: 'Digite seu critério de busca...',
                  labelStyle: TextStyle(color: Colors.white),
                  border: OutlineInputBorder()),
              style: TextStyle(color: Colors.white, fontSize: 18),
              textAlign: TextAlign.center,
              onSubmitted: (texto) {
                setState(() {
                  _criterioBusca = texto;
                  _paginacao = 0;
                });
              },
            ),
          ),
          Expanded(
            child: FutureBuilder(
              future: _buscarGifs(),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                  case ConnectionState.none:
                    return Container(
                      width: 200,
                      height: 200,
                      alignment: Alignment.center,
                      child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                          strokeWidth: 5),
                    );
                  default:
                    if (snapshot.hasError)
                      return Container();
                    else
                      return _exibeListaGifs(context, snapshot);
                }
              },
            ),
          )
        ],
      ),
    );
  }
}
