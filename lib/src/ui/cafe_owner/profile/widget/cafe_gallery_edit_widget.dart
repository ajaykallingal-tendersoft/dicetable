import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:soloseaters/src/constants/assets.dart';
import '../bloc/profile_bloc.dart';
import 'package:soloseaters/src/constants/app_colors.dart';

// class EditGalleryPhotosWidget extends StatelessWidget {
//   final List<String> photoUrls; // server photos
//   final List<File> stagedPhotoFiles; // newly picked local files
//   final VoidCallback? onUploadGallery; // pick from gallery
//   final VoidCallback? onTakePicture; // pick from camera
//   final void Function(int index, bool isNetwork)? onDelete; // delete handler

//   const EditGalleryPhotosWidget({
//     super.key,
//     required this.photoUrls,
//     required this.stagedPhotoFiles,
//     this.onUploadGallery,
//     this.onTakePicture,
//     this.onDelete,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final total = photoUrls.length + stagedPhotoFiles.length;
//     final bool isEmpty = total == 0;
//     final bool canAddMore = total < 4; // 🧩 new rule — max 4 total

//     return Container(
//       padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
//       decoration: BoxDecoration(
//         color: AppColors.signUpContainerColor,
//         borderRadius: BorderRadius.circular(15),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Cafe/Eatery Photos',
//             style: Theme.of(context).textTheme.labelMedium?.copyWith(
//                   fontSize: 14,
//                   color: AppColors.primary,
//                 ),
//           ),
//           const Gap(10),

//           // ----------------  GRID  ----------------
//           isEmpty
//               ? Center(
//                   child: Text(
//                     'No photos uploaded yet',
//                     style: Theme.of(context)
//                         .textTheme
//                         .bodySmall!
//                         .copyWith(color: AppColors.textPrimaryGrey),
//                   ),
//                 )
//               : GridView.builder(
//                   shrinkWrap: true,
//                   physics: const NeverScrollableScrollPhysics(),
//                   gridDelegate:
//                       const SliverGridDelegateWithFixedCrossAxisCount(
//                     crossAxisCount: 2,
//                     mainAxisSpacing: 10,
//                     crossAxisSpacing: 10,
//                   ),
//                   itemCount: total,
//                   itemBuilder: (context, index) =>
//                       _buildGalleryItem(context, index),
//                 ),
//           const Gap(20),

//           // ----------------  UPLOAD BUTTONS  ----------------
//           if (canAddMore) ...[
//             _buildUploadOption(
//               context,
//               title: 'Upload from Gallery',
//               subtitle:
//                   'Supported formats JPEG and PNG\n(Size ≤ 5MB, Max 4 photos)',
//               icon: Icons.photo_library_outlined,
//               onTap: onUploadGallery,
//             ),
//             const Gap(10),
//             Center(
//               child: Text(
//                 'Or',
//                 style: Theme.of(context)
//                     .textTheme
//                     .bodySmall!
//                     .copyWith(color: AppColors.textPrimaryGrey),
//               ),
//             ),
//             const Gap(10),
//             _buildUploadOption(
//               context,
//               title: 'Take Picture',
//               icon: Icons.camera_alt_outlined,
//               onTap: onTakePicture,
//             ),
//           ] else
//             // 🧩 New message when limit reached
//             Center(
//               child: Text(
//                 'Maximum of 4 photos reached. Delete one to add more.',
//                 style: Theme.of(context)
//                     .textTheme
//                     .bodySmall!
//                     .copyWith(color: AppColors.textPrimaryGrey),
//                 textAlign: TextAlign.center,
//               ),
//             ),
//         ],
//       ),
//     );
//   }

//   // ----------------  GRID ITEM  ----------------
//   Widget _buildGalleryItem(BuildContext context, int index) {
//     final bool isNetwork = index < photoUrls.length;

//     final Widget imageWidget = isNetwork
//         ? CachedNetworkImage(
//             imageUrl: photoUrls[index],
//             fit: BoxFit.cover,
//             width: double.infinity,
//             height: double.infinity,
//             placeholder: (c, u) => _buildPlaceholder(),
//             errorWidget: (c, u, e) => _buildErrorWidget(),
//           )
//         : Image.file(
//             stagedPhotoFiles[index - photoUrls.length],
//             fit: BoxFit.cover,
//             width: double.infinity,
//             height: double.infinity,
//           );

