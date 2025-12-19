import 'package:flutter/material.dart';

class CustomBottomNavBar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<BottomNavItem> items;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  State<CustomBottomNavBar> createState() => _CustomBottomNavBarState();
}

class _CustomBottomNavBarState extends State<CustomBottomNavBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  int _previousIndex = 0;

  @override
  void initState() {
    super.initState();
    _previousIndex = widget.currentIndex;
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutCubic,
    );
    _animationController.forward();
  }

  @override
  void didUpdateWidget(CustomBottomNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _previousIndex = oldWidget.currentIndex;
      _animationController.reset();
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final backgroundColor = isDark ? Colors.grey[900]! : Colors.white;
    final selectedColor = theme.colorScheme.primary;
    final unselectedColor = theme.colorScheme.secondary;

    return Container(
      height: 70,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return CustomPaint(
              painter: AnimatedNotchPainter(
                selectedIndex: widget.currentIndex,
                previousIndex: _previousIndex,
                itemCount: widget.items.length,
                notchColor: backgroundColor,
                animation: _animation.value,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(
                  widget.items.length,
                  (index) => _buildNavItem(
                    context,
                    widget.items[index],
                    index,
                    widget.currentIndex == index,
                    selectedColor,
                    unselectedColor,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    BottomNavItem item,
    int index,
    bool isSelected,
    Color selectedColor,
    Color unselectedColor,
  ) {
    return Expanded(
      child: GestureDetector(
        onTap: () => widget.onTap(index),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  transitionBuilder: (child, animation) {
                    return ScaleTransition(
                      scale: animation,
                      child: child,
                    );
                  },
                  child: Icon(
                    isSelected ? item.activeIcon : item.icon,
                    key: ValueKey('${item.label}_$isSelected'),
                    color: isSelected ? selectedColor : unselectedColor,
                    size: 24,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? selectedColor : unselectedColor,
              ),
              child: Text(item.label),
            ),
          ],
        ),
      ),
    );
  }
}

class AnimatedNotchPainter extends CustomPainter {
  final int selectedIndex;
  final int previousIndex;
  final int itemCount;
  final Color notchColor;
  final double animation;

  AnimatedNotchPainter({
    required this.selectedIndex,
    required this.previousIndex,
    required this.itemCount,
    required this.notchColor,
    required this.animation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final itemWidth = size.width / itemCount;
    
    // Tính toán vị trí notch với animation
    final previousCenterX = (previousIndex * itemWidth) + (itemWidth / 2);
    final currentCenterX = (selectedIndex * itemWidth) + (itemWidth / 2);
    final centerX = previousCenterX + (currentCenterX - previousCenterX) * animation;
    
    const notchHeight = 18.0;
    const notchWidth = 48.0;
    const borderRadius = 24.0;

    final paint = Paint()
      ..color = notchColor
      ..style = PaintingStyle.fill;

    // Tạo path với notch tích hợp
    final path = Path();
    
    // Bắt đầu từ góc trên bên trái
    path.moveTo(borderRadius, 0);
    
    // Nếu notch nằm ở phần đầu, vẽ notch trước
    if (centerX - notchWidth / 2 > borderRadius) {
      path.lineTo(centerX - notchWidth / 2, 0);
    } else {
      path.lineTo(borderRadius, 0);
    }
    
    // Vẽ notch (vết lõm lên trên) với animation
    final animatedNotchHeight = notchHeight * (0.5 + 0.5 * animation);
    path.quadraticBezierTo(
      centerX - notchWidth / 3,
      -animatedNotchHeight * 0.5,
      centerX - notchWidth / 6,
      -animatedNotchHeight * 0.2,
    );
    path.quadraticBezierTo(
      centerX,
      -animatedNotchHeight,
      centerX + notchWidth / 6,
      -animatedNotchHeight * 0.2,
    );
    path.quadraticBezierTo(
      centerX + notchWidth / 3,
      -animatedNotchHeight * 0.5,
      centerX + notchWidth / 2,
      0,
    );
    
    // Tiếp tục đến góc trên bên phải
    if (centerX + notchWidth / 2 < size.width - borderRadius) {
      path.lineTo(size.width - borderRadius, 0);
    }
    
    // Góc trên bên phải
    path.quadraticBezierTo(
      size.width,
      0,
      size.width,
      borderRadius,
    );
    
    // Cạnh phải
    path.lineTo(size.width, size.height - borderRadius);
    
    // Góc dưới bên phải
    path.quadraticBezierTo(
      size.width,
      size.height,
      size.width - borderRadius,
      size.height,
    );
    
    // Cạnh dưới
    path.lineTo(borderRadius, size.height);
    
    // Góc dưới bên trái
    path.quadraticBezierTo(
      0,
      size.height,
      0,
      size.height - borderRadius,
    );
    
    // Cạnh trái
    path.lineTo(0, borderRadius);
    
    // Góc trên bên trái
    path.quadraticBezierTo(0, 0, borderRadius, 0);
    
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(AnimatedNotchPainter oldDelegate) {
    return oldDelegate.selectedIndex != selectedIndex ||
        oldDelegate.animation != animation ||
        oldDelegate.previousIndex != previousIndex;
  }
}

class BottomNavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const BottomNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

