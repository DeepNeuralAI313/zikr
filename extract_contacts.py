import re

# Read the CSV file
with open('test.csv', 'r', encoding='utf-8') as f:
    lines = f.readlines()

names = []
emails = []

for line in lines:
    line = line.strip().rstrip(',')
    if not line:
        continue
    
    # Pattern: "Name <email>" or just "email"
    match = re.match(r'^(.+?)\s*<(.+?)>$', line)
    if match:
        name = match.group(1).strip()
        email = match.group(2).strip()
        names.append(name)
        emails.append(email)
    else:
        # Just email without name
        email = line.strip()
        emails.append(email)
        names.append("")  # Empty name

# Print results
print("NAMES LIST:")
print(names)
print("\n" + "="*80 + "\n")
print("EMAILS LIST:")
print(emails)
print("\n" + "="*80 + "\n")
print(f"Total contacts: {len(emails)}")
print(f"With names: {len([n for n in names if n])}")
print(f"Email only: {len([n for n in names if not n])}")

# Save to output file
with open('extracted_contacts.txt', 'w', encoding='utf-8') as f:
    f.write("NAMES:\n")
    f.write(str(names))
    f.write("\n\n" + "="*80 + "\n\n")
    f.write("EMAILS:\n")
    f.write(str(emails))
    f.write("\n\n" + "="*80 + "\n\n")
    f.write("Python Lists (ready to copy):\n\n")
    f.write("names = " + str(names) + "\n\n")
    f.write("emails = " + str(emails) + "\n")

print("\nOutput saved to: extracted_contacts.txt")
