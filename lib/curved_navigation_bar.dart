import 'dart:developer';

import '/src/bar_item.dart';
import 'package:flutter/material.dart';
import 'src/nav_button.dart';
import 'src/nav_custom_painter.dart';

typedef _LetIndexPage = bool Function(int value);

class CurvedNavigationBar extends StatefulWidget {
  final List<BarItem> items;
  final int index;
  final Color color;
  final Color? buttonBackgroundColor;
  final Color backgroundColor;
  final ValueChanged<int>? onTap;
  final _LetIndexPage letIndexChange;
  final Curve animationCurve;
  final Duration animationDuration;
  final double height;

  CurvedNavigationBar({
    Key? key,
    required this.items,
    this.index = 1,
    this.color = Colors.white,
    this.buttonBackgroundColor,
    this.backgroundColor = Colors.blueAccent,
    this.onTap,
    _LetIndexPage? letIndexChange,
    this.animationCurve = Curves.easeOut,
    this.animationDuration = const Duration(milliseconds: 600),
    this.height = 110.0,
  })  : letIndexChange = letIndexChange ?? ((_) => true),
        assert(items.length >= 1),
        assert(0 <= index && index < items.length),
        assert(0 <= height && height <= 110.0),
        super(key: key);

  @override
  CurvedNavigationBarState createState() => CurvedNavigationBarState();
}

class CurvedNavigationBarState extends State<CurvedNavigationBar>
    with SingleTickerProviderStateMixin {
  late double _startingPos;
  late int _endingIndex;
  late double _pos;
  double _buttonHide = 0;
  late Widget _icon;
  late AnimationController _animationController;
  late int _length;
  late bool _isCenter;

  @override
  void initState() {
    super.initState();
    _endingIndex = widget.index;
    _icon = widget.items[widget.index].icon;
    _length = widget.items.length;
    _pos = widget.index / _length;
    _startingPos = widget.index / _length;
    _animationController = AnimationController(vsync: this, value: _pos);
    _isCenter = widget.items[widget.index].isCenter;
    _animationController.addListener(() {
      setState(() {
        _pos = _animationController.value;
        final endingPos = _endingIndex / widget.items.length;
        final middle = (endingPos + _startingPos) / 2;
        if ((endingPos - _pos).abs() < (_startingPos - _pos).abs()) {
          _icon = widget.items[_endingIndex].icon;
          _isCenter = widget.items[_endingIndex].isCenter;
        }
        _buttonHide =
            (1 - ((middle - _pos) / (_startingPos - middle)).abs()).abs();
      });
    });
  }

  @override
  void didUpdateWidget(CurvedNavigationBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.index != widget.index) {
      final newPosition = widget.index / _length;
      _startingPos = _pos;
      _endingIndex = widget.index;
      _animationController.animateTo(newPosition,
          duration: widget.animationDuration, curve: widget.animationCurve);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      height: widget.height - 10,
      decoration: BoxDecoration(
        color: widget.backgroundColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
          bottomLeft: Radius.circular(10),
          bottomRight: Radius.circular(10),
        ),
        boxShadow: [
          BoxShadow(
            color: widget.backgroundColor,
            blurRadius: 4,
            offset: Offset(4, 8), // Shadow position
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: <Widget>[
          Positioned(
            bottom: -30 - ((_isCenter ? 120.0 : 105.0) - widget.height),
            left: Directionality.of(context) == TextDirection.rtl
                ? null
                : _pos * size.width,
            right: Directionality.of(context) == TextDirection.rtl
                ? _pos * size.width
                : null,
            width: size.width / _length,
            child: Center(
              child: Transform.translate(
                offset: Offset(
                  0,
                  -(1 - _buttonHide) * 80,
                ),
                child: Material(
                  color: _isCenter
                      ? Colors.white.withOpacity(0.5)
                      : Colors.white.withOpacity(0),
                  type: MaterialType.circle,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: _icon,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0 - (110.0 - widget.height),
            child: CustomPaint(
              painter: NavCustomPainter(
                _pos,
                _length,
                widget.color,
                Directionality.of(context),
              ),
              child: Container(
                height: widget.height,
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0 - (125.0 - widget.height),
            child: SizedBox(
              height: 100.0,
              child: Row(
                children: widget.items.map((item) {
                  String? title =
                      !widget.items[_endingIndex].isCenter ? item.title : '';
                  title = item.isCenter && title != null && title.isEmpty
                      ? ''
                      : item.title;

                  return Expanded(
                    child: Column(
                      children: <Widget>[
                        NavButton(
                          onTap: _buttonTap,
                          position: _pos,
                          length: _length,
                          index: widget.items.indexOf(item),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              item.icon,
                              if (!item.isCenter) ...[
                                SizedBox(height: 2.0),
                              ],
                            ],
                          ),
                        ),
                        if (item.title != null) ...[
                          Flexible(
                            flex: 2,
                            child: Text(
                              title!,
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void setPage(int index) {
    _buttonTap(index);
  }

  void _buttonTap(int index) {
    if (!widget.letIndexChange(index)) {
      return;
    }
    if (widget.onTap != null) {
      widget.onTap!(index);
    }

    if (widget.items[index].isCenter) {
      final newPosition = index / _length;
      setState(() {
        _startingPos = _pos;
        _endingIndex = index;
        _animationController.animateTo(
          newPosition,
          duration: widget.animationDuration,
          curve: widget.animationCurve,
        );
      });
    }
  }
}
