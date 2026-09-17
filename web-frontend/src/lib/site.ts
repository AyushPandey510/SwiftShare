export const SITE_URL = "https://swift-share-tau.vercel.app";
export const MAX_UPLOAD_BYTES = 250 * 1024 * 1024;

export const formatFileSize = (bytes: number) => {
  if (bytes === 0) return "0 B";

  const units = ["B", "KB", "MB", "GB"];
  const unitIndex = Math.min(
    Math.floor(Math.log(bytes) / Math.log(1024)),
    units.length - 1,
  );

  const value = bytes / 1024 ** unitIndex;
  const formatted = unitIndex === 0 || Number.isInteger(value)
    ? value.toFixed(0)
    : value.toFixed(1);

  return `${formatted} ${units[unitIndex]}`;
};

export const FILE_SHARING_KEYWORDS = [
  "file sharing",
  "share files online",
  "send files",
  "upload files online",
  "file transfer",
  "free file sharing",
  "share files with link",
  "transfer files for free",
  "share files without signup",
  "online file sharing",
  "share documents online",
  "share photos and videos",
  "temporary file sharing",
  "expiring file links",
  "secure file sharing",
  "download files online",
  "file sharing website",
  "send large files",
];

export const useCases = [
  {
    path: "/share-files",
    title: "Share files online",
    shortTitle: "Files",
    description:
      "Upload a file, choose how many downloads are allowed, and share a private link that expires automatically.",
    h1: "Share files online with an expiring download link",
    keywords: [
      "share files online",
      "send files",
      "upload and share files",
      ...FILE_SHARING_KEYWORDS,
      "share files",
      "file share",
      "online file sharing",
      "share files with link",
    ],
  },
  {
    path: "/share-text",
    title: "Share copied text",
    shortTitle: "Text",
    description:
      "Paste notes, snippets, commands, JSON, logs, or copied text and turn it into a downloadable share link.",
    h1: "Paste text and share it as a file",
    keywords: [
      "share text online",
      "paste and share text",
      "share notes",
      "share code snippets",
      "share logs online",
      "share copied text",
      "text sharing tool",
      "pastebin alternative",
      "share text with link",
      "send text files",
      ...FILE_SHARING_KEYWORDS,
    ],
  },
  {
    path: "/share-apk",
    title: "Share APK files",
    shortTitle: "APK",
    description:
      "Send Android APK builds to testers or teammates with a simple download link and controlled download count.",
    h1: "Share APK files with testers",
    keywords: [
      "share apk",
      "send apk file",
      "apk upload",
      "share apk with link",
      "upload apk online",
      "send apk to testers",
      "apk download link",
      "share android apps",
      "apk file transfer",
      "share apk file online",
      "android apk sharing",
      "apk share link",
      ...FILE_SHARING_KEYWORDS,
    ],
  },
  {
    path: "/share-json",
    title: "Share JSON files",
    shortTitle: "JSON",
    description:
      "Upload JSON files or paste JSON text for quick sharing during debugging, API testing, and handoffs.",
    h1: "Share JSON files and pasted JSON",
    keywords: [
      "share json",
      "json file sharing",
      "paste json",
      "share json online",
      "send json files",
      "upload json file",
      "share json with developers",
      "json debugging",
      "api test json sharing",
      "share json data",
      "json paste tool",
      ...FILE_SHARING_KEYWORDS,
    ],
  },
  {
    path: "/large-file-transfer",
    title: `Large file transfer up to ${formatFileSize(MAX_UPLOAD_BYTES)}`,
    shortTitle: "Large Files",
    description:
      `Share larger files up to the current ${formatFileSize(MAX_UPLOAD_BYTES)} application limit. Production hosting may need object storage for heavy traffic.`,
    h1: `Large file transfer up to ${formatFileSize(MAX_UPLOAD_BYTES)}`,
    keywords: [
      "large file transfer",
      "send large files",
      "250 mb file share",
      "upload large files",
      "transfer big files",
      "share large files online",
      "free large file transfer",
      "send big files for free",
      "large file sharing website",
      "upload files up to 250 mb",
      "share large apk files",
      ...FILE_SHARING_KEYWORDS,
    ],
  },
  {
    path: "/share-pdf",
    title: "Share PDF files",
    shortTitle: "PDF",
    description:
      "Upload PDF documents and share them through controlled links. This page is for sharing PDFs, not editing or converting them yet.",
    h1: "Share PDF files with a simple link",
    keywords: [
      "share pdf",
      "send pdf",
      "pdf file sharing",
      "share pdf online",
      "upload pdf file",
      "share pdf documents",
      "pdf share link",
      "send pdf for free",
      "share pdf with link",
      "share pdf files online",
      ...FILE_SHARING_KEYWORDS,
    ],
  },
  {
    path: "/share-video",
    title: "Share video files",
    shortTitle: "Video",
    description:
      "Upload MP4, MOV, MKV, or other video files and send a temporary download link that expires after 24 hours.",
    h1: "Share video files with a download link",
    keywords: [
      "share video files",
      "send video online",
      "share videos with link",
      "upload video files",
      "share mp4 online",
      "send video file free",
      "share video clips",
      "video file transfer",
      "share movies and clips",
      "video share link",
      ...FILE_SHARING_KEYWORDS,
    ],
  },
  {
    path: "/share-audio",
    title: "Share audio & music files",
    shortTitle: "Audio",
    description:
      "Share MP3, WAV, and other audio tracks or recordings with a temporary link and a controlled download count.",
    h1: "Share audio and music files online",
    keywords: [
      "share audio files",
      "send audio online",
      "share music files",
      "upload mp3",
      "share songs with link",
      "audio file transfer",
      "share music tracks",
      "share voice recordings",
      "send audio file free",
      "mp3 share link",
      ...FILE_SHARING_KEYWORDS,
    ],
  },
  {
    path: "/share-images",
    title: "Share images & photos",
    shortTitle: "Images",
    description:
      "Upload JPG, PNG, WebP, and other image files and share them through an expiring download link with a QR code.",
    h1: "Share images and photos with a link",
    keywords: [
      "share images online",
      "send photos",
      "share pictures with link",
      "upload images",
      "share photos online",
      "image file sharing",
      "share jpg and png",
      "send photos for free",
      "photo share link",
      "image transfer",
      ...FILE_SHARING_KEYWORDS,
    ],
  },
  {
    path: "/share-zip",
    title: "Share ZIP & compressed files",
    shortTitle: "ZIP",
    description:
      "Upload ZIP archives and compressed folders, then send a temporary link that expires automatically after 24 hours.",
    h1: "Share ZIP and compressed files with a link",
    keywords: [
      "share zip files",
      "send zip archive",
      "upload compressed files",
      "zip file sharing",
      "share archives online",
      "send zip folder",
      "share zip online",
      "compressed file transfer",
      "zip share link",
      "send zip files free",
      ...FILE_SHARING_KEYWORDS,
    ],
  },
  {
    path: "/share-documents",
    title: "Share document files",
    shortTitle: "Docs",
    description:
      "Share Word, Excel, PowerPoint, and other document files with a temporary download link and controlled access.",
    h1: "Share Word, Excel, and document files",
    keywords: [
      "share documents online",
      "send word documents",
      "share excel files",
      "upload documents",
      "share files with link",
      "document sharing",
      "share ppt files",
      "send docs for free",
      "document transfer",
      "share documents with link",
      ...FILE_SHARING_KEYWORDS,
    ],
  },
] as const;

