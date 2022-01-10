import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class AddScreen extends StatefulWidget {
  final String? id;
  final String? title;
  final String? content;
  final DateTime? date;
  final String? tags;
  const AddScreen(
      {Key? key, this.id, this.title, this.content, this.date, this.tags})
      : super(key: key);

  @override
  _AddScreenState createState() => _AddScreenState();
}

class _AddScreenState extends State<AddScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();

  DateTime currentDate = DateTime.now();
  File? selectedImage;
  double? sliderValue = 0;

  @override
  void initState() {
    if (widget.id != null) {
      _titleController.text = widget.title!;
      _contentController.text = widget.content!;
      _tagsController.text = widget.tags!;
      currentDate = widget.date!;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Today Thought"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const SizedBox(
              height: 10.0,
            ),
            buildTextForm(controller: _titleController, hintTxt: "Title"),
            const SizedBox(
              height: 30,
            ),
            buildTextForm(controller: _contentController, hintTxt: "Content"),
            const SizedBox(
              height: 30,
            ),
            buildTextForm(
                controller: _tagsController, hintTxt: "Tags Comma Separate"),
            const SizedBox(
              height: 30,
            ),
            showDate(),
            const SizedBox(
              height: 30,
            ),
            Text(
                "${sliderValue == 0 ? "Sad" : sliderValue == 1 ? "Moderate" : sliderValue == 2 ? "Happy" : "Very Happy"}"),
            Slider(
              value: sliderValue!,
              onChanged: (val) {
                setState(() {
                  sliderValue = val;
                });
              },
              min: 0,
              max: 4,
              divisions: 4,
            ),
            const SizedBox(
              height: 30,
            ),
            selectedImage != null
                ? Image.file(
                    selectedImage!,
                    height: 150,
                    width: 120,
                    fit: BoxFit.fill,
                  )
                : Container(),
            const SizedBox(
              height: 30,
            ),
            selectedImage == null
                ? buildImagePicker(context)
                : ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(
                        Colors.red,
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        selectedImage = null;
                      });
                    },
                    child: const Text("Remove Image"),
                  ),
            const SizedBox(
              height: 30,
            ),
            buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget showDate() {
    return GestureDetector(
      onTap: dateSelect,
      child: Container(
        padding: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(width: 0.2, color: Colors.blueGrey),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(DateFormat('dd-MMM-yyyy').format(currentDate)),
            const SizedBox(
              width: 20,
            ),
            const Icon(Icons.calendar_today),
          ],
        ),
      ),
    );
  }

  ElevatedButton buildSubmitButton() {
    return ElevatedButton(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(Colors.indigo),
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
        ),
        onPressed: () async {
          if (_titleController.text != "" &&
              _contentController.text != "" &&
              _tagsController.text != "") {
            // if (selectedImage != null) {
            //   try {
            //     var snapshot = await FirebaseStorage.instance
            //         .ref()
            //         .child("images/${selectedImage!.path}")
            //         .putFile(selectedImage!);
            //   } catch (e) {
            //     print("errrrorrr $e");
            //   }
            // }

            if (widget.id == null) {
              FirebaseFirestore.instance.collection("dairy2022").add({
                "title": _titleController.text,
                "content": _contentController.text,
                "tags": _tagsController.text,
                "date": currentDate,
                //DateFormat("dd-MMM-yyyy").format(currentDate),
                "image": selectedImage != null ? selectedImage!.path : "",
                "mood": sliderValue,
              }).then((value) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Added Successfully"),
                    duration: Duration(seconds: 1),
                  ),
                );
                _titleController.text = "";
                _contentController.text = "";
                _tagsController.text = "";
              }).onError((error, stackTrace) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("SOMETHING WENT WRONG"),
                    duration: Duration(seconds: 1),
                  ),
                );
              });
            } else {
              ///
              FirebaseFirestore.instance
                  .collection("dairy2022")
                  .doc(widget.id)
                  .update({
                "title": _titleController.text,
                "content": _contentController.text,
                "tags": _tagsController.text,
                "date": currentDate,
                "image": selectedImage != null ? selectedImage!.path : "",
                "mood": sliderValue,
              }).then((value) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Added Successfully"),
                    duration: Duration(seconds: 1),
                  ),
                );
                _titleController.text = "";
                _contentController.text = "";
                _tagsController.text = "";
              }).onError((error, stackTrace) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("SOMETHING WENT WRONG"),
                    duration: Duration(seconds: 1),
                  ),
                );
              });
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text(
                "Enter Title and Content and Description",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              duration: Duration(seconds: 1),
              backgroundColor: Colors.black,
            ));
          }
        },
        child: const Text("Submit"));
  }

  Widget buildImagePicker(BuildContext context) {
    return ElevatedButton(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(Colors.green),
        shape: MaterialStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
      onPressed: pickImage,
      child: const Text("Pick Image"),
    );
  }

  pickImage() async {
    ImagePicker image = ImagePicker();
    var img =
        await image.pickImage(source: ImageSource.gallery, imageQuality: 50);
    if (img != null) {
      setState(() {
        selectedImage = File(img.path);
      });
    }
  }

  dateSelect() async {
    DateTime? date = await showDatePicker(
        context: context,
        initialDate: currentDate,
        firstDate: DateTime(1947),
        lastDate: DateTime(3000));

    if (date != null && date != currentDate) {
      setState(() {
        currentDate = date;
      });
    }
  }

  Widget buildTextForm(
      {TextEditingController? controller, int? maxLines, String? hintTxt}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hintTxt ?? "",
          disabledBorder: InputBorder.none,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25.0),
            borderSide: const BorderSide(
              color: Colors.blue,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25.0),
            borderSide: const BorderSide(
              color: Colors.black,
              width: 0.2,
            ),
          ),
        ),
      ),
    );
  }
}
