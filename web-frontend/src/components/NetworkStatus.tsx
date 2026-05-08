import { useEffect, useState } from "react";
import { Wifi } from "lucide-react";
import { checkBackendHealth, getApiBaseUrl } from "@/lib/api";

const NetworkStatus = () => {
  const [isOnline, setIsOnline] = useState<boolean | null>(null);

  useEffect(() => {
    let cancelled = false;

    const checkHealth = async () => {
      const healthy = await checkBackendHealth();
      if (!cancelled) {
        setIsOnline(healthy);
      }
    };

    checkHealth();
    const interval = window.setInterval(checkHealth, 30000);

    return () => {
      cancelled = true;
      window.clearInterval(interval);
    };
  }, []);

  const statusLabel = isOnline === null ? "Checking" : isOnline ? "Connected" : "Disconnected";
  const statusClass = isOnline
    ? "bg-green-100 text-green-800"
    : isOnline === false
      ? "bg-red-100 text-red-800"
      : "bg-yellow-100 text-yellow-800";

  return (
    <div className="fixed bottom-8 right-8 z-40">
      <button
        type="button"
        className="bg-accent rounded-2xl shadow-2xl p-6 border-2 border-accent/80 transform rotate-1 hover:rotate-0 transition-transform cursor-pointer max-w-xs text-left"
        onClick={() => window.open(`${getApiBaseUrl()}/health`, "_blank")}
      >
        <div className="flex items-center gap-3 mb-3">
          <Wifi className="w-6 h-6 text-foreground" />
          <span className="text-lg font-bold text-foreground">Backend Status</span>
        </div>
        <div className="flex items-center gap-2 mb-2">
          <p className="text-sm font-medium text-foreground/90">
            {getApiBaseUrl()}
          </p>
        </div>
        <div className={`inline-block px-3 py-1 rounded-full text-xs font-semibold mt-2 ${statusClass}`}>
          {statusLabel}
        </div>
      </button>
    </div>
  );
};

export default NetworkStatus;
