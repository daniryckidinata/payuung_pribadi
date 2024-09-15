import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:payuung_pribadi/models/user_model.dart';
import 'package:payuung_pribadi/utils/user_preferences.dart';

class PersonalInformationScreen extends StatefulWidget {
  final UserModel userModel;
  const PersonalInformationScreen({super.key, required this.userModel});

  @override
  State<PersonalInformationScreen> createState() =>
      _PersonalInformationScreenState();
}

class _PersonalInformationScreenState extends State<PersonalInformationScreen> {
  final _formKey = GlobalKey<FormState>();
  late UserModel _userModel = widget.userModel;
  final List<String> _genders = ['Laki-laki', 'Perempuan'];
  final List<String> _positions = ['Developer', 'Designer', 'Manager'];
  int _currentStep = 0;

  void _continue() {
    if (_currentStep < 2) {
      setState(() {
        _currentStep += 1;
      });
    }
  }

  void _cancel() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep -= 1;
      });
    }
  }

  void _tapped(int step) {
    setState(() {
      _currentStep = step;
    });
  }

  late final TextEditingController _nameController =
      TextEditingController(text: _userModel.fullName);
  late final TextEditingController _birthDateController = TextEditingController(
      text: DateFormat('dd MMMM yyyy').format(_userModel.birthDate));

  void _pickDate() async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: _userModel.birthDate,
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );

    if (selectedDate != null) {
      setState(() {
        _birthDateController.text =
            DateFormat('dd MMMM yyyy').format(selectedDate);
        _userModel = _userModel.copyWith(birthDate: selectedDate);
      });
    }
  }

  void _showImagePicker() async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Kamera'),
                onTap: () async {
                  Navigator.of(context).pop();
                  XFile? image =
                      await ImagePicker().pickImage(source: ImageSource.camera);
                  if (image != null) {
                    setState(() {
                      _userModel = _userModel.copyWith(ktp: image.path);
                    });
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_album),
                title: const Text('Galeri'),
                onTap: () async {
                  Navigator.of(context).pop();
                  XFile? image = await ImagePicker()
                      .pickImage(source: ImageSource.gallery);
                  if (image != null) {
                    setState(() {
                      _userModel = _userModel.copyWith(ktp: image.path);
                    });
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      UserPreferences.saveUserModel(_userModel);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data berhasil disimpan'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Informasi Personal')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Stepper(
            type: StepperType.horizontal,
            currentStep: _currentStep,
            onStepContinue: _continue,
            onStepCancel: _cancel,
            onStepTapped: _tapped,
            steps: <Step>[
              Step(
                title: const SizedBox(),
                label: const Text('Biodata Diri'),
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    TextFormField(
                      controller: _nameController,
                      decoration:
                          const InputDecoration(labelText: 'Nama Lengkap'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Nama lengkap wajib diisi';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _userModel = _userModel.copyWith(fullName: value);
                      },
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _birthDateController,
                      decoration: const InputDecoration(
                        labelText: 'Tanggal Lahir',
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      onTap: _pickDate,
                      readOnly: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Tanggal lahir wajib diisi';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      decoration:
                          const InputDecoration(labelText: 'Jenis Kelamin'),
                      value: _userModel.gender,
                      items: _genders.map((gender) {
                        return DropdownMenuItem(
                          value: gender,
                          child: Text(gender),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _userModel = _userModel.copyWith(gender: value);
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Pilih jenis kelamin';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
                isActive: _currentStep >= 0,
                state:
                    _currentStep > 0 ? StepState.complete : StepState.indexed,
              ),
              Step(
                title: const SizedBox(),
                label: const Text('Alamat Pribadi'),
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    ListTile(
                      title: const Text('Upload KTP'),
                      subtitle: _userModel.ktp.isNotEmpty
                          ? Image.file(File(_userModel.ktp))
                          : const Text('Belum ada gambar KTP yang diunggah'),
                      trailing: const Icon(Icons.upload_file),
                      onTap: _showImagePicker,
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
                isActive: _currentStep >= 1,
                state:
                    _currentStep > 1 ? StepState.complete : StepState.indexed,
              ),
              Step(
                title: const SizedBox(),
                label: const Text('Informasi \nPerusahaan'),
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Posisi'),
                      value: _userModel.position,
                      items: _positions.map((position) {
                        return DropdownMenuItem(
                          value: position,
                          child: Text(position),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _userModel = _userModel.copyWith(position: value);
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Pilih posisi';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
                isActive: _currentStep >= 2,
                state:
                    _currentStep == 2 ? StepState.complete : StepState.indexed,
              ),
            ],
            controlsBuilder: (BuildContext context, ControlsDetails details) {
              return Row(
                children: <Widget>[
                  if (_currentStep != 0) ...[
                    TextButton(
                      onPressed: details.onStepCancel,
                      child: const Text('Kembali'),
                    ),
                    const SizedBox(width: 8),
                  ],
                  ElevatedButton(
                    onPressed: _currentStep == 2
                        ? () => _submitForm()
                        : details.onStepContinue,
                    child: Text(_currentStep == 2 ? 'Simpan' : 'Lanjut'),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
