import { Tree, formatFiles, generateFiles, joinPathFragments, updateJson, names } from '@nx/devkit';
import * as path from 'path';
import { SharedLibraryGeneratorSchema } from './schema';

export async function sharedLibraryGenerator(tree: Tree, options: SharedLibraryGeneratorSchema) {
  const normalizedOptions = normalizeOptions(options);

  // Generate library files from templates
  generateFiles(tree, path.join(__dirname, 'files'), normalizedOptions.projectRoot, {
    ...normalizedOptions,
    template: '',
  });

  // Update tsconfig.base.json with path mapping
  updateTsconfigPaths(tree, normalizedOptions);

  // Format files
  await formatFiles(tree);
}

function normalizeOptions(options: SharedLibraryGeneratorSchema) {
  const name = names(options.name).fileName;
  const projectDirectory = `${options.directory}/${name}`;
  const projectRoot = joinPathFragments('libs/shared', projectDirectory);
  const importPath = `@entrepreneur-os/shared/${options.directory === 'ui-components' ? 'ui-components' : options.directory === 'data-access' ? 'data-access' : options.directory === 'types' ? 'types' : `utils/${name}`}`;

  return {
    ...options,
    name,
    projectName: `shared-${options.directory}-${name}`,
    projectRoot,
    projectDirectory,
    importPath,
    ...names(options.name),
  };
}

function updateTsconfigPaths(tree: Tree, options: ReturnType<typeof normalizeOptions>) {
  updateJson(tree, 'tsconfig.base.json', (json) => {
    if (!json.compilerOptions) {
      json.compilerOptions = {};
    }
    if (!json.compilerOptions.paths) {
      json.compilerOptions.paths = {};
    }

    // Add path mapping
    json.compilerOptions.paths[options.importPath] = [`${options.projectRoot}/src/index.ts`];

    return json;
  });
}

export default sharedLibraryGenerator;
