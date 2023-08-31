import os
import argparse

def replace_package_in_file(filepath, old_package, new_package):
    with open(filepath, 'r', encoding='utf-8') as file:
        content = file.read()
        content = content.replace(old_package, new_package)
    with open(filepath, 'w', encoding='utf-8') as file:
        file.write(content)

def main(directory, old_package, new_package):
    # Convert package names to path format
    old_path = old_package.replace('.', '/')
    new_path = new_package.replace('.', '/')

    # Iterate through all files in the directory
    for root, dirs, files in os.walk(directory):
        for file in files:
            if file.endswith(".as"):
                filepath = os.path.join(root, file)
                replace_package_in_file(filepath, old_package, new_package)

    # Rename directories to reflect new package name
    old_package_directory = os.path.join(directory, old_path)
    new_package_directory = os.path.join(directory, new_path)

    if os.path.exists(old_package_directory):
        os.renames(old_package_directory, new_package_directory)

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Rename AS3 package in a directory')
    parser.add_argument('directory', type=str, help='Path to the directory with AS3 files')
    parser.add_argument('old_package', type=str, help='Current package name, e.g., com.old.name')
    parser.add_argument('new_package', type=str, help='New package name, e.g., com.new.name')
    args = parser.parse_args()
    main(args.directory, args.old_package, args.new_package)
