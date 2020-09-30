function configureTheme() {
	const themeConfig = new ThemeConfig();
	themeConfig.loadTheme = () => {
		const prefersDarkMode = window.matchMedia && window.matchMedia("(prefers-color-scheme: dark)").matches;
		return prefersDarkMode ? "dark" : "light";
	};
	themeConfig.initTheme();
}