//     return Stack(
//       children: [
//         ClipRRect(
//           borderRadius: BorderRadius.circular(10),
//           child: imageWidget,
//         ),
//         if (!isNetwork)
//           Positioned(
//             bottom: 6,
//             left: 6,
//             child: Container(
//               padding:
//                   const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//               decoration: BoxDecoration(
//                 color: AppColors.primary,
//                 borderRadius: BorderRadius.circular(6),
//               ),
//               child: Text(
//                 'NEW',
//                 style: Theme.of(context).textTheme.bodySmall!.copyWith(
//                       color: Colors.white,
//                       fontWeight: FontWeight.bold,
//                       fontSize: 10,
//                     ),
//               ),
//             ),
//           ),
//         Positioned(
//           top: 6,
//           right: 6,
//           child: InkWell(
//             onTap: () => onDelete?.call(index, isNetwork),
//             child: Container(
//               padding: const EdgeInsets.all(6),
//               decoration: const BoxDecoration(
//                 color: Colors.red,
//                 shape: BoxShape.circle,
//               ),
//               child: const Icon(Icons.delete,
//                   color: Colors.white, size: 18),
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   // ----------------  HELPERS  ----------------
//   Widget _buildPlaceholder() => Container(
//         color: AppColors.disabledColor.withValues(alpha: 0.2),
//         child:
//             const Center(child: CircularProgressIndicator(strokeWidth: 2)),
//       );

//   Widget _buildErrorWidget() => Container(
//         color: AppColors.disabledColor.withValues(alpha: 0.3),
//         child: const Icon(Icons.broken_image_outlined,
//             color: Colors.white70),
//       );

//   Widget _buildUploadOption(
//     BuildContext context, {
//     required String title,
//     String? subtitle,
//     required IconData icon,
//     required VoidCallback? onTap,
//   }) {
//     return InkWell(
//       onTap: onTap,
//       child: Container(
//         width: double.infinity,
//         padding: const EdgeInsets.all(14),
//         decoration: BoxDecoration(
//           color: AppColors.primaryWhiteColor,
//           borderRadius: BorderRadius.circular(12),
//         ),
//         child: Row(
//           children: [
//             Icon(icon, color: AppColors.primary, size: 28),
//             const Gap(12),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     title,
//                     style: Theme.of(context)
//                         .textTheme
//                         .bodyMedium!
//                         .copyWith(
//                           color: AppColors.primary,
//                           fontWeight: FontWeight.w600,
//                         ),
//                   ),
//                   if (subtitle != null)
//                     Text(
//                       subtitle,
//                       style: Theme.of(context)
//                           .textTheme
//                           .bodySmall!
//                           .copyWith(
//                             color: AppColors.textPrimaryGrey,
//                             fontSize: 12,
//                           ),
//                     ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// ============================================================================
// COMPLETE EDITGALLERYPHOTOSWIDGET
// Replace the entire widget class in your edit_profile_screen.dart
// ============================================================================

class EditGalleryPhotosWidget extends StatelessWidget {
  final List<String> photoUrls; // server photos
  final List<File> stagedPhotoFiles; // newly picked local files
  final VoidCallback? onUploadGallery; // pick from gallery
  final VoidCallback? onTakePicture; // pick from camera
  final void Function(int index, bool isNetwork)? onDelete; // delete handler

