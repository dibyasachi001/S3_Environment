############################################################################
# REGION  
variable "source_region" {
  description = "Primary aws region for the resources bucket"
  type        = string
}

variable "destination_region" {
  description = "Secondary aws region for the destination bucket"
  type        = string
}

# BUCKET     
variable "source_bucket" {
  description = "Unique bucket name"
  type = string
}

variable "destination_bucket" {
  description = "Unique bucket name"
  type = string
}

############################################################################
# VERSIONING
variable "source_versioning" {
  description = "Enable versioning on the bucket."
  type        = bool
}

variable "destination_versioning" {
  description = "Enable versioning on the bucket."
  type        = bool
}

############################################################################
# LIFE CYCLE MANAGEMENT(source)
variable "apply_sourcebucket_lifecycle" {
  description = "Whether to apply lifecycle management to the entire bucket"
  type        = bool
  # default     = true
}

variable "sourcelifecycle_rule_name" {
  description = "Name of lifecycle rule"
  type = string
}

variable "sourcelifecycle_rule_prefix_name" {
  description = "Prefix name of lifecycle rule"
  type = string
}

# Bucket-wide settings###########################
variable "sourcebucket_transition_days" {
  description = "Number of days after object creation to transition bucket-wide objects"
  type        = number
  # default     = 30
}

variable "sourcebucket_transition_storage_class" {
  description = "Storage class for bucket-wide transition"
  type        = string
  # default     = "STANDARD_IA"
}

variable "sourcebucket_expiration_days" {
  description = "Number of days after object creation to expire bucket-wide objects"
  type        = number
  # default     = 365
}

# Folder-specific settings#######################
variable "sourcefolder" {
  description = "Prefix for the specific folder to apply lifecycle policies"
  type        = string
  # default     = ""
}

variable "sourcefolder_transition_days" {
  description = "Number of days to transition folder-specific objects"
  type        = number
  # default     = 30
}

variable "sourcefolder_transition_storage_class" {
  description = "Storage class for folder-specific transition"
  type        = string
  # default     = "GLACIER"
}

variable "sourcefolder_expiration_days" {
  description = "Number of days to expire folder-specific objects"
  type        = number
  # default     = 365
}

# File-specific settings#########################
variable "sourcefile" {
  description = "Specific file key to apply lifecycle policies"
  type        = string
  # default     = ""
}

variable "sourcefile_transition_days" {
  description = "Number of days to transition file-specific objects"
  type        = number
  # default     = 60
}

variable "sourcefile_transition_storage_class" {
  description = "Storage class for file-specific transition"
  type        = string
  # default     = "DEEP_ARCHIVE"
}

variable "sourcefile_expiration_days" {
  description = "Number of days to expire file-specific objects"
  type        = number
  # default     = 730
} 

# Common settings################################
variable "source_abort_multipart_days" {
  description = "Number of days to wait before cleaning up incomplete multipart uploads"
  type        = number
  # default     = 7
} 

############################################################################
# LIFE CYCLE MANAGEMENT(destination)
variable "apply_destinationbucket_lifecycle" {
  description = "Whether to apply lifecycle management to the entire bucket"
  type        = bool
  # default     = true
}

variable "destinationlifecycle_rule_name" {
  description = "Name of lifecycle rule"
  type = string
}

variable "destinationlifecycle_rule_prefix_name" {
  description = "Prefix name of lifecycle rule"
  type = string
}

# Bucket-wide settings###########################
variable "destinationbucket_transition_days" {
  description = "Number of days after object creation to transition bucket-wide objects"
  type        = number
  # default     = 30
}

variable "destinationbucket_transition_storage_class" {
  description = "Storage class for bucket-wide transition"
  type        = string
  # default     = "STANDARD_IA"
}

variable "destinationbucket_expiration_days" {
  description = "Number of days after object creation to expire bucket-wide objects"
  type        = number
  # default     = 365
}

# Folder-specific settings#######################
variable "destinationfolder" {
  description = "Prefix for the specific folder to apply lifecycle policies"
  type        = string
  # default     = ""
}

variable "destinationfolder_transition_days" {
  description = "Number of days to transition folder-specific objects"
  type        = number
  # default     = 30
}

variable "destinationfolder_transition_storage_class" {
  description = "Storage class for folder-specific transition"
  type        = string
  # default     = "GLACIER"
}

variable "destinationfolder_expiration_days" {
  description = "Number of days to expire folder-specific objects"
  type        = number
  # default     = 365
}

# File-specific settings#########################
variable "destinationfile" {
  description = "Specific file key to apply lifecycle policies"
  type        = string
  # default     = ""
}

variable "destinationfile_transition_days" {
  description = "Number of days to transition file-specific objects"
  type        = number
  # default     = 60
}

variable "destinationfile_transition_storage_class" {
  description = "Storage class for file-specific transition"
  type        = string
  # default     = "DEEP_ARCHIVE"
}

variable "destinationfile_expiration_days" {
  description = "Number of days to expire file-specific objects"
  type        = number
  # default     = 730
} 

# Common settings################################
variable "destination_abort_multipart_days" {
  description = "Number of days to wait before cleaning up incomplete multipart uploads"
  type        = number
  # default     = 7
} 

############################################################################
# S3 DATA REPLICATION
variable "enable_replication" {
  description = "Enable S3 replication (true/false)"
  type        = bool
}

variable "replication_storage_class" {
  description = "Storage class for replicated objects"
  type        = string
  #default     = "STANDARD"
}

variable "is_cross_account" {
  description = "Enable cross-account replication"
  type        = bool
  #default     = false
}

variable "destination_account_id" {
  description = "Destination AWS account ID for cross-account replication"
  type        = string
  default     = null

  validation {
    condition     = var.destination_account_id == null || can(regex("^\\d{12}$", var.destination_account_id))
    error_message = "The destination_account_id must be exactly 12 digits when provided."
  }
}

