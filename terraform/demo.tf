#Crea un bucket s3
resource "aws_s3_bucket" "demo" {
  bucket = "democertimeter"

  tags = {
    Name = "Demo"
  }
}