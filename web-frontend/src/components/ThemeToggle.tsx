import { Moon, Sun } from "lucide-react";
import { useEffect, useState } from "react";
import { useTheme } from "next-themes";

/** Light / dark switch. Default is the system setting (see App.tsx). */
const ThemeToggle = () => {
  const { resolvedTheme, setTheme } = useTheme();
  // The real theme is only known in the browser; avoid a wrong first icon.
  const [mounted, setMounted] = useState(false);
  useEffect(() => setMounted(true), []);

  const isDark = mounted && resolvedTheme === "dark";
  const label = isDark ? "Switch to light mode" : "Switch to dark mode";

  return (
    <button
      type="button"
      onClick={() => setTheme(isDark ? "light" : "dark")}
      aria-label={label}
      title={label}
      className="flex h-11 w-11 items-center justify-center rounded-lg border border-border bg-card text-muted-foreground transition-colors duration-normal hover:text-foreground"
    >
      {isDark ? <Sun className="h-5 w-5" aria-hidden="true" /> : <Moon className="h-5 w-5" aria-hidden="true" />}
    </button>
  );
};

export default ThemeToggle;
