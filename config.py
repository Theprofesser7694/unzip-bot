import os
import psutil


class Config:
    APP_ID = int(os.environ.get("APP_ID", "0"))
    API_HASH = os.environ.get("API_HASH", "")
    BASE_LANGUAGE = os.environ.get("BASE_LANGUAGE", "en")
    BOT_TOKEN = os.environ.get("BOT_TOKEN", "")
    BOT_THUMB = f"{os.path.dirname(__file__)}/bot_thumb.jpg"

    BOT_OWNER = int(os.environ.get("BOT_OWNER", "0"))

    CHUNK_SIZE = 1024 * 1024 * 10
    DOWNLOAD_LOCATION = f"{os.path.dirname(__file__)}/Downloaded"

    IS_HEROKU = os.environ.get("DYNO", "").startswith("worker.")
    LOCKFILE = "/tmp/unzipbot.lock"

    _logs_channel = os.environ.get("LOGS_CHANNEL", "").strip()
    LOGS_CHANNEL = (
        int(_logs_channel)
        if _logs_channel.lstrip("-").isdigit()
        else _logs_channel or None
    )

    MAX_CONCURRENT_TASKS = 75
    MAX_MESSAGE_LENGTH = 4096
    MAX_CPU_CORES_COUNT = psutil.cpu_count(logical=False) or 1
    MAX_CPU_USAGE = 80

    MAX_RAM_AMOUNT_KB = 1024 * 512 if IS_HEROKU else -1
    MAX_RAM_USAGE = 80

    MAX_TASK_DURATION_EXTRACT = 120 * 60
    MAX_TASK_DURATION_MERGE = 240 * 60
    MIN_SIZE_PROGRESS = 1024 * 1024 * 50

    MONGODB_URL = os.environ.get("MONGODB_URL", "")
    MONGODB_DBNAME = os.environ.get(
        "MONGODB_DBNAME", "Unzipper_Bot"
    )

    TG_MAX_SIZE = 2097152000
    THUMB_LOCATION = f"{os.path.dirname(__file__)}/Thumbnails"
    VERSION = os.environ.get("UNZIPBOT_VERSION", "7.3.0")

    if not APP_ID or not API_HASH or not BOT_TOKEN:
        raise ValueError(
            "Missing required environment variables: "
            "APP_ID, API_HASH, BOT_TOKEN"
        )