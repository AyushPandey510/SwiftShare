import { Clock, FileUp, Users } from "lucide-react";

const features = [
  {
    icon: FileUp,
    title: "Files and text, ready to send",
    description:
      "Send a document, photo, recording, or archive. Turn pasted notes and snippets into a downloadable file, too.",
  },
  {
    icon: Users,
    title: "Choose 1 to 10 downloads",
    description:
      "Set a total download limit for each upload. Once those downloads are used, the link stops accepting new downloads.",
  },
  {
    icon: Clock,
    title: "Share for the next 24 hours",
    description:
      "Links expire 24 hours after upload, or sooner if the download limit is reached. Keep your own copy for later.",
  },
];

const FeaturesSection = () => {
  return (
    <section id="features" className="bg-secondary/30 px-4 py-16">
      <div className="mx-auto max-w-6xl">
        <div className="mb-10 max-w-3xl">
          <h2 className="text-3xl font-bold text-foreground md:text-4xl">
            Easy to send. Easy to receive.
          </h2>
          <p className="mt-3 text-muted-foreground">
            No accounts or shared folders. Just a download link for the file you want to pass along.
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

      </div>
    </section>
  );
};

export default FeaturesSection;
