from flask import Flask, Response, render_template_string
import subprocess

app = Flask(__name__)

HTML_PAGE = """
<!doctype html>
<html>
<head>
  <title>Sync Log Viewer</title>
  <style>
    body { font-family: monospace; background: #111; color: #0f0; padding: 1rem; }
    pre { white-space: pre-wrap; }
  </style>
</head>
<body>
  <h2>sync-mediatemp.log (Live)</h2>
  <pre id="log"></pre>
  <script>
    const log = document.getElementById('log');
    const source = new EventSource("/stream");
    source.onmessage = function(event) {
      log.textContent += event.data + "\\n";
      window.scrollTo(0, document.body.scrollHeight);
    };
  </script>
</body>
</html>
"""

@app.route('/')
def index():
    return render_template_string(HTML_PAGE)

@app.route('/stream')
def stream():
    def generate():
        process = subprocess.Popen(
            ['tail', '-n', '50', '-F', '/var/log/sync-mediatemp.log'],
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE
        )
        for line in iter(process.stdout.readline, b''):
            yield f"data: {line.decode().rstrip()}\n\n"
    return Response(generate(), mimetype='text/event-stream')

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080, threaded=True)
