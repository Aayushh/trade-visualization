/* ============================================================================
   SHARED NAVIGATION - US Trade Data Visualization Suite
   Provides persistent dark mode and navigation across all pages
   ============================================================================ */

(function () {
    'use strict';

    // Configuration
    var DARK_MODE_KEY = 'tradeVizDarkMode';
    var HOME_URL = 'index.html';

    // Apply dark mode from localStorage on page load
    function applyStoredTheme() {
        if (localStorage.getItem(DARK_MODE_KEY) === 'true') {
            document.body.classList.add('dark-mode');
        }
    }

    // Toggle dark mode and save preference
    function toggleDarkMode() {
        document.body.classList.toggle('dark-mode');
        var isDark = document.body.classList.contains('dark-mode');
        localStorage.setItem(DARK_MODE_KEY, isDark.toString());
        updateThemeIcon();
    }

    // Update the theme toggle icon
    function updateThemeIcon() {
        var btn = document.getElementById('theme-toggle-btn');
        if (btn) {
            var isDark = document.body.classList.contains('dark-mode');
            btn.textContent = isDark ? '☀️' : '🌙';
            btn.title = isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode';
        }
    }

    // Create navigation bar
    function createNavBar(pageTitle) {
        var nav = document.createElement('nav');
        nav.className = 'nav-bar';
        nav.innerHTML =
            '<div class="nav-left">' +
            '<a href="' + HOME_URL + '" class="home-btn">🏠 Dashboard</a>' +
            '<span class="page-title">' + (pageTitle || 'Visualization') + '</span>' +
            '</div>' +
            '<div class="nav-right">' +
            '<button id="theme-toggle-btn" class="theme-toggle" onclick="window.toggleDarkMode()">🌙</button>' +
            '</div>';

        return nav;
    }

    // Inject navigation bar into page
    function injectNavBar(pageTitle) {
        // Don't inject if already exists
        if (document.querySelector('.nav-bar')) return;

        var nav = createNavBar(pageTitle);
        document.body.insertBefore(nav, document.body.firstChild);

        // Add padding to content
        document.body.style.paddingTop = '70px';

        updateThemeIcon();
    }

    // Initialize on DOM ready
    function init() {
        applyStoredTheme();

        // Check if we're on index.html (don't add nav there - it has its own)
        var isIndex = window.location.pathname.endsWith('index.html') ||
            window.location.pathname.endsWith('/');

        if (!isIndex) {
            // Try to get page title from document or use filename
            var title = document.title || 'Visualization';
            // Clean up title
            title = title.replace(' - US Trade Data', '').replace('plotly', 'Chart');
            injectNavBar(title);
        }
    }

    // Expose functions globally
    window.toggleDarkMode = toggleDarkMode;
    window.applyStoredTheme = applyStoredTheme;

    // Run on load
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', init);
    } else {
        init();
    }
})();
