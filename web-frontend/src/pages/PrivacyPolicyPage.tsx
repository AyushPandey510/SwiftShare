import Footer from "@/components/Footer";
import Navbar from "@/components/Navbar";
import SEO from "@/components/SEO";
import { FILE_SHARING_KEYWORDS } from "@/lib/site";
import { Link } from "react-router-dom";

const sections = [
  {
    heading: "Information we handle",
    body: "SwiftShare is a temporary file sharing tool. When you upload a file or paste text, we store the file contents and basic metadata (file name, size, a short access code, download date, and expiry time) in order to serve the share link back to you and to recipients. We do not require accounts, profiles, or payment information.",
  },
  {
    heading: "How long we keep files",
    body: "Uploaded files expire automatically after 24 hours and are removed from temporary storage. Downloads are also limited to the count you choose (between 1 and 10) before you create the share link. Data is not retained for longer than needed to deliver the service.",
  },
  {
    heading: "What we do not collect",
    body: "We do not collect names, email addresses, phone numbers, or browsing profiles. We do not sell personal data. Because files are temporary and self-expiring, no permanent cloud storage of your uploads takes place.",
  },
  {
    heading: "Sharing your data",
    body: "File contents are only shared through the link and access code you generate. Anyone who receives your share link can download the file until the link expires or the download limit is reached, so only share links with people you intend to receive the file.",
  },
  {
    heading: "Third-party services",
    body: "The SwiftShare application is hosted on infrastructure providers that may process requests in the course of normal operation. We do not use third-party ads that track you across sites.",
  },
  {
    heading: "Changes and contact",
    body: "This policy may be updated from time to time. The effective date below reflects the most recent revision. Questions can be sent through the project repositories linked in the SwiftShare footer.",
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
        <p className="mt-3 text-sm text-muted-foreground">Last updated: September 17, 2026</p>
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