// assets/vendor/toggle_theme.js adapted from:
// https://github.com/btihen-dev/phoenix_toggle_theme/blob/main/assets/vendor/toggle_theme.js

const localStorageKey = "theme";

const isDark = () => {
  if (localStorage.getItem(localStorageKey) === "dark") return true;
  if (localStorage.getItem(localStorageKey) === "light") return false;
  return window.matchMedia("(prefers-color-scheme: dark)").matches;
};

const setupToggleTheme = () => {
  toggleVisibility = (dark) => {
    const themeToggleDarkIcon = document.getElementById(
      "theme-toggle-dark-icon",
    );
    const themeToggleLightIcon = document.getElementById(
      "theme-toggle-light-icon",
    );
    if (themeToggleDarkIcon == null || themeToggleLightIcon == null) return;
    const show = dark ? themeToggleDarkIcon : themeToggleLightIcon;
    const hide = dark ? themeToggleLightIcon : themeToggleDarkIcon;
    show.classList.remove("hidden", "text-transparent");
    hide.classList.add("hidden", "text-transparent");
    if (dark) {
      document.documentElement.classList.add("dark");
    } else {
      document.documentElement.classList.remove("dark");
    }
    try {
      localStorage.setItem(localStorageKey, dark ? "dark" : "light");
    } catch (_err) {}
  };
  toggleVisibility(isDark());
  document
    .getElementById("theme-toggle")
    .addEventListener("click", function () {
      toggleVisibility(!isDark());
    });
};

const toggleThemeHook = {
  mounted() {
    setupToggleTheme();
  },
  updated() {},
};

export default toggleThemeHook;