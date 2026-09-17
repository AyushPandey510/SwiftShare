import Footer from "@/components/Footer";
import Navbar from "@/components/Navbar";
import QuickUpload from "@/components/QuickUpload";
import SEO from "@/components/SEO";
import {
  Breadcrumb,
  BreadcrumbItem,
  BreadcrumbLink,
  BreadcrumbList,
  BreadcrumbPage,
  BreadcrumbSeparator,
} from "@/components/ui/breadcrumb";
import { MAX_UPLOAD_BYTES, formatFileSize, SITE_URL, useCases } from "@/lib/site";
import { Link, Navigate, useLocation } from "react-router-dom";

const UseCasePage = () => {
  const location = useLocation();
  const useCase = useCases.find((item) => item.path === location.pathname);

  if (!useCase) {
    return <Navigate to="/" replace />;
  }

  const defaultMode = useCase.path === "/share-text" || useCase.path === "/share-json" ? "text" : "file";

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
        name: useCase.title,
        item: `${SITE_URL}${useCase.path}`,
      },
    ],
  };

  return (
    <div className="min-h-screen">
      <SEO
        title={useCase.title}
        description={useCase.description}
        path={useCase.path}
        keywords={useCase.keywords}
        structuredData={[breadcrumbData]}
      />
      <Navbar />
      <QuickUpload
        compact
        defaultMode={defaultMode}
        title={useCase.h1}
        description={useCase.description}
      />

      <main className="px-4 pb-16">
        <div className="mx-auto max-w-6xl">
          <Breadcrumb className="mb-6 pt-4">
            <BreadcrumbList>
              <BreadcrumbItem>
                <BreadcrumbLink asChild>
                  <Link to="/">Home</Link>
                </BreadcrumbLink>
              </BreadcrumbItem>
              <BreadcrumbSeparator />
              <BreadcrumbItem>
                <BreadcrumbPage>{useCase.title}</BreadcrumbPage>
              </BreadcrumbItem>
            </BreadcrumbList>
          </Breadcrumb>
          <div className="grid gap-8 lg:grid-cols-[1fr_320px]">
          <article className="space-y-8">
            <section>
              <h2 className="text-3xl font-bold text-foreground">
                When to use this SwiftShare page
              </h2>
              <p className="mt-3 leading-7 text-muted-foreground">
                Use this page when you need a quick temporary handoff instead of a permanent cloud
                folder. Upload the file, pick how many downloads are allowed, and send the generated
                link to the people who need it.
              </p>
            </section>

            <section>
              <h2 className="text-2xl font-bold text-foreground">Current limits</h2>
              <p className="mt-3 leading-7 text-muted-foreground">
                The application accepts files up to {formatFileSize(MAX_UPLOAD_BYTES)} because the
                backend is configured with the same limit. For consistently large public traffic, the
                next infrastructure step is object storage such as S3-compatible storage plus
                resumable uploads.
              </p>
            </section>

            <section>
              <h2 className="text-2xl font-bold text-foreground">Related search terms</h2>
              <div className="mt-4 flex flex-wrap gap-2">
                {useCase.keywords.slice(0, 14).map((keyword) => (
                  <span key={keyword} className="rounded-full bg-secondary px-3 py-1 text-sm text-muted-foreground">
                    {keyword}
                  </span>
                ))}
              </div>
            </section>
          </article>

          <aside className="rounded-xl border border-border bg-secondary/40 p-5">
            <h2 className="text-xl font-semibold text-foreground">More sharing pages</h2>
            <div className="mt-4 space-y-2">
              {useCases
                .filter((item) => item.path !== useCase.path)
                .map((item) => (
                  <Link
                    key={item.path}
                    to={item.path}
                    className="block rounded-lg bg-white px-3 py-2 text-sm font-medium text-foreground hover:text-primary"
                  >
                    {item.title}
                  </Link>
                ))}
            </div>
          </aside>
        </div>
      </div>
      </main>
      <Footer />
    </div>
  );
};

export default UseCasePage;

