output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnets" {
  value = { for k, v in aws_subnet.main : k => v.id if k == "public1" ||  k == "public2"}
}

output "private_subnets" {
  value = { for k, v in aws_subnet.main : k => v.id if k == "private1" ||  k == "private2" }
}

output "public_route_table_id" {
  value = aws_route_table.main[0].id
}

output "private_route_table_id" {
  value = aws_route_table.main[1].id
}
