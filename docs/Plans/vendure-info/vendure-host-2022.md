Here's a showcase that's been a long time coming. As some of you might know, I started the Vendure project because I couldn't find a good solution for my own use-case: my family's online art materials business. So over the past 4 years, in parallel to building the Vendure framework itself, I have been re-building our 15-year-old custom PHP/jQuery website on top of Vendure. We launched in March 2023! Some details:
• Running on Vendure v2.0.0-next (major branch)
• Storefront is Angular v15 (soon to be v16!)
• Hosted on Northflank (https://northflank.com/)
• Using Redis for job queue & session cache (multiple server instances)
• Vendure Shop API cached by Stellate (https://stellate.co/)
• Storefront app behind Cloudflare (https://www.cloudflare.com/)
• Braintree payments
• Running a number of plugins that will be made available in our marketplace later this year:
• Advanced search powered by Typesense
• Gift cards & store credit
• Advanced wishlists (multiple, public - think Amazon style)
• And more custom plugins such as reward (loyalty) points, geolocation, sitemap generation, custom redirects, featured filters, custom CMS and more
We migrated 12k products, over 200k customers and about half a million order records over from the old website. For the first 2 weeks we gradually split traffic between the old and new websites, meaning we needed a plugin to sync changes over continually from the old website to the new one. That was tricky! Next steps will be to update to the Angular v16 non-destructive hydration for improved core web vitals on the storefront. https://www.artsupplies.co.uk/

| service            | description                              | instance type        | instances   | total USD  |
| ------------------ | ---------------------------------------- | -------------------- | ----------- | ---------- |
| vendure-server     | The API server                           | nf-compute-100-2     | 2           | $48.00     |
| vendure-worker     | The background worker                    | nf-compute-100-1     | 2           | $36.00     |
| storefront         | The storefront website                   | nf-compute-100-2     | 2           | $48.00     |
| clickhouse         | Search analytics datastore               | nf-compute-100-1     | 1           | $18.00     |
| typesense          | Search engine                            | nf-compute-200       | 1           | $48.00     |
| pgadmin            | Visual database management UI            | nf-compute-20        | 1           | $5.41      |
| postgres           | The database                             | nf-compute-400       | 1           | $96.00     |
| minio              | Image server                             | ng-compute-50        | 1           | $12.00     |
| redis              | Cache server                             | nf-compute-100-1     | 1           | $18.00     |
| ------------------ | ---------------------------------------- | -------------------- | ----------- | ---------- |

Northflank monthly total $329.41
