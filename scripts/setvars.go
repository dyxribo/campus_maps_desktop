package main

import (
	"bytes"
	"fmt"
	"io/ioutil"
	"os"
	"path/filepath"
	"strings"
)

func main() {
	appname_template := "${APPNAME}"

	input, err := ioutil.ReadFile("src/application.xml")
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

	output := bytes.Replace(input, []byte(appname_template), []byte(folder), -1)
	if err = ioutil.WriteFile("src/application.xml", output, 0666); err != nil {
		fmt.Println(err)
		os.Exit(1)
	}

	os.Exit(0)
}
