import 'dart:io';

import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:file_chooser/file_chooser.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:testbed/parse_excel.dart';

import 'ItemBean.dart';
import 'down.dart';

class Home extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _State();
  }
}

class _State extends State<Home> {
  String excelResult = '';
  List<ItemBean> datas;
  ItemBean currentClickItem;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Center(
          child: Column(

            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                "CoderZeng出品",
                style: TextStyle(fontSize: 20),
              ),
              Text("Version:1.1", style: TextStyle(fontSize: 20))
            ],
          ),
        ),
        Row(
          children: [
            Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image:AssetImage(
                     "assets/bg.jpg",
                    ),
                    fit: BoxFit.fill
                  )

                ),
                height: 300,
                width: 600,
                child: Scrollbar(

                  child: ListView.builder(
                    itemBuilder: (context, index) {
                      return ListItem(
                        datas[index],
                        index,
                        onItemPressed: (index) {

                          setState(() {
                            currentClickItem = datas[index];
                          });
                        },
                      );
                    },
                    itemCount: datas == null ? 0 : datas.length,
                  ),
                )),
                Expanded(

                    child: Container(
                      height: 300,
                  color: Colors.grey,
                  child: currentClickItem == null?Text(""):DetailWidget(itemBean: currentClickItem)

                ))



          ],
        ),
        Text("当前表格为$excelResult", style: TextStyle(fontSize: 10)),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              width: 100,
              height: 40,
              child: Container(
                child: Center(
                  child: CupertinoButton(
                      padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                      color: Colors.blue,
                      child: Container(child: Text("读取表格")),
                      onPressed: () async {
                        var initialDirectory =
                            (await getApplicationDocumentsDirectory()).path;
                        final result = await showOpenPanel(
                            allowsMultipleSelection: true,
                            initialDirectory: initialDirectory);
                        try {
                          excelResult = result.paths[0];
                          datas = await ExcelTools.parseExcel(result.paths[0]);

                          datas = handlerData(datas);
                         var parent =  Directory(excelResult).parent;
                          for(var value in datas){
                            value.outPath = parent.path+Platform.pathSeparator+"download"+Platform.pathSeparator+value.sku;

                          }

                          setState(() {});
                        } catch (e) {
                          print(e);
                        }
                      }),
                ),
              ),
            ),
            SizedBox(
              width: 100,
              height: 40,
              child: Container(
                child: Center(
                  child: CupertinoButton(
                      padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                      color: Colors.blue,
                      child: Container(child: Text("开始下载")),
                      onPressed: () async {
//
//
//
                      try {
                        var outParent = Directory(excelResult).parent;
                        String _localPath = outParent.path +
                            Platform.pathSeparator + 'Download';
                        final savedDir = Directory(_localPath);
                        bool hasExisted = await savedDir.exists();
                        if (!hasExisted) {
                          savedDir.create(recursive: true);
                        }
                        var  download =    DownLoadCore();
                          download.datas = datas;
                          download.controller.stream.listen((event) {
                                event.progress = event.currentSize/event.size;
                          });

                          download.down();
                      }catch (e){
                      }

                      }),
                ),
              ),
            )
          ],
        )
      ],
    ));
  }
}

List<ItemBean> handlerData(List<ItemBean> datas) {
  var result = List<ItemBean> ();
  for (var value in datas) {
    var index = 1;
    try {
      if(value.path.toLowerCase().split("http").length<3 && value.path.toLowerCase().contains("http")){
        //只有一個
          result.add(ItemBean()..sku = value.sku..index = index..path=value.path);
          continue;
      };

      for (var value1 in value.path.trim().split("\n")) {
        if(value1.toLowerCase().contains("http")){
         var path = value1.substring(value1.toLowerCase().indexOf("http")).trim();
          result.add(ItemBean()..sku = value.sku..index = index..path = path);
         index++;
        }else{
          continue;
        }
      }


    }catch (e){
      print(e.toString());
    continue;
    }
    }
  return result;
}

class ListItem extends StatelessWidget {
  ItemBean itemBean;
  int index;
  Function(int index) onItemPressed;

  ListItem(this.itemBean, this.index, {this.onItemPressed});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: itemBean,
      builder: (context, child) {
        print("build");
        var item = Provider.of<ItemBean>(context);
        return GestureDetector(
            onTap: () {
              onItemPressed(index);
            },
            child: Column(
              children: <Widget>[
                Stack(
                  alignment: Alignment.centerLeft,
                  children: <Widget>[
                    Container(
                      height: 20,
                      child: Stack(alignment:Alignment.center,children:[Container(
                        height: 20,
                          child:LinearProgressIndicator(
                        backgroundColor: Color.fromRGBO(250, 250, 250, 0.3),
                        valueColor: new AlwaysStoppedAnimation<Color>(
                            Color.fromRGBO(2, 129, 252, 0.5)),
                        value: item.progress,
                      )),Text("${item.currentSize}/${item.size}",style: TextStyle(
                        color: Colors.pinkAccent
                      ),)
                    ])),
                    Text(
                      item.sku+"(${item.index})",
                      style: TextStyle(color: Colors.white),
                    )
                  ],
                ),
                Container(
                  height: 5,
                )
              ],
            ));
      },
    );
  }
}


class DetailWidget extends StatelessWidget{
  final ItemBean itemBean;

  const DetailWidget({Key key, this.itemBean}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(value: itemBean,
      builder: (context,child){
      var item = Provider.of<ItemBean>(context);
          return Column(
            children: [
              Text("状态:"+getState(item.state),style: TextStyle(
                color: Colors.black
              ),),
              Text(item.state == -1?"错误原因:${item.msg}":"",style: TextStyle(
                color:Colors.pink
              ),

              )
            ],
          );
      },

    );
  }

 String getState(int state){
    switch(state){
      case 0 :
        return "下载中";
      case 1:
        return "下载完成";
      case -1:
        return "出错";
    }
  }
}