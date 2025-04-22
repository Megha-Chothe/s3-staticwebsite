
# 1. Create the S3 bucket
resource "aws_s3_bucket" "mys3newbucket" {
  bucket = var.bucketname
}

# 2. Set bucket ownership (disable ACLs)
resource "aws_s3_bucket_ownership_controls" "ownership" {
  bucket = aws_s3_bucket.mys3newbucket.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }

  depends_on = [aws_s3_bucket.mys3newbucket]  # ✅ Fix: ensure bucket exists first
}

# 3. Allow public access by disabling block settings
resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket = aws_s3_bucket.mys3newbucket.id

  block_public_acls       = false
  ignore_public_acls      = false
  block_public_policy     = false
  restrict_public_buckets = false

  depends_on = [aws_s3_bucket.mys3newbucket]
}

# 4. Configure S3 for website hosting
resource "aws_s3_bucket_website_configuration" "website_config" {
  bucket = aws_s3_bucket.mys3newbucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }

  depends_on = [aws_s3_bucket_public_access_block.public_access]
}

# 5. Upload your website files
resource "aws_s3_object" "index" {
  bucket       = aws_s3_bucket.mys3newbucket.id
  key          = "index.html"
  source       = "index.html"
  content_type = "text/html"

  depends_on = [aws_s3_bucket_public_access_block.public_access]
}

resource "aws_s3_object" "error" {
  bucket       = aws_s3_bucket.mys3newbucket.id
  key          = "error.html"
  source       = "error.html"
  content_type = "text/html"

  depends_on = [aws_s3_bucket_public_access_block.public_access]
}

resource "aws_s3_object" "profile" {
  bucket       = aws_s3_bucket.mys3newbucket.id
  key          = "profile.png"
  source       = "profile.png"
  content_type = "image/png"

  depends_on = [aws_s3_bucket_public_access_block.public_access]
}

# 6. Add public read access using a bucket policy
resource "aws_s3_bucket_policy" "public_policy" {
  bucket = aws_s3_bucket.mys3newbucket.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "PublicReadGetObject",
        Effect    = "Allow",
        Principal = "*",
        Action    = "s3:GetObject",
        Resource  = "${aws_s3_bucket.mys3newbucket.arn}/*"
      }
    ]
  })

  depends_on = [aws_s3_bucket_public_access_block.public_access]
}