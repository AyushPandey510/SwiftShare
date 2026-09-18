import { Link2, MousePointerClick, Upload } from "lucide-react";

const steps = [
  {
    icon: MousePointerClick,
    title: "Choose your download limit",
    description: "Allow 1 to 10 downloads in total. Repeat downloads count, too.",
  },
  {
    icon: Upload,
    title: "Upload a file or paste text",
    description: "Send a file up to 250 MB, or turn your notes into a downloadable text file.",
  },
  {
    icon: Link2,
    title: "Send the link",
    description: "Share the download link, QR code, or file code. Your recipient needs no account.",
  },
];

const HowItWorks = () => {
  return (
    <section id="how-it-works" className="px-4 py-16">
      <div className="mx-auto max-w-6xl">
        <div className="mb-10 max-w-3xl">
          <h2 className="text-3xl font-bold text-foreground md:text-4xl">
            How SwiftShare works
          </h2>
          <p className="mt-3 text-muted-foreground">
            Three steps from your device to theirs.
          </p>
        </div>

        <div className="grid gap-5 md:grid-cols-3">
          {steps.map((step, index) => (
            <div key={step.title} className="rounded-xl border border-border bg-white p-6">
              <div className="mb-5 flex items-center gap-3">
                <span className="flex h-8 w-8 items-center justify-center rounded-full bg-primary text-sm font-bold text-primary-foreground">
                  {index + 1}
                </span>
                <step.icon className="h-6 w-6 text-primary" />
              </div>
              <h3 className="text-xl font-semibold text-foreground">{step.title}</h3>
              <p className="mt-2 text-sm leading-6 text-muted-foreground">{step.description}</p>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
};

export default HowItWorks;
