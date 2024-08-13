dashboard "Categories" {

    tags = {
      service = "WordPress Stats"
    }


    container {
      
      text {
        width = 4
        value = replace(
          replace(
            "${local.menu}",
            "__HOST__",
            "${local.host}"
          ),
          "[Categories](${local.host}/wordpress_stats.dashboard.Categories)",
          "Categories"
        )
      }

    }


    table "categories" {
      width = 6
      sql = <<EOQ
        select
          id,
          name,
          link
        from wordpress_category
      EOQ

    }


   chart "by_category" {
    width = 6
    title = "Posts by category, last 3 months"
    type = "donut"
     sql = <<EOQ
      with recent_posts as (
        select id, title, category, date
        from wordpress_post
        where date > now() - interval '3 month'
      ),
      unnested_categories as (
        select 
          rp.id,
          jsonb_array_elements(rp.category) as category_id
        from recent_posts rp
      ),
      category_counts as (
        select 
          uc.category_id::int as category_id,
          count(distinct uc.id) as post_count
        from unnested_categories uc
        group by uc.category_id
      )
      select 
        wc.name as category_name,
        cc.post_count
      from category_counts cc
      join wordpress_category wc on cc.category_id = wc.id
      order by cc.post_count desc
      EOQ
   }


}
