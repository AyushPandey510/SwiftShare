# SwiftShare design tokens (mobile)

All colours, spacing, sizes, corner radii, font sizes, opacities and animation
timings are defined **once** and used **by name** everywhere else.

| What | Where | Use it like |
|---|---|---|
| Theme colours (change in dark mode) | `lib/utils/theme.dart` → `AppPalette` | `context.palette.surface`, `context.palette.textPrimary` |
| Brand colours (same in both modes) | `lib/utils/theme.dart` → `AppColors` | `AppColors.primary`, `AppColors.success` |
| Spacing | `lib/utils/design_tokens.dart` → `AppSpacing` | `EdgeInsets.all(AppSpacing.lg)`, `SizedBox(height: AppSpacing.sm)` |
| Corner radius | `AppRadius` | `BorderRadius.circular(AppRadius.md)` |
| Font size | `AppFontSize` | `fontSize: AppFontSize.display` |
| Icon size | `AppIconSize` | `Icon(Icons.share, size: AppIconSize.lg)` |
| Component sizes | `AppSizes` | `height: AppSizes.buttonHeight` |
| Opacity | `AppOpacity` | `AppColors.primary.withValues(alpha: AppOpacity.subtle)` |
| Animation | `AppDurations`, `AppCurves` | `duration: AppDurations.normal, curve: AppCurves.standard` |
| Shadows | `AppShadows` | `boxShadow: AppShadows.card(context.palette.shadow)` |

Importing `utils/theme.dart` gives you all of the above.

## Scales

| Token | Value | Token | Value |
|---|---|---|---|
| `AppSpacing.xxs` | 2 | `AppRadius.xs` | 4 |
| `AppSpacing.xs` | 4 | `AppRadius.sm` | 8 |
| `AppSpacing.sm` | 8 | `AppRadius.md` | 12 |
| `AppSpacing.md` | 12 | `AppRadius.lg` | 16 |
| `AppSpacing.lg` | 16 | `AppRadius.xl` | 20 |
| `AppSpacing.xl` | 20 | `AppRadius.xxl` | 24 |
| `AppSpacing.xxl` | 24 | `AppRadius.pill` | 999 |
| `AppSpacing.xxxl` | 32 | | |
| `AppSpacing.huge` | 40 | | |

## Rules

1. **No hex colours in screens or widgets.** If a colour changes with the theme,
   add it to `AppPalette` (both `light` and `dark`). If it is a fixed brand
   colour, add it to `AppColors`.
2. **No raw spacing / radius / font-size numbers.** Pick the nearest token. If
   nothing fits, add a new token here instead of a one-off number.
3. **Changing the look = changing a token**, not hunting through screens.

`tool/check_design_tokens.sh` fails if a hard-coded `Color(0x...)` appears in
`lib/screens` or `lib/widgets`. Run it before committing (or in CI).
