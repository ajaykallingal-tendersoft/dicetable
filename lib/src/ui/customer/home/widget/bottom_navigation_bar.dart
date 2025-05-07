import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class FABBottomAppBarItem {
  FABBottomAppBarItem({required this.iconData, required this.text});

  Widget iconData;
  String text;
}

class BottomNavigationAppBar extends StatefulWidget {
  BottomNavigationAppBar({
    super.key,
    required this.items,
    this.height = 80.0,
    this.iconSize = 20,
    required this.backgroundColor,
    required this.color,
    required this.selectedColor,
    required this.onTabSelected,
  }) {
    assert(items.length == 2 || items.length == 5);
  }

  final List<FABBottomAppBarItem> items;
  final double height;
  final double iconSize;
  final Color backgroundColor;
  final Color color;
  final Color selectedColor;
  final ValueChanged<int> onTabSelected;

  @override
  State<StatefulWidget> createState() => BottomNavigationAppBarState();
}

class BottomNavigationAppBarState extends State<BottomNavigationAppBar> {
  int _selectedIndex = 0;

  _updateIndex(int index) {
    widget.onTabSelected(index);
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> items = List.generate(widget.items.length, (int index) {
      return _buildTabItem(
        item: widget.items[index],
        index: index,
        onPressed: _updateIndex,
      );
    });

    return BottomAppBar(
      elevation: 20,
      height: 80.h,
      color: widget.backgroundColor,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: items,
      ),
    );
  }

  Widget _buildTabItem({
    required FABBottomAppBarItem item,
    required int index,
    required ValueChanged<int> onPressed,
  }) {
    bool isSelected = _selectedIndex == index;
    Color color = _selectedIndex == index ? widget.selectedColor : widget.color;
    double iconSize = isSelected ? widget.iconSize + 4 : widget.iconSize;
    return Expanded(
      child: SizedBox(
        height: widget.height,
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: () => onPressed(index),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  flex: 2,
                  child: ColorFiltered(
                    colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
                    child: SizedBox(
                      height: iconSize,
                      width: iconSize,
                      child: item.iconData,
                    ),
                  ),
                ),

                Expanded(
                  flex: 1,
                  child: Text(
                    item.text,
                    style: TextTheme.of(context).bodySmall!.copyWith(
                      color: color,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 10.sp,
                    ),

                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
