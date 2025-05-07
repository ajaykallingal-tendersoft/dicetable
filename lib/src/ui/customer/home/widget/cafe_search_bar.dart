

import 'dart:async';

import 'package:dicetable/src/constants/app_colors.dart';
import 'package:dicetable/src/ui/customer/home/widget/filter_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

class CafeSearchBar extends StatefulWidget {
  final Function(String) onSearch;
  final VoidCallback onFilterTap;
  const CafeSearchBar({super.key,   required this.onSearch,
    required this.onFilterTap,});

  @override
  State<CafeSearchBar> createState() => _CafeSearchBarState();
}

class _CafeSearchBarState extends State<CafeSearchBar> {
  final TextEditingController _controller = TextEditingController();
  Timer? _debounce;
  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      widget.onSearch(query.trim());
    });
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.primaryWhiteColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 2),
          )
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: AppColors.textPrimaryGrey),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              style: TextTheme.of(context).bodySmall!.copyWith(
                color: AppColors.textPrimaryGrey,
                fontWeight: FontWeight.w600,
                fontSize: 12.sp,
              ),
              controller: _controller,
              onChanged: _onSearchChanged,
              decoration:  InputDecoration(
                hintText: 'Search Near By Cafe',
                border: InputBorder.none,
                contentPadding: EdgeInsets.all( 10),
                hintStyle: TextTheme.of(context).bodySmall!.copyWith(
                color: AppColors.textPrimaryGrey,
                fontWeight: FontWeight.w600,
                fontSize: 12.sp,
              ),
              ),
            ),
          ),
          IconButton(
            icon: SvgPicture.asset(
              'assets/svg/search-filter.svg',
              fit: BoxFit.scaleDown,
              color: AppColors.primary,
            ),
            onPressed: widget.onFilterTap,
          ), // Adjust as needed

        ],
      ),
    );
  }
}

