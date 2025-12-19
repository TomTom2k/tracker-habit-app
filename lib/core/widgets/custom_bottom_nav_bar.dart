import 'package:flutter/material.dart';

class CustomBottomNavBar extends StatelessWidget {
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
        child: CustomPaint(
          painter: NotchPainter(
            selectedIndex: currentIndex,
            itemCount: items.length,
            notchColor: backgroundColor,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              items.length,
              (index) => _buildNavItem(
                context,
                items[index],
                index,
                currentIndex == index,
                selectedColor,
                unselectedColor,
              ),
            ),
          ),
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
        onTap: () => onTap(index),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  isSelected ? item.activeIcon : item.icon,
                  color: isSelected ? selectedColor : unselectedColor,
                  size: 24,
                ),
                if (isSelected)
                  Positioned(
                    top: -6,
                    right: -6,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: selectedColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              item.label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? selectedColor : unselectedColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NotchPainter extends CustomPainter {
  final int selectedIndex;
  final int itemCount;
  final Color notchColor;

  NotchPainter({
    required this.selectedIndex,
    required this.itemCount,
    required this.notchColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final itemWidth = size.width / itemCount;
    final centerX = (selectedIndex * itemWidth) + (itemWidth / 2);
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
    
    // Vẽ notch (vết lõm lên trên)
    path.quadraticBezierTo(
      centerX - notchWidth / 3,
      -notchHeight * 0.5,
      centerX - notchWidth / 6,
      -notchHeight * 0.2,
    );
    path.quadraticBezierTo(
      centerX,
      -notchHeight,
      centerX + notchWidth / 6,
      -notchHeight * 0.2,
    );
    path.quadraticBezierTo(
      centerX + notchWidth / 3,
      -notchHeight * 0.5,
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
  bool shouldRepaint(NotchPainter oldDelegate) {
    return oldDelegate.selectedIndex != selectedIndex;
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

