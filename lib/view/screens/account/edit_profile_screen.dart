import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/helpers/ui/image_helper.dart';
import '../../../core/providers/account/profile_provider.dart';
import '../../../core/services/i18n/translations.g.dart';
import '../../components/containers/tile_container.dart';
import '../../components/image/user_avatar.dart';
import '../../components/inputs/form_text_field.dart';
import '../../components/misc/floating_modal.dart';
import '../../themes/app_theme.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      elevation: 0.0,
      title: Text(
        context.t.editProfile,
        style: const TextStyle(color: Colors.white),
      ),
      backgroundColor: AppTheme.getAppbarBgColor(),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        onPressed: () {
          context.pop();
        },
      ),
    ),
    body: const EditProfileScreenForm(),
  );
}

class EditProfileScreenForm extends ConsumerStatefulWidget {
  const EditProfileScreenForm({super.key});

  @override
  ConsumerState<EditProfileScreenForm> createState() => _EditProfileScreenFormState();
}

class _EditProfileScreenFormState extends ConsumerState<EditProfileScreenForm> {
  final _formKey = GlobalKey<FormBuilderState>();
  final _picker = ImagePicker();

  Future<void> _pickAvatar(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source, imageQuality: 90);

    if (pickedFile == null) return;

    final cropped = await ImageHelper.cropImage(
      File(pickedFile.path),
      cropStyle: CropStyle.circle,
      lockAspectRatio: true,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
    );

    if (cropped == null || !mounted) return;

    await ref.read(profileProvider.notifier).updateAvatar(cropped);
  }

  void _showAvatarActions({required bool hasAvatar}) {
    showFloatingModalBottomSheet(
      context: context,
      builder: (context) => Material(
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: Text(context.t.chooseInTheGallery),
                onTap: () {
                  context.pop();
                  _pickAvatar(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined),
                title: Text(context.t.takePicture),
                onTap: () {
                  context.pop();
                  _pickAvatar(ImageSource.camera);
                },
              ),
              if (hasAvatar)
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: Colors.red),
                  title: Text(context.t.delete, style: const TextStyle(color: Colors.red)),
                  onTap: () {
                    context.pop();
                    ref.read(profileProvider.notifier).removeAvatar();
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileProvider);
    final userData = profile.userData;

    return SingleChildScrollView(
      child: FormBuilder(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Center(
                child: GestureDetector(
                  onTap: () => _showAvatarActions(hasAvatar: userData?.avatar != null),
                  child: Stack(
                    children: [
                      if (userData != null) UserAvatar(userData: userData, radius: 55) else const SizedBox(width: 110, height: 110),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: CircleAvatar(
                          radius: 16,
                          backgroundColor: AppTheme.getIconColor(),
                          child: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              TileContainer(
                child: Column(
                  children: [
                    FormTextField(
                      name: 'name',
                      hint: 'name',
                      icon: Icons.person,
                      initialValue: userData?.name,
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(),
                      ]),
                    ),
                    FormTextField(
                      name: 'email',
                      hint: 'email',
                      icon: Icons.email,
                      initialValue: userData?.email,
                      keyboardType: TextInputType.emailAddress,
                      showDivider: false,
                      bottomSpace: 0,
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(),
                        FormBuilderValidators.email(),
                      ]),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: profile.isUpdatingProfile
                      ? null
                      : () async {
                          if (_formKey.currentState?.saveAndValidate(autoScrollWhenFocusOnInvalid: true) ?? false) {
                            final fields = _formKey.currentState!.fields;

                            final success = await ref
                                .read(profileProvider.notifier)
                                .updateProfile(
                                  name: fields['name']!.value,
                                  email: fields['email']!.value,
                                );

                            if (success && context.mounted) {
                              unawaited(EasyLoading.showSuccess(context.t.profileUpdatedSuccessfully));
                              context.pop();
                            }
                          }
                        },
                  icon: profile.isUpdatingProfile
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: SpinKitRing(color: Colors.white, lineWidth: 2.5),
                        )
                      : const Icon(Icons.save),
                  label: Text(context.t.save),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
