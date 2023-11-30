provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Owner = "sspreafico"
    }
  }
}
