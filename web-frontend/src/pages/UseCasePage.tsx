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
        key={useCase.path}
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
                {useCase.detailTitle}
              </h2>
              <p className="mt-3 leading-7 text-muted-foreground">
                {useCase.detail}
              </p>
            </section>

            <section>
              <h2 className="text-2xl font-bold text-foreground">{useCase.tipTitle}</h2>
              <p className="mt-3 leading-7 text-muted-foreground">
                {useCase.tip}
              </p>
            </section>

            <section>
              <h2 className="text-2xl font-bold text-foreground">How long is my file available?</h2>
              <p className="mt-3 leading-7 text-muted-foreground">
                Each file can be up to {formatFileSize(MAX_UPLOAD_BYTES)}. Choose 1 to 10 total
                downloads before uploading. The link expires after 24 hours, or when the download
                limit is reached, whichever comes first.
              </p>
              <p className="mt-3 leading-7 text-muted-foreground">
                Anyone with the link or file code can download while it is available. Repeat
                downloads count toward the limit, so share only with your intended recipients
                and keep your own copy.
              </p>
            </section>
          </article>

          <aside className="border-t border-border pt-5 lg:border-l lg:border-t-0 lg:pl-5 lg:pt-0">
            <h2 className="text-xl font-semibold text-foreground">Also sharing something else?</h2>
            <div className="mt-4 space-y-2">
              {useCases
                .filter((item) => item.path !== useCase.path)
                .map((item) => (
                  <Link
                    key={item.path}
                    to={item.path}
                    className="block py-2 text-sm font-medium text-foreground hover:text-primary hover:underline"
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
