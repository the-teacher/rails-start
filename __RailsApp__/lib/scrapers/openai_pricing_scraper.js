import { chromium } from 'playwright';

const url = process.argv[2] ?? 'https://developers.openai.com/api/docs/pricing';

const browser = await chromium.launch({ headless: true });
const page = await browser.newPage();

await page.goto(url, { waitUntil: 'networkidle', timeout: 30_000 });

const html = await page.content();
await browser.close();

process.stdout.write(html);
