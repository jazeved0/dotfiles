#!/usr/bin/env python3
import argparse
import os
import sys
import traceback
from configparser import ConfigParser
from dataclasses import dataclass
from typing import Dict


@dataclass
class WindowRule:
  color: str
  dark: bool
  window_class: str


# All custom titlebar rules
RULES = {
  "vscode": WindowRule(color="#21252b", dark=True, window_class="code"),
  "gimp": WindowRule(color="#454545", dark=True, window_class="gimp"),
  "chrome": WindowRule(color="#242424", dark=True, window_class="google-chrome"),
  "spotify": WindowRule(color="#000000", dark=True, window_class="spotify"),
  "settings": WindowRule(color="#242424", dark=True, window_class="systemsettings"),
  "dolphin": WindowRule(color="#2c2f2f", dark=True, window_class="dolphin"),
  "inkscape": WindowRule(color="#242424", dark=True, window_class="inkscape"),
  "discord": WindowRule(color="#36393f", dark=True, window_class="discord"),
  "konsole": WindowRule(color="#1F2229", dark=True, window_class="konsole"),
}

DARK_ACTIVE_TEXT_COLOR="222,222,222"
DARK_INACTIVE_TEXT_COLOR="120,120,120"
LIGHT_ACTIVE_TEXT_COLOR="40,40,40"
LIGHT_INACTIVE_TEXT_COLOR="100,100,100"


def main(kwinrulesrc: str,
         template: str,
         color_scheme_dest: str,
         rules: Dict[str, WindowRule]):
    # Read in the kwin rules file
    if os.path.exists(kwinrulesrc):
      with open(kwinrulesrc, 'r') as kwinrulesrc_file:
        kwinrulesrc_contents = kwinrulesrc_file.read()
    else:
       kwinrulesrc_contents = ""

    # Read in the template file
    with open(template, 'r') as template_file:
      template_contents = template_file.read()

    # Parse & update the kwinrulesrc file
    parsed_rules = parse_kwinrulesrc(kwinrulesrc_contents)
    updated_rules = update_kwinrulesrc(parsed_rules, rules)
    with open(kwinrulesrc, 'w') as kwinrulesrc_file:
      updated_rules.write(kwinrulesrc_file)

    # Create the templated color schemes
    color_scheme_files = render_color_schemes(rules, template_contents)
    for filename, contents in color_scheme_files.items():
      with open(os.path.join(color_scheme_dest, filename), 'w') as color_scheme_file:
        color_scheme_file.write(contents)


def parse_kwinrulesrc(contents: str) -> ConfigParser:
  config = ConfigParser()
  config.read_string(contents)
  return config


def section_to_dict(file: ConfigParser, section_name: str) -> Dict[str, str]:
  return {k: file[section_name][k] for k in file[section_name]}


def update_kwinrulesrc(file: ConfigParser, rules: Dict[str, WindowRule]) -> ConfigParser:
  numeric_section_headers = [section for section in file.sections() if section.isnumeric()]
  count = len(numeric_section_headers)

  # Match the sections to see already-existing rendered rules
  unmatched = []
  for numeric_section_header in numeric_section_headers:
    if "Description" in file[numeric_section_header] and file[numeric_section_header]["Description"].startswith("titlebar-"):
      suffix = file[numeric_section_header]["Description"].removeprefix("titlebar-")
      if suffix in rules:
        continue
    unmatched.append(numeric_section_header)

  # Preserve unmatched sections before re-numbering them
  unmatched_sections = [section_to_dict(file, header) for header in unmatched]

  # Render each rule into the config
  current_count = 0
  for rule_name, rule in rules.items():
    current_count += 1
    section_header = str(current_count)
    render_rule(file=file, section=section_header, name=rule_name, rule=rule)

  # Add unmatched rules
  for section in unmatched_sections:
    current_count += 1
    section_header = str(current_count)
    file[section_header] = section

  # Update the count
  if "General" not in file:
    file.add_section("General")
  file["General"]["count"] = str(current_count)

  # Add the version
  if "$Version" not in file:
    file.add_section("$Version")
  file["$Version"]["update_info"] = "kwinrules.upd:replace-placement-string-to-enum"

  return file


def render_rule(file: ConfigParser, section: str, name: str, rule: WindowRule):
  if section in file:
    file.remove_section(section)
  file[section] = {
    "Description": f"titlebar-{name}",
    "decocolor": f"titlebar-{name}",
    "decocolorrule": "2",
    "wmclass": rule.window_class,
    "wmclassmatch": "1",
  }


def render_color_schemes(rules: Dict[str, WindowRule], template_contents: str) -> Dict[str, str]:
  rendered = {}
  for key, rule in rules.items():
    without_pound = rule.color.removeprefix("#")
    r_hex, g_hex, b_hex = without_pound[0:2], without_pound[2:4], without_pound[4:6]
    r, g, b = int(r_hex, base=16), int(g_hex, base=16), int(b_hex, base=16)
    rendered[f"titlebar-{key}.colors"] = (template_contents
      .replace("{:name}", f"titlebar-{key}")
      .replace("{:color}", f"{r},{g},{b}")
      .replace("{:active_text_color}", DARK_ACTIVE_TEXT_COLOR if rule.dark else LIGHT_ACTIVE_TEXT_COLOR)
      .replace("{:inactive_text_color}", DARK_INACTIVE_TEXT_COLOR if rule.dark else LIGHT_INACTIVE_TEXT_COLOR)
    )
  return rendered


def bootstrap():
    parser = argparse.ArgumentParser()
    parser.add_argument('--kwinrulesrc', type=str, required=True,
                        help='location of kwinrules file to write to')
    parser.add_argument('--template', type=str, required=True,
                        help='location of template color scheme file')
    parser.add_argument('--color-scheme-dest', type=str, required=True,
                        help='destination path to create color scheme files in')
    args = parser.parse_args()
    try:
      main(kwinrulesrc=args.kwinrulesrc,
                template=args.template,
                color_scheme_dest=args.color_scheme_dest,
                rules=RULES)
      sys.exit(0)
    except Exception:
      traceback.print_exc()
      sys.exit(1)


if __name__ == "__main__":
    bootstrap()
