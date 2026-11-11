"""Check native plugin class definitions in the built APK or app bundle."""

import argparse
import struct
from zipfile import ZipFile


def defined_classes(data):
    if not data.startswith(b"dex\n"):
        raise ValueError("Expected an Android DEX file")

    def uint(offset):
        return struct.unpack_from("<I", data, offset)[0]

    def descriptor(type_index):
        string_index = uint(uint(68) + type_index * 4)
        offset = uint(uint(60) + string_index * 4)
        # Skip the ULEB128 UTF-16 string length before the descriptor.
        while data[offset] & 0x80:
            offset += 1
        offset += 1
        return data[offset:data.index(b"\0", offset)].decode("utf-8")

    return {
        descriptor(uint(uint(100) + index * 32))
        for index in range(uint(96))
    }


def verify(path):
    classes = set()
    with ZipFile(path) as archive:
        for entry in archive.namelist():
            if entry.endswith(".dex"):
                classes.update(defined_classes(archive.read(entry)))
    required = {
        "Lio/flutter/plugins/GeneratedPluginRegistrant;",
        "Lcom/tekartik/sqflite/SqflitePlugin;",
        "Lio/flutter/plugins/sharedpreferences/SharedPreferencesPlugin;",
        "Lio/flutter/plugins/pathprovider/PathProviderPlugin;",
        "Lcom/mr/flutter/plugin/filepicker/FilePickerPlugin;",
        "Lcom/dexterous/flutterlocalnotifications/FlutterLocalNotificationsPlugin;",
        "Lnet/wolverinebeach/flutter_timezone/FlutterTimezonePlugin;",
        "Ldev/fluttercommunity/plus/share/SharePlusPlugin;",
        "Lcom/dhikrapp/qurantracker/DhikrWidgetProvider;",
    }
    missing = required - classes
    if missing:
        raise SystemExit("Native plugin classes missing: " + ", ".join(sorted(missing)))
    print(f"Verified Android plugin registration classes: {path}")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("artifact")
    verify(parser.parse_args().artifact)
