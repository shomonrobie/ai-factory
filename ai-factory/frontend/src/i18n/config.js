// frontend/src/i18n/config.js
const locales = {
  en: { name: "English", flag: "ðŸ‡ºðŸ‡¸", dir: "ltr" },
  es: { name: "EspaÃ±ol", flag: "ðŸ‡ªðŸ‡¸", dir: "ltr" },
  de: { name: "Deutsch", flag: "ðŸ‡©ðŸ‡ª", dir: "ltr" },
  fr: { name: "FranÃ§ais", flag: "ðŸ‡«ðŸ‡·", dir: "ltr" },
  ja: { name: "æ—¥æœ¬èªž", flag: "ðŸ‡¯ðŸ‡µ", dir: "ltr" },
  zh: { name: "ä¸­æ–‡", flag: "ðŸ‡¨ðŸ‡³", dir: "ltr" }
};

const defaultLocale = "en";

function getLocale() {
  return localStorage.getItem("locale") || defaultLocale;
}

function setLocale(locale) {
  if (locales[locale]) {
    localStorage.setItem("locale", locale);
    window.location.reload();
  }
}

async function loadTranslations(locale) {
  try {
    const response = await fetch(`/i18n/locales/${locale}/common.json`);
    return await response.json();
  } catch (error) {
    console.error("Failed to load translations:", error);
    return {};
  }
}

export { locales, defaultLocale, getLocale, setLocale, loadTranslations };
