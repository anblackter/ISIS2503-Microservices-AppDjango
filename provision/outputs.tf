output "variables_ms_host" {
  description = "Variables MS Public IP"
  value       = aws_instance.variables_ms.public_ip
}

output "measurements_ms_host" {
  description = "Measurements MS Public IP"
  value       = aws_instance.measurements_ms.public_ip
}

output "places_ms_host" {
  description = "Places MS Public IP"
  value       = aws_instance.places_ms.public_ip
}

output "kong_host" {
  description = "Kong Public IP"
  value       = aws_instance.kong.public_ip
}

output "repository_arn" {
  value       = aws_ecr_repository.api-consumption.arn
  description = "Repository ARN."
}
