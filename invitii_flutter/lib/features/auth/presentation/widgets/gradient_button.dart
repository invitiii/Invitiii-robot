import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

class GradientButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final double? width;
  final double height;
  final EdgeInsetsGeometry padding;
  final BorderRadius? borderRadius;
  final Gradient? gradient;
  final bool isLoading;

  const GradientButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.width,
    this.height = AppTheme.buttonHeightMedium,
    this.padding = const EdgeInsets.symmetric(horizontal: AppTheme.spacingLarge),
    this.borderRadius,
    this.gradient,
    this.isLoading = false,
  });

  @override
  State<GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<GradientButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _opacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.8,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onPressed != null && !widget.isLoading) {
      setState(() => _isPressed = true);
      _animationController.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (_isPressed) {
      setState(() => _isPressed = false);
      _animationController.reverse();
    }
  }

  void _handleTapCancel() {
    if (_isPressed) {
      setState(() => _isPressed = false);
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.onPressed != null && !widget.isLoading;
    
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: isEnabled ? widget.onPressed : null,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Opacity(
              opacity: isEnabled ? _opacityAnimation.value : 0.6,
              child: Container(
                width: widget.width,
                height: widget.height,
                padding: widget.padding,
                decoration: BoxDecoration(
                  gradient: widget.gradient ?? AppTheme.primaryGradient,
                  borderRadius: widget.borderRadius ?? 
                      BorderRadius.circular(AppTheme.borderRadiusMedium),
                  boxShadow: isEnabled
                      ? [
                          BoxShadow(
                            color: AppTheme.primaryColor.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: widget.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            strokeWidth: 2,
                          ),
                        )
                      : widget.child,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// Outlined Gradient Button
class OutlinedGradientButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final double? width;
  final double height;
  final EdgeInsetsGeometry padding;
  final BorderRadius? borderRadius;
  final Gradient? gradient;
  final double borderWidth;

  const OutlinedGradientButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.width,
    this.height = AppTheme.buttonHeightMedium,
    this.padding = const EdgeInsets.symmetric(horizontal: AppTheme.spacingLarge),
    this.borderRadius,
    this.gradient,
    this.borderWidth = 2.0,
  });

  @override
  State<OutlinedGradientButton> createState() => _OutlinedGradientButtonState();
}

class _OutlinedGradientButtonState extends State<OutlinedGradientButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onPressed != null) {
      setState(() => _isPressed = true);
      _animationController.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (_isPressed) {
      setState(() => _isPressed = false);
      _animationController.reverse();
    }
  }

  void _handleTapCancel() {
    if (_isPressed) {
      setState(() => _isPressed = false);
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.onPressed != null;
    final borderRadius = widget.borderRadius ?? 
        BorderRadius.circular(AppTheme.borderRadiusMedium);
    
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: isEnabled ? widget.onPressed : null,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: widget.width,
              height: widget.height,
              padding: widget.padding,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: borderRadius,
                border: Border.all(
                  width: widget.borderWidth,
                  color: isEnabled 
                      ? AppTheme.primaryColor 
                      : AppTheme.textTertiaryColor,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: _isPressed && isEnabled
                      ? widget.gradient ?? AppTheme.primaryGradient
                      : null,
                  borderRadius: BorderRadius.circular(
                    AppTheme.borderRadiusMedium - widget.borderWidth,
                  ),
                ),
                child: Center(
                  child: DefaultTextStyle(
                    style: TextStyle(
                      color: _isPressed && isEnabled 
                          ? Colors.white 
                          : (isEnabled 
                              ? AppTheme.primaryColor 
                              : AppTheme.textTertiaryColor),
                    ),
                    child: widget.child,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// Icon Gradient Button
class IconGradientButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final String? label;
  final double size;
  final Gradient? gradient;

  const IconGradientButton({
    super.key,
    required this.onPressed,
    required this.icon,
    this.label,
    this.size = 56.0,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return GradientButton(
      onPressed: onPressed,
      width: size,
      height: size,
      padding: EdgeInsets.zero,
      borderRadius: BorderRadius.circular(size / 2),
      gradient: gradient,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: size * 0.4,
          ),
          if (label != null) ...[
            const SizedBox(height: 2),
            Text(
              label!,
              style: const TextStyle(
                fontSize: 10,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}