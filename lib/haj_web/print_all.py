import os

def print_all_files(directory):
    for root, _, files in os.walk(directory):
        for file in files:
            # Full path of the file
            file_path = os.path.join(root, file)
            # Skip non-text files
            if file.endswith(('.ex', '.heex', '.html', '.exs', '.txt')):
                try:
                    with open(file_path, 'r', encoding='utf-8') as f:
                        print(f"### File: {file_path} ###")
                        print(f.read())
                        print("\n" + "="*80 + "\n")
                except Exception as e:
                    print(f"Could not read file {file_path}: {e}")

# Replace the directory path with your actual app directory
app_directory = "/home/nils/programing/haj/lib/haj_web"
print_all_files(app_directory)
