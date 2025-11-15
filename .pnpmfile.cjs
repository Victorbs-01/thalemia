// .pnpmfile.cjs
function readPackage(pkg, context) {
  if (pkg.dependencies && pkg.dependencies['osw']) {
    pkg.dependencies['osw'] = '1.3.5';
    context.log('Forcing osw@1.3.5 in ' + pkg.name);
  }
  
  if (pkg.devDependencies && pkg.devDependencies['osw']) {
    pkg.devDependencies['osw'] = '1.3.5';
    context.log('Forcing osw@1.3.5 in ' + pkg.name + ' (dev)');
  }

  return pkg;
}

module.exports = {
  hooks: {
    readPackage
  }
};
