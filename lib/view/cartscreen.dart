import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:my_tutor/view/paymentscreen.dart';
import '../constants.dart';
import '../models/cart.dart';
import '../models/user.dart';

class CartScreen extends StatefulWidget {
  final User user;

  const CartScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<Cart> cartList = <Cart>[];
  String titlecenter = "Loading...";
  late double screenHeight, screenWidth, resWidth;
  double totalpayable = 0.0;

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth <= 600) {
      resWidth = screenWidth;
    } else {
      resWidth = screenWidth * 0.75;
    }
    return Scaffold(
        appBar: AppBar(
          title: const Text('My Cart'),
        ),
        body: cartList.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(titlecenter,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              )
            : Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  children: [
                    Text(titlecenter,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    Expanded(
                        child: GridView.count(
                            crossAxisCount: 1,
                            childAspectRatio: (1 / 0.5),
                            children: List.generate(cartList.length, (index) {
                              return InkWell(
                                  child: Card(
                                      elevation: 10,
                                      child: Row(
                                        children: [
                                          Flexible(
                                              flex: 7,
                                              child: Column(children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.fromLTRB(
                                                          5.0, 8.0, 5.0, 0.0),
                                                  child: Card(
                                                    child: CachedNetworkImage(
                                                      imageUrl: CONSTANTS
                                                              .server +
                                                          "/281279/mytutor/assets/courses/" +
                                                          cartList[index]
                                                              .subid
                                                              .toString() +
                                                          '.png',
                                                      fit: BoxFit.cover,
                                                      width: resWidth,
                                                      placeholder: (context,
                                                              url) =>
                                                          const LinearProgressIndicator(),
                                                      errorWidget: (context,
                                                              url, error) =>
                                                          const Icon(
                                                              Icons.error),
                                                    ),
                                                  ),
                                                )
                                              ])),
                                          const SizedBox(height: 10),
                                          Flexible(
                                              flex: 9,
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        0.0, 13.0, 0.0, 0),
                                                child: Column(children: [
                                                  Text(
                                                    truncateString(
                                                        cartList[index]
                                                            .subname
                                                            .toString(),
                                                        30),
                                                    textAlign: TextAlign.center,
                                                    style: const TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  const SizedBox(height: 10),
                                                  const SizedBox(
                                                    width: 135,
                                                    child: Divider(
                                                      thickness: 2,
                                                      color: Colors.purple,
                                                    ),
                                                  ),
                                                  Column(children: [
                                                    Text("RM " +
                                                        double.parse(
                                                                cartList[index]
                                                                    .price
                                                                    .toString())
                                                            .toStringAsFixed(
                                                                2) +
                                                        "/unit"),
                                                    Text(
                                                      "RM " +
                                                          double.parse(cartList[
                                                                      index]
                                                                  .pricetotal
                                                                  .toString())
                                                              .toStringAsFixed(
                                                                  2),
                                                      style: const TextStyle(
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                  ]),
                                                ]),
                                              )),
                                          Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Column(children: [
                                                  IconButton(
                                                      onPressed: () {
                                                        _deleteItem(index);
                                                      },
                                                      icon: const Icon(
                                                        Icons.delete,
                                                        color: Color.fromARGB(
                                                            255, 101, 99, 99),
                                                      ))
                                                ])
                                              ]),
                                        ],
                                      )));
                            }))),
                    Card(
                      elevation: 5,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(
                              "Total Payable: RM " +
                                  totalpayable.toStringAsFixed(2),
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                            ElevatedButton(
                                onPressed: _onPaynowDialog,
                                child: const Text("Pay Now"))
                          ],
                        ),
                      ),
                    )
                  ],
                )));
  }

  String truncateString(String data, int length) {
    return (data.length >= length) ? '${data.substring(0, length)}...' : data;
  }

  void _loadCart() {
    http.post(Uri.parse(CONSTANTS.server + "/281279/mytutor/php/load_cart.php"),
        body: {
          'email': widget.user.email,
        }).timeout(
      const Duration(seconds: 5),
      onTimeout: () {
        titlecenter = "Timeout Please retry again later";
        return http.Response(
            'Error', 408); // Request Timeout response status code
      },
    ).then((response) {
      var jsondata = jsonDecode(response.body);
      if (response.statusCode == 200 && jsondata['status'] == 'success') {
        var extractdata = jsondata['data'];
        if (extractdata['cart'] != null) {
          cartList = <Cart>[];
          extractdata['cart'].forEach((v) {
            cartList.add(Cart.fromJson(v));
          });
          int qty = 0;
          totalpayable = 0.00;
          for (var element in cartList) {
            qty = qty + int.parse(element.cartqty.toString());
            totalpayable =
                totalpayable + double.parse(element.pricetotal.toString());
          }
          titlecenter = qty.toString() + " Subjects in your cart";
          setState(() {});
        }
      } else {
        titlecenter = "Your Cart is Empty.";
        cartList.clear();
        setState(() {});
      }
    });
  }

  void _onPaynowDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0))),
          title: const Text(
            "Pay Now",
            style: TextStyle(),
          ),
          content: const Text("Are you sure?", style: TextStyle()),
          actions: <Widget>[
            TextButton(
              child: const Text(
                "Yes",
                style: TextStyle(),
              ),
              onPressed: () async {
                Navigator.of(context).pop();
                await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (content) => PaymentScreen(
                            user: widget.user, totalpayable: totalpayable)));
                _loadCart();
              },
            ),
            TextButton(
              child: const Text(
                "No",
                style: TextStyle(),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteItem(int index) {
    http.post(Uri.parse(CONSTANTS.server + "/281279/mytutor/php/del_cart.php"),
        body: {
          'email': widget.user.email,
          'cartid': cartList[index].cartid
        }).timeout(
      const Duration(seconds: 5),
      onTimeout: () {
        return http.Response(
            'Error', 408); // Request Timeout response status code
      },
    ).then((response) {
      var jsondata = jsonDecode(response.body);
      if (response.statusCode == 200 && jsondata['status'] == 'success') {
        Fluttertoast.showToast(
            msg: "Success",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            fontSize: 16.0);
        _loadCart();
      } else {
        Fluttertoast.showToast(
            msg: "Failed",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            fontSize: 16.0);
      }
    });
  }

  void _updateCart(int index, String s) {
    if (s == "-") {
      if (int.parse(cartList[index].cartqty.toString()) == 1) {
        _deleteItem(index);
      }
    }
    http.post(
        Uri.parse(CONSTANTS.server + "/281279/mytutor/php/update_cart.php"),
        body: {'cartid': cartList[index].cartid, 'operation': s}).timeout(
      const Duration(seconds: 5),
      onTimeout: () {
        return http.Response(
            'Error', 408); // Request Timeout response status code
      },
    ).then((response) {
      var jsondata = jsonDecode(response.body);
      if (response.statusCode == 200 && jsondata['status'] == 'success') {
        Fluttertoast.showToast(
            msg: "Success",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            fontSize: 16.0);
        _loadCart();
      } else {
        Fluttertoast.showToast(
            msg: "Failed",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            fontSize: 16.0);
      }
    });
  }
}
