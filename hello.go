package main

import "fmt"
import "os"

func main() {
	for i := range os.Args {
		a := os.Args[i]
		if a == "--version" {
			fmt.Printf("hello %s\n", CONST_PACKAGE_VERSION)
		}
	}
}
