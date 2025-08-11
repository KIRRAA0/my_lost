import 'dart:io';
import 'dart:math' show log, pow;
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:cloudinary/cloudinary.dart';
import 'package:path/path.dart' as path;

class FileUploadContainer extends StatelessWidget {
  final RxString fileName = ''.obs;
  final RxString filePath = ''.obs;
  final RxBool isUploading = false.obs;
  final RxString originalSize = ''.obs;
  final String? storageKey;
  final String? initialFileName;
  final String? initialFilePath;
  final List<String> allowedFileTypes;

  final cloudinary = Cloudinary.signedConfig(
    apiKey: dotenv.env['CLOUDINARY_API_KEY'] ?? '',
    apiSecret: dotenv.env['CLOUDINARY_API_SECRET'] ?? '',
    cloudName: dotenv.env['CLOUDINARY_CLOUD_NAME'] ?? '',
  );

  FileUploadContainer({
    super.key,
    this.storageKey,
    this.initialFileName,
    this.initialFilePath,
    this.allowedFileTypes = const ['pdf', 'doc', 'docx', 'txt', 'rtf'],
  }) {
    final storedData = retrieveStoredFileData(storageKey ?? '');
    if (storedData['fileName']?.isNotEmpty ?? false) {
      fileName.value = storedData['fileName']!;
      filePath.value = storedData['filePath']!;
    } else if (initialFileName?.isNotEmpty ?? false) {
      fileName.value = initialFileName!;
      filePath.value = initialFilePath!;
    }
  }

  String formatSize(int bytes) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB"];
    var i = (log(bytes) / log(1024)).floor();
    return '${(bytes / pow(1024, i)).toStringAsFixed(1)} ${suffixes[i]}';
  }

  Future<void> pickAndUploadFile(BuildContext context) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: allowedFileTypes,
      );

      if (result != null) {
        isUploading.value = true;
        File file = File(result.files.single.path!);

        // Get file size
        final fileBytes = file.lengthSync();
        originalSize.value = formatSize(fileBytes);
        fileName.value = path.basename(file.path);

        // Check file size (optional: limit to 10MB)
        if (fileBytes > 10 * 1024 * 1024) {
          throw Exception('File size exceeds 10MB limit');
        }

        try {
          // Upload to Cloudinary
          final response = await cloudinary.upload(
            file: file.path,
            resourceType: CloudinaryResourceType.raw,
            folder: 'documents',
            fileName: fileName.value,
          );

          // Check for errors in the response
          if (response.isSuccessful && response.secureUrl != null) {
            filePath.value = response.secureUrl!;
            print('Document uploaded successfully: ${fileName.value} | Size: ${originalSize.value} | URL: ${filePath.value}');
            // Rest of your success code
          } else {
            print('Cloudinary upload failed: ${response.error}');
            throw Exception('Cloudinary upload failed: ${response.error}');
          }
        } catch (error) {
          print('Detailed error during file upload: $error');
          // Rest of your error handling
        }

        saveFile(fileName.value, filePath.value);
      }
    } catch (error) {
      print('Error during file upload: $error');
      Get.snackbar(
        'Error',
        'Upload failed: ${error.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withAlpha((255 * 0.1).toInt()),
      );
    } finally {
      isUploading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Obx(() {
        if (isUploading.value) {
          return const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Uploading file...'),
            ],
          );
        }
        return fileName.value.isEmpty
            ? Container(
                decoration: BoxDecoration(
                  border:
                      Border.all(color: Colors.blue, style: BorderStyle.solid),
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.blue.withAlpha((255 * 0.1).toInt()),
                ),
                height: MediaQuery.of(context).size.height * 0.25,
                width: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.file_upload, size: 40, color: Colors.blue),
                    const SizedBox(height: 10),
                    const Text("Upload Document",
                        style: TextStyle(fontSize: 20)),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      onPressed: () => pickAndUploadFile(context),
                      icon: const Icon(Icons.upload_file),
                      label: const Text("Choose File"),
                    ),
                  ],
                ),
              )
            : Column(
                children: [
                  FileTile(
                    fileName: fileName.value,
                    fileSize: originalSize.value,
                    filePath: filePath.value,
                    onCancel: () {
                      fileName.value = '';
                      filePath.value = '';
                      originalSize.value = '';
                      saveFile('', '');
                    },
                    onReplace: () => pickAndUploadFile(context),
                  ),
                ],
              );
      }),
    );
  }

  void saveFile(String fileName, String filePath) {
    if (storageKey != null) {
      GetStorage().write('${storageKey!}_name', fileName);
      GetStorage().write('${storageKey!}_path', filePath);
    }
  }

  Map<String, String?> retrieveStoredFileData(String storageKey) {
    return {
      'fileName': GetStorage().read('${storageKey}_name'),
      'filePath': GetStorage().read('${storageKey}_path'),
    };
  }
}

// Companion FileTile widget (you'll need to create this)
class FileTile extends StatelessWidget {
  final String fileName;
  final String fileSize;
  final String filePath;
  final VoidCallback onCancel;
  final VoidCallback onReplace;

  const FileTile({
    super.key,
    required this.fileName,
    required this.fileSize,
    required this.filePath,
    required this.onCancel,
    required this.onReplace,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: ListTile(
        leading: const Icon(Icons.file_present),
        title: Text(fileName),
        subtitle: Text(fileSize),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: onReplace,
            ),
            IconButton(
              icon: const Icon(Icons.cancel, color: Colors.red),
              onPressed: onCancel,
            ),
          ],
        ),
      ),
    );
  }
}
