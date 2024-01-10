#Crea un bucket s3
resource "aws_s3_bucket" "demo" {
  bucket = "Demo"

  tags = {
    Name = "Demo"
  }
}