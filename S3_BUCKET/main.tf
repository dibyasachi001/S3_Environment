############################################################################
# Provider    
terraform { 
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.83.1"
      configuration_aliases = [aws.primary, aws.secondary]
    }
  }
} 

# RANDOM String/Timestamp for unique bucketname
resource "random_id" "random_suffix" {
  count = (var.source_bucket != "" || var.destination_bucket != "") ? 1 : 0
  byte_length = 4
}

# Source bucket resources
resource "aws_s3_bucket" "sourcebucket" {
  provider = aws.primary
  count = var.source_bucket != "" ? 1 : 0
  bucket   = var.source_bucket != "" && length(random_id.random_suffix) > 0 ? "${var.source_bucket}-${random_id.random_suffix[0].hex}" : var.source_bucket
  force_destroy = false
}

# Destination bucket resources
resource "aws_s3_bucket" "destinationbucket" {
  provider = aws.secondary
  count = var.destination_bucket != "" ? 1 : 0
  bucket   = var.destination_bucket != "" && length(random_id.random_suffix) > 0 ? "${var.destination_bucket}-${random_id.random_suffix[0].hex}" : var.destination_bucket
  force_destroy = false
}

# SOURCE BUCKET VERSIONING
resource "aws_s3_bucket_versioning" "bucket_source_versioning" {
  provider = aws.primary
  bucket = aws_s3_bucket.sourcebucket[0].bucket

  versioning_configuration {
    status = var.source_versioning ? "Enabled" : "Suspended"
  }
} 

# DESTINATION BUCKET VERSIONING
resource "aws_s3_bucket_versioning" "bucket_destination_versioning" {
  provider = aws.secondary
  bucket = aws_s3_bucket.destinationbucket[0].bucket

  versioning_configuration {
    status = var.destination_versioning ? "Enabled" : "Suspended"
  }
  
}

# S3 LIFECYCLE MANAGEMENT(source)
resource "aws_s3_bucket_lifecycle_configuration" "sourcelifecycle1" {
  provider = aws.primary
  count = var.apply_sourcebucket_lifecycle ? 1 : 0
  bucket = aws_s3_bucket.sourcebucket[0].bucket
  
  # Rule for the entire bucket#############################
  rule {
      id     = var.sourcelifecycle_rule_name                # Lifecycle rule name but should be unique
      status = "Enabled"

      filter {
        prefix = var.sourcelifecycle_rule_prefix_name
      }

      transition {
        days          = var.sourcebucket_transition_days
        storage_class = var.sourcebucket_transition_storage_class
      }

      expiration {
        days = var.sourcebucket_expiration_days
      }

      abort_incomplete_multipart_upload {
        days_after_initiation = var.source_abort_multipart_days
      }
    
  }

  # Rule for a specific folder#############################
  dynamic "rule" {
    for_each = length(var.sourcefolder) > 0 ? [1] : []
    content {
      id     = "folder-specific-rule"            # Folder name but should be unique
      status = "Enabled"

      filter {
        prefix = var.sourcefolder
      }

      transition {
        days          = var.sourcefolder_transition_days
        storage_class = var.sourcefolder_transition_storage_class
      }

      expiration {
        days = var.sourcefolder_expiration_days
      }

      abort_incomplete_multipart_upload {
        days_after_initiation = var.source_abort_multipart_days
      }
    }
  }

  # Rule for a specific file###############################
  dynamic "rule" {
    for_each = length(var.sourcefile) > 0 ? [1] : []
    content {
      id     = "file-specific-rule"              # File name but should be unique
      status = "Enabled"

      filter {
        prefix = var.sourcefile
      }

      transition {
        days          = var.sourcefile_transition_days
        storage_class = var.sourcefile_transition_storage_class
      }

      expiration {
        days = var.sourcefile_expiration_days
      }

      abort_incomplete_multipart_upload {
        days_after_initiation = var.source_abort_multipart_days
      }
    }
  }
}

# S3 LIFECYCLE MANAGEMENT(destination)
resource "aws_s3_bucket_lifecycle_configuration" "destinationlifecycle1" {
  provider = aws.secondary
  count = var.apply_destinationbucket_lifecycle ? 1 : 0
  bucket = aws_s3_bucket.destinationbucket[0].bucket
  
  # Rule for the entire bucket#############################
  rule {
      id     = var.destinationlifecycle_rule_name                # Lifecycle rule name but should be unique
      status = "Enabled"

      filter {
        prefix = var.destinationlifecycle_rule_prefix_name
      }

      transition {
        days          = var.destinationbucket_transition_days
        storage_class = var.destinationbucket_transition_storage_class
      }

      expiration {
        days = var.destinationbucket_expiration_days
      }

      abort_incomplete_multipart_upload {
        days_after_initiation = var.destination_abort_multipart_days
      }
    
  }

  # Rule for a specific folder#############################
  dynamic "rule" {
    for_each = length(var.destinationfolder) > 0 ? [1] : []
    content {
      id     = "folder-specific-rule"            # Folder name but should be unique
      status = "Enabled"

      filter {
        prefix = var.destinationfolder
      }

      transition {
        days          = var.destinationfolder_transition_days
        storage_class = var.destinationfolder_transition_storage_class
      }

      expiration {
        days = var.destinationfolder_expiration_days
      }

      abort_incomplete_multipart_upload {
        days_after_initiation = var.destination_abort_multipart_days
      }
    }
  }

  # Rule for a specific file###############################
  dynamic "rule" {
    for_each = length(var.destinationfile) > 0 ? [1] : []
    content {
      id     = "file-specific-rule"              # File name but should be unique
      status = "Enabled"

      filter {
        prefix = var.destinationfile
      }

      transition {
        days          = var.destinationfile_transition_days
        storage_class = var.destinationfile_transition_storage_class
      }

      expiration {
        days = var.destinationfile_expiration_days
      }

      abort_incomplete_multipart_upload {
        days_after_initiation = var.destination_abort_multipart_days
      }
    }
  }
}

