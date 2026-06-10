#!/usr/bin/env python3
import http.server
import subprocess

HTML = """<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Inception Monitor</title>
    <meta http-equiv="refresh" content="5">
    <style>
        body {{ font-family: Arial, sans-serif; background: #1a1a2e; color: #eee; padding: 40px; }}
        h1 {{ color: #e94560; }}
        table {{ width: 100%; border-collapse: collapse; margin-top: 20px; }}
        th {{ background: #16213e; padding: 10px; text-align: left; }}
        td {{ padding: 10px; border-bottom: 1px solid #16213e; }}
        .up {{ color: #00ff88; font-weight: bold; }}
        .down {{ color: #e94560; font-weight: bold; }}
    </style>
</head>
<body>
    <h1>Inception Monitor</h1>
    <p>Auto-refreshes every 5 seconds</p>
    <table>
        <tr><th>Container</th><th>Image</th><th>Status</th></tr>
        {rows}
    </table>
</body>
</html>"""

class Handler(http.server.BaseHTTPRequestHandler):
    def do_GET(self):
        result = subprocess.run(
            ['docker', 'ps', '-a', '--format', '{{.Names}}|{{.Image}}|{{.Status}}'],
            capture_output=True, text=True
        )
        rows = ""
        for line in result.stdout.strip().split('\n'):
            if line:
                parts = line.split('|')
                name, image, status = parts[0], parts[1], parts[2]
                css = "up" if "Up" in status else "down"
                label = "UP" if "Up" in status else "DOWN"
                rows += f"<tr><td>{name}</td><td>{image}</td><td class='{css}'>[{label}] {status}</td></tr>"

        html = HTML.format(rows=rows).encode('utf-8')
        self.send_response(200)
        self.send_header('Content-type', 'text/html; charset=utf-8')
        self.end_headers()
        self.wfile.write(html)

    def log_message(self, *args):
        pass

httpd = http.server.HTTPServer(('0.0.0.0', 9000), Handler)
httpd.serve_forever()
