import { Button } from "@/components/ui/button";
import { Download } from "lucide-react";

const HeroSection = () => {
  const scrollToUpload = () => {
    document.getElementById("quick-upload")?.scrollIntoView({ behavior: "smooth" });
  };

  return (
    <section className="relative pt-32 pb-20 px-4 overflow-hidden">
      {/* Floating background cards */}
      <div className="absolute inset-0 pointer-events-none">
        <div className="absolute top-20 left-10 w-64 h-48 gradient-card-purple rounded-3xl opacity-20 animate-float" style={{ animationDelay: "0s" }} />
        <div className="absolute top-40 right-20 w-80 h-64 gradient-card-blue rounded-3xl opacity-20 animate-float" style={{ animationDelay: "1s" }} />
        <div className="absolute bottom-32 left-1/4 w-72 h-56 gradient-card-pink rounded-3xl opacity-20 animate-float" style={{ animationDelay: "2s" }} />
      </div>

      <div className="relative z-10 max-w-7xl mx-auto">
        <div className="text-center mb-8">
          <div className="inline-block px-4 py-2 bg-secondary rounded-full text-sm font-medium text-muted-foreground mb-6">
            Trusted by 10,000+ users worldwide
          </div>
          <h1 className="text-6xl md:text-7xl font-bold text-foreground mb-6">
            Share Files<br />
            <span className="text-primary">Instantly</span>
          </h1>
          <p className="text-xl text-muted-foreground max-w-2xl mx-auto mb-8">
            Upload files and get a shareable link with QR code. No registration required.<br />
            Fast, secure, and completely free for basic sharing.
          </p>
          <div className="flex flex-col sm:flex-row gap-4 justify-center">
            <Button size="lg" className="btn-modern text-lg" onClick={scrollToUpload}>
              Start Sharing Now
            </Button>
            <Button
              size="lg"
              variant="outline"
              className="text-lg border-2"
              onClick={() => document.getElementById("actions")?.scrollIntoView({ behavior: "smooth" })}
            >
              <Download className="w-5 h-5 mr-2" />
              Download App
            </Button>
          </div>
        </div>
      </div>
    </section>
  );
};

export default HeroSection;