############################################################################
###############################################
# IAM ROLE FOR REPLICATION
resource "aws_iam_role" "replication_role" {
  count = var.enable_replication ? 1 : 0
  name  = "s3-replication-role-${random_id.random_suffix[0].hex}"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "s3.amazonaws.com"
        },
        "Action" : "sts:AssumeRole",
        "Condition" : {
          "ArnLike" : {
            "aws:SourceArn" : "${aws_s3_bucket.sourcebucket[0].arn}"
          }
        }
      }
    ]
  })
}

###############################################
# IAM POLICY FOR REPLICATION
resource "aws_iam_policy" "replication_policy" {
  count = var.enable_replication ? 1 : 0
  name  = "s3-replication-policy-${random_id.random_suffix[0].hex}"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
       # Permissions to read and replicate objects from the source bucket
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:GetReplicationConfiguration",
          "s3:ListBucket"
        ],
        "Resource" : [
          "${aws_s3_bucket.sourcebucket[0].arn}"
        ]
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:GetObjectVersion",
          "s3:GetObjectVersionAcl",
          "s3:GetObjectVersionForReplication",
          "s3:GetObjectVersionTagging",
          "s3:ReplicateObject",
          "s3:ReplicateDelete",
          "s3:ReplicateTags"
        ],
        "Resource" : [
          "${aws_s3_bucket.sourcebucket[0].arn}/*"
        ]
      },
      # Permissions to write to the destination bucket
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:ReplicateObject",
          "s3:ReplicateDelete",
          "s3:ListBucketVersions",
          "s3:ObjectOwnerOverrideToBucketOwner"
        ],
        "Resource" : [
          "${aws_s3_bucket.destinationbucket[0].arn}/*"
          ]
      },
      # Permissions to apply the bucket policy in the destination bucket
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:GetBucketPolicy",
          "s3:PutBucketPolicy",
          "s3:GetBucketVersioning",
          "s3:PutBucketVersioning"
        ],
        "Resource" : [
          "${aws_s3_bucket.destinationbucket[0].arn}",
          "${aws_s3_bucket.destinationbucket[0].arn}/*"
          ]
      }
    ]
  })
}

###############################################
# ATTACH POLICY TO ROLE
resource "aws_iam_role_policy_attachment" "replication_role_attachment" {
  count      = var.enable_replication ? 1 : 0
  role       = aws_iam_role.replication_role[0].name
  policy_arn = aws_iam_policy.replication_policy[0].arn
}

###############################################
resource "aws_s3_bucket_policy" "destination_policy" {
  provider = aws.secondary
  #count  = var.is_cross_account ? 1 : 0
  count = (var.is_cross_account || var.enable_replication) ? 1 : 0
  bucket = aws_s3_bucket.destinationbucket[0].bucket

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      # Allow the IAM role to replicate objects
      {
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "${aws_iam_role.replication_role[0].arn}"       # Reference IAM Role dynamically
        },
        "Action" : [
          "s3:ReplicateObject",
          "s3:ReplicateDelete",
          "s3:ReplicateTags",
          "s3:GetObjectVersionTagging",
          "s3:ObjectOwnerOverrideToBucketOwner"
        ],
        "Resource" : [
          "${aws_s3_bucket.destinationbucket[0].arn}/*"
          ]
      },
      # Allow the IAM role to modify the bucket policy
      {
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "${aws_iam_role.replication_role[0].arn}"
        },
        "Action" : [
          "s3:List*",
          "s3:PutBucketPolicy",
          "s3:GetBucketPolicy",
          "s3:GetBucketVersioning",
          "s3:PutBucketVersioning"
        ],
        "Resource" : [
          "${aws_s3_bucket.destinationbucket[0].arn}"
          ]
      }
    ]
  })
}

##############################################################################
# ENABLE REPLICATION
resource "aws_s3_bucket_replication_configuration" "replication" {
  provider = aws.primary
  count  = var.enable_replication ? 1 : 0
  bucket = aws_s3_bucket.sourcebucket[0].bucket
  role   = aws_iam_role.replication_role[0].arn

  rule {
    id       = "replication-rule"
    status   = "Enabled"

    filter {
      prefix = ""
    }

    destination {
      bucket        = aws_s3_bucket.destinationbucket[0].arn
      storage_class = var.replication_storage_class
      
      dynamic "access_control_translation" {
        for_each = var.is_cross_account ? [1] : []
        content {
          owner = "Destination"
        }
      }

      # Only include account if cross-account replication is enabled
      account = var.is_cross_account ? var.destination_account_id : data.aws_caller_identity.current.account_id
    }

    delete_marker_replication {
      status = "Enabled"
    }

  }

 depends_on = [
    aws_iam_role.replication_role,
    aws_iam_policy.replication_policy,
    aws_s3_bucket_policy.destination_policy,
    aws_s3_bucket_versioning.bucket_source_versioning,
    aws_s3_bucket_versioning.bucket_destination_versioning
  ]
  
}

# Get current AWS account ID
data "aws_caller_identity" "current" {}



