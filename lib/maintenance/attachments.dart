import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import 'repository.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';

Future<Uint8List?> pickMaintenanceReceipt() async {
  final file = await ImagePicker().pickImage(
    source: ImageSource.gallery,
    maxWidth: 1400,
    maxHeight: 1400,
    imageQuality: 85,
  );
  if (file == null) return null;
  if (await file.length() > 5 * 1024 * 1024) {
    throw StateError('Choose an image smaller than 5 MB.');
  }
  return compute(_compress, await file.readAsBytes());
}

Uint8List _compress(Uint8List input) {
  final decoder = img.findDecoderForData(input);
  final info = decoder?.startDecode(input);
  if (info == null || info.width * info.height > 20000000) {
    throw StateError('Choose a JPEG or PNG image under 20 megapixels.');
  }
  var image = decoder!.decodeFrame(0);
  if (image == null) {
    throw StateError('This image could not be read. Try JPEG or PNG.');
  }
  image = img.bakeOrientation(image);
  const side = 1200;
  if (image.width > side || image.height > side) {
    image = img.copyResize(
      image,
      width: image.width >= image.height ? side : null,
      height: image.height > image.width ? side : null,
    );
  }
  const limit = 200 * 1024;
  for (final quality in [85, 70, 55, 40]) {
    final bytes = img.encodeJpg(image, quality: quality);
    if (bytes.length <= limit) return bytes;
  }
  throw StateError(
    'Image is too detailed to fit the Spark limit. Crop it and try again.',
  );
}

/// One lazy fetch per mounted image, never part of the garage metadata stream.
class AttachmentImage extends StatefulWidget {
  final MaintenanceRepository repository;
  final String vehicleId, attachmentId;
  const AttachmentImage({
    super.key,
    required this.repository,
    required this.vehicleId,
    required this.attachmentId,
  });
  @override
  State<AttachmentImage> createState() => _AttachmentImageState();
}

class _AttachmentImageState extends State<AttachmentImage> {
  late Future<Uint8List?> _image;
  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant AttachmentImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.vehicleId != widget.vehicleId ||
        oldWidget.attachmentId != widget.attachmentId) {
      _load();
    }
  }

  void _load() => _image = widget.repository.attachment(
    widget.vehicleId,
    widget.attachmentId,
  );
  @override
  Widget build(BuildContext context) => FutureBuilder<Uint8List?>(
    future: _image,
    builder: (_, s) => s.hasData
        ? Image.memory(
            s.data!,
            fit: BoxFit.contain,
            errorBuilder: (_, e, stack) => const Icon(
              Icons.broken_image_outlined,
              color: AppColors.textGrey,
            ),
          )
        : s.connectionState == ConnectionState.waiting
        ? const Center(child: CircularProgressIndicator())
        : const Icon(
            Icons.receipt_long_outlined,
            color: AppColors.primary,
            size: 60,
          ),
  );
}
