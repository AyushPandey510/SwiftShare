import { Zap, Shield, Smartphone } from "lucide-react";

const features = [
  {
    icon: Zap,
    title: "Lightning Fast",
    description: "Upload and share files in seconds with our optimized infrastructure and global CDN.",
  },
  {
    icon: Shield,
    title: "Secure & Private",
    description: "End-to-end encryption ensures your files stay private and secure during transfer.",
  },
  {
    icon: Smartphone,
    title: "Cross-Platform",
    description: "Works on any device - desktop, mobile, tablet. Access from anywhere, anytime.",
  },
];

const FeaturesSection = () => {
  return (
    <section id="features" className="py-20 px-4 bg-secondary/30">
      <div className="max-w-7xl mx-auto">
        <div className="text-center mb-16">
          <h2 className="text-sm font-semibold text-primary mb-2 uppercase tracking-wider">
            Powerful Features
          </h2>
          <h3 className="text-4xl md:text-5xl font-bold text-foreground mb-4">
            Why Choose SwiftShare?
          </h3>
          <p className="text-xl text-muted-foreground max-w-2xl mx-auto">
            Experience the fastest and most secure way to share files online
          </p>
        </div>

        <div className="grid md:grid-cols-3 gap-8">
          {features.map((feature, index) => (
            <div 
              key={index}
              className="feature-card text-center"
              style={{ animationDelay: `${index * 0.1}s` }}
            >
              <div className="w-16 h-16 rounded-2xl bg-primary/10 flex items-center justify-center mb-6 mx-auto">
                <feature.icon className="w-8 h-8 text-primary" />
              </div>
              <h3 className="text-2xl font-semibold mb-3 text-foreground">
                {feature.title}
              </h3>
              <p className="text-muted-foreground leading-relaxed">
                {feature.description}
              </p>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
};

export default FeaturesSection;
