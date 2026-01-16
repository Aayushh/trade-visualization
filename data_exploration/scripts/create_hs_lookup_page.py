"""
Create the HS Code Lookup HTML page and copy JSON data
"""
import shutil
from pathlib import Path

# Paths
OUTPUT_DIR = Path(r"C:\Code\trade_updated\data_exploration\output\interactive")
DATA_DIR = OUTPUT_DIR / "data"
DATA_DIR.mkdir(exist_ok=True)

# Copy JSON lookup to data folder
src_json = Path(r"C:\Code\trade_updated\data\processed\hs10_lookup.json")
dst_json = DATA_DIR / "hs10_lookup.json"
shutil.copy(src_json, dst_json)
print(f"Copied JSON to: {dst_json}")

# Create the HTML file
html_content = '''<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>HS Code Lookup - US Trade Data</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <style>
        :root {
            --bg-primary: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            --bg-secondary: rgba(255, 255, 255, 0.95);
            --bg-card: rgba(255, 255, 255, 0.85);
            --bg-glass: rgba(255, 255, 255, 0.25);
            --text-primary: #1a1a2e;
            --text-secondary: #4a4a6a;
            --text-muted: #6b7280;
            --accent-primary: #667eea;
            --accent-secondary: #764ba2;
            --border-color: rgba(255, 255, 255, 0.3);
            --shadow: 0 8px 32px rgba(31, 38, 135, 0.15);
            --shadow-hover: 0 12px 40px rgba(31, 38, 135, 0.25);
            --success: #10b981;
        }

        [data-theme="dark"] {
            --bg-primary: linear-gradient(135deg, #1a1a2e 0%, #16213e 100%);
            --bg-secondary: rgba(30, 30, 50, 0.95);
            --bg-card: rgba(40, 40, 70, 0.85);
            --bg-glass: rgba(255, 255, 255, 0.08);
            --text-primary: #f0f0f5;
            --text-secondary: #b0b0c5;
            --text-muted: #8080a0;
            --border-color: rgba(255, 255, 255, 0.1);
        }

        * { margin: 0; padding: 0; box-sizing: border-box; }

        body {
            font-family: "Inter", sans-serif;
            background: var(--bg-primary);
            min-height: 100vh;
            color: var(--text-primary);
            line-height: 1.6;
        }

        .container { max-width: 1600px; margin: 0 auto; padding: 2rem; }

        header {
            background: var(--bg-secondary);
            backdrop-filter: blur(20px);
            border-radius: 20px;
            padding: 2rem;
            margin-bottom: 2rem;
            box-shadow: var(--shadow);
            border: 1px solid var(--border-color);
        }

        .header-top {
            display: flex;
            justify-content: space-between;
            align-items: center;
            flex-wrap: wrap;
            gap: 1rem;
        }

        .header-left { display: flex; align-items: center; gap: 1.5rem; }

        .back-btn {
            display: flex;
            align-items: center;
            gap: 0.5rem;
            padding: 0.75rem 1.25rem;
            background: var(--bg-glass);
            border: 1px solid var(--border-color);
            border-radius: 50px;
            color: var(--text-secondary);
            text-decoration: none;
            font-size: 0.9rem;
            transition: all 0.3s ease;
        }

        .back-btn:hover { background: var(--accent-primary); color: white; }

        h1 {
            font-size: 2rem;
            font-weight: 700;
            background: linear-gradient(135deg, var(--accent-primary), var(--accent-secondary));
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
        }

        .theme-toggle {
            display: flex;
            align-items: center;
            gap: 0.5rem;
            padding: 0.5rem 1rem;
            background: var(--bg-glass);
            border: 1px solid var(--border-color);
            border-radius: 50px;
            cursor: pointer;
            font-size: 0.9rem;
            color: var(--text-secondary);
        }

        .theme-toggle:hover { background: var(--accent-primary); color: white; }

        .stats-bar { display: flex; gap: 2rem; margin-top: 1.5rem; flex-wrap: wrap; }
        .stat-item { display: flex; align-items: center; gap: 0.5rem; font-size: 0.9rem; color: var(--text-muted); }
        .stat-value { font-weight: 600; color: var(--accent-primary); }

        .search-section { margin-bottom: 2rem; }
        .search-container { position: relative; max-width: 600px; }

        .search-input {
            width: 100%;
            padding: 1.25rem 1.5rem 1.25rem 3.5rem;
            border: 2px solid var(--border-color);
            border-radius: 16px;
            font-family: inherit;
            font-size: 1.1rem;
            background: var(--bg-card);
            color: var(--text-primary);
            box-shadow: var(--shadow);
        }

        .search-input:focus {
            outline: none;
            border-color: var(--accent-primary);
        }

        .search-icon {
            position: absolute;
            left: 1.25rem;
            top: 50%;
            transform: translateY(-50%);
            font-size: 1.25rem;
            color: var(--text-muted);
        }

        .search-clear {
            position: absolute;
            right: 1rem;
            top: 50%;
            transform: translateY(-50%);
            background: var(--bg-glass);
            border: none;
            border-radius: 50%;
            width: 28px;
            height: 28px;
            cursor: pointer;
            display: none;
            align-items: center;
            justify-content: center;
            font-size: 1rem;
            color: var(--text-muted);
        }

        .search-clear.visible { display: flex; }

        .main-content { display: grid; grid-template-columns: 350px 1fr; gap: 2rem; }
        @media (max-width: 1024px) { .main-content { grid-template-columns: 1fr; } }

        .sections-panel, .results-panel {
            background: var(--bg-secondary);
            backdrop-filter: blur(20px);
            border-radius: 20px;
            padding: 1.5rem;
            box-shadow: var(--shadow);
            border: 1px solid var(--border-color);
        }

        .sections-panel { max-height: calc(100vh - 300px); overflow-y: auto; }
        .panel-title { font-size: 0.8rem; font-weight: 600; text-transform: uppercase; letter-spacing: 0.05em; color: var(--text-muted); margin-bottom: 1rem; }

        .section-header {
            display: flex;
            align-items: center;
            gap: 0.5rem;
            padding: 0.75rem;
            background: var(--bg-glass);
            border-radius: 10px;
            cursor: pointer;
            margin-bottom: 0.5rem;
        }

        .section-header:hover { background: rgba(102, 126, 234, 0.15); }
        .section-header.expanded { background: rgba(102, 126, 234, 0.2); }
        .section-arrow { transition: transform 0.2s; font-size: 0.8rem; }
        .section-header.expanded .section-arrow { transform: rotate(90deg); }
        .section-name { font-size: 0.85rem; font-weight: 500; flex: 1; }
        .section-count { font-size: 0.75rem; color: var(--text-muted); background: var(--bg-glass); padding: 0.2rem 0.5rem; border-radius: 20px; }

        .chapters-list { display: none; margin-left: 1.5rem; margin-top: 0.5rem; }
        .chapters-list.visible { display: block; }

        .chapter-item {
            padding: 0.5rem 0.75rem;
            font-size: 0.8rem;
            color: var(--text-secondary);
            cursor: pointer;
            border-radius: 8px;
            display: flex;
            justify-content: space-between;
        }

        .chapter-item:hover { background: var(--bg-glass); color: var(--accent-primary); }
        .chapter-item.active { background: var(--accent-primary); color: white; }

        .results-header { display: flex; justify-content: space-between; margin-bottom: 1rem; }
        .results-count { font-size: 0.9rem; color: var(--text-muted); }
        .results-count strong { color: var(--accent-primary); }

        .table-container { max-height: calc(100vh - 400px); overflow-y: auto; }

        .results-table { width: 100%; border-collapse: collapse; font-size: 0.85rem; }
        .results-table th { text-align: left; padding: 0.75rem 1rem; font-weight: 600; color: var(--text-muted); text-transform: uppercase; font-size: 0.7rem; border-bottom: 2px solid var(--border-color); position: sticky; top: 0; background: var(--bg-secondary); }
        .results-table td { padding: 0.75rem 1rem; border-bottom: 1px solid var(--border-color); color: var(--text-secondary); }
        .results-table tr { cursor: pointer; }
        .results-table tr:hover { background: var(--bg-glass); }
        .results-table tr.selected { background: rgba(102, 126, 234, 0.15); }

        .code-cell { font-family: "SF Mono", monospace; font-weight: 600; color: var(--accent-primary); white-space: nowrap; }
        .desc-short { color: var(--text-primary); font-weight: 500; }
        .desc-raw { font-size: 0.8rem; color: var(--text-muted); }
        .tariff-cell { font-family: monospace; font-size: 0.8rem; }

        .code-detail {
            position: fixed;
            top: 0;
            right: -500px;
            width: 480px;
            height: 100vh;
            background: var(--bg-secondary);
            box-shadow: -8px 0 32px rgba(0, 0, 0, 0.2);
            transition: right 0.3s;
            z-index: 100;
            overflow-y: auto;
            padding: 2rem;
        }

        .code-detail.open { right: 0; }

        .detail-close {
            position: absolute;
            top: 1.5rem;
            right: 1.5rem;
            background: var(--bg-glass);
            border: none;
            border-radius: 50%;
            width: 40px;
            height: 40px;
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.25rem;
            color: var(--text-muted);
        }

        .detail-close:hover { background: var(--accent-primary); color: white; }

        .detail-code { font-family: monospace; font-size: 1.5rem; font-weight: 700; color: var(--accent-primary); margin-bottom: 0.5rem; }
        .detail-short { font-size: 1.1rem; font-weight: 500; margin-bottom: 1.5rem; }
        .detail-section { margin-bottom: 1.5rem; }
        .detail-label { font-size: 0.75rem; font-weight: 600; text-transform: uppercase; color: var(--text-muted); margin-bottom: 0.5rem; }
        .detail-value { color: var(--text-secondary); font-size: 0.9rem; line-height: 1.6; }

        .breadcrumb { background: var(--bg-glass); border-radius: 10px; padding: 1rem; font-size: 0.85rem; line-height: 1.8; }
        .breadcrumb-sep { color: var(--text-muted); margin: 0 0.25rem; }

        .tariff-grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 1rem; }
        .tariff-item { background: var(--bg-glass); border-radius: 10px; padding: 0.75rem; text-align: center; }
        .tariff-type { font-size: 0.7rem; text-transform: uppercase; color: var(--text-muted); margin-bottom: 0.25rem; }
        .tariff-rate { font-family: monospace; font-weight: 600; }

        .action-buttons { display: flex; gap: 1rem; margin-top: 2rem; }
        .action-btn { flex: 1; padding: 0.75rem 1rem; border: none; border-radius: 10px; font-family: inherit; font-size: 0.9rem; font-weight: 500; cursor: pointer; display: flex; align-items: center; justify-content: center; gap: 0.5rem; }
        .btn-primary { background: var(--accent-primary); color: white; }
        .btn-primary:hover { background: var(--accent-secondary); }
        .btn-secondary { background: var(--bg-glass); color: var(--text-secondary); border: 1px solid var(--border-color); }
        .btn-secondary:hover { background: var(--success); color: white; }

        .toast { position: fixed; bottom: 2rem; left: 50%; transform: translateX(-50%) translateY(100px); background: var(--success); color: white; padding: 1rem 2rem; border-radius: 50px; font-weight: 500; transition: transform 0.3s; z-index: 200; }
        .toast.show { transform: translateX(-50%) translateY(0); }

        .loading { display: flex; flex-direction: column; align-items: center; padding: 4rem; color: var(--text-muted); }
        .spinner { width: 50px; height: 50px; border: 4px solid var(--border-color); border-top-color: var(--accent-primary); border-radius: 50%; animation: spin 1s linear infinite; margin-bottom: 1rem; }
        @keyframes spin { to { transform: rotate(360deg); } }

        .highlight { background: rgba(245, 158, 11, 0.3); padding: 0.1em 0.2em; border-radius: 3px; }
        .empty-state { text-align: center; padding: 4rem 2rem; color: var(--text-muted); }
        .empty-state-icon { font-size: 4rem; margin-bottom: 1rem; opacity: 0.5; }

        ::-webkit-scrollbar { width: 8px; }
        ::-webkit-scrollbar-track { background: var(--bg-glass); border-radius: 4px; }
        ::-webkit-scrollbar-thumb { background: var(--text-muted); border-radius: 4px; }
        ::-webkit-scrollbar-thumb:hover { background: var(--accent-primary); }
    </style>
</head>
<body>
    <div class="container">
        <header>
            <div class="header-top">
                <div class="header-left">
                    <a href="index.html" class="back-btn">← Dashboard</a>
                    <h1>🔍 HS Code Lookup</h1>
                </div>
                <button class="theme-toggle" onclick="toggleTheme()">
                    <span id="themeIcon">🌙</span>
                    <span id="themeLabel">Dark Mode</span>
                </button>
            </div>
            <div class="stats-bar">
                <div class="stat-item">📊 Total Codes: <span class="stat-value" id="totalCodes">Loading...</span></div>
                <div class="stat-item">📁 Chapters: <span class="stat-value" id="totalChapters">--</span></div>
                <div class="stat-item">📂 Sections: <span class="stat-value" id="totalSections">--</span></div>
            </div>
        </header>

        <section class="search-section">
            <div class="search-container">
                <span class="search-icon">🔍</span>
                <input type="text" class="search-input" id="searchInput" placeholder="Search by code or description..." oninput="handleSearch(this.value)">
                <button class="search-clear" id="searchClear" onclick="clearSearch()">×</button>
            </div>
        </section>

        <div class="main-content">
            <aside class="sections-panel">
                <div class="panel-title">Browse by Section</div>
                <div id="sectionsList" class="loading"><div class="spinner"></div><span>Loading...</span></div>
            </aside>
            <main class="results-panel">
                <div class="results-header">
                    <div class="results-count">Showing <strong id="visibleCount">0</strong> of <strong id="filteredCount">0</strong> codes</div>
                </div>
                <div class="table-container">
                    <table class="results-table">
                        <thead><tr><th>HS10 Code</th><th>Description</th><th>Chapter</th><th>Tariff</th><th>Units</th></tr></thead>
                        <tbody id="resultsBody"><tr><td colspan="5" class="loading"><div class="spinner"></div></td></tr></tbody>
                    </table>
                </div>
            </main>
        </div>
    </div>

    <div class="code-detail" id="codeDetail">
        <button class="detail-close" onclick="closeDetail()">×</button>
        <div class="detail-code" id="detailCode">---</div>
        <div class="detail-short" id="detailShort">---</div>
        <div class="detail-section"><div class="detail-label">Full Breadcrumb</div><div class="breadcrumb" id="detailBreadcrumb">---</div></div>
        <div class="detail-section"><div class="detail-label">Classification</div><div class="detail-value"><div><strong>Section:</strong> <span id="detailSection">---</span></div><div><strong>Chapter:</strong> <span id="detailChapter">---</span></div></div></div>
        <div class="detail-section"><div class="detail-label">Tariff Rates</div><div class="tariff-grid"><div class="tariff-item"><div class="tariff-type">General</div><div class="tariff-rate" id="detailGeneral">--</div></div><div class="tariff-item"><div class="tariff-type">Special</div><div class="tariff-rate" id="detailSpecial">--</div></div><div class="tariff-item"><div class="tariff-type">Column 2</div><div class="tariff-rate" id="detailOther">--</div></div></div></div>
        <div class="detail-section"><div class="detail-label">Units</div><div class="detail-value" id="detailUnits">---</div></div>
        <div class="detail-section"><div class="detail-label">Code Hierarchy</div><div class="detail-value"><div>HS2: <span id="detailHs2">--</span> | HS4: <span id="detailHs4">--</span> | HS6: <span id="detailHs6">--</span> | HS8: <span id="detailHs8">--</span></div></div></div>
        <div class="action-buttons"><button class="action-btn btn-secondary" onclick="copyCode()">📋 Copy Code</button><button class="action-btn btn-primary" onclick="copyAll()">📝 Copy All</button></div>
    </div>
    <div class="toast" id="toast">Copied!</div>

    <script>
        let hsData = {}, hsArray = [], filteredData = [], selectedCode = null, currentChapter = null, displayLimit = 100;

        async function loadData() {
            try {
                const response = await fetch('data/hs10_lookup.json');
                hsData = await response.json();
                hsArray = Object.values(hsData);
                filteredData = hsArray;
                document.getElementById('totalCodes').textContent = hsArray.length.toLocaleString();
                const chapters = new Set(hsArray.map(d => d.chapter_number));
                const sections = new Set(hsArray.map(d => d.section_number));
                document.getElementById('totalChapters').textContent = chapters.size;
                document.getElementById('totalSections').textContent = sections.size;
                buildSectionsPanel();
                renderResults();
            } catch (e) {
                document.getElementById('resultsBody').innerHTML = '<tr><td colspan="5" class="empty-state"><div class="empty-state-icon">⚠️</div><div>Failed to load. Ensure hs10_lookup.json is in data folder.</div></td></tr>';
            }
        }

        function buildSectionsPanel() {
            const sections = {};
            hsArray.forEach(item => {
                if (!sections[item.section_number]) sections[item.section_number] = { name: item.section_name, chapters: {} };
                if (!sections[item.section_number].chapters[item.chapter_number]) sections[item.section_number].chapters[item.chapter_number] = { name: item.chapter_name, count: 0 };
                sections[item.section_number].chapters[item.chapter_number].count++;
            });
            let html = '';
            Object.entries(sections).sort((a,b) => parseInt(a[0].match(/\\d+/)?.[0]||0) - parseInt(b[0].match(/\\d+/)?.[0]||0)).forEach(([k, s]) => {
                const total = Object.values(s.chapters).reduce((sum, c) => sum + c.count, 0);
                html += `<div class="section-item"><div class="section-header" onclick="toggleSection(this)"><span class="section-arrow">▶</span><span class="section-name">${k.replace('SECTION ','S')}: ${s.name.split(';')[0]}</span><span class="section-count">${total}</span></div><div class="chapters-list">`;
                Object.entries(s.chapters).sort((a,b) => parseInt(a[0]) - parseInt(b[0])).forEach(([cn, c]) => {
                    html += `<div class="chapter-item" onclick="filterByChapter(${cn}, this)"><span>Ch ${cn}: ${c.name.substring(0,30)}${c.name.length>30?'...':''}</span><span class="section-count">${c.count}</span></div>`;
                });
                html += '</div></div>';
            });
            document.getElementById('sectionsList').innerHTML = html;
        }

        function toggleSection(el) { el.classList.toggle('expanded'); el.nextElementSibling.classList.toggle('visible'); }

        function filterByChapter(ch, el) {
            document.querySelectorAll('.chapter-item.active').forEach(e => e.classList.remove('active'));
            if (el) el.classList.add('active');
            currentChapter = ch;
            document.getElementById('searchInput').value = '';
            document.getElementById('searchClear').classList.remove('visible');
            filteredData = hsArray.filter(d => d.chapter_number === ch);
            displayLimit = 100;
            renderResults();
        }

        let searchTimeout;
        function handleSearch(q) {
            clearTimeout(searchTimeout);
            document.getElementById('searchClear').classList.toggle('visible', q.length > 0);
            searchTimeout = setTimeout(() => {
                if (!q.trim()) { filteredData = currentChapter ? hsArray.filter(d => d.chapter_number === currentChapter) : hsArray; }
                else {
                    const lq = q.toLowerCase();
                    filteredData = hsArray.filter(d => d.hts10.includes(q) || d.hts10_formatted.includes(q) || d.description_short.toLowerCase().includes(lq) || d.description_raw.toLowerCase().includes(lq) || d.chapter_name.toLowerCase().includes(lq));
                    currentChapter = null;
                    document.querySelectorAll('.chapter-item.active').forEach(e => e.classList.remove('active'));
                }
                displayLimit = 100;
                renderResults(q);
            }, 150);
        }

        function clearSearch() {
            document.getElementById('searchInput').value = '';
            document.getElementById('searchClear').classList.remove('visible');
            currentChapter = null;
            document.querySelectorAll('.chapter-item.active').forEach(e => e.classList.remove('active'));
            filteredData = hsArray;
            displayLimit = 100;
            renderResults();
        }

        function renderResults(hq = '') {
            const displayed = filteredData.slice(0, displayLimit);
            document.getElementById('visibleCount').textContent = Math.min(displayLimit, filteredData.length).toLocaleString();
            document.getElementById('filteredCount').textContent = filteredData.length.toLocaleString();
            if (filteredData.length === 0) { document.getElementById('resultsBody').innerHTML = '<tr><td colspan="5" class="empty-state"><div class="empty-state-icon">🔍</div><div>No codes found</div></td></tr>'; return; }
            let html = '';
            displayed.forEach(item => {
                const sd = hq ? highlightText(item.description_short, hq) : item.description_short;
                const rd = hq ? highlightText(item.description_raw, hq) : item.description_raw;
                html += `<tr onclick="showDetail('${item.hts10}')" class="${selectedCode === item.hts10 ? 'selected' : ''}"><td class="code-cell">${item.hts10_formatted}</td><td><div class="desc-short">${sd}</div><div class="desc-raw">${rd}</div></td><td>Ch ${item.chapter_number}</td><td class="tariff-cell">${item.general_rate || '--'}</td><td>${item.units || '--'}</td></tr>`;
            });
            if (filteredData.length > displayLimit) html += `<tr onclick="loadMore()"><td colspan="5" style="text-align:center;padding:1rem;color:var(--accent-primary);cursor:pointer;">Load more... (${(filteredData.length - displayLimit).toLocaleString()} remaining)</td></tr>`;
            document.getElementById('resultsBody').innerHTML = html;
        }

        function highlightText(t, q) { if (!q) return t; return t.replace(new RegExp(`(${q.replace(/[.*+?^${}()|[\\]\\\\]/g, '\\\\$&')})`, 'gi'), '<span class="highlight">$1</span>'); }
        function loadMore() { displayLimit += 100; renderResults(document.getElementById('searchInput').value); }

        function showDetail(code) {
            selectedCode = code;
            const item = hsData[code];
            if (!item) return;
            document.getElementById('detailCode').textContent = item.hts10_formatted;
            document.getElementById('detailShort').textContent = item.description_short;
            document.getElementById('detailBreadcrumb').innerHTML = item.description_long.split(' > ').map((p, i) => i === 0 ? `<strong>${p}</strong>` : p).join('<span class="breadcrumb-sep"> → </span>');
            document.getElementById('detailSection').textContent = `${item.section_number}: ${item.section_name}`;
            document.getElementById('detailChapter').textContent = `${item.chapter_number}: ${item.chapter_name}`;
            document.getElementById('detailGeneral').textContent = item.general_rate || '--';
            document.getElementById('detailSpecial').textContent = item.special_rate ? (item.special_rate.length > 20 ? item.special_rate.substring(0, 20) + '...' : item.special_rate) : '--';
            document.getElementById('detailOther').textContent = item.other_rate || '--';
            document.getElementById('detailUnits').textContent = item.units || 'Not specified';
            document.getElementById('detailHs2').textContent = item.hs2;
            document.getElementById('detailHs4').textContent = item.hs4;
            document.getElementById('detailHs6').textContent = item.hs6;
            document.getElementById('detailHs8').textContent = item.hs8;
            document.getElementById('codeDetail').classList.add('open');
            renderResults(document.getElementById('searchInput').value);
        }

        function closeDetail() { document.getElementById('codeDetail').classList.remove('open'); selectedCode = null; renderResults(document.getElementById('searchInput').value); }
        function copyCode() { if (!selectedCode) return; navigator.clipboard.writeText(hsData[selectedCode].hts10_formatted); showToast('Code copied!'); }
        function copyAll() { if (!selectedCode) return; const i = hsData[selectedCode]; navigator.clipboard.writeText(`HS10: ${i.hts10_formatted}\\nDescription: ${i.description_short}\\nChapter: ${i.chapter_number} - ${i.chapter_name}\\nTariff: ${i.general_rate || 'N/A'}`); showToast('Details copied!'); }
        function showToast(m) { const t = document.getElementById('toast'); t.textContent = m; t.classList.add('show'); setTimeout(() => t.classList.remove('show'), 2000); }

        function toggleTheme() {
            const b = document.body, icon = document.getElementById('themeIcon'), label = document.getElementById('themeLabel');
            if (b.getAttribute('data-theme') === 'dark') { b.removeAttribute('data-theme'); icon.textContent = '🌙'; label.textContent = 'Dark Mode'; localStorage.setItem('theme', 'light'); }
            else { b.setAttribute('data-theme', 'dark'); icon.textContent = '☀️'; label.textContent = 'Light Mode'; localStorage.setItem('theme', 'dark'); }
        }

        document.addEventListener('DOMContentLoaded', function() {
            if (localStorage.getItem('theme') === 'dark') { document.body.setAttribute('data-theme', 'dark'); document.getElementById('themeIcon').textContent = '☀️'; document.getElementById('themeLabel').textContent = 'Light Mode'; }
            loadData();
        });

        document.addEventListener('keydown', function(e) { if (e.key === 'Escape') closeDetail(); if (e.key === '/' && e.target.tagName !== 'INPUT') { e.preventDefault(); document.getElementById('searchInput').focus(); } });
    </script>
</body>
</html>
'''

html_path = OUTPUT_DIR / "17_hs_code_lookup.html"
with open(html_path, 'w', encoding='utf-8') as f:
    f.write(html_content)
print(f"Created HTML at: {html_path}")

print("Done!")