  const EditGalleryPhotosWidget({
    super.key,
    required this.photoUrls,
    required this.stagedPhotoFiles,
    this.onUploadGallery,
    this.onTakePicture,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    // 🟢 Calculate total correctly
    final serverCount = photoUrls.length;
    final localCount = stagedPhotoFiles.length;
    final total = serverCount + localCount;

    final bool isEmpty = total == 0;
    final bool canAddMore = total < 4;
    final int remainingSlots = 4 - total;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.signUpContainerColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Cafe/Eatery Photos',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontSize: 14,
                  color: AppColors.primary,
                ),
              ),
              // 🟢 Show count indicator
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color:
                      total >= 4
                          ? AppColors.appRedColor.withOpacity(0.1)
                          : AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color:
                        total >= 4 ? AppColors.appRedColor : AppColors.primary,
                    width: 1,
                  ),
                ),
                child: Text(
                  '$total/4',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontSize: 12,
                    color:
                        total >= 4 ? AppColors.appRedColor : AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const Gap(10),

          // ----------------  GRID  ----------------
          isEmpty
              ? Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Column(
                    children: [
                      Icon(
                        Icons.photo_library_outlined,
                        size: 48,
                        color: AppColors.textPrimaryGrey.withOpacity(0.5),
                      ),
                      const Gap(8),
                      Text(
                        'No photos uploaded yet',
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          color: AppColors.textPrimaryGrey,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              )
              : GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.0,
                
                ),
                itemCount: total,
                itemBuilder:
                    (context, index) => _buildGalleryItem(context, index),
              ),
          const Gap(20),

          // ----------------  UPLOAD BUTTONS  ----------------
          if (canAddMore) ...[
            _buildUploadOption(
              context,
              title: 'Upload from Gallery',
              subtitle:
                  'Supported formats JPEG and PNG\n(Size ≤ 5MB, $remainingSlots ${remainingSlots == 1 ? 'slot' : 'slots'} remaining)',
              icon: Icons.photo_library_outlined,
              onTap: onUploadGallery,
            ),
            const Gap(10),
            Center(
              child: Text(
                'Or',
                style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  color: AppColors.textPrimaryGrey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Gap(10),
            _buildUploadOption(
              context,
              title: 'Take Picture',
              subtitle:
                  '$remainingSlots ${remainingSlots == 1 ? 'slot' : 'slots'} remaining',
              icon: Icons.camera_alt_outlined,
              onTap: onTakePicture,
            ),
          ] else
          SizedBox.shrink()
            /*Center(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.appRedColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.appRedColor.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppColors.appRedColor,
                      size: 20,
                    ),
                    const Gap(8),
                    Expanded(
                      child: Text(
                        'Maximum of 4 photos reached. Delete a photo to add more.',
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          color: AppColors.appRedColor,
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),*/
        ],
      ),
    );
  }


  // ----------------  GRID ITEM  ----------------
  Widget _buildGalleryItem(BuildContext context, int index) {
    final bool isNetwork = index < photoUrls.length;

    final Widget imageWidget =
        isNetwork
            ? CachedNetworkImage(
              imageUrl: photoUrls[index],
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              placeholder: (c, u) => _buildPlaceholder(),
              errorWidget: (c, u, e) => _buildErrorWidget(),
            )
            : Image.file(
              stagedPhotoFiles[index - photoUrls.length],
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            );

    return Stack(
      clipBehavior: Clip.none, // allow the delete icon to overflow outside
      children: [
        // Main image with rounded corners
        ClipRRect(borderRadius: BorderRadius.circular(10), child: imageWidget),

        // 🟢 NEW badge for locally staged images
        if (!isNetwork)
          Positioned(
            bottom: 6,
            left: 6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(6),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Text(
                'NEW',
                style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
              ),
            ),
          ),

        // 🟢 Delete icon slightly outside top-right
        Positioned(
          top: -8, // push upward outside the image
          right: -1, // push rightward outside the image
          child: InkWell(
            onTap: () => onDelete?.call(index, isNetwork),
            // borderRadius: BorderRadius.circular(50),
            child: Image.asset(Assets.IMG_DELETE, fit: BoxFit.cover,scale: 2.5)
          ),
        ),
      ],
    );
  }

  /* Widget _buildGalleryItem(BuildContext context, int index) {
    final bool isNetwork = index < photoUrls.length;

    final Widget imageWidget = isNetwork
        ? CachedNetworkImage(
            imageUrl: photoUrls[index],
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            placeholder: (c, u) => _buildPlaceholder(),
            errorWidget: (c, u, e) => _buildErrorWidget(),
          )
        : Image.file(
            stagedPhotoFiles[index - photoUrls.length],
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          );

    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: imageWidget,
        ),
        // 🟢 NEW badge for locally staged images
        if (!isNetwork)
          Positioned(
            bottom: 6,
            left: 6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(6),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Text(
                'NEW',
                style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
              ),
            ),
          ),
        // Delete button
        Positioned(
          top: 6,
          right: 6,
          child: InkWell(
            onTap: () => onDelete?.call(index, isNetwork),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: const Icon(Icons.delete, color: Colors.white, size: 18),
            ),
          ),
        ),
      ],
    );
  }*/

  // ----------------  HELPERS  ----------------
  Widget _buildPlaceholder() => Container(
    color: AppColors.disabledColor.withOpacity(0.2),
    child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
  );

  Widget _buildErrorWidget() => Container(
    color: AppColors.disabledColor.withOpacity(0.3),
    child: const Icon(
      Icons.broken_image_outlined,
      color: Colors.white70,
      size: 40,
    ),
  );

  Widget _buildUploadOption(
    BuildContext context, {
    required String title,
    String? subtitle,
    required IconData icon,
    required VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.primaryWhiteColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowColor.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: AppColors.primary, size: 24),
            ),
            const Gap(12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const Gap(2),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        color: AppColors.textPrimaryGrey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: AppColors.primary.withOpacity(0.5),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
