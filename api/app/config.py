import os

from dotenv import load_dotenv

load_dotenv()


class Settings:
    oracle_user = os.environ.get("ORACLE_USER", "")
    oracle_password = os.environ.get("ORACLE_PASSWORD", "")
    oracle_dsn = os.environ.get("ORACLE_DSN", "")


settings = Settings()
