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
import { FILE_SHARING_KEYWORDS, useCases } from "@/lib/site";
import { Link } from "react-router-dom";

const languageHeadings = [
  ["English", "Share files online"],
  ["Hindi", "Online file share karein"],
  ["Spanish", "Compartir archivos en linea"],
  ["French", "Partager des fichiers en ligne"],
  ["German", "Dateien online teilen"],
  ["Portuguese", "Compartilhar arquivos online"],
];

const faqs = [
  {
    question: "Is SwiftShare free to use?",
    answer:
      "Yes, sharing files and pasted text with SwiftShare is completely free. There is no account or signup required, and every share link expires automatically after 24 hours.",
  },
  {
    question: "What is the maximum file size I can share?",
    answer:
      "You can currently upload files up to 250 MB. Larger uploads are possible for heavy production traffic once storage moves to object storage.",
  },
  {
    question: "How do I control who can download my file?",
    answer:
      "Before creating the share link, choose the allowed download count from 1 to 10 people. The link stops working once that limit is reached or after 24 hours, whichever comes first.",
  },
  {
    question: "Do people need to sign up to download a shared file?",
    answer:
      "No. Recipients can open the temporary link or scan the QR code to download the file without creating an account.",
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
        description="Upload files or paste text, choose 1 to 10 allowed downloads, and share an expiring SwiftShare link."
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
              File sharing pages for common jobs
            </h2>
            <p className="mt-3 text-muted-foreground">
              SwiftShare is being organized around real use cases so search engines and users can
              understand the exact job each page solves.
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

      <section className="bg-secondary/30 px-4 py-16">
        <div className="mx-auto max-w-6xl">
          <h2 className="text-3xl font-bold text-foreground">
            People search for file sharing in many languages
          </h2>
          <div className="mt-6 grid gap-3 sm:grid-cols-2 lg:grid-cols-3">
            {languageHeadings.map(([language, heading]) => (
              <div key={language} className="rounded-lg border border-border bg-white p-4">
                <p className="text-xs font-semibold uppercase tracking-wide text-primary">
                  {language}
                </p>
                <h3 className="mt-2 text-lg font-semibold text-foreground">{heading}</h3>
              </div>
            ))}
          </div>
        </div>
      </section>

      <section className="px-4 py-16">
        <div className="mx-auto max-w-4xl">
          <div className="mb-8 max-w-3xl">
            <h2 className="text-3xl font-bold text-foreground md:text-4xl">
              Frequently asked questions
            </h2>
            <p className="mt-3 text-muted-foreground">
              Quick answers about free file sharing, upload limits, download controls, and how
              SwiftShare links expire.
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
