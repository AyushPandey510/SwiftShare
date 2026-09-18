import Navbar from "@/components/Navbar";
import QuickUpload from "@/components/QuickUpload";
import FeaturesSection from "@/components/FeaturesSection";
import HowItWorks from "@/components/HowItWorks";
import Footer from "@/components/Footer";
import SEO from "@/components/SEO";
import {
  Accordion,
  AccordionContent,
  AccordionItem,
  AccordionTrigger,
} from "@/components/ui/accordion";
import { FILE_SHARING_KEYWORDS, formatFileSize, MAX_UPLOAD_BYTES, useCases } from "@/lib/site";
import { Link } from "react-router-dom";

const faqs = [
  {
    question: "Is SwiftShare free to use?",
    answer:
      "Yes. You can upload files, share pasted text, and download shared files for free. Neither you nor your recipient needs an account.",
  },
  {
    question: "What is the maximum file size I can share?",
    answer:
      `You can share one file up to ${formatFileSize(MAX_UPLOAD_BYTES)} per upload. To send several files together, put them in a ZIP archive that fits within this limit.`,
  },
  {
    question: "How does the download limit work?",
    answer:
      "Choose 1 to 10 total downloads before uploading. Each download uses one allowance, including repeat downloads by the same person. A download that starts but is interrupted can also count. The link expires when the limit is reached or 24 hours after upload, whichever comes first.",
  },
  {
    question: "Do people need to sign up to download a shared file?",
    answer:
      "No. Recipients can open the temporary link or scan the QR code to download the file without creating an account.",
  },
  {
    question: "Who can access a shared file?",
    answer:
      "Anyone with the link, QR code, or file code can download it while it is available. The download limit does not identify individual recipients. Share these details only with the people you want to receive the file.",
  },
  {
    question: "What happens to text I paste?",
    answer:
      "Your text becomes a downloadable file with the filename you choose. Recipients can open it in a text editor. The same file size, download limit, and expiry apply as for uploaded files.",
  },
  {
    question: "Can I recover a file after its link expires?",
    answer:
      "An expired link cannot be used to download the file. Keep your original copy, or ask the sender to upload it again for a new link. Files already downloaded stay on the recipient's device.",
  },
  {
    question: "What kinds of files can I share?",
    answer:
      "You can share APK files, JSON, PDF documents, ZIP archives, images, videos, and other files, or paste text such as notes, code snippets, and logs.",
  },
];

const faqStructuredData = {
  "@type": "FAQPage",
  mainEntity: faqs.map((faq) => ({
    "@type": "Question",
    name: faq.question,
    acceptedAnswer: {
      "@type": "Answer",
      text: faq.answer,
    },
  })),
};

const Index = () => {
  return (
    <div className="min-h-screen">
      <SEO
        title="Free file sharing with expiring links"
        description="Share files up to 250 MB or paste text to create a download link. Free, no signup, with 1 to 10 downloads and a 24-hour expiry."
        keywords={[
          "free file sharing",
          "share files online",
          "upload files for free",
          "no signup file sharing",
          ...FILE_SHARING_KEYWORDS,
        ]}
        structuredData={[faqStructuredData]}
      />
      <Navbar />
      <QuickUpload />

      <section className="px-4 py-16">
        <div className="mx-auto max-w-6xl">
          <div className="mb-8 max-w-3xl">
            <h2 className="text-3xl font-bold text-foreground md:text-4xl">
              What do you need to send?
            </h2>
            <p className="mt-3 text-muted-foreground">
              From a few lines of text to a project archive, share the file your recipient needs.
            </p>
          </div>
          <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-3">
            {useCases.map((useCase) => (
              <Link
                key={useCase.path}
                to={useCase.path}
                className="rounded-xl border border-border bg-white p-5 transition-colors hover:border-primary"
              >
                <h3 className="text-xl font-semibold text-foreground">{useCase.title}</h3>
                <p className="mt-2 text-sm text-muted-foreground">{useCase.description}</p>
              </Link>
            ))}
          </div>
        </div>
      </section>

      <FeaturesSection />
      <HowItWorks />

      <section className="px-4 py-16">
        <div className="mx-auto max-w-4xl">
          <div className="mb-8 max-w-3xl">
            <h2 className="text-3xl font-bold text-foreground md:text-4xl">
              Frequently asked questions
            </h2>
            <p className="mt-3 text-muted-foreground">
              File sizes, download limits, and what happens after you share.
            </p>
          </div>
          <Accordion type="single" collapsible className="rounded-xl border border-border bg-white px-4">
            {faqs.map((faq, index) => (
              <AccordionItem key={faq.question} value={`faq-${index}`}>
                <AccordionTrigger className="text-left text-base font-semibold text-foreground">
                  {faq.question}
                </AccordionTrigger>
                <AccordionContent className="text-muted-foreground">
                  {faq.answer}
                </AccordionContent>
              </AccordionItem>
            ))}
          </Accordion>
        </div>
      </section>

      <Footer />
    </div>
  );
};

export default Index;
