# Detailed monitoring sends EC2 metrics to CloudWatch every 1 minute
# instead of the default 5 minutes (basic monitoring, which is free).
#
# Setting default = true enables detailed monitoring, but it can cost extra,
# so it is set to false for now. Change it to true if you need 1-minute metrics.
variable "enable_detailed_monitoring" {
  description = "Enable 1-minute CloudWatch detailed monitoring (false = free 5-minute basic monitoring)"
  type        = bool
  default     = false
}
