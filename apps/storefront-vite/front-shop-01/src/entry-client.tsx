import { hydrateRoot } from 'react-dom/client';
import App from './app';

// Hydrate the app
hydrateRoot(document.getElementById('root')!, <App />);
