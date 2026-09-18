import Footer from "@/components/Footer";
import Navbar from "@/components/Navbar";
import SEO from "@/components/SEO";
import { FILE_SHARING_KEYWORDS, formatFileSize, MAX_UPLOAD_BYTES } from "@/lib/site";
import { Link } from "react-router-dom";

const sections = [
  {
    heading: "Using the service",
    body: "By using SwiftShare you agree to use it only for lawful purposes. Do not upload content that is illegal, infringing, malicious, or designed to harm other users or systems. Files are temporary and expire after 24 hours by design.",
  },
  {
    heading: "Upload limits",
    body: `You can upload one file up to ${formatFileSize(MAX_UPLOAD_BYTES)} at a time and choose a total limit of 1 to 10 downloads. Repeat downloads count toward this limit. Links expire 24 hours after upload or when their download limit is reached. Keep your own copy of files you need to retain.`,
  },
  {
    heading: "No warranty",
    body: "The service is provided \"as is\" without warranties of any kind. We do not guarantee availability, upload success, or that a file will remain downloadable for the full 24 hours if the download limit is reached first.",
  },
  {
    heading: "Limitation of liability",
    body: "SwiftShare is not liable for damages arising from the use or inability to use the service, including lost files, interrupted transfers, or reliance on temporary share links.",
  },
  {
    heading: "Privacy of uploads",
    body: "Anyone with your download link, QR code, or file code can download while the link is active and downloads remain. Share these details only with intended recipients. Link expiry does not delete copies already downloaded. See the Privacy Policy for details on how uploads are handled.",
  },
  {
    heading: "Changes to these terms",
    body: "We may update these terms as the service evolves. Continued use of SwiftShare after changes are published counts as acceptance of the revised terms.",
  },
];

const TermsPage = () => {
  return (
    <div className="min-h-screen">
      <SEO
        title="Terms of Service"
        description="Read the SwiftShare terms of service covering acceptable use, upload limits, temporary links, and liability for free file sharing."
        path="/terms"
        keywords={[
          "terms of service",
          "terms of use",
          "file sharing terms",
          "acceptable use policy",
          "swiftshare terms",
          ...FILE_SHARING_KEYWORDS,
        ]}
      />
      <Navbar />

      <main className="mx-auto max-w-3xl px-4 pt-10 pb-16">
        <p className="mb-3 text-base font-semibold uppercase tracking-wide text-primary">
          SwiftShare Policy
        </p>
        <h1 className="text-4xl font-bold text-foreground">Terms of Service</h1>
        <p className="mt-3 text-sm text-muted-foreground">Last updated: September 18, 2026</p>
        <p className="mt-6 leading-7 text-muted-foreground">
          These terms govern your use of SwiftShare, the free temporary file sharing service. By
          uploading or downloading files you agree to the terms below. For information about your
          data, read the{" "}
          <Link to="/privacy-policy" className="font-medium text-primary hover:underline">
            Privacy Policy
          </Link>
          .
        </p>

        <div className="mt-10 space-y-8">
          {sections.map((section) => (
            <section key={section.heading}>
              <h2 className="text-2xl font-bold text-foreground">{section.heading}</h2>
              <p className="mt-3 leading-7 text-muted-foreground">{section.body}</p>
            </section>
          ))}
        </div>
      </main>

      <Footer />
    </div>
  );
};

export default TermsPage;
