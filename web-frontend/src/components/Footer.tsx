import { Github, Linkedin, Twitter } from "lucide-react";
import { Link } from "react-router-dom";
import { useCases, formatFileSize, MAX_UPLOAD_BYTES } from "@/lib/site";

const Footer = () => {
  return (
    <footer className="bg-foreground px-4 py-12 text-white">
      <div className="mx-auto max-w-7xl">
        <div className="grid gap-8 md:grid-cols-[1.3fr_1fr_1fr_1fr]">
          <div>
            <div className="mb-4 flex items-center gap-2">
              <img src="/logo-mark-dark.svg" alt="" width={40} height={40} className="h-10 w-10" />
              <span className="text-xl font-bold tracking-tight">
                <span className="text-[#E0E7FF]">Swift</span>
                <span className="text-[#818CF8]">Share</span>
              </span>
            </div>
            <p className="max-w-md text-sm leading-6 text-gray-400">
              Send a file. Share a link. Get on with your day.
              Free, temporary sharing for files and text, with no account needed.
            </p>
            <div className="mt-5 flex gap-3">
              <a href="https://x.com/AyushPande28353" target="_blank" rel="noopener noreferrer" className="flex h-10 w-10 items-center justify-center rounded-lg bg-white/10 hover:bg-primary" aria-label="X">
                <Twitter className="h-5 w-5" />
              </a>
              <a href="https://github.com/AyushPandey510" target="_blank" rel="noopener noreferrer" className="flex h-10 w-10 items-center justify-center rounded-lg bg-white/10 hover:bg-primary" aria-label="GitHub">
                <Github className="h-5 w-5" />
              </a>
              <a href="https://www.linkedin.com/in/ayush-pandey-097027242/" target="_blank" rel="noopener noreferrer" className="flex h-10 w-10 items-center justify-center rounded-lg bg-white/10 hover:bg-primary" aria-label="LinkedIn">
                <Linkedin className="h-5 w-5" />
              </a>
            </div>
          </div>

          <div>
            <h2 className="mb-4 font-semibold">Share with SwiftShare</h2>
            <ul className="space-y-2">
              {useCases.slice(0, 6).map((useCase) => (
                <li key={useCase.path}>
                  <Link to={useCase.path} className="text-sm text-gray-400 hover:text-white">
                    {useCase.title}
                  </Link>
                </li>
              ))}
            </ul>
          </div>

          <div>
            <h2 className="mb-4 font-semibold">Every share includes</h2>
            <ul className="space-y-2 text-sm text-gray-400">
              <li>Up to {formatFileSize(MAX_UPLOAD_BYTES)} per file</li>
              <li>Your choice of 1 to 10 total downloads</li>
              <li>A link that expires within 24 hours</li>
              <li>A QR code and file code</li>
            </ul>
          </div>

          <div>
            <h2 className="mb-4 font-semibold">Legal</h2>
            <ul className="space-y-2">
              <li>
                <Link to="/privacy-policy" className="text-sm text-gray-400 hover:text-white">
                  Privacy policy
                </Link>
              </li>
              <li>
                <Link to="/terms" className="text-sm text-gray-400 hover:text-white">
                  Terms of service
                </Link>
              </li>
              <li>
                <Link to="/access" className="text-sm text-gray-400 hover:text-white">
                  Access a shared file
                </Link>
              </li>
            </ul>
          </div>
        </div>

        <div className="mt-10 border-t border-white/10 pt-6 text-sm text-gray-400">
          © 2026 SwiftShare. Built for fast temporary sharing.
        </div>
      </div>
    </footer>
  );
};

export default Footer;
