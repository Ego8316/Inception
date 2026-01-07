#!/usr/bin/env python3
import html
import socket
import time
from http.server import BaseHTTPRequestHandler, HTTPServer

SERVICES = [
	{"name": "nginx", "host": "nginx", "port": 443, "label": "Wordpress entrypoint"},
	{"name": "wordpress", "host": "wordpress", "port": 9000, "label": "PHP-FPM"},
	{"name": "mariadb", "host": "mariadb", "port": 3306, "label": "Database"},
	{"name": "redis", "host": "redis", "port": 6379, "label": "Cache"},
	{"name": "adminer", "host": "adminer", "port": 8080, "label": "DB UI"},
	{"name": "ftp", "host": "ftp", "port": 21, "label": "File access"},
	{"name": "backup", "host": "backup", "port": 3307, "label": "Database backup"},
	{"name": "static-site", "host": "static-site", "port": 8081, "label": "Portfolio"},
]

TEMPLATE_PATH = "/app/dashboard.html"
STYLE_PATH = "/app/style.css"

def load_text(path):
	try:
		with open(path, "r", encoding="utf-8") as fh:
			return fh.read()
	except OSError:
		return None

def load_bytes(path):
	try:
		with open(path, "rb") as fh:
			return fh.read()
	except OSError:
		return None

def check_service(host, port):
	start = time.time()
	try:
		with socket.create_connection((host, port), timeout=0.6):
			latency = int((time.time() - start) * 1000)
			return True, latency
	except OSError:
		return False, None

def render_page(hostname):
	template = load_text(TEMPLATE_PATH)
	rows = []
	for svc in SERVICES:
		ok, latency = check_service(svc["host"], svc["port"])
		status = "UP" if ok else "DOWN"
		status_class = "chip-up" if ok else "chip-down"
		latency_text = f"{latency} ms" if latency is not None else "--"
		rows.append(
			f"<tr class='{status.lower()}'>"
			f"<td class='svc-name'>{html.escape(svc['name'])}</td>"
			f"<td class='svc-role'>{html.escape(svc['label'])}</td>"
			f"<td class='svc-host'>{html.escape(svc['host'])}:{svc['port']}</td>"
			f"<td class='svc-status'><span class='chip {status_class}'>{status}</span></td>"
			f"<td class='svc-latency'>{latency_text}</td>"
			"</tr>"
		)
	host = hostname or "localhost"
	external_links = [
		("Main site", f"https://{host}"),
		("Adminer", f"http://{host}:8080"),
		("Portfolio", f"http://{host}:8081"),
	]
	links_html = "".join(
		f"<a href='{html.escape(url)}'>{html.escape(name)}</a>"
		for name, url in external_links
	)
	updated = time.strftime("%Y-%m-%d %H:%M:%S")
	return (
		template.replace("{{ROWS}}", "".join(rows))
		.replace("{{LINKS}}", links_html)
		.replace("{{UPDATED}}", updated)
	)

class DashboardHandler(BaseHTTPRequestHandler):
	def do_GET(self):
		if self.path == "/style.css":
			data = load_bytes(STYLE_PATH)
			if data is None:
				self.send_response(404)
				self.end_headers()
				return
			self.send_response(200)
			self.send_header("Content-Type", "text/css; charset=utf-8")
			self.send_header("Cache-Control", "no-store")
			self.send_header("Content-Length", str(len(data)))
			self.end_headers()
			self.wfile.write(data)
			return
		host = self.headers.get("Host", "").split(":")[0]
		page = render_page(host)
		data = page.encode("utf-8")
		self.send_response(200)
		self.send_header("Content-Type", "text/html; charset=utf-8")
		self.send_header("Cache-Control", "no-store")
		self.send_header("Content-Length", str(len(data)))
		self.end_headers()
		self.wfile.write(data)

if __name__ == "__main__":
	server = HTTPServer(("0.0.0.0", 8082), DashboardHandler)
	server.serve_forever()
