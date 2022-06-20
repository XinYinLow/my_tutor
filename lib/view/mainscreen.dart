import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
//import 'package:intl/intl.dart';
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
  //final df = DateFormat('dd/MM/yyyy hh:mm a');
  var numofpage, curpage = 1;
  var color;
  TextEditingController searchController = TextEditingController();
  String search = "";
  

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
        title: const Text("Subject"),
        automaticallyImplyLeading: false,
        elevation: 10,
  
        actions: [
          // Navigate to the Search Screen
          IconButton(
            onPressed: () {
             _loadSSearchDialog();
            },
              icon: const Icon(Icons.search))
        ],
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.search),
        //     onPressed: () {
        //       _loadSSearchDialog();
        //       showSearch(context: context, delegate: SubjectSearch());

        //     },
        //   )
        // ],
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
                          splashColor: Colors.amber,
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
        //do something
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
              style: TextStyle(),
            ),
            content: SingleChildScrollView(
                child: SizedBox(
                    height: screenHeight / 0.76,
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
                          height: screenHeight / 1.26,
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
                                      const TableCell(child: Text("Price")),
                                      TableCell(
                                          child: Text(
                                        "RM " +
                                            double.parse(subList[index]
                                                    .subjectPrice
                                                    .toString())
                                                .toStringAsFixed(2),
                                      )),
                                    ]),
                                    TableRow(children: [
                                      const TableCell(child: Text("Rating")),
                                      TableCell(
                                          child: Text(subList[index]
                                              .subjectRating
                                              .toString())),
                                    ]),
                                    TableRow(children: [
                                      const TableCell(child: Text("Sessions")),
                                      TableCell(
                                          child: Text(subList[index]
                                              .subjectSessions
                                              .toString())),
                                    ]),
                                    TableRow(children: [
                                      const TableCell(
                                          child: Text("Description")),
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

  void _loadSSearchDialog() {
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
                content:  SingleChildScrollView(
                  child: SizedBox(
                    height: screenHeight / 8,
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
                ),
                actions: [
                  ElevatedButton(
                    onPressed: () {
                      search = searchController.text;
                      Navigator.of(context).pop();
                      _loadSubjects(1, search);
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



// class SubjectSearch extends SearchDelegate {
//   List<String> seacrhSub = [
//     'Programming 101',
//     'Programming 201',
//     'Introduction to Web programming ',
//     'Web programming advanced',
//     'Python for Everybody',
//     'Introduction to Computer Science',
//     'Code Yourself! An Introduction to Programming',
//     'IBM Full Stack Software Developer Professional Certificate',
//     'Graphic Design Specialization',
//     'Fundamentals of Graphic Design',
//     'Full-Stack Web Development with React',
//     'Software Design and Architecture',
//     'Software Testing and Automation',
//     'Introduction to Cyber Security',
//   ];

//   @override
//   List<Widget>? buildActions(BuildContext context) {
//     // TODO: implement buildActions
//     return [
//       IconButton(
//           icon: const Icon(Icons.clear),
//           onPressed: () {
//             query = '';
//           })
//     ];
//   }

//   @override
//   Widget? buildLeading(BuildContext context) {
//     // TODO: implement buildLeading
//     return IconButton(
//         icon: const Icon(Icons.arrow_back),
//         onPressed: () {
//           close(context, null);
//         });
//   }

//   @override
//   Widget buildResults(BuildContext context) {
//     // TODO: implement buildResults
//     List<String> matchQuery = [];
//     for (var sub in seacrhSub) {
//       if (sub.toLowerCase().contains(query.toLowerCase())) {
//         matchQuery.add(sub);
//       }
//     }
//     return ListView.builder(
//       itemCount: matchQuery.length,
//       itemBuilder: (context, index) {
//         var result = matchQuery[index];
//         return ListTile(
//           title: Text(result),
//         );
//       },
//     );
//   }

//   @override
//   Widget buildSuggestions(BuildContext context) {
//     // TODO: implement buildSuggestions
//     List<String> matchQuery = [];
//     for (var sub in seacrhSub) {
//       if (sub.toLowerCase().contains(query.toLowerCase())) {
//         matchQuery.add(sub);
//       }
//     }
//     return ListView.builder(
//       itemCount: matchQuery.length,
//       itemBuilder: (context, index) {
//         var result = matchQuery[index];
//         return ListTile(
//           title: Text(result),
//         );
//       },
//     );
    
//   }
// }
