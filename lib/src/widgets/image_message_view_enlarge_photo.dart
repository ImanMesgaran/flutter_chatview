import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatview/chatview.dart';
import 'package:chatview/src/extensions/blurhash.dart';
import 'package:chatview/src/utils/image_types.dart';
import 'package:chatview/src/widgets/image_message_view.dart';
import 'package:flutter/material.dart';
import 'package:octo_image/octo_image.dart';

class EnlargedPhotoPage extends StatelessWidget {
  final PictureType pictureType;
  final String? imageUrl;
  final File? localImageFile;

  const EnlargedPhotoPage({
    super.key,
    required this.imageUrl,
    required this.pictureType,
    required this.localImageFile,
  });

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Disable hardware back button and swipe-to-go-back
        return false;
      },
      child: Scaffold(
        body: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: OctoImage(
            colorBlendMode: BlendMode.modulate,
            fit: BoxFit.cover,
            image: _getPicture(),
            placeholderBuilder:
                OctoBlurHashFix.placeHolder('LEHV6nWB2yk8pyo0adR*.7kCMdnj'),
            errorBuilder: OctoBlurHashFix.error('LKO2:N%2Tw=w]~RBVZRi};RPxuwH',
                iconColor: Colors.transparent),
          ),
        ),
      ),
    );
  }

  _getPicture() {
    if (pictureType == PictureType.NetworkImage) {
      return CachedNetworkImageProvider(imageUrl!);
    } else if (pictureType == PictureType.FileImage) {
      return FileImage(localImageFile!);
    } else {
      return '';
    }
  }
}
