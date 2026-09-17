import { Share2 } from "lucide-react";
import { Link } from "react-router-dom";

const Navbar = () => {
  return (
    <nav className="sticky top-0 z-50 border-b border-border bg-white/90 backdrop-blur-md">
      <div className="mx-auto flex h-16 max-w-7xl items-center justify-between px-4 sm:px-6 lg:px-8">
        <Link to="/" className="flex items-center gap-2">
          <div className="flex h-8 w-8 items-center justify-center rounded-lg bg-primary">
            <Share2 className="h-5 w-5 text-white" />
          </div>
          <span className="text-2xl font-bold text-foreground">SwiftShare</span>
        </Link>

        <div className="hidden items-center gap-6 md:flex">
          <Link to="/share-files" className="text-sm font-medium text-foreground hover:text-primary">
            Share files
          </Link>
          <Link to="/share-text" className="text-sm font-medium text-foreground hover:text-primary">
            Share text
          </Link>
          <Link to="/large-file-transfer" className="text-sm font-medium text-foreground hover:text-primary">
            Large files
          </Link>
          <a href="/#features" className="text-sm font-medium text-foreground hover:text-primary">
            Features
          </a>
        </div>

        <div className="flex items-center gap-3">
          <Link
            to="/access"
            className="rounded-lg bg-primary px-4 py-2 text-sm font-semibold text-primary-foreground"
          >
            Access file
          </Link>
          <a
            href="#quick-upload"
            className="rounded-lg bg-primary px-4 py-2 text-sm font-semibold text-primary-foreground"
          >
            Upload
          </a>
        </div>
      </div>
    </nav>
  );
};

export default Navbar;

