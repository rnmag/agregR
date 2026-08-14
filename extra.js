document.addEventListener("DOMContentLoaded", function() {
    var script = document.createElement("script");
    script.src = "https://unpkg.com/@twemoji/api@latest/dist/twemoji.min.js";
    script.crossOrigin = "anonymous";
    script.onload = function() {
        // Parse all emojis in the document body and replace them with Twemoji SVGs
        twemoji.parse(document.body, {
            folder: 'svg',
            ext: '.svg'
        });
    };
    document.head.appendChild(script);
});
