
import 'package:flutter/material.dart';
import 'package:flutter_application_1/HomeScreen.dart';
import 'package:local_auth/local_auth.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final LocalAuthentication auth = LocalAuthentication();
  TextEditingController usernameInput = TextEditingController();
  FocusNode usernameText = FocusNode();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        padding: EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Expanded(
                  child: Focus(
                    onFocusChange: (focus){setState(() {
                    });},
                    child: TextFormField(
                      controller: usernameInput,
                      focusNode: usernameText,
                      style: TextStyle(
                        fontFamily: "PlusJakartaSans"
                      ),
                      decoration: InputDecoration(
                        label: Text("Username"),
                        labelStyle: TextStyle(color: usernameText.hasFocus ? Colors.blue : Colors.grey,fontFamily: "PlusJakartaSans"),
                        
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey)
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue)
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10,),
                // IconButton(
                //   onPressed: () async {
                //     print("Hello World");
                //     final List<BiometricType> availableBiometrics = await auth.getAvailableBiometrics();

                //     if (availableBiometrics.isNotEmpty) {
                //       print(availableBiometrics);
                //     }
                //     final bool canAuthenticateWithBiometrics = await auth.canCheckBiometrics;
                //     // print(canAuthenticateWithBiometrics);
                //     if(canAuthenticateWithBiometrics){
                //       try{
                //         final bool didAuthenticate = await auth.authenticate(
                //           localizedReason: "Please",
                //           options: const AuthenticationOptions(
                //             biometricOnly: false,
                //             stickyAuth: true
                //           ),

                //         );
                //         if(didAuthenticate){
                //           Navigator.push(context, MaterialPageRoute(builder: (context) => HomeScreen(),));
                //         }
                //       } catch (e){
                //         print(e);
                //       }
                //     }
                //   },
                //   icon: Icon(Icons.fingerprint),
                //   // icon: Image.asset("images/logo.png",scale: 20,)
                // )
                GestureDetector(
                  onTap: ()async{
                    print("Hello World");
                    final List<BiometricType> availableBiometrics = await auth.getAvailableBiometrics();

                    if (availableBiometrics.isNotEmpty) {
                      print(availableBiometrics);
                    }
                    final bool canAuthenticateWithBiometrics = await auth.canCheckBiometrics;
                    // print(canAuthenticateWithBiometrics);
                    if(canAuthenticateWithBiometrics){
                      try{
                        final bool didAuthenticate = await auth.authenticate(
                          localizedReason: "Please",
                          options: const AuthenticationOptions(
                            biometricOnly: false,
                            stickyAuth: true
                          ),

                        );
                        if(didAuthenticate){
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(builder: (context) => HomeScreen(),), (Route<dynamic> route) => false,
                          );
                        }
                      } catch (e){
                        print(e);
                      }
                    }
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    child: Container(
                      height: 55,
                      width: 50,
                      decoration: BoxDecoration(
                        color: Colors.blue
                      ),
                      child: Icon(Icons.fingerprint,color: Colors.white,size: 40,),
                    ),
                  ),
                )
              ],
            ),
            SizedBox(height: 10,),
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: 50,
              child: ElevatedButton(
                onPressed: (){
                  if(usernameInput.text == "Hello"){
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => HomeScreen(),), (Route<dynamic> route) => false,
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                  )
                ),
                child: Text("Sign In",
                  style: TextStyle(fontFamily: "PlusJakartaSans",fontSize: 16),
                ),
              )
            ),
          ],
        ),
      ),
    );
  }
}