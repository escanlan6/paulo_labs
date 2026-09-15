// Embed bundled KaTeX in Quarto HTML. Usage: node finalize_html.cjs file.html ...
const fs = require('fs');
const path = require('path');
const candidates = [
  path.join(__dirname, 'vendor/katex'),
  path.join(__dirname, '../slides/vendor/katex')
];
const vendor = candidates.find(p => fs.existsSync(path.join(p, 'katex.min.js')));
if (!vendor) throw Error('Cannot find the bundled vendor/katex directory.');
if (process.argv.length < 3) throw Error('Supply at least one HTML file.');
let css = fs.readFileSync(path.join(vendor, 'katex.min.css'), 'utf8')
  .replace(/,url\([^)]*\.woff\) format\("woff"\)/g, '')
  .replace(/,url\([^)]*\.ttf\) format\("truetype"\)/g, '');
const fonts = [...new Set([...css.matchAll(/url\((fonts\/[^)]+)\)/g)].map(m => m[1]))];
for (const font of fonts) {
  const bytes = fs.readFileSync(path.join(vendor, font)).toString('base64');
  css = css.replaceAll('url(' + font + ')', 'url(data:font/woff2;base64,' + bytes + ')');
}
const js = fs.readFileSync(path.join(vendor, 'katex.min.js'));
for (const filename of process.argv.slice(2)) {
  let html = fs.readFileSync(filename, 'utf8');
  html = html
    .replace(/https:\/\/cdn\.jsdelivr\.net\/npm\/katex@[^"']+\/katex\.min\.css/g,
      'data:text/css;base64,' + Buffer.from(css).toString('base64'))
    .replace(/https:\/\/cdn\.jsdelivr\.net\/npm\/katex@[^"']+\/katex\.min\.js/g,
      'data:text/javascript;base64,' + js.toString('base64'));
  fs.writeFileSync(filename, html);
  console.log('Embedded offline mathematics in ' + filename);
}
