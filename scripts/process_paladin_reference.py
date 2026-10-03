#!/usr/bin/env python3
"""Compatibility entry point for rebuilding only the Paladin sheets."""
from process_character_references import process_class

if __name__ == "__main__":
    process_class("paladin")
