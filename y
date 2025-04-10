from flask import Flask, Response, render_template_string
import subprocess

app = Flask(__name__)

HTML_PAGE = '''
<!doctype html>
<html>
<head>
  <title>sync-mediatemp Log Viewer</title>
  <style>
    body { font-family: monospace; background: #111; color: #0f0; padding: 1rem; }
    #status { background: #222; padding: 1rem; border-radius: 8px; margin-bottom: 1rem; }
    pre { white-space: pre-wrap; }
  </style>
</head>
<body>
  <div id="status">
    <strong>🟢 Status:</strong>
    <div id="current-status">Waiting for updates...</div>
  </div>
  <pre id="log"></pre>
  <script>
    const status = document.getElementById('current-status');
    const log = document.getElementById('log');
    const source = new EventSource("/stream");
    source.onmessage = function(event) {
      if (event.data.includes("SYNCING")) {
        status.textContent = event.data;
      }
      log.textContent += event.data + "\n";
      window.scrollTo(0, document.body.scrollHeight);
    };
  </script>
</body>
</html>
'''

@app.route('/')
def index():
    return render_template_string(HTML_PAGE)

@app.route('/stream')
def stream():
    def generate():
        process = subprocess.Popen(
            ['tail', '-n', '50', '-f', '/var/log/sync-mediatemp.log'],
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE
        )
        yield f"data: [INFO] Log viewer started and watching...

"
        for line in iter(process.stdout.readline, b''):
            yield f"data: {line.decode().rstrip()}

"
    return Response(generate(), mimetype='text/event-stream')

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080, threaded=True)
