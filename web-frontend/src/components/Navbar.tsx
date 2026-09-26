import { Download, Upload } from "lucide-react";
import { Link } from "react-router-dom";

const Navbar = () => {
  return (
    <nav className="sticky top-0 z-50 border-b border-border bg-white/90 backdrop-blur-md">
      <div className="mx-auto flex min-h-16 max-w-7xl items-center justify-between gap-2 px-4 py-3 sm:gap-4 sm:px-6 lg:px-8">
        <Link to="/" className="flex min-w-0 items-center gap-2">
          <img src="/logo-mark.svg" alt="" width={40} height={40} className="h-10 w-10 shrink-0" />
          <span className="text-xl font-bold tracking-tight sm:text-2xl">
            <span className="text-[#1E1B4B]">Swift</span>
            <span className="text-[#4F46E5]">Share</span>
          </span>
        </Link>

        <div className="hidden items-center gap-6 lg:flex">
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

        <div className="flex shrink-0 items-center gap-2 sm:gap-3">
          <Link
            to="/access"
            aria-label="Get file"
            title="Get file"
            className="flex h-11 w-11 items-center justify-center gap-2 rounded-lg bg-primary text-sm font-semibold text-primary-foreground sm:w-auto sm:px-4"
          >
            <Download className="h-5 w-5 shrink-0" aria-hidden="true" />
            <span className="hidden sm:inline">Get file</span>
          </Link>
          <Link
            to="/#quick-upload"
            aria-label="Upload"
            title="Upload"
            className="flex h-11 w-11 items-center justify-center gap-2 rounded-lg bg-primary text-sm font-semibold text-primary-foreground sm:w-auto sm:px-4"
          >
            <Upload className="h-5 w-5 shrink-0" aria-hidden="true" />
            <span className="hidden sm:inline">Upload</span>
          </Link>
        </div>
      </div>
    </nav>
  );
};

export default Navbar;
