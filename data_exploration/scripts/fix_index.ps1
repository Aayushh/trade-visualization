# Post-process index.html to fix encoding and add features
# Run this AFTER 06_generate_viz_index.R

$indexPath = "data_exploration/output/interactive/index.html"

# Read with proper encoding
$content = [System.IO.File]::ReadAllText((Resolve-Path $indexPath), [System.Text.Encoding]::UTF8)

Write-Host "File size: $($content.Length) chars"

# Check if modal already exists
if ($content -match "vizModal") {
    Write-Host "Modal already exists"
} else {
    Write-Host "Adding modal..."
    
    # Modal CSS
    $modalCss = @'
        /* Iframe Modal */
        .viz-modal { display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.85); z-index: 10000; }
        .viz-modal.active { display: flex; }
        .viz-modal .modal-content { width: 95%; height: 95%; margin: auto; background: #1e1e2e; border-radius: 16px; overflow: hidden; box-shadow: 0 20px 60px rgba(0,0,0,0.5); }
        .viz-modal .modal-header { display: flex; justify-content: space-between; align-items: center; padding: 14px 24px; background: #2d2d4a; border-bottom: 1px solid #3d3d5c; }
        .viz-modal .modal-title { font-size: 18px; font-weight: 600; color: white; }
        .viz-modal .close-btn { padding: 10px 20px; background: #ef4444; color: white; border: none; border-radius: 8px; cursor: pointer; font-size: 14px; font-weight: 600; }
        .viz-modal .close-btn:hover { background: #dc2626; }
        .viz-modal iframe { width: 100%; height: calc(100% - 60px); border: none; background: white; }
        .viz-modal img.static-plot { max-width: 100%; max-height: calc(100% - 60px); object-fit: contain; display: block; margin: auto; }
'@

    # Modal HTML
    $modalHtml = @'
    <!-- Iframe Modal -->
    <div id="vizModal" class="viz-modal" onclick="if(event.target===this)closeModal()">
        <div class="modal-content">
            <div class="modal-header">
                <span id="modalTitle" class="modal-title">Visualization</span>
                <button onclick="closeModal()" class="close-btn">X Close</button>
            </div>
            <div id="modalBody" style="width:100%;height:calc(100% - 60px);overflow:auto;display:flex;align-items:center;justify-content:center;background:white;">
                <iframe id="modalIframe" src="" style="width:100%;height:100%;border:none;" allowfullscreen></iframe>
            </div>
        </div>
    </div>
'@

    # Modal JS
    $modalJs = @'
        // Modal Functions
        function openInModal(url, title, isImage) {
            var modal = document.getElementById('vizModal');
            var body = document.getElementById('modalBody');
            var titleEl = document.getElementById('modalTitle');
            titleEl.textContent = title || 'Visualization';
            
            if (isImage) {
                body.innerHTML = '<img src="' + url + '" class="static-plot" alt="' + title + '">';
            } else {
                body.innerHTML = '<iframe id="modalIframe" src="' + url + '" style="width:100%;height:100%;border:none;" allowfullscreen></iframe>';
            }
            modal.classList.add('active');
            document.body.style.overflow = 'hidden';
        }
        
        function closeModal() {
            var modal = document.getElementById('vizModal');
            document.getElementById('modalBody').innerHTML = '';
            modal.classList.remove('active');
            document.body.style.overflow = '';
        }
        
        document.addEventListener('keydown', function(e) { if (e.key === 'Escape') closeModal(); });
'@

    # Inject CSS before </style>
    $content = $content -replace '</style>', "$modalCss`n    </style>"
    
    # Inject modal HTML before </body>
    $content = $content -replace '</body>', "$modalHtml`n</body>"
    
    # Inject JS at start of script
    $content = $content -replace '<script>', "<script>`n$modalJs"
}

# Fix card links to use modal (handle both html and image types)
$content = $content -replace 'href="([^"]+\.html)" class="card-link" target="_blank"', 'href="#" class="card-link" onclick="openInModal(''$1'', this.closest(''.card'').querySelector(''.card-title'').textContent, false); return false;"'
$content = $content -replace 'href="([^"]+\.(png|jpg|jpeg|gif))" class="card-link" target="_blank"', 'href="#" class="card-link" onclick="openInModal(''$1'', this.closest(''.card'').querySelector(''.card-title'').textContent, true); return false;"'

Write-Host "Card links updated for modal"

# Add Tools tab if not present
if (-not ($content -match 'data-category="tools"')) {
    Write-Host "Adding Tools tab..."
    $content = $content -replace '(data-category="animations"[^>]*>)[^<]*Animations</button>\s*</div>', '$1Animations</button><button class="tab-btn" data-category="tools" onclick="filterCards(''tools'')">Tools</button></div>'
}

# Add --cat-tools color if not present
if (-not ($content -match '--cat-tools')) {
    Write-Host "Adding Tools category color..."
    $content = $content -replace '(--cat-animations:[^;]+;)', '$1`n            --cat-tools: #06b6d4;'
}

# Write back with UTF-8 BOM to ensure encoding
[System.IO.File]::WriteAllText((Resolve-Path $indexPath), $content, [System.Text.Encoding]::UTF8)

Write-Host "Done! File saved with UTF-8 encoding."
