import { Upload, Link2, Share2 } from "lucide-react";

const steps = [
  {
    number: "1",
    icon: Upload,
    title: "Upload Files",
    description: "Drag and drop your files or click to browse. Support for all file types up to 100MB.",
  },
  {
    number: "2",
    icon: Link2,
    title: "Get Share Link",
    description: "Receive a unique shareable link and QR code instantly after upload.",
  },
  {
    number: "3",
    icon: Share2,
    title: "Share Anywhere",
    description: "Send the link or scan the QR code. Recipients can download immediately.",
  },
];

const HowItWorks = () => {
  return (
    <section id="how-it-works" className="py-20 px-4">
      <div className="max-w-7xl mx-auto">
        <div className="text-center mb-16">
          <h2 className="text-sm font-semibold text-primary mb-2 uppercase tracking-wider">
            Simple Process
          </h2>
          <h3 className="text-4xl md:text-5xl font-bold text-foreground mb-4">
            How It Works
          </h3>
          <p className="text-xl text-muted-foreground">
            Sharing files has never been easier. Just follow these simple steps.
          </p>
        </div>

        <div className="grid md:grid-cols-3 gap-8">
          {steps.map((step, index) => (
            <div 
              key={index}
              className="relative"
            >
              <div className="feature-card text-center">
                <div className="absolute -top-4 left-1/2 -translate-x-1/2 w-12 h-12 bg-primary text-white rounded-full flex items-center justify-center text-xl font-bold">
                  {step.number}
                </div>
                <div className="w-16 h-16 rounded-2xl bg-primary/10 flex items-center justify-center mb-4 mx-auto mt-8">
                  <step.icon className="w-8 h-8 text-primary" />
                </div>
                <h3 className="text-xl font-semibold mb-3 text-foreground">
                  {step.title}
                </h3>
                <p className="text-muted-foreground leading-relaxed">
                  {step.description}
                </p>
              </div>
              {index < steps.length - 1 && (
                <div className="hidden md:block absolute top-1/2 right-0 transform translate-x-1/2 -translate-y-1/2">
                  <svg width="40" height="40" viewBox="0 0 40 40" fill="none" xmlns="http://www.w3.org/2000/svg">
                    <path d="M15 10L25 20L15 30" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" className="text-primary"/>
                  </svg>
                </div>
              )}
            </div>
          ))}
        </div>
      </div>
    </section>
  );
};

export default HowItWorks;
