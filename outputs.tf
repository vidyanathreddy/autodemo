output VPC-ID {
  value = "${aws_vpc.main.id}"
}

output "instance_ips" {
  value = ["${aws_instance.wp_ubuntu.*.public_ip}"]
}

output "instance_id" {
  value = ["${aws_instance.wp_ubuntu.*.id}"]
}

output "lb_address" {
  value = "${aws_lb.lb-wordpress.dns_name}"
}

output "autoscaling_group_id" {
  value = "${aws_autoscaling_group.autoscaling-grp.id}"
}

output "autoscaling_group_name" {
  value = "${aws_autoscaling_group.autoscaling-grp.name}"
}

