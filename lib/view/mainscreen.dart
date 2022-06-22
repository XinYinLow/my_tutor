import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:my_tutor/models/Subject.dart';
import 'package:my_tutor/models/user.dart';
import '../constants.dart';
import 'package:cached_network_image/cached_network_image.dart';

class MainScreen extends StatefulWidget {
  final User user;

  const MainScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  List<Subjects> subList = <Subjects>[];
  String titlecenter = "Loading...";
  late double screenHeight, screenWidth, resWidth;
  var numofpage, curpage = 1;
  var color;
  TextEditingController searchController = TextEditingController();
  String search = "";
  Icon pressIcon = const Icon(Icons.search);
  Widget titleS = const Text("Subject");
  bool _searching = false;

  @override
  void initState() {
    super.initState();
    _loadSubjects(1, search);
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
        backgroundColor: Colors.purple,
        automaticallyImplyLeading: false,
        elevation: 10,
        title: titleS,
        actions: [
          _searchSub(),
        ],
      ),
      body: subList.isEmpty
          ? Center(
              child: Text(titlecenter,
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold)))
          : Column(children: [
              const SizedBox(height: 5),
              Expanded(
                  child: GridView.count(
                      crossAxisCount: 2,
                      childAspectRatio: (1 / 1.9),
                      children: List.generate(subList.length, (index) {
                        return InkWell(
                          splashColor: Colors.purpleAccent,
                          onTap: () => {_loadSubjectDetails(index)},
                          child: Card(
                              elevation: 10,
                              child: Column(
                                children: [
                                  Flexible(
                                    flex: 10,
                                    child: CachedNetworkImage(
                                      imageUrl: CONSTANTS.server +
                                          "/mytutor/assets/courses/" +
                                          subList[index].subjectId.toString() +
                                          '.png',
                                      fit: BoxFit.cover,
                                      height: double.infinity,
                                      width: resWidth,
                                      placeholder: (context, url) =>
                                          const LinearProgressIndicator(),
                                      errorWidget: (context, url, error) =>
                                          const Icon(Icons.error),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Flexible(
                                      flex: 10,
                                      child: Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            0.0, 8.0, 0.0, 8.0),
                                        child: Column(
                                          children: [
                                            SizedBox(
                                              height: 35,
                                              child: Text(
                                                truncateString(
                                                    subList[index]
                                                        .subjectName
                                                        .toString(),
                                                    30),
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(
                                                    fontSize: 15,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                            const SizedBox(height: 10),
                                            const Divider(
                                              thickness: 2,
                                              color: Colors.purple,
                                            ),
                                            const SizedBox(height: 10),
                                            Row(
                                              children: [
                                                Column(children: [
                                                  Text(
                                                      "RM " +
                                                          double.parse(subList[
                                                                      index]
                                                                  .subjectPrice
                                                                  .toString())
                                                              .toStringAsFixed(
                                                                  2),
                                                      style: const TextStyle(
                                                          fontSize: 13)),
                                                  const SizedBox(height: 5),
                                                  Row(children: [
                                                    const Icon(Icons.star,
                                                        color: Colors.purple,
                                                        size: 15),
                                                    Column(
                                                      children: [
                                                        Text(
                                                          "Rating: " +
                                                              subList[index]
                                                                  .subjectRating
                                                                  .toString(),
                                                          style:
                                                              const TextStyle(
                                                                  fontSize: 13),
                                                        ),
                                                      ],
                                                    ),
                                                  ]),
                                                ]),
                                              ],
                                            )
                                          ],
                                        ),
                                      ))
                                ],
                              )),
                        );
                      }))),
              SizedBox(
                height: 30,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: numofpage,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    if ((curpage - 1) == index) {
                      color = Colors.purple;
                    } else {
                      color = Colors.black;
                    }
                    return SizedBox(
                      width: 40,
                      child: TextButton(
                          onPressed: () => {_loadSubjects(index + 1, "")},
                          child: Text(
                            (index + 1).toString(),
                            style: TextStyle(color: color),
                          )),
                    );
                  },
                ),
              ),
            ]),
    );
  }

  void _loadSubjects(int pageno, String _search) {
    curpage = pageno;
    numofpage ?? 1;
    http.post(Uri.parse(CONSTANTS.server + "/mytutor/php/load_subject.php"),
        body: {
          'pageno': pageno.toString(),
          'search': _search,
        }).timeout(
      const Duration(seconds: 5),
      onTimeout: () {
        return http.Response(
            'Error', 408); // Request Timeout response status code
      },
    ).then((response) {
      var jsondata = jsonDecode(response.body);

      print(jsondata);
      if (response.statusCode == 200 && jsondata['status'] == 'success') {
        var extractdata = jsondata['data'];
        numofpage = int.parse(jsondata['numofpage']);

        if (extractdata['subjects'] != null) {
          subList = <Subjects>[];
          extractdata['subjects'].forEach((v) {
            subList.add(Subjects.fromJson(v));
          });
        } else {
          titlecenter = "No Subject Available";
        }
        setState(() {});
      } else {
        titlecenter = "No Subject Available";
        subList.clear();
      }
    });
  }

  _loadSubjectDetails(int index) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            insetPadding: const EdgeInsets.all(15),
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0))),
            title: const Text(
              "Subject Details",
              style:
                  TextStyle(color: Colors.purple, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            content: Stack(children: [
            Positioned(
                top: -50,
                left: -50,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      color: Colors.purple[50]),
                )),
            Positioned(
                top: 200,
                right: -30,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      color: Colors.purple[50]),
                )),
            SingleChildScrollView(
                child: SizedBox(
                    height: screenHeight / 0.67,
                    width: screenWidth,
                    child: Column(children: [
                      SizedBox(
                          height: screenHeight / 3.0,
                          width: screenWidth / 1.5,
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            elevation: 10,
                            child: CachedNetworkImage(
                              imageUrl: CONSTANTS.server +
                                  "/mytutor/assets/courses/" +
                                  subList[index].subjectId.toString() +
                                  '.png',
                              fit: BoxFit.fill,
                              placeholder: (context, url) =>
                                  const LinearProgressIndicator(),
                              errorWidget: (context, url, error) =>
                                  const Icon(Icons.error),
                            ),
                          )),
                      const SizedBox(height: 10),
                      const Divider(
                        thickness: 2,
                        color: Colors.purple,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        subList[index].subjectName.toString(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 15),
                      SizedBox(
                          height: screenHeight / 1.1,
                          width: screenWidth / 1.05,
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            color: Colors.white,
                            elevation: 10,
                            child: Padding(
                                padding: const EdgeInsets.fromLTRB(
                                    8.0, 15.0, 8.0, 15.0),
                                child: Table(
                                  columnWidths: const {
                                    0: FlexColumnWidth(3),
                                    1: FlexColumnWidth(4),
                                  },
                                  border: TableBorder.all(color: Colors.white),
                                  children: [
                                    TableRow(children: [
                                      const TableCell(
                                          child: Text(
                                        "Price",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      )),
                                      TableCell(
                                          child: Text("RM " +
                                              double.parse(subList[index]
                                                      .subjectPrice
                                                      .toString())
                                                  .toStringAsFixed(2))),
                                    ]),
                                    const TableRow(children: [
                                      TableCell(child: Text("")),
                                      TableCell(child: Text("")),
                                    ]),
                                    TableRow(children: [
                                      const TableCell(
                                          child: Text(
                                        "Rating",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      )),
                                      TableCell(
                                          child: Text(subList[index]
                                              .subjectRating
                                              .toString())),
                                    ]),
                                    const TableRow(children: [
                                      TableCell(child: Text("")),
                                      TableCell(child: Text("")),
                                    ]),
                                    TableRow(children: [
                                      const TableCell(
                                          child: Text(
                                        "Sessions",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      )),
                                      TableCell(
                                          child: Text(subList[index]
                                              .subjectSessions
                                              .toString())),
                                    ]),
                                    const TableRow(children: [
                                      TableCell(child: Text("")),
                                      TableCell(child: Text("")),
                                    ]),
                                    TableRow(children: [
                                      const TableCell(
                                          child: Text(
                                        "Description",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      )),
                                      TableCell(
                                          child: Text(
                                              subList[index]
                                                  .subjectDescription
                                                  .toString(),
                                              textAlign: TextAlign.justify)),
                                    ]),
                                  ],
                                )),
                          ))
                    ])))]),
            actions: [
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(120.0, 0, 50.0, 10.0),
                  child: Row(children: const [
                    CircleAvatar(
                      radius: 20.0,
                      child: Icon(Icons.close, color: Colors.white),
                    )
                  ]),
                ),
              )
            ],
          );
        });
  }

  String truncateString(String data, int length) {
    return (data.length >= length) ? '${data.substring(0, length)}...' : data;
  }

  Widget _searchSub() {
    return IconButton(
      onPressed: () {
        setState(() {
          if (this.pressIcon.icon == Icons.search) {
            this.pressIcon = const Icon(
              Icons.cancel,
              color: Colors.white,
            );
            this.titleS = TextField(
              controller: searchController,
              style: const TextStyle(
                color: Colors.white,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                  prefixIcon: Icon(Icons.search, color: Colors.white),
                  hintText: "Search...",
                  hintStyle: TextStyle(color: Colors.white)),
              onChanged: (value) {
                setState(() {
                  if (searchController.text.isEmpty) {
                    _loadSubjects(1, "");
                    subList = [];
                  } else {
                    _loadSubjects(1, value);
                  }
                });
              },
            );
            _searching = true;
          } else {
            setState(() {
              this.pressIcon = const Icon(
                Icons.search,
                color: Colors.white,
              );
              this.titleS = const Text(
                "Subject",
                style: TextStyle(color: Colors.white),
              );
              _searching = false;
              _loadSubjects(1, "");
              subList = [];
              searchController.clear();
            });
          }
        });
      },
      icon: pressIcon,
    );
  }
}
