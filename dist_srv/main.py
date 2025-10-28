from flask import Flask, Response, send_file
import requests
import os

app = Flask(__name__)


@app.route("/")
def index():
    return Response("""
            <html style="background: linear-gradient(135deg, #330000 0%, #ff0000 100%); min-height: 100vh;">
        <head>
            <title>Distribution Department </title>
            <style>
                body { 
                    font-family: 'Inter', Arial, sans-serif; 
                    background: linear-gradient(135deg, #ffffff 0%, #ff0000 100%);
                    color: #232323; 
                    max-width: 400px; 
                    margin: 5% auto; 
                    padding: 2em 1.5em; 
                    box-shadow: 0 1px 8px rgba(0,0,0,0.06);
                    border-radius: 8px;
                    position: relative;
                }
                body::before {
                    content: '';
                    position: absolute;
                    top: 0;
                    left: 0;
                    right: 0;
                    bottom: 0;
                    background-image: url('data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSIzMDAiIGhlaWdodD0iMzAwIj48ZmlsdGVyIGlkPSJuZyIgeD0iMCIgeT0iMCI+PGZlVHVyYnVsZW5jZSBiYXNlRnJlcXVlbmN5PSIyLjAiIG51bU9jdGF2ZXM9IjYiIHJlc3VsdD0ibm9pc2UiLz48ZmVDb2xvck1hdHJpeCB0eXBlPSJzYXR1cmF0ZSIgdmFsdWVzPSIwIi8+PC9maWx0ZXI+PHJlY3Qgd2lkdGg9IjEwMCUiIGhlaWdodD0iMTAwJSIgZmlsdGVyPSJ1cmwoI25nKSIgb3BhY2l0eT0iMC42MCIvPjwvc3ZnPg==');
                    opacity: 0.60;
                    mix-blend-mode: multiply;
                    pointer-events: none;
                }
                body * {
                    position: relative;
                    z-index: 1;
                }
                h1 {
                    font-size: 1.3em;
                    font-weight: 600;
                    margin-bottom: 0.5em;
                    letter-spacing: 0.01em;
                }
                .desc {
                    font-size: 0.98em;
                    color: #6a6a6a;
                    margin-bottom: 1.5em;
                }
                .links {
                    font-size: 0.98em;
                    margin-top: 1.5em;
                }
                a {
                    color: #0366d6;
                    text-decoration: none;
                    border-bottom: 1px dotted #bcd;
                    transition: border 0.2s;
                }
                a:hover { border-bottom: 1px solid #0366d6; }
                .pepe-gif {
                    text-align: center;
                    margin: 1em 0;
                }
                .pepe-gif img {
                    max-width: 200px;
                    height: auto;
                    border-radius: 8px;
                    box-shadow: 0 2px 8px rgba(0,0,0,0.1);
                }
            </style>
        </head>
        <body>
            <h1>🎉 Distribution Department 🎉</h1>
            <div class="pepe-gif">
                <img src="/pepe-cheers.gif" alt="Pepe Cheers" />
            </div>
            <div class="desc">
                The greatest distribution server since the atomic bomb.<br>
            </div>
            <div class="links">
                <a href="https://github.com/lucabased/pakbomb" target="_blank">pakbomb repo</a>
                &nbsp;/&nbsp;
                <a href="/pakbomb.sh">pakbomb.sh</a>
            </div>
        </body>
        </html>
    """, mimetype="text/html")


@app.route("/pakbomb.sh")
def get_pakbomb_sh():
    url = "https://raw.githubusercontent.com/lucabased/pakbomb/refs/heads/main/pakbomb.sh"
    try:
        resp = requests.get(url)
        resp.raise_for_status()
        content = resp.text
        return Response(content, mimetype="text/plain")
    except Exception as e:
        return Response(f"Error fetching file: {e}", status=500, mimetype="text/plain")


@app.route("/pepe-cheers.gif")
def get_pepe_gif():
    gif_path = os.path.join(os.path.dirname(__file__), "pepe-cheers.gif")
    if os.path.exists(gif_path):
        return send_file(gif_path, mimetype="image/gif")
    else:
        return Response("GIF file not found", status=404)

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=False)
