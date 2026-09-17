import { useCallback, useMemo, useState } from "react";
import { CheckCircle, ClipboardType, Download, File as FileIcon, Link2, Loader2, QrCode, Upload } from "lucide-react";
import { Button } from "@/components/ui/button";
import { getQRCode, uploadFile } from "@/lib/api";
import { copyToClipboard } from "@/lib/clipboard";
import { formatFileSize, MAX_UPLOAD_BYTES } from "@/lib/site";
import { FileData } from "@/types/file";
import { useToast } from "@/hooks/use-toast";

type UploadMode = "file" | "text";

type QuickUploadProps = {
  compact?: boolean;
  defaultMode?: UploadMode;
  title?: string;
  description?: string;
};

const downloadOptions = Array.from({ length: 10 }, (_, index) => index + 1);

const QuickUpload = ({
  compact = false,
  defaultMode = "file",
  title = "Upload and share a file now",
  description = "Choose a file or paste text, set the allowed download count, and get a share link.",
}: QuickUploadProps) => {
  const [mode, setMode] = useState<UploadMode>(defaultMode);
  const [isUploading, setIsUploading] = useState(false);
  const [uploadedFile, setUploadedFile] = useState<FileData | null>(null);
  const [qrUrl, setQrUrl] = useState<string | null>(null);
  const [dragActive, setDragActive] = useState(false);
  const [maxDownloads, setMaxDownloads] = useState(1);
  const [textValue, setTextValue] = useState("");
  const [textFilename, setTextFilename] = useState("swiftshare-note.txt");
  const { toast } = useToast();

  const limitLabel = useMemo(() => formatFileSize(MAX_UPLOAD_BYTES), []);

  const handleDrag = useCallback((event: React.DragEvent) => {
    event.preventDefault();
    event.stopPropagation();
    setDragActive(event.type === "dragenter" || event.type === "dragover");
  }, []);

  const uploadSelectedFile = useCallback(async (file: File) => {
    if (file.size > MAX_UPLOAD_BYTES) {
      toast({
        title: "File too large",
        description: `SwiftShare currently accepts files up to ${limitLabel}.`,
        variant: "destructive",
      });
      return;
    }

    setIsUploading(true);

    try {
      const result = await uploadFile(file, maxDownloads);

      if (result.success && result.data) {
        setQrUrl((previous) => {
          if (previous) URL.revokeObjectURL(previous);
          return null;
        });
        setUploadedFile(result.data);
        const url = await getQRCode(result.data.code);
        setQrUrl(url);
        toast({
          title: "Ready to share",
          description: `"${file.name}" has a download link and QR code.`,
        });
      } else {
        toast({
          title: "Upload failed",
          description: result.error || "The backend did not accept this upload.",
          variant: "destructive",
        });
      }
    } catch {
      toast({
        title: "Upload failed",
        description: "Please try again with a stable connection.",
        variant: "destructive",
      });
    } finally {
      setIsUploading(false);
    }
  }, [limitLabel, maxDownloads, toast]);

  const handleDrop = useCallback(
    async (event: React.DragEvent) => {
      event.preventDefault();
      event.stopPropagation();
      setDragActive(false);

      const files = Array.from(event.dataTransfer.files);
      if (files.length > 0) {
        await uploadSelectedFile(files[0]);
      }
    },
    [uploadSelectedFile],
  );

  const handleFileSelect = async (event: React.ChangeEvent<HTMLInputElement>) => {
    const file = event.target.files?.[0];
    if (file) {
      await uploadSelectedFile(file);
    }
    event.target.value = "";
  };

  const handleTextUpload = async () => {
    const trimmed = textValue.trim();
    if (!trimmed) {
      toast({
        title: "Nothing to share",
        description: "Paste text first, then create the share link.",
        variant: "destructive",
      });
      return;
    }

    const filename = textFilename.trim() || "swiftshare-note.txt";
    const file = new File([textValue], filename, { type: "text/plain" });
    await uploadSelectedFile(file);
  };

  const copyShareLink = async () => {
    if (!uploadedFile) return;
    const copied = await copyToClipboard(uploadedFile.url);
    toast(
      copied
        ? { title: "Link copied", description: "Share link copied to clipboard." }
        : {
            title: "Copy failed",
            description: "Select the link and copy it manually.",
            variant: "destructive",
          },
    );
  };

  const openFilePicker = () => {
    if (!isUploading) {
      document.getElementById("file-input")?.click();
    }
  };

  return (
    <section id="quick-upload" className={compact ? "py-10 px-4" : "pt-8 pb-16 px-4"}>
      <div className="mx-auto max-w-5xl">
        <div className="mb-8 text-center">
          <p className="mb-3 text-base font-semibold uppercase tracking-wide text-primary">
            SwiftShare
          </p>
          <h1 className="text-4xl font-bold text-foreground md:text-6xl">
            {title}
          </h1>
          <p className="mx-auto mt-4 max-w-3xl text-lg text-muted-foreground">
            {description}
          </p>
        </div>

        <div className="rounded-2xl border border-border bg-white shadow-xl">
          <div className="grid gap-3 border-b border-border bg-secondary/60 p-3 md:grid-cols-2">
            <button
              type="button"
              aria-pressed={mode === "file"}
              className={`relative flex items-center justify-between rounded-xl border px-5 py-4 text-left transition-all ${
                mode === "file"
                  ? "border-primary bg-primary text-primary-foreground shadow-md"
                  : "border-border bg-white text-foreground hover:border-primary/50"
              }`}
              onClick={() => setMode("file")}
            >
              <span className="flex items-center gap-3">
                <span
                  className={`flex h-10 w-10 items-center justify-center rounded-lg ${
                    mode === "file" ? "bg-white/15" : "bg-primary/10 text-primary"
                  }`}
                >
                  <Upload className="h-5 w-5" />
                </span>
                <span>
                  <span className="block text-base font-bold">File upload</span>
                  <span className={`block text-xs ${mode === "file" ? "text-white/80" : "text-muted-foreground"}`}>
                    APK, JSON, PDF, ZIP, media
                  </span>
                </span>
              </span>
              {mode === "file" && (
                <span className="rounded-full bg-white px-3 py-1 text-xs font-bold text-primary">
                  Active
                </span>
              )}
            </button>
            <button
              type="button"
              aria-pressed={mode === "text"}
              className={`relative flex items-center justify-between rounded-xl border px-5 py-4 text-left transition-all ${
                mode === "text"
                  ? "border-primary bg-primary text-primary-foreground shadow-md"
                  : "border-border bg-white text-foreground hover:border-primary/50"
              }`}
              onClick={() => setMode("text")}
            >
              <span className="flex items-center gap-3">
                <span
                  className={`flex h-10 w-10 items-center justify-center rounded-lg ${
                    mode === "text" ? "bg-white/15" : "bg-primary/10 text-primary"
                  }`}
                >
                  <ClipboardType className="h-5 w-5" />
                </span>
                <span>
                  <span className="block text-base font-bold">Paste text</span>
                  <span className={`block text-xs ${mode === "text" ? "text-white/80" : "text-muted-foreground"}`}>
                    Notes, logs, commands, snippets
                  </span>
                </span>
              </span>
              {mode === "text" && (
                <span className="rounded-full bg-white px-3 py-1 text-xs font-bold text-primary">
                  Active
                </span>
              )}
            </button>
          </div>

          <div className="grid gap-0 lg:grid-cols-[1fr_280px]">
            <div className="p-6 md:p-8">
              {uploadedFile ? (
                <div>
                  <div className="mb-4 flex items-center gap-2 text-green-700">
                    <CheckCircle className="h-6 w-6" />
                    <span className="text-lg font-semibold text-foreground">Share link ready</span>
                  </div>

                  <div className="rounded-xl border border-border bg-secondary/40 p-5">
                    <div className="flex justify-center">
                      {qrUrl ? (
                        <div className="flex flex-col items-center rounded-xl border border-green-200 bg-white p-4">
                          <img
                            src={qrUrl}
                            alt="QR code linking to the shared file"
                            className="h-40 w-40"
                          />
                          <p className="mt-3 flex items-center gap-1 text-sm font-medium text-green-700">
                            <QrCode className="h-4 w-4" />
                            Scan to open the share link
                          </p>
                        </div>
                      ) : (
                        <Button
                          variant="outline"
                          onClick={async () => {
                            if (!uploadedFile) return;
                            setQrUrl(await getQRCode(uploadedFile.code));
                          }}
                        >
                          <QrCode className="mr-2 h-4 w-4" />
                          Show QR code
                        </Button>
                      )}
                    </div>

                    <div className="mt-5 flex items-center gap-2 text-sm text-foreground">
                      <FileIcon className="h-4 w-4 text-primary" />
                      <span className="truncate font-medium">{uploadedFile.filename}</span>
                      <span className="ml-auto shrink-0 text-xs text-muted-foreground">
                        {formatFileSize(uploadedFile.size)}
                      </span>
                    </div>

                    <p className="mt-1 text-xs text-muted-foreground">
                      Code:{" "}
                      <code className="rounded bg-white px-1 py-0.5 font-mono text-xs text-foreground">
                        {uploadedFile.code}
                      </code>
                    </p>

                    <div className="mt-3 flex items-center gap-2 rounded-lg border border-border bg-white px-3 py-2">
                      <Link2 className="h-4 w-4 shrink-0 text-primary" />
                      <span className="truncate text-xs text-muted-foreground">{uploadedFile.url}</span>
                      <button
                        type="button"
                        onClick={copyShareLink}
                        className="ml-auto shrink-0 text-xs font-semibold text-primary hover:underline"
                      >
                        Copy
                      </button>
                    </div>

                    <div className="mt-4 grid gap-2 sm:grid-cols-2">
                      <a
                        href={uploadedFile.url}
                        target="_blank"
                        rel="noopener noreferrer"
                        className="flex w-full items-center justify-center rounded-md border border-border bg-white px-4 py-2 text-sm font-medium text-foreground hover:bg-secondary/50"
                      >
                        <Download className="mr-2 h-4 w-4" />
                        Open file
                      </a>
                      <Button
                        variant="outline"
                        onClick={() => {
                          setUploadedFile(null);
                          setQrUrl((previous) => {
                            if (previous) URL.revokeObjectURL(previous);
                            return null;
                          });
                        }}
                      >
                        Share another
                      </Button>
                    </div>
                  </div>
                </div>
              ) : mode === "file" ? (
                <div
                  role="button"
                  tabIndex={0}
                  aria-label="Upload a file by browsing or dropping it here"
                  aria-disabled={isUploading}
                  className={`relative cursor-pointer rounded-xl border-2 border-dashed p-10 text-center transition-all outline-none focus-visible:ring-2 focus-visible:ring-ring ${
                    dragActive
                      ? "border-primary bg-primary/5"
                      : "border-border hover:border-primary/60 hover:bg-secondary/40"
                  } ${isUploading ? "pointer-events-none opacity-70" : ""}`}
                  onDragEnter={handleDrag}
                  onDragLeave={handleDrag}
                  onDragOver={handleDrag}
                  onDrop={handleDrop}
                  onClick={openFilePicker}
                  onKeyDown={(event) => {
                    if (event.key === "Enter" || event.key === " ") {
                      event.preventDefault();
                      openFilePicker();
                    }
                  }}
                >
                  <input
                    id="file-input"
                    type="file"
                    className="hidden"
                    onChange={handleFileSelect}
                    disabled={isUploading}
                  />
                  <div className="mx-auto mb-5 flex h-16 w-16 items-center justify-center rounded-2xl bg-primary/10">
                    {isUploading ? (
                      <Loader2 className="h-8 w-8 animate-spin text-primary" />
                    ) : (
                      <Upload className="h-8 w-8 text-primary" />
                    )}
                  </div>
                  <p className="text-xl font-semibold text-foreground">
                    Drop a file here or click to browse
                  </p>
                  <p className="mt-2 text-sm text-muted-foreground">
                    Supports APK, JSON, PDF, ZIP, images, videos, and documents up to {limitLabel}.
                  </p>
                </div>
              ) : (
                <div className="space-y-4">
                  <textarea
                    value={textValue}
                    onChange={(event) => setTextValue(event.target.value)}
                    aria-label="Text to share"
                    className="min-h-[220px] w-full rounded-xl border border-input bg-background p-4 text-sm outline-none ring-offset-background focus-visible:ring-2 focus-visible:ring-ring"
                    placeholder="Paste copied text, JSON, logs, notes, commands, or anything you want to share..."
                  />
                  <input
                    value={textFilename}
                    onChange={(event) => setTextFilename(event.target.value)}
                    aria-label="File name for the shared text"
                    className="w-full rounded-lg border border-input bg-background px-3 py-2 text-sm outline-none focus-visible:ring-2 focus-visible:ring-ring"
                    placeholder="Filename, for example debug-log.txt"
                  />
                  <Button onClick={handleTextUpload} disabled={isUploading} className="w-full">
                    {isUploading ? (
                      <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                    ) : (
                      <Link2 className="mr-2 h-4 w-4" />
                    )}
                    Create text share link
                  </Button>
                </div>
              )}
            </div>

            <aside className="border-t border-border bg-secondary/50 p-6 lg:border-l lg:border-t-0">
              <label className="text-sm font-semibold text-foreground" htmlFor="max-downloads">
                Allowed downloads
              </label>
              <select
                id="max-downloads"
                value={maxDownloads}
                onChange={(event) => setMaxDownloads(Number(event.target.value))}
                className="mt-2 w-full rounded-lg border border-input bg-white px-3 py-2 text-sm"
              >
                {downloadOptions.map((count) => (
                  <option key={count} value={count}>
                    {count} {count === 1 ? "person" : "people"}
                  </option>
                ))}
              </select>

              <div className="mt-6 space-y-3 text-sm text-muted-foreground">
                <p>Files expire after 24 hours.</p>
                <p>Download access is limited to your selected count.</p>
                <p>
                  The app limit is {limitLabel}; heavy production traffic should move file storage
                  to object storage.
                </p>
              </div>
            </aside>
          </div>
        </div>
      </div>
    </section>
  );
};

export default QuickUpload;
