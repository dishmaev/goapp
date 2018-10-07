package main

import "fmt"
import "os"
import "./version"

func main() {
	for i := range os.Args {
		a := os.Args[i]
		if a == "--version" {
			fmt.Printf("hello %s\n", version.CONST_PACKAGE_VERSION)
		}
	}
}
