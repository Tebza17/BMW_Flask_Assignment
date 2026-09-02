import json
import os
import threading
import time
from datetime import datetime, timezone

from flask import Flask, jsonify

app = Flask(__name__)
_kafka_thread_started = False


def _as_bool(value: str) -> bool:
    return str(value).strip().lower() in {"1", "true", "yes", "y"}


def _get_env(name: str, default: str = "") -> str:
    return os.getenv(name, default)


def start_kafka_consumer_if_enabled() -> None:
    global _kafka_thread_started
    if _kafka_thread_started:
        return

    kafka_enabled = _as_bool(_get_env("KAFKA_ENABLED", "false"))
    if not kafka_enabled:
        app.logger.info("Kafka consumer is disabled")
        _kafka_thread_started = True
        return

    try:
        from kafka import KafkaConsumer
    except Exception as exc:
        app.logger.error("Kafka library import failed: %s", exc)
        return

    bootstrap_servers = _get_env("KAFKA_BOOTSTRAP_SERVERS", "")
    topic = _get_env("KAFKA_TOPIC", "events")
    group_id = _get_env("KAFKA_GROUP_ID", "flask-kafka-app")

    if not bootstrap_servers:
        app.logger.error("KAFKA_ENABLED=true but KAFKA_BOOTSTRAP_SERVERS is empty")
        return

    username = _get_env("KAFKA_USERNAME", "")
    password = _get_env("KAFKA_PASSWORD", "")

    security_protocol = "PLAINTEXT"
    sasl_mechanism = None
    if username and password:
        security_protocol = "SASL_SSL"
        sasl_mechanism = "PLAIN"

    def _consume() -> None:
        app.logger.info("Starting Kafka consumer on topic=%s", topic)
        consumer_kwargs = {
            "bootstrap_servers": bootstrap_servers.split(","),
            "group_id": group_id,
            "auto_offset_reset": "earliest",
            "enable_auto_commit": True,
        }

        if username and password:
            consumer_kwargs.update(
                {
                    "security_protocol": security_protocol,
                    "sasl_mechanism": sasl_mechanism,
                    "sasl_plain_username": username,
                    "sasl_plain_password": password,
                }
            )

        try:
            consumer = KafkaConsumer(topic, **consumer_kwargs)
            for message in consumer:
                try:
                    value = message.value.decode("utf-8")
                except Exception:
                    value = str(message.value)
                app.logger.info("Kafka message received: %s", value)
        except Exception as exc:
            app.logger.error("Kafka consumer stopped due to error: %s", exc)

    thread = threading.Thread(target=_consume, daemon=True)
    thread.start()
    _kafka_thread_started = True


@app.get("/")
def index():
    return jsonify(
        {
            "service": "flask-kafka-app",
            "status": "ok",
            "timestamp": datetime.now(timezone.utc).isoformat(),
            "environment": _get_env("APP_ENV", "dev"),
            "kafka_enabled": _as_bool(_get_env("KAFKA_ENABLED", "false")),
        }
    )


@app.get("/health")
def health():
    return jsonify({"status": "healthy", "time": int(time.time())})


start_kafka_consumer_if_enabled()


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=int(_get_env("PORT", "8080")))
