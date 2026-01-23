import re

input_file = r'c:\Users\lezpr\Desktop\scripts\Game Scripts\Retro Breach\rbreachv4.15.lua'
output_file = r'c:\Users\lezpr\Desktop\scripts\Game Scripts\Retro Breach\rbreachv4.15.lua'

with open(input_file, 'r', encoding='utf-8') as f:
    content = f.read()

lines = content.split('\n')
cleaned_lines = []

for line in lines:
    stripped = line.strip()
    if stripped.startswith('--'):
        continue
    if 'print(' in line and (line.strip().startswith('print(') or 'local' not in line):
        continue
    if 'warn(' in line and (line.strip().startswith('warn(') or 'local' not in line):
        continue
    if '--' in line:
        idx = line.find('--')
        line = line[:idx].rstrip()
    if line.strip() or not cleaned_lines or cleaned_lines[-1].strip():
        cleaned_lines.append(line)

while cleaned_lines and not cleaned_lines[-1].strip():
    cleaned_lines.pop()

with open(output_file, 'w', encoding='utf-8') as f:
    f.write('\n'.join(cleaned_lines))

print("✅ Removed all comments and debug output")
