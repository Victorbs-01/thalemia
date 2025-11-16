import { Tree, formatFiles, generateFiles, joinPathFragments, names } from '@nx/devkit';
import * as path from 'path';
import { VendurePluginGeneratorSchema } from './schema';

export async function vendurePluginGenerator(tree: Tree, options: VendurePluginGeneratorSchema) {
  const normalizedOptions = normalizeOptions(options);

  // Generate plugin files from templates
  generateFiles(tree, path.join(__dirname, 'files'), normalizedOptions.projectRoot, {
    ...normalizedOptions,
    template: '',
  });

  // Format files
  await formatFiles(tree);
}

function normalizeOptions(options: VendurePluginGeneratorSchema) {
  const name = names(options.name).fileName;
  const projectRoot = joinPathFragments('libs/vendure/plugins/src', name);

  return {
    ...options,
    name,
    projectRoot,
    ...names(options.name),
  };
}

export default vendurePluginGenerator;
