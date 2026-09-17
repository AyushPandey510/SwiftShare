import { useEffect } from "react";
import { SITE_URL } from "@/lib/site";

type SEOProps = {
  title: string;
  description: string;
  path?: string;
  keywords?: readonly string[];
  image?: string;
  structuredData?: Array<Record<string, unknown>>;
};

const upsertMeta = (selector: string, attribute: "name" | "property", key: string, content: string) => {
  let tag = document.head.querySelector<HTMLMetaElement>(selector);

  if (!tag) {
    tag = document.createElement("meta");
    tag.setAttribute(attribute, key);
    document.head.appendChild(tag);
  }

  tag.setAttribute("content", content);
};

const SEO = ({
  title,
  description,
  path = "/",
  keywords,
  image = `${SITE_URL}/og-image.png`,
  structuredData,
}: SEOProps) => {
  useEffect(() => {
    const fullTitle = `${title} | SwiftShare`;
    const canonicalUrl = `${SITE_URL}${path}`;

    document.title = fullTitle;
    upsertMeta('meta[name="description"]', "name", "description", description);
    upsertMeta('meta[name="keywords"]', "name", "keywords", keywords?.join(", ") ?? "");
    upsertMeta('meta[property="og:title"]', "property", "og:title", fullTitle);
    upsertMeta('meta[property="og:description"]', "property", "og:description", description);
    upsertMeta('meta[property="og:url"]', "property", "og:url", canonicalUrl);
    upsertMeta('meta[property="og:image"]', "property", "og:image", image);
    upsertMeta('meta[name="twitter:title"]', "name", "twitter:title", fullTitle);
    upsertMeta('meta[name="twitter:description"]', "name", "twitter:description", description);
    upsertMeta('meta[name="twitter:image"]', "name", "twitter:image", image);

    let canonical = document.head.querySelector<HTMLLinkElement>('link[rel="canonical"]');
    if (!canonical) {
      canonical = document.createElement("link");
      canonical.rel = "canonical";
      document.head.appendChild(canonical);
    }
    canonical.href = canonicalUrl;

    const selector = 'script[data-seo-ld="true"]';
    document.head.querySelectorAll(selector).forEach((script) => script.remove());

    if (structuredData && structuredData.length > 0) {
      structuredData.forEach((data) => {
        const script = document.createElement("script");
        script.type = "application/ld+json";
        script.dataset.seoLd = "true";
        script.textContent = JSON.stringify({
          "@context": "https://schema.org",
          ...data,
        });
        document.head.appendChild(script);
      });
    }
  }, [description, image, keywords, path, structuredData, title]);

  return null;
};

export default SEO;