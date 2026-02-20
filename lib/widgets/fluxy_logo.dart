import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// The official Fluxy Logo widget.
/// Uses the high-fidelity official SVG asset.
class FluxyLogo extends StatelessWidget {
  final double size;
  final bool showText;
  final Color? color;
  final Color? textColor;

  const FluxyLogo({
    super.key,
    this.size = 32,
    this.showText = true,
    this.color,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Official Asset
        SizedBox(
          width: size,
          height: size,
          child: SvgPicture.asset(
            'assets/logo.svg',
            // If color is provided, we use a ColorFilter to override the SVG's internal colors
            // Otherwise, we let it use its native gradient.
            colorFilter: color != null 
                ? ColorFilter.mode(color!, BlendMode.srcIn) 
                : null,
          ),
        ),
        
        if (showText) ...[
          const SizedBox(width: 10),
          Text(
            'Fluxy',
            style: TextStyle(
              fontSize: size * 0.55,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
              color: textColor ?? (isDark ? Colors.white : const Color(0xFF1E293B)),
            ),
          ),
        ],
      ],
    );
  }
}
