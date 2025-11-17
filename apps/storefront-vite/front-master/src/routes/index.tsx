import { createFileRoute } from '@tanstack/react-router';
import { Button, Card, CardContent, CardHeader, CardTitle } from '@entrepreneur-os/storefront/ui';
import { ArrowRight, ShoppingBag, Zap, Shield } from 'lucide-react';

export const Route = createFileRoute('/')({
  component: HomePage,
});

function HomePage() {
  return (
    <div className="container mx-auto px-4 py-12">
      {/* Hero Section */}
      <section className="text-center py-20">
        <h1 className="text-5xl font-bold mb-6">
          Welcome to {import.meta.env.VITE_SITE_NAME}
        </h1>
        <p className="text-xl text-muted-foreground mb-8 max-w-2xl mx-auto">
          Your one-stop shop for quality products. Built with modern
          technology and designed for the best shopping experience.
        </p>
        <div className="flex gap-4 justify-center">
          <Button size="lg" asChild>
            <a href="/products">
              Shop Now <ArrowRight className="ml-2 h-5 w-5" />
            </a>
          </Button>
          <Button size="lg" variant="outline">
            Learn More
          </Button>
        </div>
      </section>

      {/* Features Section */}
      <section className="py-16 grid md:grid-cols-3 gap-8">
        <Card>
          <CardHeader>
            <ShoppingBag className="h-12 w-12 mb-4 text-primary" />
            <CardTitle>Wide Selection</CardTitle>
          </CardHeader>
          <CardContent>
            <p className="text-muted-foreground">
              Browse through thousands of quality products across multiple
              categories.
            </p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <Zap className="h-12 w-12 mb-4 text-primary" />
            <CardTitle>Fast Delivery</CardTitle>
          </CardHeader>
          <CardContent>
            <p className="text-muted-foreground">
              Quick and reliable shipping to get your products to you faster.
            </p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <Shield className="h-12 w-12 mb-4 text-primary" />
            <CardTitle>Secure Shopping</CardTitle>
          </CardHeader>
          <CardContent>
            <p className="text-muted-foreground">
              Shop with confidence using our secure payment processing.
            </p>
          </CardContent>
        </Card>
      </section>
    </div>
  );
}
