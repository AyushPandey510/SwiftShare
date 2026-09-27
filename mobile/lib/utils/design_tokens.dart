// ─────────────────────────────────────────────────────────────────────────────
//  SwiftShare design tokens
//
//  The ONE place where the app's sizes, spacing, corner radii, font sizes,
//  animation timings, opacities and brand colours are defined.
//
//  Screens and widgets must use these names instead of raw numbers:
//
//      padding: const EdgeInsets.all(AppSpacing.lg)        ✅
//      padding: const EdgeInsets.all(16)                   ❌
//
//      borderRadius: BorderRadius.circular(AppRadius.md)   ✅
//      color: context.palette.surface                      ✅  (theme colours)
//      color: Color(0xFF131A2E)                            ❌
//
//  Change a value here and the whole app follows.
//  Colours that change between light and dark mode live in `AppPalette`
//  (utils/theme.dart) and are read with `context.palette.<name>`.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';

/// Spacing scale (padding, margins, gaps). Based on a 4-point grid.
class AppSpacing {
  AppSpacing._();

  static const double none = 0;
  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
  static const double huge = 40;

  /// Side padding of every screen.
  static const double screen = xl;
}

/// Corner radius scale.
class AppRadius {
  AppRadius._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;

  /// Fully rounded ends (chips, avatars, pills).
  static const double pill = 999;
}

/// Font sizes. Pair with the styles in `AppTextStyles`.
class AppFontSize {
  AppFontSize._();

  static const double xxs = 11; // tiny labels, badges
  static const double xs = 12; // captions
  static const double sm = 14; // secondary body
  static const double md = 16; // body
  static const double lg = 18; // card titles
  static const double xl = 20; // section titles
  static const double xxl = 24; // page sub-headings
  static const double display = 28; // page titles
  static const double hero = 30; // splash wordmark
}

/// Icon sizes.
class AppIconSize {
  AppIconSize._();

  static const double xs = 14;
  static const double sm = 16;
  static const double md = 18;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 40;
  static const double hero = 64;
}

/// Fixed component sizes.
class AppSizes {
  AppSizes._();

  /// Height of primary / secondary buttons.
  static const double buttonHeight = 48;

  /// Round icon buttons (back, close...). Also the minimum touch target.
  static const double iconButton = 44;

  /// Square tile behind a list / settings icon.
  static const double iconTile = 40;

  /// Large icon tile (device cards).
  static const double iconTileLg = 56;

  /// Hero icon tile at the top of a card.
  static const double iconTileXl = 72;

  /// Hairline divider thickness.
  static const double divider = 1;
}

/// Opacity levels for tints and overlays (`color.withValues(alpha: ...)`).
class AppOpacity {
  AppOpacity._();

  static const double hairline = 0.04;
  static const double faint = 0.08;
  static const double subtle = 0.10;
  static const double soft = 0.15;
  static const double medium = 0.20;
  static const double quarter = 0.25;
  static const double strong = 0.30;
  static const double half = 0.50;
  static const double high = 0.60;
  static const double overlay = 0.70;
}

/// Animation timings.
class AppDurations {
  AppDurations._();

  /// Press feedback, tiny changes.
  static const Duration instant = Duration(milliseconds: 120);

  /// Quick fades.
  static const Duration fast = Duration(milliseconds: 150);

  /// Default for most UI transitions.
  static const Duration normal = Duration(milliseconds: 200);

  /// Tab / panel switches.
  static const Duration medium = Duration(milliseconds: 240);

  /// Larger, deliberate motion.
  static const Duration slow = Duration(milliseconds: 600);

  /// Looping "breathing" animations (splash logo pulse, card glow).
  static const Duration pulse = Duration(seconds: 2);

  /// Background gradient colour cycle.
  static const Duration ambient = Duration(seconds: 6);
}

/// Animation curves.
class AppCurves {
  AppCurves._();

  static const Curve standard = Curves.easeOutCubic;
  static const Curve enter = Curves.easeOutCubic;
  static const Curve exit = Curves.easeInCubic;
  static const Curve gentle = Curves.easeInOut;
}

/// Drop shadows. Use with a colour from the palette:
/// `boxShadow: AppShadows.card(context.palette.shadow)`.
class AppShadows {
  AppShadows._();

  static List<BoxShadow> card(Color color) => [
        BoxShadow(color: color, blurRadius: 24, offset: const Offset(0, 12)),
      ];

  static List<BoxShadow> raised(Color color) => [
        BoxShadow(color: color, blurRadius: 14, offset: const Offset(0, 7)),
      ];

  static List<BoxShadow> subtle(Color color) => [
        BoxShadow(color: color, blurRadius: 8, offset: const Offset(0, 3)),
      ];
}
