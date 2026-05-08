import Navbar from "@/components/Navbar";
import HeroSection from "@/components/HeroSection";
import ActionCards from "@/components/ActionCards";
import QuickUpload from "@/components/QuickUpload";
import FeaturesSection from "@/components/FeaturesSection";
import HowItWorks from "@/components/HowItWorks";
import TransferHistory from "@/components/TransferHistory";
import NetworkStatus from "@/components/NetworkStatus";
import Footer from "@/components/Footer";

const Index = () => {
  return (
    <div className="min-h-screen">
      <Navbar />
      <HeroSection />
      <ActionCards />
      <QuickUpload />
      <FeaturesSection />
      <HowItWorks />
      <TransferHistory />
      <NetworkStatus />
      <Footer />
    </div>
  );
};

export default Index;
