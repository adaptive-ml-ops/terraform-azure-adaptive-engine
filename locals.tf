locals {
  domain = regex("https://[^.]+\\.(.+)", var.hostname)[0]
}
