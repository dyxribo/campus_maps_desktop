package main

import (
	"bytes"
	"fmt"
	"os"
	"path/filepath"
	"regexp"
	"strconv"
	"strings"
)

func main() {
	appname_template := "${APPNAME}"
	savedata_file_path := "src/config/SaveData.as"
	application_xml_path := "src/application.xml"

	pattern := regexp.MustCompile(`(VERSION_REVISION:uint\s*=\s*)(\d+)`)

	application_xml, err := os.ReadFile(application_xml_path)
	if err != nil {
		fmt.Println(err)
		os.Exit(1)
	}

	fp, err := filepath.Abs(".")
	if err != nil {
		fmt.Println(err)
		os.Exit(1)
	}
	folder := strings.ToUpper(filepath.Base(fp))

	revised_app_xml := bytes.Replace(application_xml, []byte(appname_template), []byte(folder), -1)
	if err = os.WriteFile(application_xml_path, revised_app_xml, 0666); err != nil {
		fmt.Println(err)
		os.Exit(1)
	}

	savedata_struct, err := os.ReadFile(savedata_file_path)
	if err != nil {
		fmt.Println(err)
		os.Exit(1)
	}

	revised_savedata_struct := pattern.ReplaceAllFunc(savedata_struct, func(match []byte) []byte {
		submatch := pattern.FindSubmatch(match)
		prefix := submatch[1]
		numberStr := submatch[2]

		number, err := strconv.Atoi(string(numberStr))
		if err != nil {
			return match
		}

		// Increment the number
		number++

		// Return the incremented number as a byte slice
		return append(prefix, []byte(strconv.Itoa(number))...)
	})

	err = os.WriteFile(savedata_file_path, revised_savedata_struct, os.ModePerm)
	if err != nil {
		fmt.Println("Error writing the updated content to the file:", err)
		return
	}

	os.Exit(0)
}
