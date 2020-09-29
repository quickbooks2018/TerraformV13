output "ses_user_name" {
  value       = module.smtp-ses.this_user_name
  description = "IAM user name"
}

output "ses_user_arn" {
  value       = module.smtp-ses.this_user_arn
  description = "ARN of the IAM user"
}

output "ses_user_access_key" {
  value       = module.smtp-ses.this_access_key
  description = "IAM Access Key of the created user, used as the STMP user name"
}

output "ses_user_secret_access_key" {
  value       = module.smtp-ses.this_ses_smtp_password
  description = "The secret access key converted into an SES SMTP password"

}
