# PowerShell script to inject iframe modal into index.html
# Run after 06_generate_viz_index.R

$indexPath = "data_exploration/output/interactive/index.html"

# Read the file
$content = Get-Content $indexPath -Raw

# Modal CSS to inject before </style>
$modalCss = @"
        /* Iframe Modal */
        .viz-modal { display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.8); z-index: 10000; }
        .viz-modal.active { display: flex; }
        .viz-modal .modal-content { width: 95%; height: 95%; margin: auto; background: var(--bg-secondary); border-radius: 16px; overflow: hidden; box-shadow: 0 20px 60px rgba(0,0,0,0.5); }
        .viz-modal .modal-header { display: flex; justify-content: space-between; align-items: center; padding: 14px 24px; background: var(--bg-card); border-bottom: 1px solid var(--border-color); }
        .viz-modal .modal-title { font-size: 18px; font-weight: 600; color: var(--text-primary); }
        .viz-modal .close-btn { padding: 10px 20px; background: #ef4444; color: white; border: none; border-radius: 8px; cursor: pointer; font-size: 14px; font-weight: 600; }
        .viz-modal .close-btn:hover { background: #dc2626; }
        .viz-modal iframe { width: 100%; height: calc(100% - 60px); border: none; background: white; }
"@

# Modal HTML to inject before </body>
$modalHtml = @"
    <!-- Iframe Modal for Visualizations -->
    <div id="vizModal" class="viz-modal" onclick="if(event.target===this)closeModal()">
        <div class="modal-content">
            <div class="modal-header">
                <span id="modalTitle" class="modal-title">Visualization</span>
                <button onclick="closeModal()" class="close-btn">&times; Close</button>
            </div>
            <iframe id="modalIframe" src="" allowfullscreen></iframe>
        </div>
    </div>
"@

# Modal JS to inject before </script>
$modalJs = @"
        // Iframe Modal Functions
        function openInModal(url, title) {
            var modal = document.getElementById('vizModal');
            var iframe = document.getElementById('modalIframe');
            var titleEl = document.getElementById('modalTitle');
            iframe.src = url;
            titleEl.textContent = title || 'Visualization';
            modal.classList.add('active');
            document.body.style.overflow = 'hidden';
        }
        
        function closeModal() {
            var modal = document.getElementById('vizModal');
            var iframe = document.getElementById('modalIframe');
            modal.classList.remove('active');
            iframe.src = '';
            document.body.style.overflow = '';
        }
        
        document.addEventListener('keydown', function(e) {
            if (e.key === 'Escape') closeModal();
        });

"@

# Inject modal CSS before </style>
$content = $content -replace '</style>', "$modalCss`n    </style>"

# Inject modal HTML before </body>
$content = $content -replace '</body>', "$modalHtml`n</body>"

# Inject modal JS at the start of the script section
$content = $content -replace '<script>', "<script>`n$modalJs"

# Replace card links to use openInModal
$content = $content -replace 'href="([^"]+)" class="card-link" target="_blank"', 'href="#" class="card-link" onclick="openInModal(''$1'', this.closest(''.card'').querySelector(''.card-title'').textContent); return false;"'

# Write back
Set-Content $indexPath $content -Encoding UTF8

Write-Host "Modal injection complete!"
