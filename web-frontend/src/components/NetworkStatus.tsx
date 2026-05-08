import { Wifi } from "lucide-react";

const NetworkStatus = () => {
  return (
    <div className="fixed bottom-8 right-8 z-40">
      <div className="bg-accent rounded-2xl shadow-2xl p-6 border-2 border-accent/80 transform rotate-1 hover:rotate-0 transition-transform cursor-pointer max-w-xs">
        <div className="flex items-center gap-3 mb-3">
          <Wifi className="w-6 h-6 text-foreground" />
          <span className="text-lg font-bold text-foreground">Network Status ✏️</span>
        </div>
        <div className="flex items-center gap-2 mb-2">
          <span className="text-3xl">🌐</span>
          <p className="text-sm font-medium text-foreground/90">
            "All devices connected!"
          </p>
        </div>
        <div className="inline-block px-3 py-1 bg-green-100 text-green-800 rounded-full text-xs font-semibold mt-2">
          Online
        </div>
      </div>
    </div>
  );
};

export default NetworkStatus;
