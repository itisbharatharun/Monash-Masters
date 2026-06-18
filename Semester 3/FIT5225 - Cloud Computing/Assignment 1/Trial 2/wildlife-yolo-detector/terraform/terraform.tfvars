# =============================================================================
# terraform.tfvars — Actual values for CloudEco GCP deployment (Melbourne)
# NEVER commit this file to version control — it contains your SSH public key.
# =============================================================================

project_id           = "fit5225-cloudeco"
region               = "australia-southeast2"
zone                 = "australia-southeast2-a"
machine_type         = "e2-standard-4"
disk_size_gb         = 50
ssh_private_key_path = "~/.ssh/fit5225_oci"

# Paste the full content of: cat ~/.ssh/fit5225_oci.pub
ssh_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC7a28/J21T+F6xfmrLtFq4yBLsQ5dKgvPz2aKP4HQ03q6mVL+BIKa0jt+rwZO/ZHYuWKlL4eZNpZl4F4rpfiWiZ/iAIg6RU5Pfa8o9GeIQLypSHO7FqStYjNiW6f/z582ynhanM+YqbzUN+59PPM02wgaAFuxxj84RjwQ+WkOCzP4P+7t94+Nx/F6sMrgByUMvCvBgd8zGloKDpFZtyG6URFfw+CcDGNCkb77RpvDuNzcQAJdez6jKlMhPjJsyLFlbVSlhKSxJ3JS44yG3DsDpf9U53lqRFtsufZiyrwCMByxZqSVSdzoPOGzsHxeeYPj9hPXWyMnf7j1IT4WAo5ibDyH2x5wL6FLPxBwgxJqBnE1rwVCSXpi0DPI7k+GBkNz5TRaYIfOJ7SgnIiVd8UkcjlVjXFNauaaOn2Yea841aOtAdoISgsguFa2aYN0e+1NxSijKPbGk9CP0Z1QrCHC+FfGj4gMz/7Y4m34gsnHkkZJ5CxMPvTlmzVYrmGcc37rDYCbohG5xCvX3l4puPVuRIZJOF9tW8wdoY9jz/vrJTNYbsM6aiiU9IYSPEhhga5QrH0h9F2j/FJ2emz82VVMDl7AmNDsSj8Jmdbn1rYTfJDSsHlO+HNPt1TcVHEQJYTIH2sda+Utsz8Mu0AfvVuGjGAYAX1uB6EfWBnPITDJOaQ== heisenberg@Mac.modem"
