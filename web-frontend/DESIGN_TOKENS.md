# SwiftShare design tokens (web)

Every colour, radius, shadow and timing is defined **once** and used **by name**.
The colours are the same as the mobile app (`mobile/lib/utils/theme.dart`).

| File | Holds |
|---|---|
| `src/index.css` | The values: `:root` (light) and `.dark` (dark), plus a few reusable component classes |
| `tailwind.config.ts` | Maps each value to a Tailwind class name |

## Use names, never raw colours

```tsx
<div className="card-surface p-6">                  ✅
<p className="text-muted-foreground">                ✅
<span className="text-success">Uploaded</span>       ✅

<div className="rounded-xl border bg-white p-6">     ❌  breaks dark mode
<p className="text-gray-400">                        ❌
<span className="text-[#059669]">                    ❌
```

## Colour tokens

| Class | Use for |
|---|---|
| `bg-background` / `text-foreground` | Page and main text |
| `bg-card` / `text-card-foreground` | Cards, panels |
| `text-body` | Long text inside cards |
| `text-muted-foreground` | Secondary text |
| `text-subtle-foreground` | Hints, captions |
| `bg-muted` | Quiet fills (code chips, skeletons) |
| `bg-primary` / `text-primary-foreground` | Main buttons, links |
| `bg-accent` / `text-accent-foreground` | Soft brand tint (hovers, selected rows) |
| `text-success` · `text-warning` · `text-info` · `text-destructive` | Status (add `/10`, `/30` for tinted backgrounds and borders) |
| `border-border` · `border-input` · `ring-ring` | Lines, inputs, focus |
| `text-wordmark` / `text-wordmark-accent` | "Swift" / "Share" in the logo |
| `bg-footer` · `text-footer-foreground` · `text-footer-muted` | Footer (dark band in both themes) |
| `bg-qr` | Behind QR images: always white so they scan |

## Other tokens

| Class | Value |
|---|---|
| `rounded-lg` / `rounded-md` / `rounded-sm` | `--radius` (12px) and steps below |
| `shadow-sm` / `shadow-card` / `shadow-raised` | Elevation levels |
| `duration-fast` / `duration-normal` / `duration-slow` | 150 / 200 / 300 ms |
| `ease-standard` | Default easing |
| `animate-fade-in-up` | Entrance animation |

## Ready-made component classes (in `index.css`)

| Class | What it is |
|---|---|
| `card-surface` | Standard bordered card |
| `panel` | Large elevated card (upload / access boxes) |
| `code-chip` | Inline code / share code |
| `alert-error`, `alert-success` | Status messages |

## Dark mode

- `next-themes` adds `class="dark"` to `<html>`; the `.dark` block in `index.css` swaps every value.
- Default is the visitor's system setting; the sun/moon button in the navbar overrides it (saved in `localStorage`).
- A tiny script in `index.html` applies the theme before the first paint, so there's no white flash.

## Adding or changing a colour

1. Add or edit the variable in **both** `:root` and `.dark` in `src/index.css`.
2. If it's new, map it in `tailwind.config.ts` → `colors`.
3. Use it by name. Run `npm run check:tokens` before committing.
