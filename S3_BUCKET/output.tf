############################################################################
# BUCKET   
output "SourceBucket_name" {
  description = "The name of the created S3 bucket."
  value       = aws_s3_bucket.sourcebucket[0].bucket
}

output "DestinationBucket_name" {
  description = "The name of the created S3 bucket."
  value       = aws_s3_bucket.destinationbucket[0].bucket
}

output "sourcebucket_arn" {
  description = "Amazon Resource Names that is uniquely identify AWS resources."
  value       = aws_s3_bucket.sourcebucket[0].arn
}

output "destinationbucket_arn" {
  description = "Amazon Resource Names that is uniquely identify AWS resources."
  value       = aws_s3_bucket.destinationbucket[0].arn
}

output "source_versioning_status" {
  description = "Versioning status of the bucket"
  value       = aws_s3_bucket_versioning.bucket_source_versioning.versioning_configuration[0].status
}  

output "destination_versioning_status" {
  description = "Versioning status of the bucket"
  value       = aws_s3_bucket_versioning.bucket_destination_versioning.versioning_configuration[0].status
}  


############################################################################
# LIFE CYCLE MANAGEMENT(source)
output "sourcelifecycle_configuration_id" {
  description = "Lifecycle configuration ID for the S3 bucket"
  value       = aws_s3_bucket_lifecycle_configuration.sourcelifecycle1[0].id
}

# LIFE CYCLE MANAGEMENT(destination)
output "destinationlifecycle_configuration_id" {
  description = "Lifecycle configuration ID for the S3 bucket"
  value       = aws_s3_bucket_lifecycle_configuration.destinationlifecycle1[0].id
}

############################################################################
# S3 DATA REPLICATION
output "replication_role_arn" {
  description = "IAM Role ARN for S3 Replication"
  #value       = aws_iam_role.replication_role[0].arn
  value = aws_iam_role.replication_role[0].arn
} 

output "replication_policy_arn" {
  description = "IAM Policy ARN for S3 Replication"
  value       = aws_iam_policy.replication_policy[0].arn
}

output "replication_configuration_id" {
  description = "ID of the replication configuration"
  value       = aws_s3_bucket_replication_configuration.replication[0].id
} 











