# @NOTE: All DNS is handled by Prod env

resource "aws_route53_zone" "ourtilt_net" {
  count = var.environment == "prod" ? 1 : 0
  name = "ourtilt.net"
  tags = local.default_tags
}


resource "aws_route53_record" "master" {
  count = var.environment == "prod" ? 1 : 0
  name    = "*"
  type    = "CNAME"
  ttl     = "60"
  zone_id = aws_route53_zone.ourtilt_net[0].zone_id

  # This address is the output of "kubectl get ing --all-namespace"
  records = ["cce7493b-stage-tiltbackend-1a58-1072266262.us-west-2.elb.amazonaws.com"]
}
