import Footer from "@/components/Footer";
import Navbar from "@/components/Navbar";
import SEO from "@/components/SEO";
import { FILE_SHARING_KEYWORDS } from "@/lib/site";
import { Link } from "react-router-dom";

const sections = [
  {
    heading: "Information we handle",
    body: "When you upload a file or paste text, SwiftShare stores the content so recipients can download it. We also handle the filename, file size and type, upload and expiry times, file code, and download count. You do not need to create an account or provide payment information.",
  },
  {
    heading: "File availability and expiry",
    body: "Links expire 24 hours after upload, or stop accepting downloads when the limit you selected is reached. Expiry prevents further access through the link; it does not remove copies that recipients have already downloaded. SwiftShare is temporary storage, so keep a copy of any file you need later.",
  },
  {
    heading: "Information you choose to share",
    body: "SwiftShare does not ask for your name, email address, or phone number to share a file. Files and pasted text may still contain personal information you choose to include. Review your content and filenames before uploading.",
  },
  {
    heading: "Sharing your data",
    body: "Anyone with a file's download link, QR code, or file code can access it while downloads remain available. These details can be forwarded. A download limit counts downloads, not individual people, and does not verify a recipient's identity.",
  },
  {
    heading: "Third-party services",
    body: "The SwiftShare application is hosted on infrastructure providers that may process requests in the course of normal operation. We do not use third-party ads that track you across sites.",
  },
  {
    heading: "Changes and contact",
    body: "We may update this policy as the service changes. The date on this page shows the latest revision. You can reach the project maintainer through the GitHub profile linked in the footer. Do not post private file links or personal information in public discussions.",
  },
];

const PrivacyPolicyPage = () => {
  return (
    <div className="min-h-screen">
      <SEO
        title="Privacy Policy"
        description="Read the SwiftShare privacy policy to learn how temporary file shares, uploads, and metadata are stored and expiring links are handled."
        path="/privacy-policy"
        keywords={[
          "privacy policy",
          "swiftshare privacy",
          "temporary file sharing privacy",
          "file sharing data policy",
          "what happens to uploaded files",
          ...FILE_SHARING_KEYWORDS,
        ]}
      />
      <Navbar />

      <main className="mx-auto max-w-3xl px-4 pt-10 pb-16">
        <p className="mb-3 text-base font-semibold uppercase tracking-wide text-primary">
          SwiftShare Policy
        </p>
        <h1 className="text-4xl font-bold text-foreground">Privacy Policy</h1>
        <p className="mt-3 text-sm text-muted-foreground">Last updated: September 18, 2026</p>
        <p className="mt-6 leading-7 text-muted-foreground">
          SwiftShare provides free, temporary file sharing with expiring links. This page explains
          what happens to the files you upload and the limited data involved in sharing them. Read
          the <Link to="/terms" className="font-medium text-primary hover:underline">Terms of Service</Link>{" "}
          for the rules that govern use of the service.
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

export default PrivacyPolicyPage;
