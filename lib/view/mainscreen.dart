import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
//import 'package:intl/intl.dart';
import 'package:my_tutor/models/Subject.dart';
import 'package:my_tutor/models/tutor.dart';
import 'package:my_tutor/models/user.dart';
import 'package:my_tutor/view/subdetailscreen.dart';
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
  String dropdownvalue = 'Programming 101';
  var types = [
    'Programming 101',
    'Programming 201',
    'Introduction to Web programming',
    'Web programming advanced',
    'Python for Everybody',
    'Introduction to Computer Science',
    'Code Yourself! An Introduction to Programming',
    'IBM Full Stack Software Developer Professional Certificate',
    'Graphic Design Specialization',
    'Fundamentals of Graphic Design',
    'Full-Stack Web Development with React',
    'Software Design and Architecture',
    'Software Testing and Automation',
    'Introduction to Cyber Security',
  ];

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
        title: const Text('Subject'),
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.search),
        //     onPressed: () {
        //       _loadSearchDialog();
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
              const Padding(
                padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
              ),
              Expanded(
                  child: GridView.count(
                      crossAxisCount: 2,
                      childAspectRatio: (1 / 1.9),
                      children: List.generate(subList.length, (index) {
                        return InkWell(
                          splashColor: Colors.purple,
                          onTap: () => {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    SubDetailScreen(sub: subList[index]),
                              ),
                            )
                          },
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
                                              height: 47,
                                              child: Text(
                                                subList[index]
                                                    .subjectName
                                                    .toString(),
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(
                                                    fontSize: 13,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                            const SizedBox(height: 10),
                                            const Divider(
                                              thickness: 2,
                                              color: Colors.purple,
                                            ),
                                            const SizedBox(height: 5),
                                            Row(
                                              children: [
                                                Column(children: [
                                                  Text(
                                                    "RM " +
                                                        double.parse(subList[
                                                                    index]
                                                                .subjectPrice
                                                                .toString())
                                                            .toStringAsFixed(2),
                                                    textAlign: TextAlign.left,style: const TextStyle(fontSize: 13)
                                                  ),
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
                                                          textAlign:
                                                              TextAlign.left,
                                                              style: const TextStyle(fontSize: 13),
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
          titlecenter = "No Product Available";
        }
        setState(() {});
      } else {
        //do something
      }
    });
  }

  // _loadProductDetails(int index) {
  //   showDialog(
  //       context: context,
  //       builder: (BuildContext context) {
  //         return AlertDialog(
  //           shape: const RoundedRectangleBorder(
  //               borderRadius: BorderRadius.all(Radius.circular(20.0))),
  //           title: const Text(
  //             "Product Details",
  //             style: TextStyle(),
  //           ),
  //           content: SingleChildScrollView(
  //               child: Column(
  //             children: [
  //               CachedNetworkImage(
  //                 imageUrl: CONSTANTS.server +
  //                     "/slumshop/mobile/assets/products/" +
  //                     productList[index].productId.toString() +
  //                     '.jpg',
  //                 fit: BoxFit.cover,
  //                 width: resWidth,
  //                 placeholder: (context, url) =>
  //                     const LinearProgressIndicator(),
  //                 errorWidget: (context, url, error) => const Icon(Icons.error),
  //               ),
  //               Text(
  //                 productList[index].productName.toString(),
  //                 style: const TextStyle(
  //                     fontSize: 16, fontWeight: FontWeight.bold),
  //               ),
  //               Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
  //                 Text("Product Description: \n" +
  //                     productList[index].productDesc.toString()),
  //                 Text("Price: RM " +
  //                     double.parse(productList[index].productPrice.toString())
  //                         .toStringAsFixed(2)),
  //                 Text("Quantity Available: " +
  //                     productList[index].productQty.toString() +
  //                     " units"),
  //                 Text("Product Status: " +
  //                     productList[index].productStatus.toString()),
  //                 Text("Product Date: " +
  //                     df.format(DateTime.parse(
  //                         productList[index].productDate.toString()))),
  //               ]),
  //               ElevatedButton(onPressed: _addtocartDialog, child: Text("Add to cart"))
  //             ],
  //           )),
  //           actions: [
  //             TextButton(
  //               child: const Text(
  //                 "Close",
  //                 style: TextStyle(),
  //               ),
  //               onPressed: () {
  //                 Navigator.of(context).pop();
  //               },
  //             ),
  //           ],
  //         );
  //       });
  // }

  // void _loadSearchDialog() {
  //   showDialog(
  //       context: context,
  //       builder: (BuildContext context) {
  //         // return object of type Dialog
  //         return StatefulBuilder(
  //           builder: (context, StateSetter setState) {
  //             return AlertDialog(
  //               title: const Text(
  //                 "Search ",
  //               ),
  //               content: SizedBox(
  //                 height: screenHeight / 3,
  //                 child: Column(
  //                   children: [
  //                     TextField(
  //                       controller: searchController,
  //                       decoration: InputDecoration(
  //                           labelText: 'Search',
  //                           border: OutlineInputBorder(
  //                               borderRadius: BorderRadius.circular(5.0))),
  //                     ),
  //                     const SizedBox(height: 5),
  //                     Container(
  //                       height: 60,
  //                       padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
  //                       decoration: BoxDecoration(
  //                           border: Border.all(color: Colors.grey),
  //                           borderRadius:
  //                               const BorderRadius.all(Radius.circular(5.0))),
  //                       child: DropdownButton(
  //                         value: dropdownvalue,
  //                         underline: const SizedBox(),
  //                         isExpanded: true,
  //                         icon: const Icon(Icons.keyboard_arrow_down),
  //                         items: types.map((String items) {
  //                           return DropdownMenuItem(
  //                             value: items,
  //                             child: Text(items),
  //                           );
  //                         }).toList(),
  //                         onChanged: (String? newValue) {
  //                           setState(() {
  //                             dropdownvalue = newValue!;
  //                           });
  //                         },
  //                       ),
  //                     ),
  //                     ElevatedButton(
  //                       onPressed: () {
  //                         search = searchController.text;
  //                         Navigator.of(context).pop();
  //                         _loadProducts(1, search);
  //                       },
  //                       child: const Text("Search"),
  //                     )
  //                   ],
  //                 ),
  //               ),
  //             );
  //           },
  //         );
  //       });
  // }

}
