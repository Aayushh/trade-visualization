# GitHub Pages Deployment Guide - UPDATED

✅ **Setup Complete!** The `/docs` folder has been created and populated with all visualizations.

---

## 📋 Pre-Deployment Checklist

- ✅ `/docs` folder created with all 17 visualizations
- ✅ Static plots copied to `/docs/static/`
- ✅ Supporting files (`*_files/` folders) included
- ✅ `.gitignore` configured for large data files
- ✅ `README.md` created with comprehensive documentation
- ✅ `REPO_REFERENCE.md` created for AI reference

---

## Step 1: Create GitHub Repository

1. Go to [github.com/new](https://github.com/new)
2. **Repository name:** `trade-visualizations`
3. **Description:** "Interactive US trade and tariff analysis dashboards"
4. **Visibility:** Public (required for free GitHub Pages)
5. **Initialize repository:** NO - Leave blank (you already have files)
6. Click **Create repository**

---

## Step 2: Configure Git & Push Code

Open PowerShell in `c:\Code\trade_dashboards` and run:

```powershell
# Initialize git repository
git init
git branch -M main

# Add remote (replace YOUR_USERNAME)
git remote add origin https://github.com/YOUR_USERNAME/trade-visualizations.git

# Verify remote
git remote -v

# Add all files
git add .

# Initial commit
git commit -m "Initial commit: Trade visualization dashboards with 17 interactive charts"

# Push to GitHub
git push -u origin main
```

**Note:** This will push:
- ✅ `/docs/` (all visualizations)
- ✅ `data_exploration/scripts/` (R generation code)
- ✅ `README.md`, `REPO_REFERENCE.md`, `.gitignore`
- ❌ `data/raw/` (ignored - too large)
- ❌ `data/processed/` (ignored - too large)

---

## Step 3: Enable GitHub Pages

1. Go to your repository: https://github.com/YOUR_USERNAME/trade-visualizations
2. Click **Settings** (top navigation)
3. Click **Pages** (left sidebar, under "Code and automation")
4. Under **Build and deployment**:
   - **Source:** Select "Deploy from a branch"
   - **Branch:** `main`
   - **Folder:** `/docs`
5. Click **Save**
6. GitHub will display: _"Your site is live at https://YOUR_USERNAME.github.io/trade-visualizations/"_
7. Wait 1-2 minutes for initial build

---

## Step 4: Verify Deployment

Visit your site:
```
https://YOUR_USERNAME.github.io/trade-visualizations/
```

You should see:
- ✅ Main index page with visualization grid
- ✅ 17 interactive visualizations accessible
- ✅ Static reference plots displayed
- ✅ All charts responsive and functional

---

## 🔄 Updating Visualizations

### When you regenerate dashboards locally:

```powershell
cd c:\Code\trade_dashboards

# Regenerate all visualizations (in R)
Rscript data_exploration/scripts/00_master_regenerate_dashboards.R

# Copy updated files to docs folder
Copy-Item -Path "data_exploration/output/interactive/*" -Destination "docs" -Recurse -Force

# Commit and push
git add docs/
git commit -m "Update: [describe what changed]"
git push origin main
```

**GitHub Pages will automatically update within ~1 minute.**

---

## 📁 Deployment Structure

```
github.com/YOUR_USERNAME/trade-visualizations/
├── /docs                                    # GitHub Pages source
│   ├── index.html                          # Main entry point
│   ├── 01_monthly_imports_interactive.html
│   ├── 02_tariff_evolution_interactive.html
│   ├── ... (charts 03-17)
│   ├── static/
│   │   ├── monthly_imports.png
│   │   ├── top_chapters.png
│   │   └── top_countries.png
│   ├── *_files/                            # Supporting assets
│   │   ├── plotly, jquery, datatables
│   │   └── css, fonts
│   └── data/
│       └── hs10_lookup.json
│
├── data_exploration/scripts/               # R generation code
│   ├── 00_master_regenerate_dashboards.R
│   ├── 01_prepare_interactive_data.R
│   └── ... (other scripts)
│
├── README.md                               # Project overview
├── REPO_REFERENCE.md                       # Detailed documentation
└── .gitignore                             # Ignore large files
```

---

## ⚠️ Important Notes

### File Paths
- All HTML files use **relative paths** only
- Examples: `./data/hs10_lookup.json`, `../static/plot.png`
- Never use absolute paths

### File Size Limits
- GitHub Pages: No file size limit for static hosting
- Git LFS: Not needed (all files are small HTML/JS)
- Data files: Excluded via `.gitignore` (in `data/raw/` and `data/processed/`)

### Browser Compatibility
- Modern browsers only (HTML5, ES6)
- Chrome, Firefox, Safari, Edge (all recent versions)
- Mobile responsive design included

### Custom Domain (Optional)
To use a custom domain:
1. Settings → Pages → Custom domain
2. Enter your domain (e.g., `trade-viz.example.com`)
3. Update DNS CNAME record to point to `YOUR_USERNAME.github.io`

---

## 🆘 Troubleshooting

### Site not accessible after push
- **Wait 2-3 minutes** - GitHub Pages needs time to build
- Check Settings → Pages for any build errors
- Verify repository is Public

### Visualizations show "404 Not Found"
- Confirm all `*_files/` folders were copied to `/docs/`
- Check relative paths in HTML files (should use `./`)
- Verify `index.html` exists in `/docs/` root

### Charts not interactive
- Verify JavaScript files loaded (check browser console F12)
- Confirm Plotly.js is accessible
- Clear browser cache (Ctrl+Shift+Del)

### Data not loading in visualizations
- Check `docs/data/` folder exists with `hs10_lookup.json`
- Verify file paths in HTML match actual file locations
- Look for CORS errors in browser console

---

## 🎯 Next Steps

1. ✅ Create GitHub repository
2. ✅ Push code to main branch
3. ✅ Enable GitHub Pages in Settings
4. ✅ Verify site is live
5. 📊 Share your dashboard!

**Your dashboard is now live on GitHub Pages!**

For full documentation, see:
- [README.md](../README.md) - Project overview and quick start
- [REPO_REFERENCE.md](../REPO_REFERENCE.md) - Detailed script documentation

---

## 📞 Support

If you encounter issues:
1. Check browser console (F12) for errors
2. Review [troubleshooting section](#troubleshooting)
3. Check GitHub Pages documentation: https://pages.github.com/
