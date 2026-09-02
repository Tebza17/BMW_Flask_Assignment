import json
import os
import threading
import time
from datetime import datetime, timezone

from flask import Flask, jsonify, request

app = Flask(__name__)
_kafka_thread_started = False
_last_kafka_message = {"value": None, "received_at": None}


def _as_bool(value: str) -> bool:
    return str(value).strip().lower() in {"1", "true", "yes", "y"}


def _get_env(name: str, default: str = "") -> str:
    return os.getenv(name, default)


def _kafka_connection_settings() -> tuple[dict, str]:
    bootstrap_servers = _get_env("KAFKA_BOOTSTRAP_SERVERS", "")
    topic = _get_env("KAFKA_TOPIC", "events")
    username = _get_env("KAFKA_USERNAME", "")
    password = _get_env("KAFKA_PASSWORD", "")

    settings = {
        "bootstrap_servers": bootstrap_servers.split(",") if bootstrap_servers else [],
    }

    if username and password:
        settings.update(
            {
                "security_protocol": "SASL_SSL",
                "sasl_mechanism": "PLAIN",
                "sasl_plain_username": username,
                "sasl_plain_password": password,
            }
        )

    return settings, topic


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

    connection_settings, topic = _kafka_connection_settings()
    group_id = _get_env("KAFKA_GROUP_ID", "flask-kafka-app")
    bootstrap_servers = connection_settings.get("bootstrap_servers", [])

    if not bootstrap_servers:
        app.logger.error("KAFKA_ENABLED=true but KAFKA_BOOTSTRAP_SERVERS is empty")
        return

    def _consume() -> None:
        app.logger.info("Starting Kafka consumer on topic=%s", topic)
        consumer_kwargs = {
            "bootstrap_servers": bootstrap_servers,
            "group_id": group_id,
            "auto_offset_reset": "earliest",
            "enable_auto_commit": True,
        }

        for key in [
            "security_protocol",
            "sasl_mechanism",
            "sasl_plain_username",
            "sasl_plain_password",
        ]:
            if key in connection_settings:
                consumer_kwargs[key] = connection_settings[key]

        try:
            consumer = KafkaConsumer(topic, **consumer_kwargs)
            for message in consumer:
                try:
                    value = message.value.decode("utf-8")
                except Exception:
                    value = str(message.value)
                _last_kafka_message["value"] = value
                _last_kafka_message["received_at"] = datetime.now(timezone.utc).isoformat()
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


@app.get("/kafka/last-message")
def kafka_last_message():
    return jsonify(
        {
            "kafka_enabled": _as_bool(_get_env("KAFKA_ENABLED", "false")),
            "topic": _get_env("KAFKA_TOPIC", "events"),
            "last_message": _last_kafka_message["value"],
            "received_at": _last_kafka_message["received_at"],
        }
    )


@app.post("/kafka/publish")
def kafka_publish():
    if not _as_bool(_get_env("KAFKA_ENABLED", "false")):
        return jsonify({"error": "Kafka is disabled. Set KAFKA_ENABLED=true."}), 400

    connection_settings, topic = _kafka_connection_settings()
    bootstrap_servers = connection_settings.get("bootstrap_servers", [])
    if not bootstrap_servers:
        return jsonify({"error": "KAFKA_BOOTSTRAP_SERVERS is empty."}), 400

    payload = request.get_json(silent=True) or {}
    message = payload.get("message", "hello-from-flask")

    try:
        from kafka import KafkaProducer

        producer_kwargs = {"bootstrap_servers": bootstrap_servers}
        for key in [
            "security_protocol",
            "sasl_mechanism",
            "sasl_plain_username",
            "sasl_plain_password",
        ]:
            if key in connection_settings:
                producer_kwargs[key] = connection_settings[key]

        producer = KafkaProducer(**producer_kwargs)
        future = producer.send(topic, value=str(message).encode("utf-8"))
        result = future.get(timeout=10)
        producer.flush(timeout=10)
        producer.close(timeout=10)

        return (
            jsonify(
                {
                    "published": True,
                    "topic": topic,
                    "partition": result.partition,
                    "offset": result.offset,
                    "message": str(message),
                }
            ),
            201,
        )
    except Exception as exc:
        app.logger.error("Kafka publish failed: %s", exc)
        return jsonify({"published": False, "error": str(exc)}), 500


start_kafka_consumer_if_enabled()


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=int(_get_env("PORT", "8080")))
