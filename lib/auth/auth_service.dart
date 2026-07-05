import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
class AuthService{
  //instance of auth
  final FirebaseAuth _auth = FirebaseAuth.instance;

  //instance of firestore
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;



  //sign in
  Future<UserCredential> signInWithEmailAndPassword(String email,  password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }}


    //sign up
    Future<UserCredential> signUpWithEmailAndPassword(
        String name,
        String email,
        String password) async {
      try{

      UserCredential userCredential=
          await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password
      );

      //add user to firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'name': name,
        'email': email,
      });
      
      return  userCredential;
      } on FirebaseAuthException catch(e){
        throw Exception(e.code);
      }

    }

  // Reset Password
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(
        email: email.trim(),
      );
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }


    //sign out
    Future<void> signOut() async {
      await _auth.signOut();
    }


    //errors



}