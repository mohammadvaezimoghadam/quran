const https = require('https');

https.get('https://everyayah.com/data/', (res) => {
    let html = '';
    res.on('data', chunk => html += chunk);
    res.on('end', () => {
        const regex = /href="([^"]+\/)"/g;
        let match;
        const folders = [];
        while ((match = regex.exec(html)) !== null) {
            const name = match[1].replace('/', '');
            if (name && !name.startsWith('?') && !name.startsWith('http') && name !== '..' && name !== '.') {
                folders.push(name);
            }
        }
        console.log(`🎉 Total EveryAyah Reciter Folders Found: ${folders.length}`);
        console.log("Sample Folders (first 30):");
        console.log(folders.slice(0, 30));
    });
}).on('error', err => console.error("Error:", err.message));
