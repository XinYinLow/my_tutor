import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../CONSTANTS.dart';
import '../models/Subject.dart';
import '../models/tutor.dart';

class SubDetailScreen extends StatefulWidget {
  final Subjects sub;
  const SubDetailScreen({Key? key, required this.sub}) : super(key: key);

  @override
  State<SubDetailScreen> createState() => _SubDetailScreenState();
}

class _SubDetailScreenState extends State<SubDetailScreen> {
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
                height: screenHeight / 0.9,
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
                              widget.sub.subjectId.toString() +
                              '.png',
                          fit: BoxFit.fill,
                          placeholder: (context, url) =>
                              const LinearProgressIndicator(),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.error),
                        ),
                      )
                      ),
                  const SizedBox(height: 10),
                  const Divider(
                    thickness: 2,
                    color: Colors.purple,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.sub.subjectName.toString(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 15),
                  SizedBox(
                      height: screenHeight / 1.7,
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
                                  color: Colors.white),
                              children: [
                                TableRow(children: [
                                  const TableCell(child: Text("Price")),
                                  TableCell(
                                      child: Text(
                                    "RM " +
                                        double.parse(widget.sub.subjectPrice
                                                .toString())
                                            .toStringAsFixed(2),
                                  )),
                                ]),
                                TableRow(children: [
                                  const TableCell(child: Text("Rating")),
                                  TableCell(
                                      child: Text(
                                          widget.sub.subjectRating.toString())),
                                ]),
                                TableRow(children: [
                                  const TableCell(child: Text("Sessions")),
                                  TableCell(
                                      child: Text(widget.sub.subjectSessions
                                          .toString())),
                                ]),
                                TableRow(children: [
                                  const TableCell(child: Text("Description")),
                                  TableCell(
                                      child: Text(
                                          widget.sub.subjectDescription
                                              .toString(),
                                          textAlign: TextAlign.justify)),
                                ]),
                              ],
                            )),
                      ))
                ]))),
      ),
    );
  }
}
