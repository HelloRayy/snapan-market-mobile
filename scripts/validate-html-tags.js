import fs from 'fs';
import path from 'path';

const filesToCheck = [
  './src/ui/components/pwa/popSiteHtml.ts',
  './src/ui/components/pwa/popSiteMobileHtml.ts',
];

const selfClosingTags = new Set([
  'area', 'base', 'br', 'col', 'embed', 'hr', 'img', 'input',
  'link', 'meta', 'param', 'source', 'track', 'wbr', 'use'
]);

let totalErrors = 0;

filesToCheck.forEach((filePath) => {
  const fullPath = path.resolve(filePath);
  if (!fs.existsSync(fullPath)) {
    console.warn(`⚠️ File not found: ${filePath}`);
    return;
  }

  const content = fs.readFileSync(fullPath, 'utf8');
  const tagRegex = /<\/?([a-zA-Z0-9:-]+)(\s+[^>]*)?\/?>/g;
  const stack = [];
  let match;
  let fileErrors = 0;

  while ((match = tagRegex.exec(content)) !== null) {
    const fullTag = match[0];
    const tagName = match[1].toLowerCase();
    const isClose = fullTag.startsWith('</');
    const isSelfClosing = fullTag.endsWith('/>') || selfClosingTags.has(tagName);

    if (isSelfClosing) continue;

    if (isClose) {
      if (stack.length === 0) {
        console.error(`❌ [${filePath}] Unexpected extra close tag </${tagName}> at character ${match.index}`);
        fileErrors++;
        totalErrors++;
      } else {
        const top = stack.pop();
        if (top.tagName !== tagName) {
          console.error(
            `❌ [${filePath}] Tag mismatch: <${top.tagName}> (opened at index ${top.index}) was closed by </${tagName}> at index ${match.index}`
          );
          const snippet = content.substring(Math.max(0, match.index - 60), Math.min(content.length, match.index + 60));
          console.error(`   Snippet around error: ... ${snippet.trim()} ...`);
          fileErrors++;
          totalErrors++;
        }
      }
    } else {
      stack.push({ tagName, index: match.index });
    }
  }

  if (stack.length > 0) {
    console.error(`❌ [${filePath}] ${stack.length} unclosed tag(s) remaining at end of file:`);
    stack.forEach((s) => {
      const snippet = content.substring(s.index, Math.min(content.length, s.index + 80));
      console.error(`   - Unclosed <${s.tagName}> at index ${s.index}: ${snippet.trim()}`);
    });
    fileErrors += stack.length;
    totalErrors += stack.length;
  }

  if (fileErrors === 0) {
    console.log(`✅ [${filePath}] Tag structure is 100% valid & balanced.`);
  }
});

if (totalErrors > 0) {
  console.error(`\n🚨 HTML Validation Failed with ${totalErrors} error(s). Please fix tag mismatches before continuing.`);
  process.exit(1);
} else {
  console.log(`\n🎉 All HTML landing page templates passed validation!`);
  process.exit(0);
}
