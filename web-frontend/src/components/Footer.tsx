import { Github, Linkedin, Share2, Twitter } from "lucide-react";
import { Link } from "react-router-dom";
import { useCases, formatFileSize, MAX_UPLOAD_BYTES } from "@/lib/site";

const Footer = () => {
  return (
    <footer className="bg-foreground px-4 py-12 text-white">
      <div className="mx-auto max-w-7xl">
        <div className="grid gap-8 md:grid-cols-[1.3fr_1fr_1fr_1fr]">
          <div>
            <div className="mb-4 flex items-center gap-2">
              <div className="flex h-8 w-8 items-center justify-center rounded-lg bg-primary">
                <Share2 className="h-5 w-5 text-white" />
              </div>
              <span className="text-xl font-bold">SwiftShare</span>
            </div>
            <p className="max-w-md text-sm leading-6 text-gray-400">
              Temporary file sharing for quick handoffs. Upload a file or pasted text, limit access
              to 1-10 downloads, and share the generated link.
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
            <h2 className="mb-4 font-semibold">Use cases</h2>
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
            <h2 className="mb-4 font-semibold">Current limits</h2>
            <ul className="space-y-2 text-sm text-gray-400">
              <li>Maximum file size: {formatFileSize(MAX_UPLOAD_BYTES)}</li>
              <li>Allowed downloads: 1-10</li>
              <li>File expiry: 24 hours</li>
              <li>No permanent cloud storage</li>
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

