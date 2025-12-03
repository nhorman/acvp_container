
.PHONY: all clean

all:
	podman build -t acvp .

clean:
	podman rmi localhost/acvp
