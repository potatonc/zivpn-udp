#!/usr/bin/env python3
# Potato
######################

import json
import sys
import os
import tempfile

CONF = "/etc/zivpn/config.json"


def die(msg):
    print(f"❌ {msg}")
    sys.exit(1)


def load_config():
    try:
        with open(CONF, "r") as f:
            return json.load(f)
    except FileNotFoundError:
        die("config not found")
    except json.JSONDecodeError:
        die("invalid json")


def save_config(data):
    fd, tmp_path = tempfile.mkstemp()
    try:
        with os.fdopen(fd, "w") as f:
            json.dump(data, f, indent=2)
        os.replace(tmp_path, CONF)
    except Exception as e:
        os.unlink(tmp_path)
        die(str(e))


def add_value(val):
    if not val:
        die("value empty")

    data = load_config()

    auth = data.setdefault("auth", {})
    config = auth.setdefault("config", [])

    if val not in config:
        config.append(val)

    save_config(data)


def del_value(val):
    if not val:
        die("value empty")

    data = load_config()

    try:
        data["auth"]["config"] = [
            v for v in data["auth"]["config"] if v != val
        ]
    except KeyError:
        pass

    save_config(data)


def list_value():
    data = load_config()
    for v in data.get("auth", {}).get("config", []):
        print(v)


def main():
    if len(sys.argv) < 2:
        sys.exit(1)

    cmd = sys.argv[1]

    if cmd == "add":
        add_value(sys.argv[2] if len(sys.argv) > 2 else None)
    elif cmd == "del":
        del_value(sys.argv[2] if len(sys.argv) > 2 else None)
    elif cmd == "list":
        list_value()
    else:
        sys.exit(1)


if __name__ == "__main__":
    main()
