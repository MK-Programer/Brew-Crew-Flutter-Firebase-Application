import 'package:brew_crew/models/user.dart';
import 'package:brew_crew/services/database.dart';
import 'package:firebase_auth/firebase_auth.dart';

// provide different ways for sign in
class AuthService{
  // _auth => private
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // create user object based on FirebaseUser(User)
  Users? _userFromFirebaseUser(User? user){
    return user != null ? Users(uid: user.uid) : null;
  }

  // auth change user stream
  // state of the user sign in or sign out
  Stream<Users?> get user{
    return _auth.authStateChanges()
        // .map((User? user) => _userFromFirebaseUser(user));
    .map(_userFromFirebaseUser);
  }

  // sign in as anonymous
  Future signInAnon() async{
    try{
      // AuthResult => UserCredential
      UserCredential result =  await _auth.signInAnonymously();
      // FirebaseUser => User
      User? user = result.user;
      return _userFromFirebaseUser(user);
    }catch(e){
      print(e.toString());
      return null;
    }
  }

  // sign in with email & password
  Future signInWithEmailAndPassword(String email, String password) async{
    try{
      UserCredential result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      User? user = result.user;
      return _userFromFirebaseUser(user);
    }catch(e){
      print(e.toString());
      return null;
    }
  }

  // register with email & password
  // firebase check automatic if the email entered is valid or not (@, .)
  Future registerWithEmailAndPassword(String email, String password) async{
    try{
      UserCredential result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      User? user = result.user;

      // create a new document for the user with the uid
      await DatabaseService(uid: user!.uid).updateUserData('0', 'new crew member', 100);

      return _userFromFirebaseUser(user);
    }catch(e){
      print(e.toString());
      return null;
    }
  }

  // sign out
  Future signOut() async{
    try{
      return  await _auth.signOut();
    }catch(e){
      print(e.toString());
      return null;
    }
  }
}