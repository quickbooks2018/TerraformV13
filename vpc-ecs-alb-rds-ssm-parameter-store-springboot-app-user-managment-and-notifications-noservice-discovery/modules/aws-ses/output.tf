output "this_user_name" {
  value       = element(concat(aws_iam_user.this.*.name, [""]), 0)
  description = "IAM user name"
}

output "this_user_arn" {
  value       = element(concat(aws_iam_user.this.*.arn, [""]), 0)
  description = "ARN of the IAM user"
}

output "this_access_key" {
  value       = element(concat(aws_iam_access_key.this.*.id, [""]), 0)
  description = "IAM Access Key of the created user, used as the STMP user name"
}

output "this_ses_smtp_password" {
  value       = element(concat(aws_iam_access_key.this.*.ses_smtp_password_v4, [""]), 0)
  description = "The secret access key converted into an SES SMTP password"
  sensitive   = true
}
