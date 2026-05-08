import { Upload, Download, Smartphone, QrCode, LayoutDashboard, Code } from "lucide-react";
import { Card, CardContent } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { getApiBaseUrl } from "@/lib/api";

const actions = [
  {
    icon: Upload,
    title: "Upload Files",
    description: "Share files instantly with anyone",
    action: "Start Uploading",
    color: "bg-blue-50",
    iconColor: "text-blue-600",
  },
  {
    icon: Download,
    title: "Access Files",
    description: "Download files using access code",
    action: "Enter Code",
    color: "bg-green-50",
    iconColor: "text-green-600",
  },
  {
    icon: Smartphone,
    title: "Mobile App",
    description: "Download for iOS & Android",
    action: "Download App",
    color: "bg-purple-50",
    iconColor: "text-purple-600",
  },
  {
    icon: QrCode,
    title: "QR Access",
    description: "Scan QR codes to access files",
    action: "Scan QR",
    color: "bg-pink-50",
    iconColor: "text-pink-600",
  },
  {
    icon: LayoutDashboard,
    title: "Web Dashboard",
    description: "Manage your files online",
    action: "Open Dashboard",
    color: "bg-orange-50",
    iconColor: "text-orange-600",
  },
  {
    icon: Code,
    title: "API Access",
    description: "Integrate with your applications",
    action: "View Docs",
    color: "bg-indigo-50",
    iconColor: "text-indigo-600",
  },
];

const ActionCards = () => {
  const handleAction = (title: string) => {
    if (title === "Upload Files") {
      document.getElementById("quick-upload")?.scrollIntoView({ behavior: "smooth" });
      return;
    }

    if (title === "Access Files" || title === "QR Access") {
      const code = window.prompt("Enter your SwiftShare file code");
      if (code?.trim()) {
        window.open(`${getApiBaseUrl()}/api/download/${encodeURIComponent(code.trim())}`, "_blank");
      }
      return;
    }

    if (title === "API Access") {
      window.open(`${getApiBaseUrl()}/health`, "_blank");
      return;
    }

    document.getElementById("quick-upload")?.scrollIntoView({ behavior: "smooth" });
  };

  return (
    <section id="actions" className="py-20 px-4 bg-secondary/30">
      <div className="max-w-7xl mx-auto">
        <div className="text-center mb-12">
          <h2 className="text-4xl md:text-5xl font-bold text-foreground mb-4">
            Choose Your Action
          </h2>
          <p className="text-xl text-muted-foreground">
            Select what you want to do with SwiftShare
          </p>
        </div>

        <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-6">
          {actions.map((action, index) => (
            <Card 
              key={index} 
              className="feature-card border-2 hover:border-primary cursor-pointer"
              style={{ animationDelay: `${index * 0.1}s` }}
            >
              <CardContent className="p-6">
                <div className={`w-14 h-14 ${action.color} rounded-2xl flex items-center justify-center mb-4`}>
                  <action.icon className={`w-7 h-7 ${action.iconColor}`} />
                </div>
                <h3 className="text-xl font-semibold mb-2 text-foreground">
                  {action.title}
                </h3>
                <p className="text-muted-foreground mb-4">
                  {action.description}
                </p>
                <Button
                  variant="outline"
                  className="w-full"
                  onClick={() => handleAction(action.title)}
                >
                  {action.action}
                </Button>
              </CardContent>
            </Card>
          ))}
        </div>
      </div>
    </section>
  );
};

export default ActionCards;
