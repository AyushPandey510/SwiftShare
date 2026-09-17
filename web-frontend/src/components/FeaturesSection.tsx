import { Clock, FileUp, Users } from "lucide-react";

const features = [
  {
    icon: FileUp,
    title: "Upload files or pasted text",
    description:
      "Share APK, JSON, PDF, ZIP, media, documents, or pasted text from one upload panel.",
  },
  {
    icon: Users,
    title: "Choose 1 to 10 downloads",
    description:
      "Pick how many people can download the shared file. Unlimited public links are intentionally not offered.",
  },
  {
    icon: Clock,
    title: "Temporary links",
    description:
      "Shared files expire after 24 hours, keeping SwiftShare focused on quick handoffs instead of permanent storage.",
  },
];

const futureFeatures = [
  "QR access",
  "Mobile app distribution",
  "Web dashboard",
  "Public API access",
  "PDF editing or conversion tools",
];

const FeaturesSection = () => {
  return (
    <section id="features" className="bg-secondary/30 px-4 py-16">
      <div className="mx-auto max-w-6xl">
        <div className="mb-10 max-w-3xl">
          <h2 className="text-3xl font-bold text-foreground md:text-4xl">
            Features that work today
          </h2>
          <p className="mt-3 text-muted-foreground">
            The page now describes only the upload and sharing workflow that is currently wired to
            the backend.
          </p>
        </div>

        <div className="grid gap-5 md:grid-cols-3">
          {features.map((feature) => (
            <div key={feature.title} className="rounded-xl border border-border bg-white p-6">
              <div className="mb-4 flex h-11 w-11 items-center justify-center rounded-lg bg-primary/10">
                <feature.icon className="h-6 w-6 text-primary" />
              </div>
              <h3 className="text-xl font-semibold text-foreground">{feature.title}</h3>
              <p className="mt-2 text-sm leading-6 text-muted-foreground">{feature.description}</p>
            </div>
          ))}
        </div>

        <div className="mt-8 rounded-xl border border-dashed border-border bg-white p-5">
          <h3 className="text-lg font-semibold text-foreground">Parked for later</h3>
          <p className="mt-2 text-sm text-muted-foreground">
            These are intentionally not promoted as live features yet:
          </p>
          <div className="mt-4 flex flex-wrap gap-2">
            {futureFeatures.map((feature) => (
              <span key={feature} className="rounded-full bg-secondary px-3 py-1 text-sm text-muted-foreground">
                {feature}
              </span>
            ))}
          </div>
        </div>
      </div>
    </section>
  );
};

export default FeaturesSection;
