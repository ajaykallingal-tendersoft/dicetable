import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:soloseaters/src/constants/app_colors.dart';

class CafeEateryPhotosWidget extends StatelessWidget {
  final List<String> photoUrls;

  const CafeEateryPhotosWidget({
    super.key,
    required this.photoUrls,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.profileTextFiledBorderColor,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cafe/Eatery Photos',
            style: TextTheme.of(context).bodySmall!.copyWith(
                  color: AppColors.profileTextFiledSubColor,
                  fontSize: 13,
                ),
          ),
          const Gap(10),
          photoUrls.isEmpty
              ? Center(
                  child: Text(
                    'No photos available',
                    style: TextTheme.of(context).bodySmall!.copyWith(
                          color: AppColors.disabledColor,
                        ),
                  ),
                )
              : GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1,
                  ),
                  itemCount: photoUrls.length,
                  itemBuilder: (context, index) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: CachedNetworkImage(
                        imageUrl: photoUrls[index],
                        fit: BoxFit.cover,
                        placeholder:  (context, url) => Shimmer.fromColors(
                                    baseColor: Color(0xFF003E69),
                                    highlightColor: Color(0xFF0067AF),
                                    child: Container(
                                      width: 170.w,
                                      height: 170.h,
                                      color: Colors.white,
                                    ),
                                  ),
                        errorWidget: (context, url, error) => Container(
                          color: AppColors.disabledColor.withOpacity(0.3),
                          child: const Icon(
                            Icons.broken_image_outlined,
                            color: Colors.white70,
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }
}
