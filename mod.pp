mod "wordpress_stats" {
  title = "WordPress stats"
}

locals {
  host = "http://localhost:9033"
  menu = <<EOT
[Author](__HOST__/wordpress_stats.dashboard.Author)
🞄
[Authors](__HOST__/wordpress_stats.dashboard.Authors)
🞄
[RecentPosts](__HOST__/wordpress_stats.dashboard.RecentPosts)
🞄
EOT
}
