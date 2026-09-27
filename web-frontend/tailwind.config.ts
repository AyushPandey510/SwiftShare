import type { Config } from "tailwindcss";
import tailwindcssAnimate from "tailwindcss-animate";

/**
 * SwiftShare Tailwind config.
 *
 * Every value here points at a CSS variable defined in src/index.css, so:
 *   - components use names: bg-card, text-muted-foreground, text-success, shadow-card
 *   - light / dark values live in ONE place (index.css :root and .dark)
 *   - opacity modifiers still work: bg-primary/10, border-success/30
 */
const token = (name: string) => `hsl(var(--${name}) / <alpha-value>)`;

export default {
  darkMode: ["class"],
  content: ["./index.html", "./src/**/*.{ts,tsx}"],
  prefix: "",
  theme: {
    container: {
      center: true,
      padding: "2rem",
      screens: {
        "2xl": "1400px",
      },
    },
    extend: {
      colors: {
        background: token("background"),
        foreground: token("foreground"),
        border: token("border"),
        input: token("input"),
        ring: token("ring"),

        body: token("body"),

        primary: { DEFAULT: token("primary"), foreground: token("primary-foreground") },
        secondary: { DEFAULT: token("secondary"), foreground: token("secondary-foreground") },
        accent: { DEFAULT: token("accent"), foreground: token("accent-foreground") },
        muted: { DEFAULT: token("muted"), foreground: token("muted-foreground") },
        subtle: { foreground: token("subtle-foreground") },
        card: { DEFAULT: token("card"), foreground: token("card-foreground") },
        popover: { DEFAULT: token("popover"), foreground: token("popover-foreground") },

        destructive: { DEFAULT: token("destructive"), foreground: token("destructive-foreground") },
        success: { DEFAULT: token("success"), foreground: token("success-foreground") },
        warning: { DEFAULT: token("warning"), foreground: token("warning-foreground") },
        info: { DEFAULT: token("info"), foreground: token("info-foreground") },

        wordmark: { DEFAULT: token("wordmark"), accent: token("wordmark-accent") },

        footer: {
          DEFAULT: token("footer"),
          foreground: token("footer-foreground"),
          muted: token("footer-muted"),
          wordmark: token("footer-wordmark"),
          "wordmark-accent": token("footer-wordmark-accent"),
        },

        qr: token("qr"),
      },
      fontFamily: {
        sans: ["var(--font-sans)"],
      },
      borderRadius: {
        lg: "var(--radius)",
        md: "calc(var(--radius) - 2px)",
        sm: "calc(var(--radius) - 4px)",
      },
      boxShadow: {
        sm: "var(--shadow-sm)",
        card: "var(--shadow-card)",
        raised: "var(--shadow-raised)",
      },
      transitionDuration: {
        fast: "var(--duration-fast)",
        normal: "var(--duration-normal)",
        slow: "var(--duration-slow)",
      },
      transitionTimingFunction: {
        standard: "var(--ease-standard)",
      },
      keyframes: {
        "accordion-down": {
          from: { height: "0" },
          to: { height: "var(--radix-accordion-content-height)" },
        },
        "accordion-up": {
          from: { height: "var(--radix-accordion-content-height)" },
          to: { height: "0" },
        },
        "fade-in-up": {
          from: { opacity: "0", transform: "translateY(12px)" },
          to: { opacity: "1", transform: "translateY(0)" },
        },
      },
      animation: {
        "accordion-down": "accordion-down var(--duration-normal) ease-out",
        "accordion-up": "accordion-up var(--duration-normal) ease-out",
        "fade-in-up": "fade-in-up var(--duration-slow) var(--ease-standard)",
      },
    },
  },
  plugins: [tailwindcssAnimate],
} satisfies Config;
