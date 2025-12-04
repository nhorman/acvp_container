
.PHONY: all clean

all:
	podman build -t acvp .

run:
	podman run -it --rm --secret=ACV_CA_FILE_SECRET,type=mount,target=/secrets/acv_ca_file --secret=ACV_KEY_FILE_SECRET,type=mount,target=/secrets/acv_key_file --secret=ACV_CERT_FILE_SECRET,type=mount,target=/secrets/acv_cert_file --secret=ACV_TOTP_SEED_SECRET,type=mount,target=/secrets/acv_totp_seed localhost/acvp

clean:
	podman rmi localhost/acvp
