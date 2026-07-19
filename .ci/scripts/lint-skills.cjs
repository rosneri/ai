const fs = require("fs");
const path = require("path");

const ROOT = path.resolve(__dirname, "../..");
let errors = 0;
let warnings = 0;

function error(file, msg) {
  const rel = path.relative(ROOT, file);
  console.error(`  \x1b[31m✗\x1b[0m ${rel}: ${msg}`);
  errors++;
}

function warn(file, msg) {
  const rel = path.relative(ROOT, file);
  console.warn(`  \x1b[33m⚠\x1b[0m ${rel}: ${msg}`);
  warnings++;
}

// Accept skill directories as arguments, or scan all if none provided
const args = process.argv.slice(2);
const skillDirs =
  args.length > 0
    ? args.map((d) => path.resolve(ROOT, d))
    : fs
        .readdirSync(ROOT, { withFileTypes: true })
        .filter(
          (e) =>
            e.isDirectory() &&
            !e.name.startsWith(".") &&
            !["ci", "scripts", "node_modules"].includes(e.name),
        )
        .map((e) => path.join(ROOT, e.name));

for (const skillDir of skillDirs) {
  const entry = { name: path.basename(skillDir) };
  const skillFile = path.join(skillDir, "SKILL.md");
  if (!fs.existsSync(skillFile)) continue;

  const content = fs.readFileSync(skillFile, "utf-8");
  const lines = content.split("\n");

  // SKILL.md line count
  if (lines.length > 200) {
    warn(skillFile, `SKILL.md is ${lines.length} lines (max 200)`);
  }

  // Directory name: lowercase, hyphens, digits only
  if (!/^[a-z0-9][a-z0-9-]*$/.test(entry.name)) {
    error(
      skillDir,
      `Directory name '${entry.name}' must be lowercase with hyphens only (e.g. 'processing-pdfs')`,
    );
  }

  // Parse frontmatter
  if (lines[0] !== "---") continue;
  const closingIdx = lines.indexOf("---", 1);
  if (closingIdx === -1) continue;

  const frontmatter = lines.slice(1, closingIdx).join("\n");
  const descMatch = frontmatter.match(/^description:\s*(.+)$/m);

  if (descMatch) {
    const desc = descMatch[1].trim();

    // Description length
    if (desc.length > 1024) {
      error(skillFile, `Description is ${desc.length} chars (max 1024)`);
    }

    // Description must be third person
    if (/^I[\s']/.test(desc)) {
      error(
        skillFile,
        "Description must be in third person (not 'I help...'), use 'Processes...' style",
      );
    }
  }

  // No nested subdirectories (one level deep only)
  const subdirs = fs
    .readdirSync(skillDir, { withFileTypes: true })
    .filter((e) => e.isDirectory());

  for (const sub of subdirs) {
    const nested = fs
      .readdirSync(path.join(skillDir, sub.name), { withFileTypes: true })
      .filter((e) => e.isDirectory());

    for (const n of nested) {
      error(
        skillDir,
        `Nested subdirectory: ${sub.name}/${n.name} (max one level deep)`,
      );
    }
  }
}

if (warnings > 0) {
  console.warn(`\n${warnings} skill lint warning(s) found`);
}

if (errors > 0) {
  console.error(`${errors} skill lint error(s) found`);
  process.exit(1);
} else {
  console.log("All skills passed lint checks");
}
