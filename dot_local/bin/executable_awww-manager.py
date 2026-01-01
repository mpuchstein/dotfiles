#!/usr/bin/env python3
import argparse
import json
import os
import random
import shlex
import shutil
import subprocess
import sys
import time

__version__ = "0.1.0"


def _load_toml(path):
    try:
        import toml
    except ImportError:
        print("toml not available; install python-toml", file=sys.stderr)
        raise SystemExit(2)

    try:
        with open(path, "r", encoding="utf-8") as handle:
            return toml.load(handle)
    except FileNotFoundError:
        print(f"config not found: {path}", file=sys.stderr)
        raise SystemExit(2)


def _config_path(explicit):
    if explicit:
        return explicit
    if "AWWW_MANAGER_CONFIG" in os.environ:
        return os.environ["AWWW_MANAGER_CONFIG"]
    config_home = os.environ.get("XDG_CONFIG_HOME", os.path.expanduser("~/.config"))
    return os.path.join(config_home, "awww-manager", "config.toml")


def _state_path():
    state_home = os.environ.get("XDG_STATE_HOME", os.path.expanduser("~/.local/state"))
    return os.path.join(state_home, "awww-manager", "state.json")


def _load_state():
    path = _state_path()
    try:
        with open(path, "r", encoding="utf-8") as handle:
            return json.load(handle)
    except FileNotFoundError:
        return {}
    except json.JSONDecodeError:
        print(f"state file is invalid JSON: {path}", file=sys.stderr)
        return {}


def _save_state(state):
    path = _state_path()
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "w", encoding="utf-8") as handle:
        json.dump(state, handle)


def _expand_path(value):
    if not isinstance(value, str):
        return value
    return os.path.expandvars(os.path.expanduser(value))


def _merged_settings(general, output):
    merged = dict(general)
    merged.update(output)
    return merged


def _quote_cmd(cmd):
    return " ".join(shlex.quote(part) for part in cmd)


def _run(cmd, dry_run):
    if dry_run:
        print(_quote_cmd(cmd))
        return
    subprocess.run(cmd, check=True)


