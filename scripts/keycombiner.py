import itertools
import xml.etree.ElementTree as ET
import csv
import re

ascii = {
    'add': '+',
      'closebracket': ']',
    'openbracket': ']',
    'backslash': '\\',
    'backquote': '`',
    'slash': '/',
    'comma': ',',
    'multiply': '*',
    'divide': '/',
    'subtract': '-',
    'period': '.',
    'quote': '\'',
    'space': 'space',
    'equals': '=',
    'minus': '-',
    'control': 'ctrl',
    #'meta': 'ctrl',
}

def split_camel_case(camel_case_str):
    # Use a regular expression to find matches where a lowercase letter is followed by an uppercase letter
    split_words = re.sub('([a-z])([A-Z])', r'\1 \2', camel_case_str)
    return split_words.replace(".", " ")

def trans(key):
   if str(key) in ascii:
      return ascii[str(key)]
   return key

# Prepare data for CSV
def parse_xml(file):
  # Parse the XML content
  root = None
  with open(file, "r") as f:  
    root = ET.fromstring(f.read())

  result = {}


  for action in root.findall('action'):
      action_id = action.get('id')
      context, description = "Main", action_id
      
      if '.' in action_id:
          context, description = action_id.split('.', 1)
      
      context, description = split_camel_case(context), split_camel_case(description)
      if context and context.lower().startswith("Editor"):
          context = "Editor"
      keys = []
      for shortcut in action.findall('keyboard-shortcut'):
          f = shortcut.get('first-keystroke')
          s = shortcut.get('second-keystroke')
        
          first = f.lower().replace("_", "") if f else None
          second = s.lower().replace("_", "") if s else None


          first_keystroke = "+".join(map(trans, str(first).split(" ")))
          second_keystroke = "+".join(map(trans, str(second).split(" ")))
          if second:
              keys.append(f"{first_keystroke} {second_keystroke}")
          else:
              keys.append(first_keystroke)
      
      for shortcut in action.findall('mouse-shortcut'):
        keystroke = "+".join(shortcut.get('keystroke').split(" "))
        keys.append(keystroke)

      if keys:
          keys_combined = " OR ".join(keys)
      else:
          keys_combined = ""

      result[(description, context)] = keys_combined
  return result

def write(target, data):
  # Define CSV file header
  csv_header = ["Description","Keys","Context","Category","Conf.","Actions"]

  done = []
  with open(target, mode='w', newline='') as file:
      writer = csv.writer(file, quoting=csv.QUOTE_ALL)
      writer.writerow(csv_header)
      for key, val in data.items():
        desription, context = key
        if not val or "++" in val or "+-" in val or "click" in val or "button" in val: 
           continue
        if val in done: continue
        done.append(val)
        writer.writerow([desription, val, context, "General", "0", ""])

  print(f"CSV file '{target}' has been created.")

def transform(origin, target):

    #default = parse("C:\\dev\\zmk\\shortcut\\$default.xml")
    keymap = parse_xml(origin)
    # print(set(list((map(lambda x: (x[0],x[1]), data)))))
    # print(set(list(itertools.chain.from_iterable((map(lambda x: re.split("\s*(OR|\\+|>)\s*", x[1]), data))))))
    write(target, keymap)