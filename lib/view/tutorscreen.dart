import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
import 'package:my_tutor/models/tutor.dart';
import 'package:my_tutor/models/user.dart';
import '../constants.dart';
import 'package:cached_network_image/cached_network_image.dart';

class TutorScreen extends StatefulWidget {
  final User user;
  const TutorScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<TutorScreen> createState() => _TutorScreenState();
}

class _TutorScreenState extends State<TutorScreen> {
  List<Tutors> tutList = <Tutors>[];
  String titlecenter = "Loading...";
  late double screenHeight, screenWidth, resWidth;
  // final df = DateFormat('dd/MM/yyyy hh:mm a');
  var numofpage, curpage = 1;
  var color;
  TextEditingController searchController = TextEditingController();
  String search = "";

  @override
  void initState() {
    super.initState();
    _loadTutors(1, search);
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
        title: const Text('Tutor'),
        elevation: 10,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              _loadTSearchDialog();
            },
          )
        ],
      ),
      body: tutList.isEmpty
          ? Center(
              child: Text(titlecenter,
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold)))
          : Column(children: [
              const SizedBox(height: 5),
              Expanded(
                  child: GridView.count(
                      crossAxisCount: 2,
                      childAspectRatio: (1 / 1.5),
                      children: List.generate(tutList.length, (index) {
                        return InkWell(
                          splashColor: Colors.amber,
                          onTap: () => {_loadTutorDetails(index)},
                          child: Card(
                              elevation: 10,
                              child: Column(
                                children: [
                                  Flexible(
                                    flex: 10,
                                    child: CachedNetworkImage(
                                      imageUrl: CONSTANTS.server +
                                          "/mytutor/assets/tutors/" +
                                          tutList[index].tutorId.toString() +
                                          '.jpg',
                                      fit: BoxFit.cover,
                                      width: resWidth,
                                      placeholder: (context, url) =>
                                          const LinearProgressIndicator(),
                                      errorWidget: (context, url, error) =>
                                          const Icon(Icons.error),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Flexible(
                                      flex: 7,
                                      child: Column(
                                        children: [
                                          SizedBox(
                                            height: 35,
                                            child: Text(
                                                truncateString(
                                                    tutList[index]
                                                        .tutorName
                                                        .toString(),
                                                    30),
                                                style: const TextStyle(
                                                    fontSize: 15,
                                                    fontWeight:
                                                        FontWeight.bold),
                                                textAlign: TextAlign.center),
                                          ),
                                          const SizedBox(height: 5),
                                          const Divider(
                                            thickness: 2,
                                            color: Colors.purple,
                                          ),
                                          const SizedBox(height: 5),
                                          Row(
                                            children: [
                                              const SizedBox(width: 5,),
                                              const Icon(Icons.phone,
                                                        color: Colors.purple,
                                                        size: 15),
                                              Column(
                                                children: [
                                                  Text(
                                                      "Phone: " +
                                                          tutList[index]
                                                              .tutorPhone
                                                              .toString(),
                                                      style: const TextStyle(
                                                          fontSize: 12))
                                                ],
                                              ),
                                            ],
                                           ),
                                           
                                ]))
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
                          onPressed: () => {_loadTutors(index + 1, "")},
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

  void _loadTutors(int pageno, String _search) {
    curpage = pageno;
    numofpage ?? 1;
    http.post(Uri.parse(CONSTANTS.server + "/mytutor/php/load_tutor.php"),
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

        if (extractdata['tutors'] != null) {
          tutList = <Tutors>[];
          extractdata['tutors'].forEach((v) {
            tutList.add(Tutors.fromJson(v));
          });
        } else {
          titlecenter = "No Tutor Available";
        }
        setState(() {});
      } else {
        //do something
      }
    });
  }

  _loadTutorDetails(int index) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            insetPadding: const EdgeInsets.all(15),
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0))),
            title: const Text(
              "Tutor Detail",
              style: TextStyle(),
            ),
            content: SingleChildScrollView(
                child: SizedBox(
                    height: screenHeight / 0.83,
                    width: screenWidth,
                    child: Column(children: [
                      SizedBox(
                          height: screenHeight / 3.0,
                          width: screenWidth / 1.9,
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            elevation: 10,
                            child: CachedNetworkImage(
                              imageUrl: CONSTANTS.server +
                                  "/mytutor/assets/tutors/" +
                                  tutList[index].tutorId.toString() +
                                  '.jpg',
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
                      const SizedBox(height: 15),
                      SizedBox(
                          height: screenHeight / 1.3,
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
                                  border: TableBorder.all(
                                      width: 1.5,
                                      color: Colors.white), //table border
                                  children: [
                                    TableRow(children: [
                                      const TableCell(child: Text("Name")),
                                      TableCell(
                                          child: Text(
                                        tutList[index].tutorName.toString(),
                                      )),
                                    ]),
                                    TableRow(children: [
                                      const TableCell(child: Text("Subjects")),
                                      TableCell(
                                          child: Text(tutList[index]
                                              .subName
                                              .toString())),
                                    ]),
                                    TableRow(children: [
                                      const TableCell(
                                          child: Text("Description")),
                                      TableCell(
                                          child: Text(
                                              tutList[index]
                                                  .tutorDescription
                                                  .toString(),
                                              textAlign: TextAlign.justify)),
                                    ]),
                                    TableRow(children: [
                                      const TableCell(child: Text("Phone")),
                                      TableCell(
                                          child: Text(tutList[index]
                                              .tutorPhone
                                              .toString())),
                                    ]),
                                    TableRow(children: [
                                      const TableCell(child: Text("Email")),
                                      TableCell(
                                          child: Text(tutList[index]
                                              .tutorEmail
                                              .toString())),
                                    ]),
                                    
                                  ],
                                )),
                          ))
                    ]))),
            actions: [
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: const CircleAvatar(
                  radius: 20.0,
                  child: Icon(Icons.close, color: Colors.white),
                ),
              )
            ],
          );
        });
  }

  void _loadTSearchDialog() {
    searchController.text = "";
    showDialog(
        context: context,
        builder: (BuildContext context) {
          // return object of type Dialog
          return StatefulBuilder(
            builder: (context, StateSetter setState) {
              return AlertDialog(
                title: const Text(
                  "Search ",
                ),
                content: SizedBox(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: searchController,
                        decoration: InputDecoration(
                            labelText: 'Search',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5.0))),
                      ),
                    ],
                  ),
                ),
                actions: [
                  ElevatedButton(
                    onPressed: () {
                      search = searchController.text;
                      Navigator.of(context).pop();
                      _loadTutors(1, search);
                    },
                    child: const Text("Search"),
                  )
                ],
              );
            },
          );
        });
  }

  String truncateString(String data, int length) {
    return (data.length >= length) ? '${data.substring(0, length)}...' : data;
  }
}
