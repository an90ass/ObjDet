import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../services/efficientnet_model_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ImagePicker _picker = ImagePicker();
  File? _imageFile;
  List<Map<String, dynamic>>? _results;
  bool _loading = false;

  final EfficientNetService _modelService = EfficientNetService();

  @override
  void initState() {
    super.initState();
    _modelService.loadModel();
  }

  Future<void> _pickImageAndRunModel() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);

    if (pickedFile == null) return;

    setState(() {
      _imageFile = File(pickedFile.path);
      _loading = true;
    });

    final result = await _modelService.runModel(_imageFile!);

    setState(() {
      _results = result;
      _loading = false;
    });
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.grey[900], 

    appBar: CustomAppBar(),
    body:  Container(
      decoration: BoxDecoration(
        gradient: LinearGradient( begin: Alignment.topCenter,
            end: Alignment.bottomCenter,colors: [
                  Colors.grey[900]!,
              const Color.fromARGB(255, 231, 231, 231),
            ]
        
        )
      ),  
         
   
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Capture Button Section
              CaptureButton(_results),
      
              SizedBox(height: 24),
      
              // Image Preview Section
              if (_imageFile != null) ...[
                ImagePreview(imageFile: _imageFile),
                SizedBox(height: 20),
              ],
      
              // Results Section
              if (_results != null) ...[
                Text(
                  "Detection Results",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 12),
                ResultsSection(results: _results),
              ] else ...[
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.image_search,
                          size: 60,
                          color: Colors.redAccent[700],
                        ),
                        SizedBox(height: 16),
                        Text(
                          "Take photos to analyze...",
                          style: TextStyle(
                            color: Colors.redAccent[700],
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
   
  );
}

  Card CaptureButton(results) {
    return Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              color: Colors.grey[800],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    ElevatedButton.icon(
                      onPressed: _pickImageAndRunModel,
                      icon: Icon( results ==null ? Icons.camera_alt :Icons.refresh, size: 24,color: Colors.white,),
                      label: Text(
                       results ==null ? "Take a photo": "Retake a photo",
                        style: const TextStyle(fontSize: 18,
                        color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent[700],
                        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    if (_loading) 
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Column(
                          children: [
                            CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.redAccent),
                            ),
                            SizedBox(height: 8),
                            Text(
                              "Analyzing...",
                              style: TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            );
  }}

class ResultsSection extends StatelessWidget {
  const ResultsSection({
    super.key,
    required List<Map<String, dynamic>>? results,
  }) : _results = results;

  final List<Map<String, dynamic>>? _results;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        color: Colors.grey[800],
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: ListView.separated(
            padding: EdgeInsets.zero,
            itemCount: _results!.length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              color: Colors.grey[700],
            ),
            itemBuilder: (context, index) {
              final result = _results![index];
              final label = result['label'];
              final score = result['score'];
              final confidence = (score * 100).toStringAsFixed(1);
          
              return Container(
                decoration: BoxDecoration(
                  color: index.isEven 
                      ? Colors.grey[800] 
                      : Colors.grey[850],
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: const Color.fromARGB(255, 154, 96, 96).withOpacity(0.2),
                    child: Text(
                      "${index + 1}",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(
                    label,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  trailing: Chip(
                    label: Text("$confidence%",style: TextStyle(
                      color: Colors.white
                    ),),
                    backgroundColor: _getConfidenceColor(score),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class ImagePreview extends StatelessWidget {
  const ImagePreview({
    super.key,
    required File? imageFile,
  }) : _imageFile = imageFile;

  final File? _imageFile;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Image.file(
            _imageFile!,
            height: 240,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
          Container(
            padding: EdgeInsets.all(8),
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.7),
                ],
              ),
            ),
            child: Text(
              "Detected Image",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

Color _getConfidenceColor(double score) {
  final percent = score * 100;
  if (percent > 70) return Colors.green[800]!;
  if (percent > 40) return Colors.orange[800]!;
  return Colors.red[800]!;
}
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
  
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text(
        "OBJECT DETECTION",
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 18,
          letterSpacing: 1.2,
        ),
      ),
      centerTitle: true,
      backgroundColor: Colors.transparent, 
      elevation: 8,
      shadowColor: Colors.black.withOpacity(0.4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(200),
        ),
      ),
      flexibleSpace: ClipRRect( 
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(200), 
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.redAccent[700]!,
                const Color.fromARGB(255, 199, 155, 164)!,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
    );
  }
}
