import 'dart:io';

import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show ByteData, rootBundle;

import 'ItemBean.dart';

class ExcelTools {
  static Future<List<ItemBean>> parseExcel(path) async {
    var data = File(path).readAsBytesSync();
    var excel = Excel.decodeBytes(data);
    var table = excel.tables[excel.tables.keys.toList()[0]];
    var result = <ItemBean>[];
    for(var row in table.rows){
      result.add(ItemBean()..sku = row[0]..path = row[1]);
    }
    return result;
  }
}
