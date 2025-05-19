# Image Parser
This project demonstrates a serverless image upload pipeline using AWS services — S3, Lambda, and DynamoDB — provisioned with Terraform.

## Architecture

![image](https://github.com/user-attachments/assets/f481df6d-4fec-4e31-a96e-f45686e7bdea)


## Workflow

- Upload `.jpg`, `jpeg` or `.png` files to an S3 bucket.
- Trigger a Lambda function upon upload.
- Extract image metadata (name, size, upload time).
- Store metadata in a DynamoDB table.

## Project Structure
.

├── function/

│     └── lambda_function.py # Lambda function to process uploaded images

├── infrastructure/

│     └── main.tf # Main Terraform file for resources

└── get_zip.sh # simple bash script to create a zip file of lambda_function.py and place in infrastructure directory
  

## Prerequisites
- [Terraform](https://developer.hashicorp.com/terraform/install)
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)
- AWS account credentials configured (`aws configure`) with admin privileges
- zip

NB: This project was built in a linux environment

## Running Locally

1. Clone the repository and change directory to the file_parser folder


```bash
    git clone https://github.com/Ghaby-X/file_parser.git
    cd file_parser
```


2. Run get_zip.sh script
```bash
   chmod +x get_zip.sh && ./get_zip.sh
```

This script generates a zip file of lambda_function.py and stores it in infrastructure/lambda_function_payload.zip


3. Navigate to infrastructure and initialize terraform
```bash
   cd infrastructure && terraform init
```


4. Provision the infrastructure with terraform
```bash
   terraform apply --auto-approve
```

## Cleanup
To cleanup the provisioned resources, ensure you are in the infrastructure directory and run the following;
```
    terraform destroy --auto-approve
```
