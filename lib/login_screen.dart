import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:personal_diary_app_project/view_screen.dart';

class LogInScreen extends StatefulWidget {
  const LogInScreen({Key? key}) : super(key: key);

  @override
  _LogInScreenState createState() => _LogInScreenState();
}

class _LogInScreenState extends State<LogInScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isSignIn = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.2,
            ),
            const Text(
              "SignIn/Register to Continue",
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.1,
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  isSignIn = !isSignIn;
                });
              },
              child: Text(isSignIn ? "Don't have Account Register" : "SignIn"),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.1,
            ),
            buildTextForm(controller: emailController, hintTxt: "Email"),
            const SizedBox(
              height: 30,
            ),
            buildTextForm(controller: passwordController, hintTxt: "Password"),
            const SizedBox(
              height: 30,
            ),
            buildLoginButton(),
          ],
        ),
      ),
    );
  }

  ElevatedButton buildLoginButton() {
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
          if (isSignIn == true) {
            try {
              FirebaseAuth.instance
                  .signInWithEmailAndPassword(
                      email: emailController.text,
                      password: passwordController.text)
                  .then((value) {
                if (value.additionalUserInfo != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return const ViewScreen();
                      },
                    ),
                  );
                }
              }).onError((error, stackTrace) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('User does not exist'),
                  ),
                );
              });
            } on FirebaseAuthException catch (e) {
              if (e.code == 'user-not-found') {
                print('No user found for that email.');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('No user found for that email.'),
                  ),
                );
              } else if (e.code == 'wrong-password') {
                print('Wrong password provided for that user.');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Wrong password provided for that user.'),
                  ),
                );
              }
            }
          } else {
            try {
              UserCredential userCredential = await FirebaseAuth.instance
                  .createUserWithEmailAndPassword(
                      email: emailController.text,
                      password: passwordController.text);
              if (userCredential.user != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return const ViewScreen();
                    },
                  ),
                );
              }
            } on FirebaseAuthException catch (e) {
              if (e.code == 'weak-password') {
                print('The password provided is too weak.');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('No user found for that email.'),
                  ),
                );
              } else if (e.code == 'email-already-in-use') {
                print('The account already exists for that email.');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Wrong password provided for that user.'),
                  ),
                );
              }
            } catch (e) {
              print(e);
            }
          }
        },
        child: const Text("Submit"));
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
