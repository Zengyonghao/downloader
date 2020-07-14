import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';

import 'ItemBean.dart';

class DownLoadCore {
  List<ItemBean> _datas;

  StreamController<ItemBean> controller = StreamController();
  List<Future<ItemBean>> downQueue = List();

  int downNumber;
  List<ItemBean> get datas => _datas;

  int currentDownNumber;
  set datas(List<ItemBean> value) {
    _datas = value;
  }

  down() async {

    //分割list
    int getSize(){
      return downQueue.length;
    }
    for (var value in _datas)  {
      print("添加了一个");
      Future<ItemBean> future = downFile(value);
      downQueue.add(future);
      future.then((value) {
      }).whenComplete(() {
        downQueue.remove(future);
        print("删除了一个:${downQueue.length}");

      });
        while(downQueue.length>=15){
          print("等待"+downQueue.length.toString());
          await Future.delayed(Duration(seconds: 5));
        }
    }


  }

  Future<ItemBean> downFile(ItemBean model) async {
    try {
      print("开始下载"+model.path);
      var response = await Dio().download(model.path,(Headers responseHeaders){

        var outName = model.outPath+Platform.pathSeparator+model.sku+"-"+model.index.toString();
        print("outname"+outName);

        if(responseHeaders.map["content-type"].contains("image")){
          outName =   outName+".jpg";
        }else{
          outName =  outName+".jpg";
        }
        return outName;
      },
          onReceiveProgress: (count, total) {
        model.size = total;
        model.currentSize = count;
        controller.add(model);
      });
      model.state = 2;
      return model;
    } catch (e) {
      print("出错了"+e.toString());
      model.state = -1;
      model.msg = e.toString();
      return model;
    }

    Dio().download(model.realUrl, model.outName,
        onReceiveProgress: (count, total) {
      model.size = total;
      model.currentSize = count;
      controller.add(model);
    }).then((value) {
      model.state = 2;
      controller.add(model);
    });
  }
}

Future<ItemBean> getName(ItemBean itemBean) async {
  var headers = {
    'User-Agent':
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/60.0.3112.90 Safari/537.36',
    'Accept':
        'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8',
  };
  Options options = Options();
  options.headers = headers;
  //获取头部
  var name = "";
  try {
    var headerResponse = await Dio().request(itemBean.path, options: options);
    itemBean.realUrl = headerResponse.realUri.path;
    return itemBean;
  } catch (e) {
    if (e is DioError) {
      if (e.response.statusCode == 302 || e.response.statusCode == 303) {
        itemBean.realUrl = e.response.realUri.path;
        return itemBean;
      }
    }
  }
}