def _wait_for_backend(cmd, timeout, interval):
    deadline = time.time() + timeout
    while time.time() < deadline:
        result = subprocess.run(cmd, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        if result.returncode == 0:
            return True
        time.sleep(interval)
    return False


def _build_img_command(base_cmd, settings, wallpaper):
    cmd = [base_cmd, "img"]

    output_name = settings.get("name")
    if output_name:
        cmd.extend(["-o", str(output_name)])

    resize = settings.get("resize")
    if resize:
        cmd.extend(["--resize", str(resize)])

    image_filter = settings.get("filter")
    if image_filter:
        cmd.extend(["--filter", str(image_filter)])

    transition_type = settings.get("transition_type")
    if transition_type:
        cmd.extend(["--transition-type", str(transition_type)])

    transition_step = settings.get("transition_step")
    if transition_step is not None:
        cmd.extend(["--transition-step", str(transition_step)])

    transition_fps = settings.get("transition_fps")
    if transition_fps is not None:
        cmd.extend(["--transition-fps", str(transition_fps)])

    transition_duration = settings.get("transition_duration")
    if transition_duration is not None:
        cmd.extend(["--transition-duration", str(transition_duration)])

    transition_angle = settings.get("transition_angle")
    if transition_angle is not None:
        cmd.extend(["--transition-angle", str(transition_angle)])

    transition_pos = settings.get("transition_pos")
    if transition_pos:
        cmd.extend(["--transition-pos", str(transition_pos)])

    fill_color = settings.get("fill_color")
    if fill_color:
        cmd.extend(["--fill-color", str(fill_color)])

    cmd.append(_expand_path(wallpaper))
    return cmd


def _ensure_backend_available(base_cmd):
    if not shutil.which(base_cmd):
        print(f"backend not found in PATH: {base_cmd}", file=sys.stderr)
        raise SystemExit(2)


def _output_mode(output):
    mode = output.get("mode")
    if mode:
        return str(mode).lower()
    if output.get("dir"):
        return "cycle"
    return "static"


def _output_key(output, index):
    return output.get("name") or f"output-{index}"


def _collect_images(output):
    dir_path = _expand_path(output.get("dir", ""))
    if not dir_path:
        return []
    if not os.path.isdir(dir_path):
        print(f"wallpaper dir not found: {dir_path}", file=sys.stderr)
        return []

    extensions = output.get("extensions") or ["png", "jpg", "jpeg", "gif", "webp"]
    ext_set = {str(ext).lower().lstrip(".") for ext in extensions}
    recursive = bool(output.get("recursive", False))

    images = []
    if recursive:
        for root, _, files in os.walk(dir_path):
            for filename in files:
                _, ext = os.path.splitext(filename)
                if ext.lower().lstrip(".") in ext_set:
                    images.append(os.path.join(root, filename))
    else:
        for filename in os.listdir(dir_path):
            _, ext = os.path.splitext(filename)
            if ext.lower().lstrip(".") in ext_set:
                path = os.path.join(dir_path, filename)
                if os.path.isfile(path):
                    images.append(path)

    images.sort()
    return images


def _choose_random(images, last_path):
    if not images:
        return None
    if len(images) == 1:
        return images[0]
    choice = random.choice(images)
    if last_path and choice == last_path:
        choice = random.choice([path for path in images if path != last_path])
    return choice


def _resolve_wallpaper(output, key, command, state):
    mode = _output_mode(output)
    if mode == "static":
        return output.get("wallpaper"), False

    images = _collect_images(output)
    if not images:
        return None, False

    entry = state.get(key, {})
    last_path = entry.get("path")
    index = entry.get("index", 0)

    if command == "random" or mode == "random":
        selection = _choose_random(images, last_path)
        state[key] = {"index": images.index(selection), "path": selection}
        return selection, True

    if command == "next":
        index = (index + 1) % len(images)
    elif command == "prev":
        index = (index - 1) % len(images)

    index = min(max(index, 0), len(images) - 1)
    selection = images[index]
    state[key] = {"index": index, "path": selection}
    return selection, True


def cmd_apply_like(config, dry_run, wait_seconds, command):
    general = config.get("general", {})
    base_cmd = general.get("backend_cmd", general.get("backend", "swww"))
    outputs = config.get("output", [])

    if not outputs:
        print("config has no [[output]] entries", file=sys.stderr)
        raise SystemExit(2)

    _ensure_backend_available(base_cmd)

    if wait_seconds > 0:
        ok = _wait_for_backend([base_cmd, "query"], wait_seconds, 0.1)
        if not ok:
            print(f"{base_cmd} backend not responding to query", file=sys.stderr)
            raise SystemExit(2)

    state = _load_state()
    updated = False

    for index, output in enumerate(outputs):
        key = _output_key(output, index)
        wallpaper, changed = _resolve_wallpaper(output, key, command, state)
        if not wallpaper:
            print(f"skipping output without wallpaper: {output.get('name', '<unknown>')}", file=sys.stderr)
            continue
        settings = _merged_settings(general, output)
        cmd = _build_img_command(base_cmd, settings, wallpaper)
        _run(cmd, dry_run)
        updated = updated or changed

    if updated and not dry_run:
        _save_state(state)


def cmd_list(config):
    outputs = config.get("output", [])
    if not outputs:
        print("config has no [[output]] entries", file=sys.stderr)
        raise SystemExit(2)
    state = _load_state()
    for index, output in enumerate(outputs):
        name = output.get("name", "<unknown>")
        mode = _output_mode(output)
        if mode == "static":
            wallpaper = output.get("wallpaper", "")
            current = _expand_path(wallpaper)
        else:
            images = _collect_images(output)
            key = _output_key(output, index)
            current = state.get(key, {}).get("path")
            if not current and images:
                current = images[0]
            current = _expand_path(current or "")
        print(f"{name}\t{mode}\t{current}")


def main():
    parser = argparse.ArgumentParser(description="Apply wallpapers via swww/awww using a TOML config.")
    parser.add_argument("--config", help="Path to config.toml (default: XDG config)")
    parser.add_argument("--dry-run", action="store_true", help="Print commands without executing them")
    parser.add_argument("--print-config", action="store_true", help="Print the config file and exit")
    parser.add_argument("--version", action="version", version=f"awww-manager {__version__}")
    parser.add_argument(
        "--wait",
        type=float,
        default=2.0,
        help="Seconds to wait for backend query to succeed (default: 2.0)",
    )

    subparsers = parser.add_subparsers(dest="command")
    subparsers.add_parser("apply", help="Apply wallpapers from config")
    subparsers.add_parser("list", help="List outputs and wallpapers from config")
    subparsers.add_parser("next", help="Advance to the next wallpaper for cycle outputs")
    subparsers.add_parser("prev", help="Go to the previous wallpaper for cycle outputs")
    subparsers.add_parser("random", help="Randomize wallpapers for non-static outputs")

    args = parser.parse_args()

    config_path = _config_path(args.config)

    if args.print_config:
        try:
            with open(config_path, "r", encoding="utf-8") as handle:
                print(handle.read(), end="")
        except FileNotFoundError:
            print(f"config not found: {config_path}", file=sys.stderr)
            raise SystemExit(2)
        return

    if not args.command:
        parser.error("the following arguments are required: command")

    config = _load_toml(config_path)

    if args.command == "apply":
        cmd_apply_like(config, args.dry_run, args.wait, "apply")
    elif args.command == "next":
        cmd_apply_like(config, args.dry_run, args.wait, "next")
    elif args.command == "prev":
        cmd_apply_like(config, args.dry_run, args.wait, "prev")
    elif args.command == "random":
        cmd_apply_like(config, args.dry_run, args.wait, "random")
    elif args.command == "list":
        cmd_list(config)


if __name__ == "__main__":
    main()
