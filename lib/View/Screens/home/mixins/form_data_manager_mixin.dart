import 'package:flutter/material.dart';

mixin FormDataManagerMixin<T extends StatefulWidget> on State<T> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  
  final TextEditingController itemNameController = TextEditingController();
  final TextEditingController itemDescriptionController = TextEditingController();
  final TextEditingController additionalInfoController = TextEditingController();
  final TextEditingController finderNameController = TextEditingController();
  final TextEditingController finderEmailController = TextEditingController();
  final TextEditingController finderPhoneController = TextEditingController();
  
  String selectedCategory = 'Electronics';

  void updateSelectedCategory(String? newCategory) {
    if (newCategory != null) {
      setState(() {
        selectedCategory = newCategory;
      });
    }
  }

  bool validateForm() {
    return formKey.currentState?.validate() ?? false;
  }

  void disposeFormControllers() {
    itemNameController.dispose();
    itemDescriptionController.dispose();
    additionalInfoController.dispose();
    finderNameController.dispose();
    finderEmailController.dispose();
    finderPhoneController.dispose();
  }
}