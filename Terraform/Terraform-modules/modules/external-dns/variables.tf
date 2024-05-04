variable "oidc-arn" {
  type = string
}

variable "oidc-issuer" {
  type= string
}

variable "route_53_zone_id" {
  description = "route53 zone id"
  type = string
  default = "whats-the-weather.com"
}