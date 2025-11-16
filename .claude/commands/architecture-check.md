# Architecture Check

Validate that the code follows the established architectural patterns:

1. **Dual-Vendure Pattern**: Verify proper separation between vendure-master (PIM) and vendure-ecommerce (retail)
2. **Module Boundaries**: Check Nx enforce-module-boundaries rules are not violated
3. **Import Paths**: Ensure all imports use @entrepreneur-os/\* namespace (no relative imports across projects)
4. **Library Organization**: Verify code is in appropriate libraries:
   - Shared code → libs/shared/
   - Vendure-specific → libs/vendure/
   - App-specific → apps/\*/
5. **Multi-tenancy**: Check tenant isolation patterns are followed
6. **Data Flow**: Verify data flows correctly (master → n8n → ecommerce → storefronts)

Report any architectural violations with specific file paths and recommended fixes.
