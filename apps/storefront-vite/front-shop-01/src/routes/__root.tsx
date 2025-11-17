import { createRootRoute, Outlet, Link } from '@tanstack/react-router';
import { TanStackRouterDevtools } from '@tanstack/router-devtools';
import { ShoppingCart } from 'lucide-react';
import { Button } from '@entrepreneur-os/storefront/ui';
import '../styles/globals.css';

export const Route = createRootRoute({
  component: RootComponent,
});

function RootComponent() {
  return (
    <div className="min-h-screen flex flex-col">
      <header className="border-b bg-white sticky top-0 z-50">
        <div className="container mx-auto px-4 h-16 flex items-center justify-between">
          <Link to="/" className="text-2xl font-bold">
            {import.meta.env.VITE_SITE_NAME || 'Store'}
          </Link>

          <nav className="flex items-center gap-6">
            <Link
              to="/"
              className="text-sm font-medium hover:text-primary transition-colors"
            >
              Home
            </Link>
            <Link
              to="/products"
              className="text-sm font-medium hover:text-primary transition-colors"
            >
              Products
            </Link>
            <Button variant="ghost" size="icon">
              <ShoppingCart className="h-5 w-5" />
            </Button>
          </nav>
        </div>
      </header>

      <main className="flex-1">
        <Outlet />
      </main>

      <footer className="border-t bg-muted/50 mt-12">
        <div className="container mx-auto px-4 py-8">
          <div className="text-center text-sm text-muted-foreground">
            <p>
              © {new Date().getFullYear()}{' '}
              {import.meta.env.VITE_COMPANY_NAME || 'Entrepreneur OS'}. All
              rights reserved.
            </p>
            <p className="mt-2">
              Built with TanStack Start + React + Vendure
            </p>
          </div>
        </div>
      </footer>

      <TanStackRouterDevtools position="bottom-right" />
    </div>
  );
}
