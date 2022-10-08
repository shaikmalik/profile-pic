import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';


Future main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(home:MyApp()));
}



class MyApp extends StatefulWidget {
  const MyApp({Key?key}):super(key:key);
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  File? image;
  @override
  void initState() {
    super.initState();
  }
  
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar:AppBar(
      title:const Text("Profile Pic"),
      centerTitle:true,
    ),body:bodyWidget()
  );
  Widget bodyWidget() => Container(
    child:Column(
      children:[
        Row(
          children:[
            GestureDetector(
              onTap:sheetWidget,
              child: CircleAvatar(
                radius:60,
                backgroundColor:Colors.blue,
                child:CircleAvatar(
                  radius:55,
                  child: Stack(
                    children:[ 
                      Container(
                      height:120,
                      width:120,
                      decoration: BoxDecoration(
                        shape:BoxShape.circle,
                        image:DecorationImage(
                          fit:BoxFit.cover,
                          image : image == null ? NetworkImage('https://images.unsplash.com/photo-1573865526739-10659fec78a5?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8Mnx8Y2F0fGVufDB8fDB8fA%3D%3D&auto=format&fit=crop&w=500&q=60')
                          : FileImage(image!) as ImageProvider
                        ) 
                      )),
                      
                        
                        Positioned(
                          child:Icon(Icons.camera_alt_outlined),
                          bottom:10,
                          right:10,
                        ),
                      
                    ],
                    
            
                  )
                )
              ),
            )
          ]
        )
      ]
    )
  );
  sheetWidget() => showModalBottomSheet(
    context: this.context, 
    shape:RoundedRectangleBorder(
      borderRadius:BorderRadius.vertical(
        top:Radius.circular(20)
      )
    ),
    builder: (context) {
      return Container(
        height:200,        
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children:[
            GestureDetector(
              onTap:() async {
                await Utils.pickImageFromGallery(ImageSource.camera).then((pickedFile) async{
                  if(pickedFile == null) return;
                  await Utils.cropSelectedImage(pickedFile.path).then((croppedFile) async {
                    if(croppedFile == null) return;                   
                    final File cFile = File(croppedFile.path);
                    final bytes = cFile.readAsBytesSync().lengthInBytes;
                    final kb = bytes / 1024;
                    final mb = kb / 1024;
                    print(mb);
                    
                    await Utils.compress(cFile).then((c) async{                      
                    
                      if(c == null) return;
                      setState((){
                          image = c;
                      });
                        final bytes = c.readAsBytesSync().lengthInBytes;
                        final kb = bytes / 1024;
                        final mb = kb / 1024;
                        print(mb);
                    });
                  
                  });
                }); 
              },
              child: Row(
                children:[
                  Icon(Icons.camera_alt_sharp,size:30),
                  const SizedBox(width:20),
                  Text("Camera",style:TextStyle(fontSize:22))
                ]
              ),
            ),
            const SizedBox(height:20),
            GestureDetector(
              onTap:()async {
                await Utils.pickImageFromGallery(ImageSource.gallery).then((pickedFile) async{
                  if(pickedFile == null) return;
                  await Utils.cropSelectedImage(pickedFile.path).then((croppedFile) async{
                    if(croppedFile == null) return;
                    final File cFile = File(croppedFile.path);
                    final bytes = cFile.readAsBytesSync().lengthInBytes;
                    final kb = bytes / 1024;
                    final mb = kb / 1024;
                    print(mb);
                    
                    await Utils.compress(cFile).then((c) async{
                        if(c == null) return;
                        setState((){
                          image = c;
                        });
                        final bytes = c.readAsBytesSync().lengthInBytes;
                        final kb = bytes / 1024;
                        final mb = kb / 1024;
                        print(mb);
                    });
                  });
                }); 
              },
              child: Row(
                children:[
                  Icon(Icons.image_outlined,size:30),
                  const SizedBox(width:20),
                  Text("Gallery",style:TextStyle(fontSize:22))
                ]
              ),
            )
          ]
        ),
      );
});

}

class Utils {  
  
  Utils._();

  /// Open image gallery and pick an image
  static Future<XFile?> pickImageFromGallery(ImageSource source) async {
    return await ImagePicker().pickImage(source: source);
  }

  /// Pick Image From Gallery and return a File
  static Future<CroppedFile?> cropSelectedImage(String filePath) async {
    return await ImageCropper().cropImage(
      sourcePath:filePath,
      aspectRatioPresets: Platform.isAndroid ? [
        CropAspectRatioPreset.square,
        CropAspectRatioPreset.ratio3x2,
        CropAspectRatioPreset.original,
        CropAspectRatioPreset.ratio4x3,
        CropAspectRatioPreset.ratio16x9,
      ]:[
        CropAspectRatioPreset.original,
        CropAspectRatioPreset.square,
        CropAspectRatioPreset.ratio3x2,        
        CropAspectRatioPreset.ratio4x3, 
        CropAspectRatioPreset.ratio5x3,
        CropAspectRatioPreset.ratio5x4,
        CropAspectRatioPreset.ratio7x5,
        CropAspectRatioPreset.ratio16x9,
      ],
      uiSettings: [
        AndroidUiSettings(
        toolbarTitle:"Cropper",
        toolbarColor:Colors.deepOrange,
        toolbarWidgetColor:Colors.white,
        initAspectRatio: CropAspectRatioPreset.original,
        lockAspectRatio:false,
      ),
      IOSUiSettings(
          title: 'Cropper',
        )
      ]
      
    );
  }

  static Future<File?> compress(File imageFile) async {
    var result = await FlutterImageCompress.compressAndGetFile(
      imageFile.absolute.path,
      imageFile.path + "compressed.jpg",
      quality: 80,
    );
    return result;
  }
}