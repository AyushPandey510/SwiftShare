import Footer from "@/components/Footer";
import Navbar from "@/components/Navbar";
import SEO from "@/components/SEO";
import { Button } from "@/components/ui/button";
import {
  Breadcrumb,
  BreadcrumbItem,
  BreadcrumbLink,
  BreadcrumbList,
  BreadcrumbPage,
  BreadcrumbSeparator,
} from "@/components/ui/breadcrumb";
import { getFileByCode, getQRCode } from "@/lib/api";
import { formatFileSize, FILE_SHARING_KEYWORDS, SITE_URL } from "@/lib/site";
import { FileData } from "@/types/file";
import {
  AlertCircle as AlertIcon,
  Calendar,
  CheckCircle,
  Download,
  File,
  Link2,
  Loader2,
  QrCode,
  Search,
  Users,
} from "lucide-react";
import { FormEvent, useEffect, useState } from "react";
import { Link, useSearchParams } from "react-router-dom";

const AccessFilePage = () => {
  const [searchParams] = useSearchParams();
  const [code, setCode] = useState(searchParams.get("code") ?? "");
  const [isLoading, setIsLoading] = useState(false);
  const [file, setFile] = useState<FileData | null>(null);
  const [qrUrl, setQrUrl] = useState<string | null>(null);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const initialCode = searchParams.get("code");
    if (initialCode) {
      setCode(initialCode);
      lookupFile(initialCode);
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  const lookupFile = async (rawCode?: string) => {
    const trimmed = (rawCode ?? code).trim().toUpperCase();
    if (!trimmed) return;

    setIsLoading(true);
    setFile(null);
    setQrUrl((previous) => {
      if (previous) URL.revokeObjectURL(previous);
      return null;
    });
    setError(null);

    const result = await getFileByCode(trimmed);
    setIsLoading(false);

    if (result.success && result.data && result.data.url) {
      setFile(result.data);
      const qr = await getQRCode(trimmed);
      setQrUrl(qr);
    } else {
      setError(result.error || "Could not find a file with that code.");
    }
  };

  const handleSubmit = (event: FormEvent) => {
    event.preventDefault();
    lookupFile();
  };

  const downloadsLeft = file ? Math.max(file.maxDownloads - file.downloadCount, 0) : 0;

  const breadcrumbData = {
    "@type": "BreadcrumbList",
    itemListElement: [
      {
        "@type": "ListItem",
        position: 1,
        name: "Home",
        item: `${SITE_URL}/`,
      },
      {
        "@type": "ListItem",
        position: 2,
        name: "Access a shared file",
        item: `${SITE_URL}/access`,
      },
    ],
  };

  return (
    <div className="min-h-screen">
      <SEO
        title="Access a shared file"
        description="Enter a SwiftShare file code to view file details and download the shared file before it expires."
        path="/access"
        keywords={[
          "access shared file",
          "download shared file",
          "file download link",
          "retrieve shared file",
          "download file online",
          "file access code",
          "get file from code",
          ...FILE_SHARING_KEYWORDS,
        ]}
        structuredData={[breadcrumbData]}
      />
      <Navbar />

      <main className="mx-auto max-w-3xl px-4 pt-8 pb-16">
        <Breadcrumb className="mb-4">
          <BreadcrumbList>
            <BreadcrumbItem>
              <BreadcrumbLink asChild>
                <Link to="/">Home</Link>
              </BreadcrumbLink>
            </BreadcrumbItem>
            <BreadcrumbSeparator />
            <BreadcrumbItem>
              <BreadcrumbPage>Access a shared file</BreadcrumbPage>
            </BreadcrumbItem>
          </BreadcrumbList>
        </Breadcrumb>
        <div className="mb-8 text-center">
          <p className="mb-3 text-base font-semibold uppercase tracking-wide text-primary">
            SwiftShare
          </p>
          <h1 className="text-4xl font-bold text-foreground md:text-5xl">Access a shared file</h1>
          <p className="mx-auto mt-4 max-w-xl text-lg text-muted-foreground">
            Enter the file code from the share link to download the file before it expires.
          </p>
        </div>

        <div className="rounded-2xl border border-border bg-white p-6 shadow-xl md:p-8">
          <form onSubmit={handleSubmit} className="flex flex-col gap-3 sm:flex-row">
            <div className="relative flex-1">
              <Search className="pointer-events-none absolute top-1/2 left-3 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
              <input
                value={code}
                onChange={(event) => setCode(event.target.value.toUpperCase())}
                placeholder="Enter 6-character code, e.g. ABC123"
                maxLength={6}
                className="w-full rounded-lg border border-input bg-background py-2 pl-9 pr-3 text-sm uppercase tracking-wide outline-none focus-visible:ring-2 focus-visible:ring-ring"
              />
            </div>
            <Button type="submit" disabled={isLoading || code.trim().length === 0}>
              {isLoading ? <Loader2 className="mr-2 h-4 w-4 animate-spin" /> : <Link2 className="mr-2 h-4 w-4" />}
              Access file
            </Button>
          </form>

          {error && (
            <div className="mt-4 flex items-center gap-2 rounded-lg border border-red-200 bg-red-50 px-4 py-3 text-sm text-red-700">
              <AlertIcon className="h-4 w-4 shrink-0" />
              {error}
            </div>
          )}

          {file && (
            <div className="mt-6 rounded-xl border border-border bg-secondary/40 p-5">
              <div className="mb-4 flex items-center gap-2 text-green-700">
                <CheckCircle className="h-5 w-5" />
                <span className="font-semibold text-foreground">File found</span>
              </div>

              <div className="flex items-center gap-3 border-b border-border pb-4">
                <div className="flex h-12 w-12 shrink-0 items-center justify-center rounded-xl bg-primary/10">
                  <File className="h-6 w-6 text-primary" />
                </div>
                <div className="min-w-0">
                  <p className="truncate font-semibold text-foreground">{file.filename}</p>
                  <p className="text-sm text-muted-foreground">
                    {formatFileSize(file.size)} • Code:{" "}
                    <code className="rounded bg-white px-1 py-0.5 font-mono text-xs text-foreground">
                      {file.code}
                    </code>
                  </p>
                </div>
              </div>

              <div className="mt-4 grid gap-3 text-sm text-muted-foreground sm:grid-cols-3">
                <div className="flex items-center gap-2">
                  <Users className="h-4 w-4 shrink-0 text-primary" />
                  <span>
                    {downloadsLeft} download{downloadsLeft === 1 ? "" : "s"} left
                  </span>
                </div>
                <div className="flex items-center gap-2">
                  <Calendar className="h-4 w-4 shrink-0 text-primary" />
                  <span>Expires {new Date(file.expiresAt).toLocaleString()}</span>
                </div>
                <div className="flex items-center gap-2">
                  <Download className="h-4 w-4 shrink-0 text-primary" />
                  <span>{formatFileSize(file.size)}</span>
                </div>
              </div>

              {qrUrl && (
                <div className="mt-5 flex justify-center">
                  <div className="flex flex-col items-center rounded-xl border border-border bg-white p-4">
                    <img src={qrUrl} alt="QR code for downloading the shared file" className="h-32 w-32" />
                    <p className="mt-2 flex items-center gap-1 text-xs font-medium text-muted-foreground">
                      <QrCode className="h-3.5 w-3.5" />
                      Scan to download
                    </p>
                  </div>
                </div>
              )}

              <a
                href={file.url}
                className="mt-5 flex w-full items-center justify-center rounded-lg bg-primary px-4 py-3 text-sm font-semibold text-primary-foreground hover:bg-primary/90"
              >
                <Download className="mr-2 h-4 w-4" />
                Download file
              </a>
            </div>
          )}
        </div>
      </main>

      <Footer />
    </div>
  );
};

export default AccessFilePage;