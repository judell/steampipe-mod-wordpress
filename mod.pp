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
[Category](__HOST__/wordpress_stats.dashboard.Category)
🞄
[Categories](__HOST__/wordpress_stats.dashboard.Categories)
🞄
[RecentPosts](__HOST__/wordpress_stats.dashboard.RecentPosts)
EOT
}
