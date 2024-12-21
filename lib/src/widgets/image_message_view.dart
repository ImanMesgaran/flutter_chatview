/*
 * Copyright (c) 2022 Simform Solutions
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */
import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatview/src/extensions/blurhash.dart';
import 'package:chatview/src/extensions/extensions.dart';
import 'package:chatview/src/models/models.dart';
import 'package:flutter/material.dart';
import 'package:octo_image/octo_image.dart';
import 'package:path_provider/path_provider.dart';

import 'reaction_widget.dart';
import 'share_icon.dart';

class ImageMessageView extends StatefulWidget {
  const ImageMessageView({
    Key? key,
    required this.message,
    required this.isMessageBySender,
    this.imageMessageConfig,
    this.messageReactionConfig,
    this.highlightImage = false,
    this.highlightScale = 1.2,
  }) : super(key: key);

  /// Provides message instance of chat.
  final Message message;

  /// Represents current message is sent by current user.
  final bool isMessageBySender;

  /// Provides configuration for image message appearance.
  final ImageMessageConfiguration? imageMessageConfig;

  /// Provides configuration of reaction appearance in chat bubble.
  final MessageReactionConfiguration? messageReactionConfig;

  /// Represents flag of highlighting image when user taps on replied image.
  final bool highlightImage;

  /// Provides scale of highlighted image when user taps on replied image.
  final double highlightScale;

  @override
  State<ImageMessageView> createState() => _ImageMessageViewState();
}

class _ImageMessageViewState extends State<ImageMessageView> {
  String get imageUrl => widget.message.message;

  Widget get iconButton => ShareIcon(
        shareIconConfig: widget.imageMessageConfig?.shareIconConfig,
        imageUrl: imageUrl,
      );

  File? _localImageFile;

  @override
  void initState() {
    super.initState();
    // Initialize the Future here
    final _ImageFile = _loadLocalImage(
      _localImageFile,
      filePath: widget.message.message,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: widget.isMessageBySender
          ? MainAxisAlignment.end
          : MainAxisAlignment.start,
      children: [
        if (widget.isMessageBySender &&
            !(widget.imageMessageConfig?.hideShareIcon ?? false))
          iconButton,
        Stack(
          children: [
            GestureDetector(
              onTap: () => widget.imageMessageConfig?.onTap != null
                  ? widget.imageMessageConfig?.onTap!(widget.message)
                  : null,
              child: Transform.scale(
                scale: widget.highlightImage ? widget.highlightScale : 1.0,
                alignment: widget.isMessageBySender
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: Container(
                  padding:
                      widget.imageMessageConfig?.padding ?? EdgeInsets.zero,
                  margin: widget.imageMessageConfig?.margin ??
                      EdgeInsets.only(
                        top: 6,
                        right: widget.isMessageBySender ? 6 : 0,
                        left: widget.isMessageBySender ? 0 : 6,
                        bottom: widget.message.reaction.reactions.isNotEmpty
                            ? 15
                            : 0,
                      ),
                  height: widget.imageMessageConfig?.height ?? 200,
                  width: widget.imageMessageConfig?.width ?? 150,
                  child: ClipRRect(
                    borderRadius: widget.imageMessageConfig?.borderRadius ??
                        BorderRadius.circular(14),
                    child: (() {
                      if (imageUrl.isUrl) {
                        return GestureDetector(
                          onTap: () => _showFullscreenImage(context,
                              type: Type.NetworkImage),
                          child: OctoImage(
                            colorBlendMode: BlendMode.modulate,
                            fit: BoxFit.cover,
                            image: CachedNetworkImageProvider(imageUrl),
                            placeholderBuilder: OctoBlurHashFix.placeHolder(
                                'LEHV6nWB2yk8pyo0adR*.7kCMdnj'),
                            errorBuilder: OctoBlurHashFix.error(
                                'LKO2:N%2Tw=w]~RBVZRi};RPxuwH',
                                iconColor: Colors.transparent),
                          ),
                        );

                        /*return Image.network(
                          imageUrl,
                          fit: BoxFit.fitHeight,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes !=
                                        null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            );
                          },
                        );*/
                      } else if (imageUrl.fromMemory) {
                        return Image.memory(
                          base64Decode(imageUrl
                              .substring(imageUrl.indexOf('base64') + 7)),
                          fit: BoxFit.fill,
                        );
                      } else {
                        // final _ImageFile = _loadLocalImage(
                        //   _localImageFile,
                        //   filePath: widget.message.message,
                        // );

                        return GestureDetector(
                          onTap: () => _showFullscreenImage(context,
                              type: Type.FileImage),
                          child: OctoImage(
                            colorBlendMode: BlendMode.modulate,
                            fit: BoxFit.cover,
                            image: FileImage(_localImageFile!),
                            placeholderBuilder: OctoBlurHashFix.placeHolder(
                                'LEHV6nWB2yk8pyo0adR*.7kCMdnj'),
                            errorBuilder: OctoBlurHashFix.error(
                                'LKO2:N%2Tw=w]~RBVZRi};RPxuwH',
                                iconColor: Colors.transparent),
                          ),
                        );
                      }
                    }()),
                  ),
                ),
              ),
            ),
            if (widget.message.reaction.reactions.isNotEmpty)
              ReactionWidget(
                isMessageBySender: widget.isMessageBySender,
                reaction: widget.message.reaction,
                messageReactionConfig: widget.messageReactionConfig,
              ),
          ],
        ),
        if (!widget.isMessageBySender &&
            !(widget.imageMessageConfig?.hideShareIcon ?? false))
          iconButton,
      ],
    );
  }

  void _showFullscreenImage(BuildContext context, {required Type type}) async {
    dynamic provider = (type == Type.FileImage)
        ? FileImage(_localImageFile!)
        : NetworkImage(imageUrl);

    await showDialog(
      context: context,
      builder: (context) => GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Container(
          color: Colors.black,
          child: Center(
            child: OctoImage(
              image: provider,
              placeholderBuilder: OctoPlaceholder.circularProgressIndicator(),
              errorBuilder: OctoError.icon(color: Colors.red),
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }

  File? _loadLocalImage(File? localFile, {required String filePath}) {
    try {
      // Check if the file exists
      final file = File(filePath);
      if (file.existsSync()) {
        _localImageFile = file;

        return _localImageFile;
      }
      return File('assets/example_image.png');
    } catch (e) {
      print("Error loading image: $e");
      return File('assets/example_image.png');
    }
  }
}

enum Type { FileImage, NetworkImage }
