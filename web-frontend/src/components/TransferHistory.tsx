import { FileText, Image, File, CheckCircle2, XCircle } from "lucide-react";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";

const transfers = [
  {
    name: "project_proposal.pdf",
    size: "2.4 MB",
    time: "2 minutes ago",
    status: "completed",
    icon: FileText,
  },
  {
    name: "vacation_photos.zip",
    size: "15.7 MB",
    time: "1 hour ago",
    status: "completed",
    icon: Image,
  },
  {
    name: "meeting_notes.docx",
    size: "856 KB",
    time: "3 hours ago",
    status: "failed",
    icon: File,
  },
];

const TransferHistory = () => {
  return (
    <section className="py-20 px-4 bg-secondary/30">
      <div className="max-w-5xl mx-auto">
        <div className="text-center mb-12">
          <h2 className="text-4xl md:text-5xl font-bold text-foreground mb-4">
            Transfer History
          </h2>
          <p className="text-xl text-muted-foreground">
            Recent Activity
          </p>
          <p className="text-muted-foreground">
            Track your file sharing history and statistics
          </p>
        </div>

        <Card className="border-2">
          <CardHeader>
            <CardTitle className="text-2xl">Transfer Summary</CardTitle>
          </CardHeader>
          <CardContent>
            <Tabs defaultValue="recent" className="w-full">
              <TabsList className="grid w-full grid-cols-2">
                <TabsTrigger value="recent">Recent</TabsTrigger>
                <TabsTrigger value="stats">Stats</TabsTrigger>
              </TabsList>
              <TabsContent value="recent" className="space-y-4 mt-6">
                {transfers.map((transfer, index) => (
                  <div 
                    key={index}
                    className="flex items-center justify-between p-4 bg-secondary/50 rounded-xl hover:bg-secondary transition-colors"
                  >
                    <div className="flex items-center gap-4">
                      <div className="w-12 h-12 rounded-xl bg-primary/10 flex items-center justify-center">
                        <transfer.icon className="w-6 h-6 text-primary" />
                      </div>
                      <div>
                        <p className="font-semibold text-foreground">{transfer.name}</p>
                        <p className="text-sm text-muted-foreground">
                          {transfer.size} • {transfer.time}
                        </p>
                      </div>
                    </div>
                    <div>
                      {transfer.status === "completed" ? (
                        <div className="flex items-center gap-2 text-green-600">
                          <CheckCircle2 className="w-5 h-5" />
                          <span className="text-sm font-medium">completed</span>
                        </div>
                      ) : (
                        <div className="flex items-center gap-2 text-red-600">
                          <XCircle className="w-5 h-5" />
                          <span className="text-sm font-medium">failed</span>
                        </div>
                      )}
                    </div>
                  </div>
                ))}
              </TabsContent>
              <TabsContent value="stats" className="mt-6">
                <div className="grid grid-cols-3 gap-4">
                  <div className="p-6 bg-secondary/50 rounded-xl text-center">
                    <p className="text-3xl font-bold text-primary mb-2">24</p>
                    <p className="text-sm text-muted-foreground">Total Transfers</p>
                  </div>
                  <div className="p-6 bg-secondary/50 rounded-xl text-center">
                    <p className="text-3xl font-bold text-green-600 mb-2">156 MB</p>
                    <p className="text-sm text-muted-foreground">Data Shared</p>
                  </div>
                  <div className="p-6 bg-secondary/50 rounded-xl text-center">
                    <p className="text-3xl font-bold text-blue-600 mb-2">92%</p>
                    <p className="text-sm text-muted-foreground">Success Rate</p>
                  </div>
                </div>
              </TabsContent>
            </Tabs>
          </CardContent>
        </Card>
      </div>
    </section>
  );
};

export default TransferHistory;
