import os
from flask import Flask, jsonify
from prometheus_flask_exporter import PrometheusMetrics

app = Flask(__name__)
# Автоматически добавляет метрики (количество запросов, время ответа) ко всем роутам
metrics = PrometheusMetrics(app)

DB_PATH = os.environ.get("DATABASE_PATH", "/app/data/cheatsheet.db")


@app.route("/")
def home():
    return jsonify(
        {
            "message": "DevOps Cheatsheet API is running!",
            "db_path": DB_PATH,
            "status": "OK",
        }
    )


@app.route("/health")
def health():
    # Этот роут используют orchestrators (Docker, K8s) для проверки, живо ли приложение
    return jsonify({"status": "healthy"}), 200


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)  # nosec B104
