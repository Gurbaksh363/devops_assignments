from flask import Flask, render_template
import os

PORT = int(os.getenv("PORT", 8000))

app = Flask(__name__)
env = dict(os.environ)

@app.route("/")
def home():
  return render_template("index.html", env=env)

if __name__ == "__main__":
  app.run(debug=True, host="0.0.0.0", port=PORT)