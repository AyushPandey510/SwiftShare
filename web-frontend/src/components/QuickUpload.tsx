import { useState, useCallback } from "react";
import { Upload, CheckCircle, X, File } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Progress } from "@/components/ui/progress";
import { uploadFile } from "@/lib/api";
import { FileData, UploadProgress } from "@/types/file";
import { useToast } from "@/hooks/use-toast";

const QuickUpload = () => {
  const [isUploading, setIsUploading] = useState(false);
  const [uploadProgress, setUploadProgress] = useState<UploadProgress | null>(null);
  const [uploadedFile, setUploadedFile] = useState<FileData | null>(null);
  const [dragActive, setDragActive] = useState(false);
  const { toast } = useToast();

  const handleDrag = useCallback((e: React.DragEvent) => {
    e.preventDefault();
    e.stopPropagation();
    if (e.type === "dragenter" || e.type === "dragover") {
      setDragActive(true);
    } else if (e.type === "dragleave") {
      setDragActive(false);
    }
  }, []);

  const handleDrop = useCallback(async (e: React.DragEvent) => {
    e.preventDefault();
    e.stopPropagation();
    setDragActive(false);

    const files = Array.from(e.dataTransfer.files);
    if (files.length > 0) {
      await handleFileUpload(files[0]);
    }
  }, []);

  const handleFileSelect = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const files = e.target.files;
    if (files && files.length > 0) {
      await handleFileUpload(files[0]);
    }
  };

  const handleFileUpload = async (file: File) => {
    // Validate file size (100MB limit)
    if (file.size > 100 * 1024 * 1024) {
      toast({
        title: "File too large",
        description: "Maximum file size is 100MB",
        variant: "destructive",
      });
      return;
    }

    setIsUploading(true);
    setUploadProgress({ loaded: 0, total: file.size, percentage: 0 });

    try {
      const result = await uploadFile(file);

      if (result.success && result.data) {
        setUploadedFile(result.data);
        toast({
          title: "Upload successful!",
          description: `File "${file.name}" uploaded successfully`,
        });
      } else {
        toast({
          title: "Upload failed",
          description: result.error || "Unknown error occurred",
          variant: "destructive",
        });
      }
    } catch (error) {
      toast({
        title: "Upload failed",
        description: "An unexpected error occurred",
        variant: "destructive",
      });
    } finally {
      setIsUploading(false);
      setUploadProgress(null);
    }
  };

  const formatFileSize = (bytes: number) => {
    if (bytes === 0) return '0 Bytes';
    const k = 1024;
    const sizes = ['Bytes', 'KB', 'MB', 'GB'];
    const i = Math.floor(Math.log(bytes) / Math.log(k));
    return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
  };

  return (
    <section className="py-20 px-4">
      <div className="max-w-4xl mx-auto">
        <div className="text-center mb-12">
          <h2 className="text-3xl md:text-4xl font-bold text-foreground mb-4">
            Quick Upload
          </h2>
          <p className="text-lg text-muted-foreground">
            Upload files instantly and get shareable links
          </p>
        </div>

        {/* Upload Area */}
        <div
          className={`relative bg-white rounded-3xl border-2 border-dashed transition-all duration-300 cursor-pointer overflow-hidden ${
            dragActive
              ? "border-primary bg-primary/5 scale-105"
              : "border-border hover:border-primary/50 hover:bg-primary/5"
          } ${isUploading ? "pointer-events-none opacity-75" : ""}`}
          onDragEnter={handleDrag}
          onDragLeave={handleDrag}
          onDragOver={handleDrag}
          onDrop={handleDrop}
          onClick={() => !isUploading && document.getElementById('file-input')?.click()}
        >
          {/* Background Pattern */}
          <div className="absolute inset-0 bg-gradient-to-br from-primary/5 via-transparent to-secondary/5"></div>

          <div className="relative p-12 text-center">
            {isUploading ? (
              <div className="flex flex-col items-center gap-6">
                <div className="w-20 h-20 rounded-full bg-primary/10 flex items-center justify-center animate-pulse">
                  <Upload className="w-10 h-10 text-primary animate-bounce" />
                </div>
                <div className="w-full max-w-xs">
                  <Progress value={uploadProgress?.percentage || 0} className="h-3" />
                  <p className="text-sm text-muted-foreground mt-2">
                    {uploadProgress?.percentage.toFixed(1)}% uploaded
                  </p>
                </div>
              </div>
            ) : uploadedFile ? (
              <div className="flex flex-col items-center gap-6">
                <div className="w-20 h-20 rounded-full bg-green-100 flex items-center justify-center">
                  <CheckCircle className="w-10 h-10 text-green-600" />
                </div>
                <div className="text-center">
                  <h3 className="text-xl font-bold text-foreground mb-2">Upload Successful!</h3>
                  <div className="bg-secondary/50 rounded-lg p-4 mb-4">
                    <div className="flex items-center gap-3 mb-2">
                      <File className="w-5 h-5 text-primary" />
                      <span className="font-medium">{uploadedFile.filename}</span>
                    </div>
                    <p className="text-sm text-muted-foreground">
                      Size: {formatFileSize(uploadedFile.size)} • Code: {uploadedFile.code}
                    </p>
                  </div>
                  <div className="flex gap-3 justify-center">
                    <Button
                      variant="outline"
                      size="sm"
                      onClick={(e) => {
                        e.stopPropagation();
                        navigator.clipboard.writeText(uploadedFile.url);
                        toast({ title: "Link copied!", description: "Share link copied to clipboard" });
                      }}
                    >
                      Copy Link
                    </Button>
                    <Button
                      size="sm"
                      onClick={(e) => {
                        e.stopPropagation();
                        setUploadedFile(null);
                      }}
                    >
                      Upload Another
                    </Button>
                  </div>
                </div>
              </div>
            ) : (
              <div className="flex flex-col items-center gap-6">
                <div className="w-20 h-20 rounded-full bg-primary/10 flex items-center justify-center group-hover:bg-primary/20 transition-colors">
                  <Upload className="w-10 h-10 text-primary" />
                </div>
                <div>
                  <p className="text-xl font-semibold text-foreground mb-2">
                    Drop files here or click to browse
                  </p>
                  <p className="text-sm text-muted-foreground">
                    Supports images, videos, documents up to 100MB
                  </p>
                </div>
                <Button className="bg-gradient-to-r from-primary to-primary/80 hover:from-primary/90 hover:to-primary text-primary-foreground shadow-lg hover:shadow-xl transition-all duration-300">
                  Select Files
                </Button>
              </div>
            )}
          </div>

          {/* Hidden file input */}
          <input
            id="file-input"
            type="file"
            className="hidden"
            onChange={handleFileSelect}
            disabled={isUploading}
          />
        </div>

        {/* Trust Indicators */}
        <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mt-12">
          <div className="flex items-center justify-center gap-3 p-4 bg-secondary/30 rounded-xl border border-border/50">
            <CheckCircle className="w-5 h-5 text-green-600 flex-shrink-0" />
            <span className="text-sm font-medium text-foreground">No registration required</span>
          </div>
          <div className="flex items-center justify-center gap-3 p-4 bg-secondary/30 rounded-xl border border-border/50">
            <CheckCircle className="w-5 h-5 text-green-600 flex-shrink-0" />
            <span className="text-sm font-medium text-foreground">Files expire in 24 hours</span>
          </div>
          <div className="flex items-center justify-center gap-3 p-4 bg-secondary/30 rounded-xl border border-border/50">
            <CheckCircle className="w-5 h-5 text-green-600 flex-shrink-0" />
            <span className="text-sm font-medium text-foreground">Up to 100MB per file</span>
          </div>
        </div>
      </div>
    </section>
  );
};

export default QuickUpload;
