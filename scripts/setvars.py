import os
import re
import sys
import shutil

def main():
    appname_template = "${APPNAME}"
    savedata_file_path = "src/config/SaveData.as"
    application_xml_path = "src/application.xml"

    pattern = re.compile(r'(VERSION_REVISION:uint\s*=\s*)(\d+)')

    try:
        with open(application_xml_path, 'r') as app_xml_file:
            application_xml = app_xml_file.read()
    except Exception as e:
        print(e)
        sys.exit(1)

    folder = os.path.basename(os.path.abspath('.')).upper()
    revised_app_xml = application_xml.replace(appname_template, folder)

    try:
        with open(application_xml_path, 'w') as app_xml_file:
            app_xml_file.write(revised_app_xml)
    except Exception as e:
        print(e)
        sys.exit(1)

    try:
        with open(savedata_file_path, 'r') as savedata_file:
            savedata_struct = savedata_file.read()
    except Exception as e:
        print(e)
        sys.exit(1)

    def replace_number(match):
        prefix = match.group(1)
        number_str = match.group(2)

        try:
            number = int(number_str)
        except ValueError:
            return match.group(0)

        # Increment the number
        number += 1

        # Return the incremented number as a string
        return f'{prefix}{number}'

    revised_savedata_struct = pattern.sub(replace_number, savedata_struct)

    try:
        with open(savedata_file_path, 'w') as savedata_file:
            savedata_file.write(revised_savedata_struct)
    except Exception as e:
        print("Error writing the updated content to the file:", e)
        return

    sys.exit(0)

if __name__ == "__main__":
    main()
