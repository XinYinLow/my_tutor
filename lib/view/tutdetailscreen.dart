import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../CONSTANTS.dart';
import '../models/tutor.dart';

class TutDetailScreen extends StatefulWidget {
  final Tutors tut;
  const TutDetailScreen({Key? key, required this.tut}) : super(key: key);

  @override
  State<TutDetailScreen> createState() => _TutDetailScreenState();
}

class _TutDetailScreenState extends State<TutDetailScreen> {
  late double screenHeight, screenWidth, ctrwidth;
  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth >= 800) {
      ctrwidth = screenWidth / 1.5;
    }
    if (screenWidth < 800) {
      ctrwidth = screenWidth;
    }
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.purple, title: const Text('Subject Detail')),
      body: SingleChildScrollView(
        child: Center(
            child: SizedBox(
                height: screenHeight / 1.05,
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
                              widget.tut.tutorId.toString() +
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
                      height: screenHeight / 2.0,
                      width: screenWidth / 1.05,
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        color: Colors.white,
                        elevation: 10,
                        child: Padding(
                            padding:
                                const EdgeInsets.fromLTRB(8.0, 15.0, 8.0, 15.0),
                            child: Table(
                              columnWidths: const {
                                0: FlexColumnWidth(2),
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
                                    widget.tut.tutorName.toString(),
                                  )),
                                ]),
                                TableRow(children: [
                                  const TableCell(child: Text("Description")),
                                  TableCell(
                                      child: Text(
                                          widget.tut.tutorDescription
                                              .toString(),
                                          textAlign: TextAlign.justify)),
                                ]),
                                TableRow(children: [
                                  const TableCell(child: Text("Phone")),
                                  TableCell(
                                      child: Text(
                                          widget.tut.tutorPhone.toString())),
                                ]),
                                TableRow(children: [
                                  const TableCell(child: Text("Email")),
                                  TableCell(
                                      child: Text(
                                          widget.tut.tutorEmail.toString())),
                                ]),
                              ],
                            )),
                      ))
                ]))),
      ),
    );
  }
}
